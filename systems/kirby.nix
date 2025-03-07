{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ../desktop.nix
    #../steam-deck.nix
    (inputs.jovian + "/modules")
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
  ];
  hardware.enableAllFirmware = true;
  hardware.steam-hardware.enable = true;

  # Not great but necessary for remote builds.
  nix.settings = { require-sigs = false; };

  system.stateVersion = "22.11";

  hardware.pulseaudio.enable = false;

  jovian.steam.enable = true;
  jovian.steam.autoStart = true;
  jovian.hardware.has.amd.gpu = true;
  jovian.steam.desktopSession = "gnome";
  jovian.steam.user = "shelby";
  jovian.steamos.useSteamOSConfig = true;
  # jovian.steamos.enableBluetoothConfig = false;
  jovian.decky-loader.enable = true;
  jovian.steam.updater.splash = "vendor";
  # hardware.bluetooth.settings.General.Experimental = "true";
  hardware.bluetooth.settings.Policy.AutoEnable = "true";
  # hardware.bluetooth.settings.General.ClassicBondedOnly = "false";

  # Make Steam use the full size of my 1440p monitor.
  environment.variables = {
    GAMESCOPE_WIDTH = "2560";
    GAMESCOPE_HEIGHT = "1440";
  };

  # TODO Let powertop automatically reduce power consumption since I'm using this like a server.
  powerManagement.powertop.enable = false;

  hardware.bluetooth.enable = true;
  # services.blueman.enable = true;
  # Steam network management requires network-manager, so I'm fine with using
  # that on this system instead of IWD.
  networking.wireless.iwd.enable = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # Speed up the boot process instead of waiting for a full network connection.
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  #networking.timeServers = [ "time.google.com" "pool.ntp.org" ];
  #networking.dhcpcd.wait = "background";
  hardware.bluetooth.disabledPlugins = [ "sap" ];
  hardware.bluetooth.powerOnBoot = true;
  #networking.networkmanager.dhcp = "dhcpcd";

  boot = {
    plymouth.enable = false;
    loader.timeout = 1;
    loader.efi.efiSysMountPoint = "/boot/efi";
    kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
    kernelModules =
      [ "kvm-amd" "mt7921e" "hid-playstation" "btusb" "bluetooth" "btmtk" ];
    initrd.kernelModules = [ "amdgpu" "usbhid" "btmtk" "bluetooth" "btusb" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "nvme"
      "usb_storage"
      "sd_mod"
      "btusb"
      "bluetooth"
      "btmtk"
    ];
    kernelParams = [ "quiet" ];
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "vm.dirty_writeback_centisecs" = 6000;
    };
  };

  # networking.interfaces.wlan0.useDHCP = true;
  networking.interfaces.eno1.useDHCP = true;

  environment.systemPackages = with pkgs; [
    powertop
    tcpdump
    vlc
    sublime4
    # jellyfin
    # jellyfin-web
    # jellyfin-ffmpeg
    python
    gnome.gvfs
    # kodi
    sc-controller
    steam
    openvpn
    # chromium
    jq
    # gnome.zenity
    transmission_4
    # wine
    ddcutil
    ddcui
  ];

  systemd.services.jellyfin.wants = lib.mkForce [ "network-online.target" ];
  systemd.services.jellyfin-proxy = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart =
      "${pkgs.ssl-proxy}/bin/ssl-proxy -from 0.0.0.0:443 -to 127.0.0.1:8096 -domain=server.snead.xyz -redirectHTTP";
  };

  nixpkgs.config.permittedInsecurePackages =
    [ "python-2.7.18.8" "openssl-1.1.1w" ];
  nixpkgs.overlays = [
    (self: super: {
      libbluray = super.libbluray.override {
        withAACS = true;
        withBDplus = true;
      };
      kodi = super.kodi-wayland.withPackages (p: with p; [ netflix youtube ]);

      linuxPackages_jovian = self.linuxPackagesFor self.linux_jovian;
      linux_jovian = super.callPackage "${inputs.jovian}/pkgs/linux-jovian" {
        kernelPatches = with self; [
          kernelPatches.bridge_stp_helper
          kernelPatches.request_key_helper
          kernelPatches.export-rt-sched-migrate
        ];
      };

      mesa-radv-jupiter =
        self.callPackage "${inputs.jovian}/pkgs/mesa-radv-jupiter" { };

      jupiter-fan-control =
        self.callPackage "${inputs.jovian}/pkgs/jupiter-fan-control" { };

      jupiter-hw-support =
        self.callPackage "${inputs.jovian}/pkgs/jupiter-hw-support" { };
      steamdeck-hw-theme =
        self.callPackage "${inputs.jovian}/pkgs/jupiter-hw-support/theme.nix"
        { };
      steamdeck-firmware =
        self.callPackage "${inputs.jovian}/pkgs/jupiter-hw-support/firmware.nix"
        { };
      steamdeck-bios-fwupd = self.callPackage
        "${inputs.jovian}/pkgs/jupiter-hw-support/bios-fwupd.nix" { };
      jupiter-dock-updater-bin =
        self.callPackage "${inputs.jovian}/pkgs/jupiter-dock-updater-bin" { };

      opensd = super.callPackage "${inputs.jovian}/pkgs/opensd" { };

      steamPackages = super.steamPackages.overrideScope
        (scopeFinal: scopeSuper: {
          steam = self.callPackage
            "${inputs.jovian}/pkgs/steam-jupiter/unwrapped.nix" {
              steam-original = scopeSuper.steam;
            };
          steam-fhsenv =
            self.callPackage "${inputs.jovian}/pkgs/steam-jupiter/fhsenv.nix" {
              steam-fhsenv = scopeSuper.steam-fhsenv;
            };
        });
    })
  ];
  nixpkgs.config.kodi.enableAdvancedLauncher = true;

  location = {
    latitude = 37.820248;
    longitude = -122.284792;
  };
  time.timeZone = "America/Los_Angeles";

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" "/drives/hdd" ];
  boot.supportedFilesystems.zfs = true;
  # This identifies the owner machine for the ZFS pool. Keep the host ID even if
  # the desktop dies, as long as it's an x86_64 linux machine. (currently all AMD)
  # The ZFS version mustn't be downgraded, nor the kernel version from 6.6
  networking.hostId = "aa544e7d";
  fileSystems = let
    front-nvme = "/dev/disk/by-label/linux";
    rear-nvme = "/dev/disk/by-label/nvme";
    sata-ssd = "/dev/disk/by-label/zip-zap";
    hdd = "/dev/disk/by-label/slowboss";
    subvolume = disk: name: {
      device = disk;
      fsType = "btrfs";
      options = [ "subvol=${name}" "compress=zstd" "noatime" ];
    };
  in {
    "/" = subvolume front-nvme "@";
    "/media/hdd" = {
      device = hdd;
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
    "/media/rear-nvme" = {
      device = rear-nvme;
      fsType = "ntfs";
      options = [ "noatime" ];
    };
    "/media/sata-ssd" = {
      device = sata-ssd;
      fsType = "ntfs";
      options = [ "noatime" ];
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

    # "/media/nas" = {
    #   fsType = "zfs";
    #   device = "nas"; # check name from zpool status
    #   # options = [ "noatime" "zfsutil" ];
    # };

  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  users.users.shelby = {
    isNormalUser = true;
    description = "Shelby Snead";
    extraGroups = [
      "networkmanager"
      "wheel"
      "scanner"
      "lp"
      "audio"
      "video"
      "keyd"
      "plugdev"
      "input"
    ];
    openssh.authorizedKeys.keys = [
      # Personal Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVldsHCxoEpdN9K+cr9EKxS5dhvUBuCuhyLht3+8CJ2 snead@loafofpiecrust"
    ];
  };
  home-manager.users.shelby = ../home/users/shelby-kirby.nix;

  # GNOME autologin workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.xserver = {
    enable = true;
    displayManager.autoLogin.enable = false;
    displayManager.autoLogin.user = "shelby";
    displayManager.gdm.enable = false;
    displayManager.gdm.wayland = true;
    displayManager.defaultSession = "gamescope-wayland";
    desktopManager.gnome.enable = true;
    desktopManager.kodi.enable = false;
    desktopManager.kodi.package = pkgs.kodi;
    layout = "us";
    xkbVariant = "";
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "lo" "eno1" "ve-transmission" ];
    externalInterface = "eno1";
    enableIPv6 = true;
    # Turn this back on if I add a password to transmission RPC.
    forwardPorts = [{
      destination = "192.168.100.10:51413";
      sourcePort = 51413;
      proto = "udp";
    }];
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 22 8096 80 ];
  networking.firewall.allowedUDPPorts = [ 1194 51413 ];

  containers.transmission = {
    autoStart = true;
    enableTun = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    bindMounts.home = {
      isReadOnly = false;
      mountPoint = "/home/shelby";
      hostPath = "/home/shelby";
    };
    bindMounts.hdd = {
      isReadOnly = false;
      mountPoint = "/media/hdd";
      hostPath = "/media/hdd";
    };
    forwardPorts = [
      {
        protocol = "tcp";
        hostPort = 9091;
        containerPort = 9091;
      }
      {
        protocol = "udp";
        hostPort = 51413;
        containerPort = 51413;
      }
    ];
    config = { config, pkgs, ... }: {
      system.stateVersion = "24.05";
      networking.firewall.enable = true;
      # environment.etc."resolv.conf".text = "nameserver 8.8.8.8";
      networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
      networking.firewall.allowedUDPPorts = [ 51413 ];
      networking.firewall.allowedTCPPorts = [ 51413 ];
      networking.firewall.checkReversePath = false;
      # networking.firewall.trustedInterfaces = [ "eth0" ];

      # Torrenting setup: Transmission server, allowing traffic only over VPN
      # Fix required in a container, see: https://github.com/NixOS/nixpkgs/issues/258793
      systemd.services.transmission.serviceConfig = {
        RootDirectoryStartOnly = lib.mkForce false;
        RootDirectory = lib.mkForce "";
        BindReadOnlyPaths = lib.mkForce [ builtins.storeDir "/etc" ];
        # Allow transmission to more easily write to my bound home directory.
        # This is okay because we're already inside a container, isolating us
        # from the host system.
        BindPaths = [ "/home/shelby" "/media/hdd" ];
        PrivateMounts = lib.mkForce false;
        PrivateUsers = lib.mkForce false;
        ProtectHome = lib.mkForce false;
      };

      services.openvpn.servers.bahamas = {
        config = "config /home/shelby/documents/openvpn-strong/bahamas.ovpn";
        autoStart = true;
        authUserPass.username = "p9354391";
        authUserPass.password = "mDBWYVpE58";
        updateResolvConf = true;
      };
      systemd.services.transmission.partOf = [ "openvpn-bahamas.service" ];
      systemd.services.transmission.after = [ "openvpn-bahamas.service" ];

      environment.systemPackages = with pkgs; [ http-server tcpdump ];

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
          download-dir = "/home/shelby";
          watch-dir-enabled = false;
          watch-dir = "/home/shelby/torrents";
          incomplete-dir-enabled = false;
          trash-original-torrent-files = true;
          preallocation = 2;
          download-queue-size = 6;
          speed-limit-down-enabled = true;
          speed-limit-down = 4096;
          speed-limit-up-enabled = true;
          speed-limit-up = 200;
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

  # Switch back to sudo for this build to maximize compatibility.
  security.sudo.wheelNeedsPassword = false;

  services.logind.extraConfig = ''
    HandlePowerKey=poweroff
  '';

  services.jellyfin = {
    enable = true;
    user = "shelby";
    openFirewall = true;
  };

  # Allows SSH during boot to debug failed boot remotely.
  boot.initrd.network.ssh.enable = true;

  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Basic blocking of malicious entry or DDOS attacks.
  services.fail2ban.enable = true;
}
