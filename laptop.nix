{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./nixos.nix
    ./gui.nix
    ./wifi.nix
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
    allowedTCPPorts = [ 8008 8009 ];
    # allowedUDPPorts = [{
    #   from = 32768;
    #   to = 61000;
    # }];
  };

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.unstable.hplipWithPlugin ];

  hardware.logitech.wireless.enable = true;

  # Mimic sudo settings, where users in the wheel group can run as root, caching
  # the password for 5 minutes.
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    runAs = "root";
    persist = true;
  }];

  # Allow OTA firmware updates.
  services.fwupd.enable = true;
  environment.etc."fwupd/remotes.d/lvfs-testing.conf" = { source = ./fwupd-lvfs-testing.conf;  };

  # Common power management for laptops.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  # Optimizes I/O on battery power. Maybe don't need this anymore?
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  # Enables screen dimming and session locking.
  services.upower.enable = true;
  # Backlight management
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    power-profiles-daemon
    powertop
    ppp # Needed for NUwave network setup
  ];

  # Only log out when the lid is closed with power.
  services.logind = {
    killUserProcesses = true;
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=hibernate
    '';
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';
}
