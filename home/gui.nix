{ config, lib, pkgs, ... }:

{
  xdg.configFile."fontconfig/fonts.conf".source = ./gui/fonts.conf;
  home.file."bin/light-notify".source = ./scripts/light-notify.sh;
  home.file."bin/power-menu".source = ./scripts/power-menu.sh;

  # GPG agent handles locked files and SSH keys.
  services.gpg-agent = {
    enable = true;
    enableSshSupport = lib.mkDefault true;
    defaultCacheTtl = 60 * 60;
    defaultCacheTtlSsh = 60 * 60;
    pinentry.package = pkgs.pinentry-gnome3;
    extraConfig = ''
      display :0
    '';
  };

  gtk = {
    enable = true;
    font.name = "sans";
    font.size = 13;
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-Light";
    };
    iconTheme = {
      package = pkgs.whitesur-icon-theme;
      name = "WhiteSur-light";
    };
  };

  # Make QT match the GTK theme.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.git.extraConfig.core.editor = "emacsclient -r";
}
