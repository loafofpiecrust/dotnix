# For touchpad after hibernation:
# it seems that disabling PS/2 mouse emulation in BIOS fixed the problem.
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
    ../laptop.nix
    ../vpn.nix
    ../dev.nix
    # ../erasure.nix
  ];

  # Prevent nix from taking all available CPU time.
  nix.settings.max-jobs = 3;
  nix.settings.cores = 3;

  environment.etc = let persistInEtc = [ "nixos" ];
  in lib.mkMerge
  (map (name: { "${name}".source = "/persist/etc/${name}"; }) persistInEtc);

  system.stateVersion = "22.05";

  # Disable fingerprint for login, because it's unreliable.
  services.fprintd.enable = false;
  security.pam.services.greetd.fprintAuth = false;

  hardware.i2c.enable = true;

  # Setup basic boot options and kernel modules.
  boot = {
    plymouth.enable = false;
    # Use the latest LTS kernel because those keep getting patch updates for 2+ years.
    # Let's try the latest version...
    kernelPackages = pkgs.linuxKernel.packages.linux_6_11;
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
      "btusb"
      "btintel"
    ];
    kernelModules = [ "kvm-intel" ];
    # blacklistedKernelModules = [ "i2c-designware-pci" ];

    # kernel options
    kernelParams = [
      "pcie_aspm.policy=powersave"
      "i915.enable_fbc=1"
      "nvme.noacpi=1" # Apparently good for battery life
      "i915.enable_psr=1"
      "i915.enable_guc=3"
      "i915.disable_power_well=0"
      "mem_sleep_default=deep"
      "snd-hda-intel.power_save=1"
      "iwlwifi.power_save=1"
      "iwlmvm.power_scheme=3"
      # Try to quiet down the boot process to only error messages.
      "quiet"
      "loglevel=3"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      # Block cursor at boot
      "vt.current=6"
      "usbcore.autosuspend=10"
      # Ask the arch wiki
      ''acpi_osi="!Windows 2020"''
      "irqaffinity=0,1"
    ];
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "dev.i915.perf_stream_paranoid" = 0;
    };

    # Make the font as large as possible.
    loader.systemd-boot.consoleMode = "max";

    # Some people claim on the Framework Laptop forums that this makes wifi more reliable.
    extraModprobeConfig = ''
      options iwlwifi disable_11ax=Y
    '';
  };

  # Recommended for battery life
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    # PLATFORM_PROFILE_ON_BAT = "low-power";
    PCIE_ASPM_ON_BAT = "powersupersave";
    # START_CHARGE_THRESH_BAT1 = 80;
    # STOP_CHARGE_THRESH_BAT1 = 95;
    # CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
    # Disable auto-suspend on the Logitech unifying receiver
    # USB_DENYLIST = "046d:c52b";
    # Give a little more power while plugged in, because it's usually at my desk.
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    INTEL_GPU_MIN_FREQ_ON_AC = 300;
    DISK_DEVICES = "nvme0n1";
    DISK_IOSCHED = "mq-deadline";
  };

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-gpu-tools
  ];

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];

  # Setup root, boot, home, and swap partitions.
  boot.initrd.luks.devices."enc".device =
    "/dev/disk/by-uuid/0a45658a-84b6-4a62-bcf5-ee19efa79b7e";
  fileSystems = let
    subvolume = name: {
      device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=${name}" "compress=zstd" "noatime" ];
    };
  in {
    "/" = subvolume "root";
    "/home" = subvolume "home";
    "/nix" = (subvolume "nix") // { neededForBoot = true; };
    "/persist" = (subvolume "persist") // { neededForBoot = true; };
    "/var/log" = (subvolume "log") // { neededForBoot = true; };

    "/boot" = {
      device = "/dev/disk/by-uuid/AF05-9D01";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-partlabel/swap"; }];

  networking.interfaces.wlan0.useDHCP = true;
  # This device is for wired tethering with my phone, but now halts my boot for
  # over a minute while it looks for my phone.
  # networking.interfaces.enp0s20f0u1.useDHCP = true;
  # I don't need fwupd running since this machine has all the updates by now.
  services.fwupd.enable = false;

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.promptInit = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
  '';
  users.users = let
    extraGroups = [
      "wheel"
      "docker"
      "adbusers"
      "scanner"
      "lp"
      "audio"
      "video"
      "libvirtd"
      "keyd"
      "plugdev"
      "input"
      "uinput"
      "cdrom"
      "vboxusers"
    ];
  in {
    snead = {
      inherit extraGroups;
      isNormalUser = true;
      hashedPassword =
        "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    };

    work = {
      inherit extraGroups;
      isNormalUser = true;
      hashedPassword =
        "$6$KdJ7E2kLCXKj0knB$xh70j/AmbevG3fpQAqwDK6uX5lWvB7DT/36WsFB6rivFw/cndbhgWCf.krQ4fo77o8.zDjU693QfcbEzED7k.0";
    };

    root.hashedPassword =
      "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
  };

  home-manager.users.snead = ../home/users/snead-framework.nix;
  home-manager.users.work = ../home/users/work.nix;

  # Sway is my primary WM since X doesn't do scaling well.
  programs.sway.enable = true;

  # Use greetd because it's the simplest Wayland DM with no issues!
  services.greetd = {
    enable = true;
    settings = {
      # Might need  ${pkgs.sway}/share/wayland-sessions
      default_session = {
        # command = "${config.programs.regreet.package}/bin/regreet";
        user = "greeter";
      };
    };
  };

  lib.meta = rec {
    dynamicBgRepo = pkgs.fetchgit {
      url = "https://github.com/saint-13/Linux_Dynamic_Wallpapers";
      rev = "8904f832affb667c2926061d8e52b9131687451b";
      # Avoid massive clone time by only fetching the wallpaper I use.
      sparseCheckout = [ "Dynamic_Wallpapers/Mojave" ];
      sha256 = "VW1xOSLtal6VGP7JHv8NKdu7YTXeAHRrwZhnJy+T9bQ=";
    };
    dynamicBg = index:
      "${dynamicBgRepo}/Dynamic_Wallpapers/Mojave/mojave_dynamic_${index}.jpeg";
  };

  programs.regreet = {
    enable = true;
    cageArgs = [ "-s" "-m" "last" ];
    settings = {
      GTK.cursor_theme_name = "Bibata-Modern-Classic";
      GTK.font_name = "sans 12";
      GTK.theme_name = "Arc";
      GTK.icon_theme_name = "Numix";
      background.path = config.lib.meta.dynamicBg "1";
      background.fit = "Cover";
    };
  };

  services.displayManager.defaultSession = "SwayFX";

  services.xserver = {
    enable = false;
    dpi = 200;
    # Use LightDM instead of GDM because the latter is super fucking slow.
    # displayManager.lightdm.enable = lib.mkForce false;
    videoDrivers = [ "intel" "modesetting" "fbdev" ]; # TODO: Pick gpu drivers

    desktopManager = {
      xterm.enable = false;
      xfce = {
        # Bits of xfce that I need: power-manager, session?, xfsettingsd, xfconf
        # Don't need: xfce4-volumed-pulse, nmapplet
        enable = false;
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
    # DON'T START ON BOOT! Docker draws lots of power!
    enableOnBoot = false;
    autoPrune.enable = true;
  };
  virtualisation.virtualbox = {
    host.enable = true;
    # host.enableKvm = true;
  };

  # Let's try out bluetooth!
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Open the shitload of ports apparently required to connect to my Bambu A1
  # printer over LAN.
  networking.firewall.allowedTCPPorts = [ 3000 1990 2021 8883 123 990 6000 ];
  networking.firewall.allowedTCPPortRanges = [{
    from = 50000;
    to = 50100;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 10001;
    to = 10512;
  }];
  networking.firewall.allowedUDPPorts = [ 123 1990 2021 ];

  # Install some applications!
  environment.systemPackages = with pkgs; [
    # blesh
    docker
    # ungoogled-chromium
    brave
    # apps
    # gnome3.gnome-settings-daemon
    gnome.gvfs
    font-manager
    gimp
    vlc
    inkscape
    audacity # Audacity has telemetry now...
    mate.eom
    mate.caja
    mate.engrampa
    mate.atril # pdf viewer
    # mate.mate-tweak
    mate.mate-system-monitor
    xfce.xfburn

    # Try some file managers
    # pcmanfm
    # spaceFM
    ranger-plus
    cinnamon.nemo
    # gnome.nautilus

    libreoffice
    # virt-manager
    # pynitrokey

    unstable.beets
  ];
  # Let mate-panel find applets
  environment.sessionVariables."MATE_PANEL_APPLETS_DIR" =
    "${config.system.path}/share/mate-panel/applets";
  environment.sessionVariables."MATE_PANEL_EXTRA_MODULES" =
    "${config.system.path}/lib/mate-panel/applets";

  # Disable automatic location updates because geoclue makes the boot process
  # wait for internet, stalling it for 5-10 seconds!
  location = {
    latitude = 37.820248;
    longitude = -122.284792;
  };
  # I can just manually set the timezone when I move.
  # I don't really need the local timezone on my laptop when I travel.
  time.timeZone = "America/Los_Angeles";

  virtualisation.libvirtd.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Enable the tailscale module, but disable the auto-running service because it
  # seems to be power hungry even when it's down.
  services.tailscale = { enable = true; };
  systemd.services.tailscaled.enable = false;

  # Let me rip and burn CDs on this laptop.
  programs.k3b.enable = true;

  # Make slack a wayland app
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  security.pam.loginLimits = [{
    domain = "@users";
    item = "rtprio";
    type = "-";
    value = 1;
  }];

  programs.partition-manager.enable = true;

  # Userspace workaround for high power usage by touchpad
  systemd.services.touchpad-smp-affinity = {
    wantedBy = [ "basic.target" ];
    script =
      "/bin/sh -c 'echo 2-2 > /proc/irq/$(grep designware.2 /proc/interrupts | cut -d \":\" -f1 | xargs)/smp_affinity_list'";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStop =
        "/bin/sh -c 'echo \"0-$(nproc --all --ignore=1)\" > /proc/irq/$(grep designware.2 /proc/interrupts | cut -d \":\" -f1 | xargs)/smp_affinity_list'";
    };
  };
}
