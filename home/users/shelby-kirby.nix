{ config, lib, pkgs, ... }: {
  imports = [ ../common.nix ];
  home.stateVersion = lib.mkDefault "21.05";
  home.packages = with pkgs; [ transgui rclone librewolf-bin beets ];

  xdg.userDirs = {
    # TODO Change these back to default title case, why does everything have to
    # be casual lowercase?
    documents = "$HOME/documents";
    download = "$HOME/downloads";
    music = "$HOME/music";
    pictures = "$HOME/pictures";
    templates = "$HOME/templates";
    videos = "$HOME/videos";
    desktop = "$HOME/desktop";
  };

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
