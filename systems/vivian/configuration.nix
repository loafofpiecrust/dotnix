# CPU is Intel i5-11500, Rocket Lake
# 
# Installation steps:
# Boot server with nixos installer ISO
# server: sudo passwd
# laptop: nix run github:nix-community/nixos-anywhere -- --disk-encryption-keys /tmp/secret.key '<diskpass>' --flake .#vivian root@192.168.0.103
#
# Remote update steps:
# nixos-rebuild boot --target-host shelby@vivian --flake .#vivian --fast --use-remote-sudo
#
# Except DO NOT do remote deploys on this machine because it fails to properly
# copy over the LUKS secret to store in TPM.
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ../../server.nix
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
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

    # Don't wait for system selection when booting. Hold space to choose.
    loader.timeout = 2;

    # Use Limine bootloader since it supports secure boot
    loader.limine.enable = true;
    loader.limine.secureBoot.enable = true;
    # Unattended disk decryption with TPM encrypted password
    initrd.clevis.enable = true;
    initrd.clevis.devices."enc".secretFile = ./luks.jwe;
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
        # Work laptop
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXlF6Kh40z6NxPXtfG5t+DIZSJDn/oJAPKrnRkwRfPM shelby@snead.xyz"
      ];
      hashedPassword =
        "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    };
  };

  # Run a persistent session for my user so I can run backups
  # automatically as a user service.
  users.manageLingering = true;
  users.users.shelby.linger = true;

  home-manager.users.shelby = ./users/shelby.nix;

  # Disks!
  # System volume (NVMe) is btrfs, storage pool (HDD) is ZFS.
  boot.supportedFilesystems.zfs = true;
  # Don't hang the boot on importing zfs pools
  boot.zfs.forceImportAll = false;
  fileSystems = {
    "/var/lib".neededForBoot = true;
    "/media/pool" = {
      fsType = "zfs";
      device = "nas";
      options = [ "nofail" ];
    };
    "/mnt/personal" = {
      fsType = "zfs";
      device = "nas/personal";
      options = [ "nofail" ];
    };
  };

  system.activationScripts = {
    # Link my fixed music dir for beets compatibility
    linkMusic = {
      text = "ln -sfT /mnt/personal/Music /mnt/music";
      deps = [ ];
    };
  };

  # Disk management services
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  services.zfs = {
    # Weekly scrub to avoid bitrot
    autoScrub = {
      enable = true;
      pools = [ "nas" ];
      interval = "weekly";
    };
    # Automatically snapshot data pool frequently
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
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

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

  # Open a few ports in the firewall for web hosting and such.
  # Most of these should actually be opened by the corresponding service already.
  networking.firewall.allowedTCPPorts = [ 443 22 8096 80 ];
  networking.firewall.allowedUDPPorts = [ 1194 51413 ];

  # Jellyfin for media streaming
  services.jellyfin = {
    enable = true;
    user = "shelby";
    openFirewall = true;
  };
  systemd.services.jellyfin.wants = lib.mkForce [ "network-online.target" ];

  # Import secrets like service passwords
  age.secrets = {
    pia.file = ../../secrets/pia-password.age;
    transmission.file = ../../secrets/transmission-credentials.age;
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
      "${secrets.transmission.path}".isReadOnly = true;
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
        config = "config ${../../openvpn-strong/bahamas.ovpn}";
        autoStart = true;
        authUserPass = secrets.pia.path;
        updateResolvConf = true;
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
        credentialsFile = secrets.transmission.path;
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
          rpc-authentication-required = true;
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist-enabled = false;
          rpc-whitelist = "192.168.*.*,127.0.0.1";
          rpc-host-whitelist-enabled = false;
          rpc-host-whitelist = "server.snead.xyz";
          ratio-limit = 4.0;
          ratio-limit-enabled = true;
          # Use final filename for partial files to support streaming
          # in-progress downloads.
          rename-partial-files = false;
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

  networking.nat = {
    enable = true;
    # Give internet access to containers via ethernet?
    # Or is this exposing containers to the outside world?
    internalInterfaces = [ "lo" "enp0s31f6" "ve-+" ];
    externalInterface = "enp0s31f6";
    enableIPv6 = true;
    # Expose transmission RPC for public access? Not sure this does anything for me.
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
    net-tools
    e2fsprogs
  ];

  # Container for Friends with Bikes
  containers.fwb-services = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.12";
    localAddress = "192.168.100.13";
    forwardPorts = [{
      protocol = "tcp";
      hostPort = 9001;
      containerPort = 9001;
    }];
    config = { config, pkgs, ... }: {
      system.stateVersion = "25.11";
      # Defer to host firewall
      networking.firewall.enable = false;
      # Mailing list management
      services.listmonk = {
        enable = true;
        settings = { app.address = "0.0.0.0:9001"; };
        database = { createLocally = true; };
      };
      # See discourse.nixos.org/t/how-to-enable-internet-access-inside-a-nixos-container/62458
      networking.useHostResolvConf = false;
      services.resolved.enable = true;
    };
  };

  # Expose many services at public domains
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "server.snead.xyz" = {
        useACMEHost = "server.snead.xyz";
        forceSSL = true;
        locations."/.well-known/".root = "/var/lib/acme/acme-challenge/";
        locations."/".proxyPass = "http://127.0.0.1:8096";
      };
      "torrent.snead.xyz" = {
        useACMEHost = "server.snead.xyz";
        forceSSL = true;
        locations."/".proxyPass = "http://192.168.100.10:9091";
      };
      "newsletter.fwb.snead.xyz" = {
        useACMEHost = "server.snead.xyz";
        serverName = "newsletter.fwb.snead.xyz";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://192.168.100.12:9001";
          # extraConfig = "proxy_ssl_server_name on;";
        };
      };
      "news.fwboakland.com" = {
        useACMEHost = "news.fwboakland.com";
        serverName = "news.fwboakland.com";
        forceSSL = true;
        locations."/.well-known/".root = "/var/lib/acme/acme-challenge/";
        locations."/" = {
          proxyPass = "http://192.168.100.12:9001";
          # extraConfig = "proxy_ssl_server_name on;";
        };
      };
    };
  };

  # Request SSL certificates to support HTTPS access to my services
  security.acme = {
    acceptTerms = true;
    defaults.email = "shelby@snead.xyz";
    defaults.webroot = "/var/lib/acme/acme-challenge/";
    certs = {
      "server.snead.xyz" = {
        group = config.services.nginx.group;
        extraDomainNames = [ "newsletter.fwb.snead.xyz" "torrent.snead.xyz" ];
      };
      "news.fwboakland.com" = {
        group = config.services.nginx.group;
        extraDomainNames = [ ];
      };
    };
  };

  # Regular system backups to the pool
  # services.restic.backups = {
  #   "var" = {
  #     initialize = true;
  #     paths = [ "/var" "/etc" "/root" ];
  #     repository = "/mnt/personal/Backups/Home Server";
  #   };
  # };

  # Backup server state to NAS
  systemd.services.backup-state = {
    serviceConfig = { Type = "oneshot"; };
    script = let
      script = pkgs.writeShellApplication {
        name = "backup-state";
        runtimeInputs = with pkgs; [ rclone coreutils ];
        text = ''
          mkdir -p /mnt/personal/Backups/vivian
          rclone sync /var /mnt/personal/Backups/vivian/var --max-delete 100 --retries 10 --local-no-check-updated
          rclone sync /etc /mnt/personal/Backups/vivian/etc --max-delete 100 --retries 10 --local-no-check-updated
          rclone sync /home /mnt/personal/Backups/vivian/home --max-delete 100 --retries 10 --local-no-check-updated
        '';
      };
    in "${script}/bin/backup-state";
  };
  systemd.timers.backup-state = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "backup-state.service";
      Persistent = "true";
      OnCalendar = "hourly";
      RandomizedDelaySec = "120";
    };
  };
}
