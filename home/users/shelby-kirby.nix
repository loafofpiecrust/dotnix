{ config, lib, pkgs, ... }: {
  imports = [ ../common.nix ../firefox.nix ];
  home.packages = with pkgs; [ transgui rclone ];

  programs.alacritty = {
    enable = true;
    settings = {
      background_opacity = 0.8;
      font.normal.family = "monospace";
      font.size = 11;
      window.padding = {
        x = 8;
        y = 8;
      };
    };
  };
}
