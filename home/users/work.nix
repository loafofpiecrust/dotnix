{ config, lib, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../email.nix
    ../firefox.nix
    ../chromium.nix
    ../fish.nix
    ../sway.nix
    ../zsh.nix
  ];
  home.packages = with pkgs; [ # teams
    unstable.zoom-us
    unstable.slack
  ];
  systemd.user.services.vpn-neu = {
    Unit = { Description = "Connect to Northeastern University VPN"; };
    Service = {
      Type = "simple";
      ExecStart = ''
        get-password neuidm.neu.edu t.snead | sudo ${pkgs.openconnect}/bin/openconnect --protocol=gp --user=t.snead --passwd-on-stdin vpn.northeastern.edu
      '';
    };
  };
}
