{ config, lib, pkgs, ... }:

{
  # Allow easy discovery of network devices (like printers).
  services = {
    avahi.enable = true;
    avahi.nssmdns4 = true;
    avahi.openFirewall = true;
    printing.enable = lib.mkDefault true;
    printing.drivers = with pkgs; [ hplip gutenprint ];
  };

  # Scanning
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplip ];

  environment.systemPackages = with pkgs; [ simple-scan ];
}
