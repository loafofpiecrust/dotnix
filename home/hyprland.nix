{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./wayland.nix ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
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
          "exec = gsettings set org.gnome.desktop.interface ${key} '${value}'")
        gsettings);
    in ''
      exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      ${gsettingsString}
      source = ${config.lib.meta.mkMutableSymlink ./hyprland.conf}
    '';
  };
}
