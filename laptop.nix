{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./desktop.nix
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
  ];

  # Disable this service because it consumes a lot of power.
  systemd.services.systemd-udev-settle.enable = false;

  # Common power management for laptops.
  # Use TLP for now because it's the most comprehensive and has been built and
  # supported for the longest time.
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.auto-cpufreq.enable = false;
  # Optimizes I/O on battery power.
  powerManagement.enable = true;
  powerManagement.powertop.enable = false;
  # Enables screen dimming and session locking.
  services.upower.enable = true;
  services.upower.criticalPowerAction = "Hibernate";
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
      HandlePowerKey=poweroff
      IdleAction=suspend
      IdleActionSec=600
    '';
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=2h
  '';

  services.acpid = {
    enable = true;
    # lidEventCommands = ''
    #   case "$1" in
    #     close)
    #       brightnessctl -s
    #       brightnessctl s 0;;
    #     open)
    #       brightnessctl -r;;
    #     *)
    #       echo "ACPI action undefined: $1";;
    # '';
  };
}
