{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ../laptop.nix
    ../vpn.nix
    ../dev.nix
    ../erasure.nix
  ];

  system.stateVersion = "22.05";

  # Enable fingerprint reader?
  services.fprintd.enable = false;
  # services.fprintd.package = pkgs.unstable.fprintd;
  # Disable fingerprint for login, because it's unreliable.
  security.pam.services.greetd.fprintAuth = false;

  # Setup basic boot options and kernel modules.
  boot = {
    plymouth.enable = false;
    kernelPackages = pkgs.linuxKernel.packages.linux_5_15;
    initrd.availableKernelModules =
      [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "btusb" ];
    blacklistedKernelModules = [ "hid_sensor_hub" ];
    # extraModprobeConfig = "options snd_hda_intel power_save=1";
    kernelModules = [ "kvm-intel" ];

    # kernel options
    kernelParams = [
      # "pcie_aspm.policy=powersave"
      "i915.enable_fbc=1"
      #"i915.enable_psr=1"
      "quiet"
      #"mem_sleep_default=s3"
      "nvme.noacpi=1"
    ];
    kernel.sysctl = { "kernel.nmi_watchdog" = 0; };

    # Make the font as large as possible.
    loader.systemd-boot.consoleMode = "max";
  };

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-gpu-tools
  ];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];

  # Setup root, boot, home, and swap partitions.
  boot.initrd.luks.devices."enc".device = "/dev/disk/by-partlabel/linux";
  fileSystems = let
    subvolume = name: {
      device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=${name}" "compress=zstd" "relatime" ];
    };
  in {
    "/" = subvolume "root";
    "/home" = subvolume "home";
    "/nix" = (subvolume "nix") // { neededForBoot = true; };
    "/persist" = (subvolume "persist") // { neededForBoot = true; };
    "/var/log" = (subvolume "log") // { neededForBoot = true; };

    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-partlabel/swap"; }];

  networking.interfaces.wlan0.useDHCP = true;
  # This device is for wired tethering with my phone, but now halts my boot for
  # over a minute while it looks for my phone.
  # networking.interfaces.enp0s20f0u1.useDHCP = true;

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    snead = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "adbusers"
        "scanner"
        "lp"
        "audio"
        "video"
        "libvirtd"
      ];
      hashedPassword =
        "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    };

    #work = {
    #  isNormalUser = true;
    #  extraGroups =
    #    [ "wheel" "docker" "adbusers" "scanner" "lp" "audio" "video" ];
    #  hashedPassword =
    #    "$6$tsPlzan2qXEAIir$Jyj78Sq6tuRqBY/R5raqee0oNjx5iuJTB1m0s4RaAuMukbmojE0q6FjnBth8x/tTpCsFDS7DlWXYRcn65R15q.";
    #};
  };
  users.users.root.hashedPassword =
    "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
  home-manager.users.snead = ../home/users/snead-framework.nix;

  # Sway is my primary WM since X doesn't do scaling well.
  programs.sway.enable = true;

  # Use greetd because it's the simplest Wayland DM with no issues!
  services.greetd = {
    enable = true;
    package = pkgs.greetd.greetd;
    settings = {
      default_session = {
        command = "${
            lib.makeBinPath [ pkgs.greetd.tuigreet ]
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
      };
    };
  };

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

  # Framework laptop doesn't require battery polling.
  services.upower.noPollBatteries = true;

  # Replace docker with podman since it's daemon-less?
  virtualisation.docker = {
    enable = false;
    autoPrune.enable = true;
  };

  # Let's try out bluetooth!
  hardware.bluetooth.enable = true;

  # Install some applications!
  environment.systemPackages = with pkgs; [
    # apps
    # gnome3.gnome-settings-daemon
    gnome.gvfs
    xfce.parole # video player
    font-manager
    gimp
    vlc
    inkscape
    # audacity # Audacity has telemetry now...
    mate.eom
    mate.caja
    mate.engrampa
    mate.atril # pdf viewer
    mate.mate-tweak
    mate.mate-system-monitor
    xfce.xfce4-power-manager
    xfce.xfce4-session
    xfce.xfce4-settings
    xfce.xfce4-taskmanager

    pcmanfm

    libreoffice
    # virt-manager
    nixos-generators
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

  virtualisation.libvirtd.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

}
