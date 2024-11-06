{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./wayland.nix ];

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = null;
    extraConfig = let
      gsettings = {
        gtk-theme = config.gtk.theme.name;
        icon-theme = config.gtk.iconTheme.name;
        cursor-theme = config.home.pointerCursor.name;
        font-name = "sans 13";
        document-font-name = "serif 13";
      };
      gsettingsString = lib.concatStringsSep "\n" (lib.mapAttrsToList
        (key: value:
          "gsettings set org.gnome.desktop.interface ${key} '${value}'")
        gsettings);
    in ''
      set $gnome-schema org.gnome.desktop.interface
      exec_always {
          ${gsettingsString}
      }
      seat seat0 xcursor_theme ${config.home.pointerCursor.name} ${
        builtins.toString config.home.pointerCursor.size
      }
      exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      include ${config.lib.meta.mkMutableSymlink ./sway.config}
    '';
  };

}
