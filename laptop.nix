{ config, lib, pkgs, inputs, ... }: {
  imports =
    [ ./desktop.nix inputs.nixos-hardware.nixosModules.common-pc-laptop ];

  # Auto-mount plugged in disks
  services.udisks2.enable = true;

  # Disable this service because it consumes a lot of power.
  systemd.services.systemd-udev-settle.enable = false;

  # Common power management for laptops.
  # Use TLP for now because it's the most comprehensive and has been built and
  # supported for the longest time.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  services.auto-cpufreq.enable = false;
  # Optimizes I/O on battery power.
  powerManagement.enable = true;
  powerManagement.powertop.enable = lib.mkDefault false;
  # Enables screen dimming and session locking.
  services.upower.enable = true;
  services.upower.criticalPowerAction = "Hibernate";
  # Backlight management
  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    # power-profiles-daemon
    powertop
    ppp # Needed for NUwave network setup
    ffmpeg
  ];

  services.logind = {
    # killUserProcesses = true;
    lidSwitch = "suspend";
    lidSwitchExternalPower = config.services.logind.lidSwitch;
    powerKey = "poweroff";
    powerKeyLongPress = "poweroff";
    extraConfig = ''
      IdleAction=suspend
      IdleActionSec=600
    '';
  };
  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=1h
  # '';

  # Don't wait for networking to come on to finish booting, because for laptops
  # with WiFi this is often >5s. Let it happen while I type in my password.
  networking.dhcpcd.wait = "background";

  # Allow loading a color profile for my specific monitor.
  services.colord.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Allow control of mediatek devices over USB (for SP Flash Tool / Jelly Star)
  services.udev.extraRules = ''
    ATTRS{idVendor}=="0e8d", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';
}
