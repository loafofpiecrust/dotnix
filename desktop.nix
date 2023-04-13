{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./nixos.nix
    ./gui.nix
    ./wifi.nix
    ./bluetooth.nix
    ./keyboard.nix
    inputs.nixos-hardware.nixosModules.common-pc
    # All of my desktop systems use SSD
    inputs.nixos-hardware.nixosModules.common-pc-ssd
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

  services.thermald.enable = true;

  hardware.steam-hardware.enable = true;
}
