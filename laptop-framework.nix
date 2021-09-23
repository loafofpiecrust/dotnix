# Config for Lenovo Ideapad 720s 14-IKB
# Import this file into the main configuration.nix and call it a day.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ./common.nix
    ./gui.nix
    ./vpn.nix
    ./dev.nix
    #    ./music.nix
    ./erasure.nix
    ./cloud.nix
    ./cachix.nix
  ];

  # Should correspond with a system name in flake.nix
  networking.hostName = "portable-spudger";

  # Enable fingerprint reader.
  services.fprintd.enable = true;
  services.fprintd.package = pkgs.unstable.fprintd;
  security.pam.services.lightdm.fprintAuth = true;
  security.pam.services.lightdm-autologin.fprintAuth = true;
  # Disable fingerprint for login, because it's unreliable.
  security.pam.services.greetd.fprintAuth = false;

  hardware.enableRedistributableFirmware = true;

  # Setup basic boot options and kernel modules.
  boot = {
    plymouth.enable = false;
    #kernelPackages = pkgs.framework-kernel.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_5_14;
    loader.systemd-boot = {
      # Use the systemd-boot EFI boot loader.
      enable = true;
      # editor defeats the purpose of all security...
      editor = false;
      consoleMode = "max";
    };
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules =
      [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "btusb" ];
    blacklistedKernelModules = [ ];
    extraModprobeConfig = "options snd_hda_intel power_save=1";

    kernelModules = [ "kvm-intel" ];

    # boot niceties
    cleanTmpDir = true;
    consoleLogLevel = 0;

    # kernel options
    kernelParams = [
      "pcie_aspm.policy=powersave"
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
      "quiet"
      #"udev.log_priority=3"
      #"mem_sleep_default=deep"
    ];
    kernel.sysctl = { "kernel.nmi_watchdog" = 0; };

    tmpOnTmpfs = false;
  };

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];

  # Setup root, boot, home, and swap partitions.
  fileSystems = let
    subvolume = name: {
      device = "/dev/disk/by-partlabel/linux";
      fsType = "btrfs";
      options = [ "subvol=${name}" "compress=zstd" "relatime" ];
    };
  in {
    "/" = subvolume "root";
    "/home" = subvolume "home";
    "/nix" = subvolume "nix";
    "/persist" = subvolume "persist";
    "/var/log" = (subvolume "log") // { neededForBoot = true; };

    "/boot" = {
      device = "/dev/disk/by-uuid/AF05-9D01";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-partlabel/swap"; }];

  networking.firewall = {
    enable = true;
    # Open the ports needed for Chromecast.
    allowedTCPPorts = [ 8008 8009 ];
    # allowedUDPPorts = [{
    #   from = 32768;
    #   to = 61000;
    # }];
  };

  # Use better DNS resolution service, networkd.
  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
  };

  # Use DHCP only on specific network interfaces.
  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;
  # Disable this service because it consumes a lot of power.
  systemd.services.systemd-udev-settle.enable = false;

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  users.users = {
    snead = {
      isNormalUser = true;
      extraGroups =
        [ "wheel" "docker" "adbusers" "scanner" "lp" "audio" "video" ];
      shell = pkgs.fish;
      hashedPassword =
        "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    };

    work = {
      isNormalUser = true;
      extraGroups =
        [ "wheel" "docker" "adbusers" "scanner" "lp" "audio" "video" ];
      shell = pkgs.fish;
      hashedPassword =
        "$6$tsPlzan2qXEAIir$Jyj78Sq6tuRqBY/R5raqee0oNjx5iuJTB1m0s4RaAuMukbmojE0q6FjnBth8x/tTpCsFDS7DlWXYRcn65R15q.";
    };
  };

  # Sway is my backup WM when things go wrong with EXWM.
  programs.sway.enable = true;
  services.greetd = {
    enable = true;
    package = pkgs.unstable.greetd.greetd;
    settings = {
      default_session = {
        command = "${
            lib.makeBinPath [ pkgs.unstable.greetd.tuigreet ]
          }/tuigreet --width 100 --time --asterisks --cmd sway";
        user = "greeter";
      };
    };
  };

  services.xserver = {
    enable = false;
    dpi = 200;
    # Use LightDM instead of GDM because the latter is super fucking slow.
    # displayManager.lightdm.enable = lib.mkForce false;
    displayManager.defaultSession = "sway";
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
    enable = false;
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

  # Allow OTA firmware updates.
  services.fwupd.enable = true;

  # Common power management for laptops.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  services.thermald.enable = true;
  # Optimizes I/O on battery power. Maybe don't need this anymore?
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  # Enables screen dimming and session locking.
  services.upower.enable = true;
  services.upower.noPollBatteries = true;
  # Backlight management
  programs.light.enable = true;

  # Only log out when the lid is closed with power.
  services.logind = {
    killUserProcesses = true;
    lidSwitchExternalPower = "ignore";
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=hibernate
    '';
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  # Replace docker with podman since it's daemon-less?
  virtualisation.docker = {
    enable = false;
    autoPrune.enable = true;
  };

  # Let's try out bluetooth.
  hardware.bluetooth.enable = false;
  # GUI control center for bluetooth
  services.blueman.enable = false;

  # Install some applications!
  environment.systemPackages = with pkgs; [
    xkbset
    # Power management
    powertop
    brightnessctl

    # apps
    gnome3.gnome-settings-daemon
    gnome.gvfs
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
    power-profiles-daemon
  ];

  # Disable automatic location updates because geoclue makes the boot process
  # wait for internet, stalling it for 5-10 seconds!
  location = {
    # Oakland
    latitude = 37.820248;
    longitude = -122.284792;
  };
  # I can just manually set the timezone when I move.
  # I don't really need the local timezone on my laptop when I travel.
  time.timeZone = "America/Los_Angeles";

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
}
