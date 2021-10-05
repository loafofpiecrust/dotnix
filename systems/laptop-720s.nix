# Config for Lenovo Ideapad 720s 14-IKB
# Import this file into the main configuration.nix and call it a day.
{ config, lib, pkgs, modulesPath, inputs, ... }: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ../laptop.nix
    ../vpn.nix
    ../dev.nix
    ../erasure.nix
  ];

  # Should correspond with a system name in flake.nix
  networking.hostName = "loafofpiecrust";

  # Setup basic boot options and kernel modules.
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    # editor defeats the purpose of all security...
    loader.systemd-boot.editor = false;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules =
      [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ "i915" ];
    blacklistedKernelModules = [ "nouveau" "nvidia" ];

    kernelModules = [ "kvm-intel" "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    # boot niceties
    cleanTmpDir = true;
    consoleLogLevel = 0;

    # kernel options
    kernelParams = [
      "pcie_aspm.policy=powersave"
      "i915.enable_fbc=1"
      "i915.enable_psr=2"
      "quiet"
      "udev.log_priority=3"
    ];
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "vm.swappiness" = 1;
    };

    tmpOnTmpfs = false;
  };

  nix.maxJobs = lib.mkDefault 8;

  # Setup root, boot, home, and swap partitions.
  fileSystems = let btrfsOpts = [ "compress=zstd" "noatime" ];
  in {
    "/" = {
      device = "/dev/disk/by-partlabel/LINUX";
      fsType = "btrfs";
      options = [ "subvol=root" ] ++ btrfsOpts;
    };

    "/home" = {
      device = "/dev/disk/by-partlabel/LINUX";
      fsType = "btrfs";
      options = [ "subvol=home" ] ++ btrfsOpts;
    };

    "/nix" = {
      device = "/dev/disk/by-partlabel/LINUX";
      fsType = "btrfs";
      options = [ "subvol=nix" ] ++ btrfsOpts;
    };

    "/persist" = {
      device = "/dev/disk/by-partlabel/LINUX";
      fsType = "btrfs";
      options = [ "subvol=persist" ] ++ btrfsOpts;
    };

    "/var/log" = {
      device = "/dev/disk/by-partlabel/LINUX";
      fsType = "btrfs";
      options = [ "subvol=log" ] ++ btrfsOpts;
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F3E8-3D3D";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-partlabel/LINUX_SWAP"; }];

  networking.firewall = {
    enable = true;
    # Open the ports needed for Chromecast.
    allowedTCPPorts = [ 8008 8009 ];
    # allowedUDPPorts = [{
    #   from = 32768;
    #   to = 61000;
    # }];
  };
  networking.useDHCP = false;
  # networking.useNetworkd = true;
  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
  };
  systemd.network.enable = true;
  networking.interfaces.wlan0.useDHCP = true;
  systemd.services.systemd-udev-settle.enable = false;
  # systemd.services.NetworkManager-wait-online.enable = false;

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.unstable.hplipWithPlugin ];

  home-manager.users.snead = ../home/users/snead.nix;
  home-manager.users.work = ../home/users/work.nix;
  users.users = {
    snead = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "adbusers" "scanner" "lp" "audio" ];
      shell = pkgs.fish;
      hashedPassword =
        "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    };

    work = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "adbusers" "scanner" "lp" "audio" ];
      shell = pkgs.fish;
      hashedPassword =
        "$6$tsPlzan2qXEAIir$Jyj78Sq6tuRqBY/R5raqee0oNjx5iuJTB1m0s4RaAuMukbmojE0q6FjnBth8x/tTpCsFDS7DlWXYRcn65R15q.";
    };
  };

  # Sway is my backup WM when things go wrong with EXWM.
  programs.sway.enable = true;
  # services.greetd = {
  #   enable = true;
  #   restart = false;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
  #     };
  #     initial_session = {
  #       command = "sway";
  #       user = "snead";
  #     };
  #   };
  # };
  services.xserver = {
    displayManager.lightdm.enable = true;
    # displayManager.gdm.enable = true;
    # displayManager.defaultSession = "sway";
    videoDrivers = [ "intel" "modesetting" "fbdev" ]; # TODO: Pick gpu drivers

    desktopManager = {
      xterm.enable = false;
      xfce = {
        # Bits of xfce that I need: power-manager, session?, xfsettingsd, xfconf
        # Don't need: xfce4-volumed-pulse, nmapplet
        enable = true;
        # noDesktop = true;
        # enableXfwm = false;
        thunarPlugins = with pkgs; [
          xfce.thunar-archive-plugin
          xfce.thunar-volman
        ];
      };
    };
  };

  # Lock the screen after some idle time, forcing me to login again.
  services.xserver.xautolock = {
    enable = true;
    time = 20;
    locker = ''
      ${pkgs.i3lock}/bin/i3lock -i "$(readlink /home/snead/.config/wpg/.current)"'';
  };
  # Don't require a password for doas, but lock the session.
  # This is basically the same as persisting my password without a session lock.
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    noPass = true;
  }];

  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
      export MOZ_ENABLE_WAYLAND=0
      export SDL_VIDEODRIVER=x11
      xrdb ~/.Xdefaults
      ${pkgs.gnome3.gnome-settings-daemon}/libexec/gnome-settings-daemon &
      EMACS_EXWM=t ${pkgs.dbus}/bin/dbus-launch --exit-with-session ${pkgs.emacsCustom}/bin/emacs -mm
    '';
  };

  # Common power management for laptops.
  services.tlp.enable = true;
  # Optimizes I/O on battery power.
  powerManagement.powertop.enable = true;
  # Enables screen dimming and session locking.
  services.upower.enable = true;
  programs.light.enable = true;

  # Only log out when the lid is closed with power.
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.killUserProcesses = true;

  # Replace docker with podman since it's daemon-less.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Let's try out bluetooth.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Trim SSD to keep the drive healthy.
  services.fstrim.enable = true;

  # Install some applications!
  environment.systemPackages = with pkgs; [
    xkbset
    # Power management
    powertop
    brightnessctl

    # apps
    gnome3.gnome-settings-daemon
    mate.atril # pdf viewer
    #xfce.parole # video player
    font-manager
    gimp
    vlc
    inkscape
    # audacity
    xfce.xfce4-power-manager
    xfce.thunar
    xfce.xfce4-session
    xfce.xfce4-settings
    #xfce.xfce4-taskmanager

    # communication
    teams

    # music
    unstable.spotify
    libreoffice

    # misc
    ppp # Needed for NUwave network setup
    # qgis
  ];

  # Enable NVIDIA GPU
  # hardware.bumblebee.enable = true;
  # hardware.nvidia.prime.offload.enable = true;
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   intelBusId = "PCI:0:2:0";
  #   nvidiaBusId = "PCI:60:0:0";
  # };

  # Use newer Intel Iris driver. This fixes screen tearing for me!
  # hardware.opengl.package = (pkgs.mesa.override {
  #   galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
  # }).drivers;

  # Undervolt to hopefully fix thermal throttling and fan issues.
  services.undervolt = {
    enable = true;
    coreOffset = -110;
    gpuOffset = -110;
  };
  # services.throttled.enable = true;

  # Disable automatic location updates because geoclue makes the boot process
  # wait for internet, stalling it for 5-10 seconds!
  location = let
    boston = {
      latitude = 42.3601;
      longitude = -71.0589;
    };
  in boston;
  # I can just manually set the timezone when I move.
  # I don't really need the local timezone on my laptop when I travel.
  time.timeZone = "America/New_York";

  # Make the screen color warmer at night, based on the time at my location.
  services.redshift.enable = true;

  # Use newer intel graphics drivers.
  hardware.cpu.intel.updateMicrocode = true;
  # nixpkgs.config.packageOverrides = pkgs: {
  # vaapiIntel = pkgs.vaapiIntel.override { enableHydridCodec = true; };
  # };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      # linuxPackages.nvidia_x11.out
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    # extraPackages32 = [ pkgs.linuxPackages.nvidia_x11.lib32 ];
  };

  hardware.logitech.wireless.enable = true;
}
