{ config, lib, pkgs, ... }:

{
  imports = [ ../common.nix ../email.nix ../firefox.nix ../fish.nix ];
  home.packages = with pkgs; [ teams zoom-us slack chromium ];
  systemd.user.services.vpn-neu = {
    Unit = { Description = "Connect to Northeastern University VPN"; };
    Service = {
      Type = "simple";
      ExecStart = ''
        get-password neuidm.neu.edu t.snead | doas ${pkgs.openconnect}/bin/openconnect --protocol=gp --user=t.snead --passwd-on-stdin vpn.northeastern.edu
      '';
    };
  };
}
