{ config, lib, pkgs, ... }: {
  imports = [
    ../common.nix
    ../email.nix
    ../firefox.nix
    ../fish.nix
    ../sway.nix
    ../zsh.nix
  ];
  home.packages = with pkgs; [
    unstable.zoom-us
    unstable.discord
    unstable.krita
    deluge
    transmission-gtk
    unstable.zotero
    unstable.slack
    calibre # ebook manager
    unstable.teams
    rclone
    ledger
  ];

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

  programs.foot = {
    enable = true;
    settings = {
      main.dpi-aware = false;
      main.font = "monospace:size=11";
      colors.alpha = 0.8;
      main.pad = "8x8";
    };
  };

  programs.kitty = {
    enable = true;
    font.name = "monospace";
    font.size = 11;
  };

  services.stalonetray = {
    enable = false;
    config = {
      window_type = "utility";
      sticky = true;
      grow_gravity = "W";
      icon_gravity = "SE";
      icon_size = 32;
      window_strut = null;
      skip_taskbar = true;
      dockapp_mode = "simple";
      decorations = null;
      geometry = "4x1-12-12";
      max_geometry = "4x1-12-12";
      transparent = false;
    };
  };

  services.udiskie = { enable = true; };

  #xresources.properties = { "Xft.dpi" = 192; };

  gtk.gtk3.bookmarks = [ "file:///home/snead/cloud" ];
  systemd.user.services.rclone-pcloud = {
    Unit = {
      After = [ "multi-user.target" ];
      Wants = [ "multi-user.target" ];
      Description = "Pcloud storage mounted as drive";
    };
    Install.WantedBy = [ "multi-user.target" ];
    Service = {
      Type = "simple";
      StateDirectory = "rclone/pcloud";
      CacheDirectory = "pcloud";
      ExecStart = let
        home = config.home.homeDirectory;
        script = pkgs.writeShellScript "mount-pcloud" ''
          ${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --allow-other --vfs-cache-mode full --no-modtime --dir-cache-time=30m --cache-dir=/tmp/rclone/vfs --cache-db-path=/tmp/rclone/db --cache-chunk-path=/tmp/rclone/chunks --cache-tmp-upload-path=/tmp/rclone/upload pcloud: $STATE_DIRECTORY
        '';
      in "${script}";
      Restart = "always";
      RestartSec = "240";
    };
  };

  systemd.user.services.rclone-pcloud-secret = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      Description = "Pcloud storage mounted as encrypted drive";
    };
    Install.WantedBy = [ "multi-user.target" ];
    Service = {
      Type = "simple";
      StateDirectory = "rclone/pcloud-secret";
      ExecStart = let
        home = config.home.homeDirectory;
        script = pkgs.writeShellScript "mount-pcloud" ''
          ${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --allow-other --vfs-cache-mode full --no-modtime --dir-cache-time=30m --cache-dir=/tmp/rclone/secret/vfs --cache-db-path=/tmp/rclone/secret/db --cache-chunk-path=/tmp/rclone/secret/chunks --cache-tmp-upload-path=/tmp/rclone/secret/upload pcloud-secret: $STATE_DIRECTORY
        '';
      in "${script}";
      Restart = "always";
      RestartSec = "60";
    };
  };

  # systemd.user.services.backup-home = {
  #   Unit = {
  #     Description = "Backup home folder";
  #   };
  # };

  programs.go = {
    enable = true;
    goPath = ".go";
  };

  services.gammastep = {
    enable = true;
    latitude = 37.820248;
    longitude = -122.284792;
  };

  # Change any desktop settings I want based on time of day!
  xdg.configFile."gammastep/hooks/daynight-desktop" = {
    executable = true;
    text = let
      emacsclient = "${config.programs.emacs.package}/bin/emacsclient";
      gsettings = "${pkgs.glib}/bin/gsettings";
    in ''
      #!/bin/sh
      if [ "$1" = period-changed ]; then
        case $3 in
          night)
            ${emacsclient} --eval '(load-theme +snead/theme-night)'
            ${gsettings} set org.gnome.desktop.interface color-scheme prefer-dark;;
          daytime)
            ${emacsclient} --eval '(load-theme +snead/theme-day)'
            ${gsettings} set org.gnome.desktop.interface color-scheme prefer-light;;
          esac
      fi
    '';
  };
}
