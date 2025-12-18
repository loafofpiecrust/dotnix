# CPU is Intel i5-11500, Rocket Lake
# 
# Installation steps:
# Boot server with nixos installer ISO
# server: sudo passwd
# laptop: nix run github:nix-community/nixos-anywhere -- --disk-encryption-keys /tmp/secret.key '<diskpass>' --flake .#vivian root@192.168.0.103
#
# Remote update steps:
# nixos-rebuild boot --target-host shelby@vivian --flake .#vivian --fast --use-remote-sudo
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ../server.nix

    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    # Enables the right drivers for Intel GPU, including for Quick Sync
    inputs.nixos-hardware.nixosModules.common-gpu-intel

    inputs.disko.nixosModules.disko
    ./vivian/disk-config.nix
    ./vivian/hardware-configuration.nix
  ];

  system.stateVersion = "25.11";
  hardware.graphics.enable = true;

  # Support remote deployments
  # Not great but necessary for remote builds.
  nix.settings = { require-sigs = false; };
  # Password-less sudo
  security.sudo.wheelNeedsPassword = false;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
    # initrd.availableKernelModules =
    #   [ "xhci_pci" "ahci" "usbhid" "nvme" "usb_storage" "sd_mod" ];
    # Don't remember what these are for, maybe disk efficiency.
    kernel.sysctl = {
      # "kernel.nmi_watchdog" = 0;
      # "vm.dirty_writeback_centisecs" = 6000;
    };

    # Allows SSH during boot to debug failed boot remotely.
    initrd.network.ssh.enable = true;

    # Don't wait long for system selection when booting.
    loader.timeout = 0;
    # loader.efi.efiSysMountPoint = "/boot/efi";

    # Use Limine bootloader since it supports secure boot
    loader.limine.enable = true;
    loader.limine.secureBoot.enable = true;
    # Unattended disk decryption with TPM encrypted password
    initrd.clevis.enable = true;
    initrd.clevis.devices."enc".secretFile = ./vivian/luks.jwe;
    initrd.luks.devices."enc".crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # Enable TPM2 support
  systemd.tpm2.enable = true;
  security.tpm2.enable = true;

  # Start systemd early so it can enable access to the TPM2 module for disk decryption.
  boot.initrd.systemd.enable = true;

  # Rough location and time zone
  location = {
    latitude = 37.820248;
    longitude = -122.284792;
  };
  time.timeZone = "America/Los_Angeles";

  # Users!
  users.users = {
    shelby = {
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" "video" ];
      openssh.authorizedKeys.keys = [
        # Personal Laptop
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVldsHCxoEpdN9K+cr9EKxS5dhvUBuCuhyLht3+8CJ2 snead@portable-spudger"
      ];
      hashedPassword =
        "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    };
  };

  # Run a persistent systemd session for my user so I can run backups
  # automatically as a user service.
  users.manageLingering = true;
  users.users.shelby.linger = true;

  home-manager.users.shelby = ../home/users/shelby-vivian.nix;

  # Disks!
  # System volume (NVMe) is btrfs, storage pool (HDD) is ZFS, plus swap
  boot.supportedFilesystems.zfs = true;
  # Don't hang the boot on importing zfs pools
  boot.zfs.forceImportAll = false;
  fileSystems = {
    "/media/pool" = {
      fsType = "zfs";
      device = "nas";
      options = [ "nofail" ];
    };
  };

  # Disk management services
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  services.zfs = {
    # Weekly scrub to avoid bitrot
    # autoScrub = {
    #   enable = true;
    #   pools = [ "nas" ];
    #   interval = "weekly";
    # };
    autoSnapshot = {
      enable = true;
      # Use UTC to avoid conflicts at daylight savings time switch
      flags = "-k -p --utc";
      monthly = 6;
    };
  };

  # Required for ZFS continuity.
  networking.hostId = "b84291b8";

  # Use Cloudflare for DNS
  # networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # Allow myself remote access
  services.openssh = {
    enable = true;
    allowSFTP = true;
    authorizedKeysInHomedir = true;
    settings = {
      # TODO Disable password auth once trusted keys are in place.
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      # PermitRootLogin = "no";
      UseDns = true;
    };
  };

  # Open a few ports in the firewall for web hosting and such
  networking.firewall.allowedTCPPorts = [ 443 22 8096 80 ];
  networking.firewall.allowedUDPPorts = [ 1194 51413 ];

  # Jellyfin for media streaming
  services.jellyfin = {
    enable = true;
    user = "shelby";
    openFirewall = true;
  };
  systemd.services.jellyfin.wants = lib.mkForce [ "network-online.target" ];
  systemd.services.jellyfin-proxy = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart =
      "${pkgs.ssl-proxy}/bin/ssl-proxy -from 0.0.0.0:443 -to 127.0.0.1:8096 -domain=server.snead.xyz -redirectHTTP";
  };

  # Import secrets like service passwords
  age.secrets = {
    pia.file = ../secrets/pia-password.age;
    pia.mode = "755";
  };
  age.identityPaths = [ "/root/.ssh/id_ed25519" ];

  # Isolated container for torrent downloads that can only connect to the
  # internet through a VPN.
  containers.torrent = let secrets = config.age.secrets;
  in {
    autoStart = true;
    enableTun = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    bindMounts = {
      # Allow the container to access only download folders.
      pool = {
        isReadOnly = false;
        mountPoint = "/media/pool";
        hostPath = "/media/pool";
      };
      # Share certain secrets with the container
      "${secrets.pia.path}".isReadOnly = true;
    };
    forwardPorts = [
      # Web interface
      {
        protocol = "tcp";
        hostPort = 9091;
        containerPort = 9091;
      }
      # RPC??
      {
        protocol = "udp";
        hostPort = 51413;
        containerPort = 51413;
      }
    ];
    config = { config, pkgs, ... }: {
      system.stateVersion = "25.11";
      networking.firewall.enable = true;
      networking.firewall.allowedUDPPorts = [ 51413 ];
      networking.firewall.allowedTCPPorts = [ 51413 ];
      networking.firewall.checkReversePath = false;
      networking.useHostResolvConf = false;
      services.resolved.enable = true;

      environment.systemPackages = with pkgs; [ net-tools dig ];

      # Fix required in a container, see: https://github.com/NixOS/nixpkgs/issues/258793
      systemd.services.transmission.serviceConfig = {
        RootDirectoryStartOnly = lib.mkForce false;
        RootDirectory = lib.mkForce "";
        BindReadOnlyPaths = lib.mkForce [ builtins.storeDir "/etc" ];
        # Allow transmission to more easily write to my bound home directory.
        # This is okay because we're already inside a container, isolating us
        # from the host system.
        BindPaths = [ "/media/pool" ];
        PrivateMounts = lib.mkForce false;
        PrivateUsers = lib.mkForce false;
        ProtectHome = lib.mkForce false;
      };

      services.openvpn.servers.bahamas = {
        config = "config ${../openvpn-strong/bahamas.ovpn}";
        autoStart = true;
        authUserPass = secrets.pia.path;
        # updateResolvConf = true;
      };
      systemd.services.transmission.partOf = [ "openvpn-bahamas.service" ];
      systemd.services.transmission.after = [ "openvpn-bahamas.service" ];

      services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        user = "transmission";
        group = "transmission";
        openPeerPorts = true;
        openRPCPort = true;
        downloadDirPermissions = "777";
        settings = {
          message-level = 5;
          umask = 0;
          download-dir = "/media/pool";
          watch-dir-enabled = false;
          watch-dir = "/media/pool/Torrents";
          incomplete-dir-enabled = false;
          trash-original-torrent-files = true;
          preallocation = 0;
          download-queue-size = 6;
          speed-limit-down-enabled = true;
          speed-limit-down = 4096;
          speed-limit-up-enabled = true;
          speed-limit-up = 90;
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist-enabled = true;
          rpc-whitelist = "192.168.*.*,127.0.0.1";
          rpc-host-whitelist-enabled = false;
          ratio-limit = 4.0;
          ratio-limit-enabled = true;
        };
      };

      # Only allow internet to transmission through the VPN.
      # Also explicitly allow connections on port 9091 through eth0, which is
      # required for RPC connections.
      networking.firewall.extraCommands = ''
        iptables -A OUTPUT -m owner --gid-owner transmission -p tcp --sport 9091 -o eth0 -j ACCEPT
        iptables -A OUTPUT -m owner --gid-owner transmission -o tun0 -j ACCEPT
        iptables -A OUTPUT -m owner --gid-owner transmission -o lo -j ACCEPT
        iptables -A OUTPUT -m owner --gid-owner transmission -j REJECT
      '';
    };
  };
  # Attempt to allow access to transmission from the outside world, not quite
  # working though.
  networking.nat = {
    enable = true;
    internalInterfaces = [ "lo" "eno1" "ve-+" ];
    externalInterface = "eno1";
    enableIPv6 = true;
    # Turn this back on if I add a password to transmission RPC.
    forwardPorts = [{
      destination = "192.168.100.10:51413";
      sourcePort = 51413;
      proto = "udp";
    }];
  };

  environment.systemPackages = with pkgs; [
    # Disk testing
    smartmontools
    htop
    sbctl
    mokutil
    clevis
    vim
  ];
}
