{ config, lib, pkgs, inputs, ... }:
let
  jovian = (
    # Put the most recent revision here:
    let revision = "924a18ea8df89a39166dd202f3e73cd022825768";
    in builtins.fetchTarball {
      url =
        "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
      # Update the hash as needed:
      sha256 = "sha256:0vrdhxy0pn9k4241xd09nx2kkaxif483ah2kv43dm0wv7cqfaypy";
    });
in {
  imports = [
    ../desktop.nix
    #../steam-deck.nix
    (jovian + "/modules")
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
  ];

  # Not great but necessary for remote builds.
  nix.settings = { require-sigs = false; };

  system.stateVersion = "22.11";

  hardware.pulseaudio.enable = false;

  jovian.steam.enable = true;
  # jovian.hardware.has.amd.gpu = true;
  jovian.steam.desktopSession = "gnome";

  # Make Steam use the full size of my 1440p monitor.
  environment.variables = {
    GAMESCOPE_WIDTH = "2560";
    GAMESCOPE_HEIGHT = "1440";
  };

  # Let powertop automatically reduce power consumption since I'm using this like a server.
  powerManagement.powertop.enable = true;

  hardware.bluetooth.enable = true;
  # Steam network management requires network-manager, so I'm fine with using
  # that on this system instead of IWD.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # hardware.fancontrol = {
  #   enable = true;
  # };

  boot = {
    plymouth.enable = false;
    loader.timeout = 1;
    loader.efi.efiSysMountPoint = "/boot/efi";
    # kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "kvm-amd" "mt7921e" "hid-playstation" ];
    initrd.kernelModules = [ "amdgpu" "usbhid" ];
    initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "usbhid" "nvme" "usb_storage" "sd_mod" "btusb" ];
    kernelParams = [ "quiet" ];
  };

  networking.interfaces.wlan0.useDHCP = true;
  networking.interfaces.eno1.useDHCP = true;

  environment.systemPackages = with pkgs; [
    vlc
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
    transmission_3
    wine
    ddcutil
    ddcui
  ];

  systemd.services.jellyfin-proxy = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart =
      "${pkgs.ssl-proxy}/bin/ssl-proxy -from 0.0.0.0:443 -to 127.0.0.1:8096 -domain=server.snead.xyz -redirectHTTP";
  };

  #systemd.user.services.scc-daemon = {
  #wantedBy = [ "graphical-session.target" ];
  #serviceConfig.ExecStart = "${pkgs.sc-controller}/bin/scc-daemon start";
  #serviceConfig.Type = "forking";
  #};

  nixpkgs.config.permittedInsecurePackages = [ "python-2.7.18.8" ];
  nixpkgs.overlays = [
    (self: super: {
      libbluray = super.libbluray.override {
        withAACS = true;
        withBDplus = true;
      };
      kodi = super.kodi-wayland.withPackages (p: with p; [ netflix youtube ]);

      linuxPackages_jovian = self.linuxPackagesFor self.linux_jovian;
      linux_jovian = super.callPackage "${jovian}/pkgs/linux-jovian" {
        kernelPatches = with self; [
          kernelPatches.bridge_stp_helper
          kernelPatches.request_key_helper
          kernelPatches.export-rt-sched-migrate
        ];
      };

      mesa-radv-jupiter =
        self.callPackage "${jovian}/pkgs/mesa-radv-jupiter" { };

      jupiter-fan-control =
        self.callPackage "${jovian}/pkgs/jupiter-fan-control" { };

      jupiter-hw-support =
        self.callPackage "${jovian}/pkgs/jupiter-hw-support" { };
      steamdeck-hw-theme =
        self.callPackage "${jovian}/pkgs/jupiter-hw-support/theme.nix" { };
      steamdeck-firmware =
        self.callPackage "${jovian}/pkgs/jupiter-hw-support/firmware.nix" { };
      steamdeck-bios-fwupd =
        self.callPackage "${jovian}/pkgs/jupiter-hw-support/bios-fwupd.nix" { };
      jupiter-dock-updater-bin =
        self.callPackage "${jovian}/pkgs/jupiter-dock-updater-bin" { };

      opensd = super.callPackage "${jovian}/pkgs/opensd" { };

      steamPackages = super.steamPackages.overrideScope
        (scopeFinal: scopeSuper: {
          steam =
            self.callPackage "${jovian}/pkgs/steam-jupiter/unwrapped.nix" {
              steam-original = scopeSuper.steam;
            };
          steam-fhsenv =
            self.callPackage "${jovian}/pkgs/steam-jupiter/fhsenv.nix" {
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

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  fileSystems = let
    front-nvme = "/dev/disk/by-label/linux";
    rear-nvme = "/dev/disk/by-label/nvme";
    sata-ssd = "/dev/disk/by-label/zip-zap";
    subvolume = disk: name: {
      device = disk;
      fsType = "btrfs";
      options = [ "subvol=${name}" "compress=zstd" "noatime" ];
    };
  in {
    "/" = subvolume front-nvme "@";
    "/boot/efi" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
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
      "transmission"
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
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    displayManager.defaultSession = "gamescope-wayland";
    desktopManager.gnome.enable = true;
    desktopManager.kodi.enable = true;
    desktopManager.kodi.package = pkgs.kodi;
    layout = "us";
    xkbVariant = "";
  };

  # networking.nat = {
  #   enable = true;
  #   internalInterfaces = [ "lo" "eno1" ];
  #   externalInterface = "eno1";
  #   enableIPv6 = true;
  #   forwardPorts = [{
  #     destination = "192.168.100.10:9091";
  #     sourcePort = 9091;
  #     proto = "tcp";
  #   }];
  # };

  # SAD but the firewall seems to be broken on nixos-unstable.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 9091 443 22 8096 ];

  #networking.nftables = {
  #enable = true;
  #ruleset = ''
  #table ip nat {
  #chain PREROUTING {
  #type nat hook prerouting priority dstnat; policy accept;
  #iifname "eno1" tcp dport 9091 dnat to 192.168.100.10:9091
  #}
  #}
  #'';
  #};

  # containers.transmission = {
  #   autoStart = true;
  #   enableTun = true;
  #   privateNetwork = true;
  #   hostAddress = "192.168.100.10";
  #   localAddress = "192.168.100.11";
  #   bindMounts.home = {
  #     isReadOnly = false;
  #     mountPoint = "/home/shelby";
  #     hostPath = "/home/shelby";
  #   };
  #   forwardPorts = [{
  #     protocol = "tcp";
  #     hostPort = 9091;
  #     containerPort = 9091;
  #   }];
  #   config = { config, pkgs, ... }: {
  #     #networking.interfaces."eth0".ipv4.routes = [
  #     #{ address = "192.168.1.0"; prefixLength = 24; via = "192.168.100.10"; }
  #     #];
  #     system.stateVersion = "22.11";
  #     networking.firewall.enable = true;
  #     # environment.etc."resolv.conf".text = "nameserver 8.8.8.8";
  #     # Torrenting setup: Transmission server, allowing traffic only over VPN
  #     # Fix required in a container, see: https://github.com/NixOS/nixpkgs/issues/258793
  #     systemd.services.transmission.serviceConfig = {
  #       RootDirectoryStartOnly = lib.mkForce false;
  #       RootDirectory = lib.mkForce "";
  #       BindReadOnlyPaths = lib.mkForce [ builtins.storeDir "/etc" ];
  #     };

  #   };
  # };

  services.openvpn.servers.bahamas = {
    config = ''
      config /home/shelby/documents/openvpn-strong/bahamas.ovpn
      auth-user-pass /home/shelby/documents/openvpn-strong/user-pass.txt
    '';
    autoStart = true;
    # updateResolvConf = true;
  };
  systemd.services.transmission.partOf = [ "openvpn-bahamas.service" ];
  systemd.services.transmission.after = [ "openvpn-bahamas.service" ];

  services.transmission = {
    enable = true;
    # FIXME: make sure to prevent data loss before upgrading
    package = pkgs.transmission_3;
    user = "transmission";
    group = "transmission";
    openPeerPorts = true;
    openRPCPort = true;
    downloadDirPermissions = "777";
    settings = {
      umask = 0;
      download-dir = "/home/shelby";
      watch-dir-enabled = false;
      watch-dir = "/home/shelby/torrents";
      preallocation = 2;
      download-queue-size = 6;
      speed-limit-down-enabled = true;
      speed-limit-down = 3000;
      speed-limit-up-enabled = true;
      speed-limit-up = 256;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      ratio-limit = 4.0;
      ratio-limit-enabled = true;
    };
  };

  # Only allow internet to transmission through VPN, and only allow VPN use by transmission.
  # This way, most of my connections are non-tunneled, but transmission is
  # always and only tunneled.
  networking.firewall.extraCommands = ''
    iptables -A OUTPUT -m owner --gid-owner transmission -o tun0 -j ACCEPT
    iptables -A INPUT -m owner --gid-owner transmission -i tun0 -j ACCEPT
    iptables -A OUTPUT -m owner --gid-owner transmission -o lo -j ACCEPT
    iptables -A OUTPUT -m owner --gid-owner transmission -j REJECT
    iptables -A OUTPUT -o tun0 -j REJECT
    iptables -A INPUT -i tun0 -j REJECT
  '';

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

  services.openssh = { enable = true; };
}
