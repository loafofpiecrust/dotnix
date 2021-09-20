{ config, lib, pkgs, ... }: {
  imports = [ ../common.nix ../email.nix ../firefox.nix ../fish.nix ];
  home.packages = with pkgs; [
    zoom-us
    discord
    ledger
    krita
    calibre # ebook manager
    deluge
    rclone
    zotero
  ];

  # home.file.".face".source = pkgs.requireFile {
  #   name = "face-file";
  #   url =
  #     "https://www.startpage.com/av/proxy-image?piurl=https%3A%2F%2Fcdn.vox-cdn.com%2Fthumbor%2FYXtm49VNZeW4Q3ZUtFaQg0H1dHM%3D%2F0x0%3A1280x720%2F1400x1400%2Ffilters%3Afocal%28538x258%3A742x462%29%3Aformat%28jpeg%29%2Fcdn.vox-cdn.com%2Fuploads%2Fchorus_image%2Fimage%2F47718349%2Fadventuretimestakes.0.jpg&sp=1631325138Tbe957154b1f3959536c2626b332a4fc220a2ec82a2110804c11c8b46bbcd3979";

  # };
  programs.mako = {
    enable = true;
    font = "monospace 11";
    extraConfig = ''
      [category=overlay]
      default-timeout=1000
      ignore-timeout=1
      history=0
      anchor=center
      layer=overlay

      [anchor=center]
      max-visible=1
    '';
  };

  # Enables power status notifications when using Sway.
  services.poweralertd.enable = true;
  systemd.user.services.poweralertd = {
    Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    # TODO I might not need to change Unit.PartOf
    Unit.PartOf = lib.mkForce [ "sway-session.target" ];
  };

  wayland.windowManager.sway = {
    enable = true;
    config.output = {
      # Framework Laptop screen
      "Unknown 0x095F 0x00000000" = {
        mode = "2256x1504@60Hz";
        scale = "1.3";
      };
    };
    config.gaps = {
      outer = 0;
      inner = 10;
    };
    config.modifier = "Mod4";
    config.terminal = "${pkgs.alacritty}/bin/alacritty";
    config.keybindings = let
      mod = config.wayland.windowManager.sway.config.modifier;
      brightness = "${pkgs.brightnessctl}/bin/brightnessctl";
      light = "${pkgs.light}/bin/light";
      pamixer = "${pkgs.pamixer}/bin/pamixer";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      setLight = arg:
        pkgs.writeShellScript "set-light" ''
          ${light} ${arg}
          LIGHT=$(${light} -G)
          LIGHT=$(printf "%.0f" $LIGHT)
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Brightness" -c overlay -h int:value:$LIGHT -R /tmp/overlay-notification
        '';
      setVolume = arg:
        pkgs.writeShellScript "set-volume" ''
          ${pamixer} ${arg}
          VOLUME=$(${pamixer} --get-volume)
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Volume" -c overlay -h int:value:$VOLUME -R /tmp/overlay-notification
        '';
    in lib.mkOptionDefault {
      "XF86MonBrightnessUp" = "exec ${setLight "-A 5"}";
      "XF86MonBrightnessDown" = "exec ${setLight "-U 5"}";
      "Ctrl+Alt+Backspace" = "exit";
      "${mod}+w" = "kill";
      "${mod}+p" = "exec ${pkgs.wofi}/bin/wofi";
      "${mod}+s" = "floating toggle";
      "${mod}+a" = "focus parent";
      "${mod}+c" = "exec ${playerctl} play-pause";
      "${mod}+b" = "exec ${config.programs.firefox.package}/bin/firefox";
      "${mod}+e" = "exec ${config.programs.emacs.package}/bin/emacsclient -c";
      "${mod}+bracketright" = "workspace next";
      "${mod}+bracketleft" = "workspace prev";
      "${mod}+shift+bracketright" = "move container to workspace next";
      "${mod}+shift+bracketleft" = "move container to workspace prev";
      "XF86AudioRaiseVolume" = "exec ${setVolume "-i 5"}";
      "XF86AudioLowerVolume" = "exec ${setVolume "-d 5"}";
      "XF86AudioMute" = "exec ${pamixer} -m";
    };
    config.input."type:touchpad" = {
      natural_scroll = "enabled";
      middle_emulation = "enabled";
      scroll_method = "two_finger";
      click_method = "clickfinger";
    };
    config.input."type:keyboard" = { xkb_options = "caps:swapescape"; };
    config.startup = [
      { command = "${pkgs.wpgtk}/bin/wpg -m"; }
      { command = "systemctl --user start rclone-pcloud"; }
      {
        command =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &";
      }
      # Use clipman as a clipboard manager.
      {
        command =
          "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store";
      }
    ];
    config.bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
    extraConfig = ''
      set $gnome-schema org.gnome.desktop.interface
      exec_always {
          gsettings set $gnome-schema gtk-theme '${config.gtk.theme.name}'
          gsettings set $gnome-schema icon-theme '${config.gtk.iconTheme.name}'
          gsettings set $gnome-schema cursor-theme '${config.xsession.pointerCursor.name}'
          gsettings set $gnome-schema font-name 'Overpass'
      }
      include "$HOME/.cache/wal/colors-sway"
      output * bg $wallpaper fill
      for_window [app_id="firefox"] inhibit_idle fullscreen
    '';
  };

  programs.waybar = {
    enable = true;
    settings = [{
      position = "top";
      layer = "top";
      height = 30;
      modules-left = [ "sway/mode" "sway/workspaces" ];
      modules-right =
        [ "tray" "idle_inhibitor" "pulseaudio" "battery" "clock" ];
      modules.tray = {
        icon-size = 24;
        spacing = 8;
      };
    }];
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

  programs.kitty = {
    enable = true;
    font.name = "monospace";
    font.size = 11;
  };

  services.stalonetray = {
    enable = true;
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

  systemd.user.services.rclone-pcloud = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
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
      RestartSec = "60";
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
}
