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
    inputs.home-manager.nixosModules.home-manager
  ];

  # Pass flake inputs to home-manager modules.
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.backupFileExtension = "bak";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  boot = {
    loader.systemd-boot = {
      # Use the systemd-boot EFI boot loader.
      enable = true;
      # Editor defeats the purpose of bootloader security.
      editor = false;
    };
    loader.efi.canTouchEfiVariables = true;

    # boot niceties
    consoleLogLevel = 0;
    tmp.useTmpfs = lib.mkDefault false;
    tmp.cleanOnBoot = true;
  };

  # Open the ports needed for Chromecast.
  networking.firewall = {
    allowedTCPPorts = [
      8008
      8009
      8010
      # Calibre local network port
      9090
    ];
    allowedUDPPorts = [ 9090 5353 ];
    allowedUDPPortRanges = [{
      from = 32768;
      to = 61000;
    }];
  };

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplip ];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  services.thermald.enable = true;

  hardware.steam-hardware.enable = true;

  programs.java.enable = true;
  programs.dconf.enable = true;
}
