{ config, lib, pkgs, systemConfig, ... }: {
  imports = [ ./wayland.nix ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = systemConfig.programs.hyprland.package;
    # systemd.enable = true;
    extraConfig = let
      gsettings = {
        gtk-theme = config.gtk.theme.name;
        icon-theme = config.gtk.iconTheme.name;
        cursor-theme = config.home.pointerCursor.name;
        font-name = "sans-serif 13";
        document-font-name = "serif 13";
      };
      gsettingsString = lib.concatStringsSep "\n" (lib.mapAttrsToList
        (key: value:
          "exec = gsettings set org.gnome.desktop.interface ${key} '${value}'")
        gsettings);
    in ''
      source = ${config.lib.meta.mkMutableSymlink ./hyprland.conf}
    '';
  };
}
