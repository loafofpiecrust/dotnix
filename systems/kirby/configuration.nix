{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ../../desktop.nix
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

  services.pulseaudio.enable = false;

  jovian.steam.enable = true;
  jovian.steam.autoStart = true;
  jovian.hardware.has.amd.gpu = true;
  jovian.steam.desktopSession = "mate";
  jovian.steam.user = "shelby";
  jovian.steamos.useSteamOSConfig = true;
  # jovian.steamos.enableBluetoothConfig = false;
  jovian.decky-loader.enable = true;
  jovian.steam.updater.splash = "vendor";
  # hardware.bluetooth.settings.General.Experimental = "true";
  hardware.bluetooth.settings.Policy.AutoEnable = "true";
  # hardware.bluetooth.settings.General.ClassicBondedOnly = "false";

  # Make Steam use the full size of my 4K TV.
  environment.variables = {
    GAMESCOPE_WIDTH = "3840";
    GAMESCOPE_HEIGHT = "2160";
  };

  powerManagement.powertop.enable = false;

  hardware.bluetooth.enable = true;
  services.blueman.enable = false;
  # Steam network management requires network-manager, so I'm fine with using
  # that on this system instead of IWD.
  networking.wireless.iwd.enable = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # Speed up the boot process instead of waiting for a full network connection.
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  #networking.timeServers = [ "time.google.com" "pool.ntp.org" ];
  networking.dhcpcd.wait = "background";
  hardware.bluetooth.disabledPlugins = [ "sap" ];
  hardware.bluetooth.powerOnBoot = true;
  #networking.networkmanager.dhcp = "dhcpcd";

  boot = {
    # plymouth.enable = false;
    loader.timeout = 2;
    loader.efi.efiSysMountPoint = "/boot/efi";
    kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
    kernelModules = [
      "kvm-amd"
      "mt7921e"
      "hid-playstation"
      "btusb"
      "bluetooth"
      "btmtk"
      "usbhid"
    ];
    initrd.kernelModules = [ "amdgpu" ];
    initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "usbhid" "nvme" "usb_storage" "sd_mod" ];
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
    python3
    gnome.gvfs
    sc-controller
    steam
    # chromium
    jq
    # gnome.zenity
    # wine
    ddcutil
    ddcui
  ];

  nixpkgs.overlays = [
    (self: super: {
      libbluray = super.libbluray.override {
        withAACS = true;
        withBDplus = true;
      };
      # If I ever want to try kodi again.
      # kodi = super.kodi-wayland.withPackages (p: with p; [ netflix youtube ]);

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

  # Disallow hibernation, we don't need it on this machine.
  systemd.targets.hibernate.enable = false;
  systemd.sleep.settings.Sleep = {
    AllowHibernate = "no";
    AllowSuspendThenHibernate = "no";
  };

  # Set rough location
  location = {
    latitude = 37.820248;
    longitude = -122.284792;
  };
  time.timeZone = "America/Los_Angeles";

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" "/media/hdd" ];

  # boot.supportedFilesystems.zfs = true;
  # This identifies the owner machine for the ZFS pool. Keep the host ID even if
  # the desktop dies, as long as it's an x86_64 linux machine. (currently all AMD)
  # The ZFS version mustn't be downgraded, nor the kernel version from 6.6
  # I don't have ZFS drives connected anymore but leave this for posterity.
  networking.hostId = "aa544e7d";
  fileSystems = let
    front-nvme = "/dev/disk/by-label/linux";
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
      options = [ "compress=zstd" "noatime" "nofail" ];
    };
    # TODO Convert this drive from ntfs to btrfs
    "/media/sata-ssd" = {
      device = sata-ssd;
      fsType = "ntfs";
      options = [ "noatime" "nofail" ];
    };

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
    ];
    openssh.authorizedKeys.keys = [
      # TODO Consider putting SSH public keys into a shared config file for
      # several systems to reference.
      # Personal Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVldsHCxoEpdN9K+cr9EKxS5dhvUBuCuhyLht3+8CJ2 snead@loafofpiecrust"
    ];
  };
  home-manager.users.shelby = ./users/shelby.nix;

  # GNOME autologin workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  # TODO: I think I can remove this since I'm having Steam auto-start as display manager.
  services.displayManager = {
    # autoLogin.enable = false;
    # autoLogin.user = "shelby";
    gdm.enable = false;
    gdm.wayland = true;
    defaultSession = "gamescope-wayland";
  };
  # Enable MATE as the fallback desktop mode.
  services.xserver = {
    enable = true;
    desktopManager.mate.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # This should help with P2P networking stuff, though I'm not sure it's needed anymore.
  networking.nat = {
    enable = true;
    internalInterfaces = [ "lo" "eno1" ];
    externalInterface = "eno1";
    enableIPv6 = true;
  };

  # age.secrets.pia.file = ../secrets/pia-password.age;
  # age.identityPaths = [ "/home/shelby/.ssh/id_ed25519" ];

  # Switch back to sudo for this build to maximize compatibility.
  security.sudo.wheelNeedsPassword = false;

  # Shutdown fully when I press the power button.
  services.logind.settings.Login = { HandlePowerKey = lib.mkForce "poweroff"; };

  # Allow SSH during boot to debug failed boot remotely.
  boot.initrd.network.ssh.enable = true;

  # Allow SSH into the machine from elsewhere on the local network.
  # Useful for debugging and remote updates.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    authorizedKeysInHomedir = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      UseDns = true;
    };
  };

  # Basic blocking of malicious entry or DDOS attacks.
  services.fail2ban = {
    enable = false;
    ignoreIP = [ "192.168.0.0/16" ];
    maxretry = 10;
  };
}
