{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./nixos.nix
    ./gui.nix
    ./wifi.nix
    ./bluetooth.nix
    ./keyboard.nix
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
  ];

  boot = {
    loader.systemd-boot = {
      # Use the systemd-boot EFI boot loader.
      enable = true;
      # Editor defeats the purpose of bootloader security.
      editor = false;
    };
    loader.efi.canTouchEfiVariables = true;

    # boot niceties
    cleanTmpDir = true;
    consoleLogLevel = 0;
    tmpOnTmpfs = lib.mkDefault false;
  };

  # Disable this service because it consumes a lot of power.
  systemd.services.systemd-udev-settle.enable = false;

  # Open the ports needed for Chromecast.
  networking.firewall = {
    allowedTCPPorts = [
      8008
      8009
      # Calibre local network port
      9090
    ];
    allowedUDPPorts = [ 9090 ];
    # allowedUDPPorts = [{
    #   from = 32768;
    #   to = 61000;
    # }];
  };

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Mimic sudo settings, where users in the wheel group can run as root, caching
  # the password for 5 minutes.
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    runAs = "root";
    persist = true;
  }];

  # Allow OTA firmware updates from the testing channel.
  services.fwupd.enable = true;
  environment.etc."fwupd/remotes.d/lvfs-testing.conf" = {
    source = ./fwupd-lvfs-testing.conf;
  };
  environment.etc."fwupd/uefi_capsule.conf".source =
    lib.mkForce ./fwupd-uefi-capsule.conf;

  # Common power management for laptops.
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  # Optimizes I/O on battery power. Maybe don't need this anymore?
  powerManagement.enable = true;
  powerManagement.powertop.enable = false;
  # Enables screen dimming and session locking.
  services.upower.enable = true;
  # Backlight management
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    power-profiles-daemon
    powertop
    ppp # Needed for NUwave network setup
  ];

  services.logind = {
    killUserProcesses = true;
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = config.services.logind.lidSwitch;
    extraConfig = ''
      HandlePowerKey=power-off
    '';
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  programs.noisetorch.enable = true;
}
