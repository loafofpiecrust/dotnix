{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./wayland.nix ];

  wayland.windowManager.sway = {
    enable = true;
    # package = pkgs.swayfx;
    # config.menu = "${pkgs.sirula}/bin/sirula";
    wrapperFeatures.gtk = true;
    config.output = {
      # Framework Laptop screen
      "BOE 0x095F Unknown" = {
        mode = "2256x1504@60Hz";
        # Use a scale that'll frequently give me whole numbers.
        # 4 => 5; 8 => 10; 12 => 15; 16 => 20
        scale = "1.333333"; # Roughly 1080p density
        scale_filter = "nearest";
      };
      "Acer Technologies XV272U 0x0000BFCC" = {
        mode = "2560x1440@144Hz";
        # scale = "1.0";
        scale_filter = "nearest";
      };
    };

    # Assign the first five workspaces to the laptop screen, and the next five
    # workspaces to the external monitor (if any)
    config.workspaceOutputAssign = (builtins.map (idx: {
      output = "eDP-1";
      workspace = builtins.toString idx;
    }) (lib.range 1 4)) ++ (builtins.map (idx: {
      output = "DP-4";
      workspace = builtins.toString idx;
    }) (lib.range 5 9)) ++ [{
      output = "DP-4";
      workspace = "0";
    }];

    config.gaps = {
      outer = 0;
      inner = 8;
    };
    config.modifier = "Mod4";
    config.terminal = "${pkgs.foot}/bin/foot";
    config.keybindings = let
      mod = config.wayland.windowManager.sway.config.modifier;
      setLight = pkgs.writeShellScript "set-light" ''
        light $@
        LIGHT=$(light -G)
        LIGHT=$(printf "%.0f" $LIGHT)
        ${pkgs.notify-send-sh}/bin/notify-send.sh "Brightness" -c overlay -h int:value:$LIGHT -R /tmp/overlay-notification
      '';
      setVolume = arg:
        pkgs.writeShellScript "set-volume" ''
          pamixer ${arg}
          VOLUME=$(pamixer --get-volume)
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Volume" -c overlay -h int:value:$VOLUME -R /tmp/overlay-notification
        '';
      setMicVolume = arg:
        pkgs.writeShellScript "set-mic-volume" ''
          pamixer --default-source ${arg}
          VOLUME=$(pamixer --default-source --get-volume)
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Microphone" -c overlay -h int:value:$VOLUME -R /tmp/overlay-notification
        '';
      screenshot = withRegion:
        pkgs.writeShellScript "take-screenshot" ''
          mkdir -p $HOME/pictures/screenshots
          IMG_FILENAME="$HOME/pictures/screenshots/$(date).png"
          grim ${if withRegion then ''-g "$(slurp)"'' else ""} "$IMG_FILENAME"
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Screenshot taken" "$IMG_FILENAME" -i "$IMG_FILENAME" -t 2000
        '';
    in lib.mkOptionDefault {
      "XF86MonBrightnessUp" = "exec ${setLight} -A 5";
      "XF86MonBrightnessDown" = "exec ${setLight} -U 5";
      "Ctrl+Alt+Backspace" = "exit";
      "Print" = "exec ${screenshot false}";
      "Shift+Print" = "exec ${screenshot true}";
      "${mod}+w" = "kill";
      "${mod}+s" = "floating toggle";
      "${mod}+a" = "focus parent";
      "${mod}+c" = "exec playerctl play-pause";
      "${mod}+b" = "exec firefox";
      "${mod}+e" = "exec emacsclient -c";
      "${mod}+n" = "exec caja";
      "${mod}+p" = "exec wofi --show drun -I -a -M fuzzy";
      "${mod}+apostrophe" = "exec clipman pick -t wofi";
      "${mod}+bracketright" = "workspace next";
      "${mod}+bracketleft" = "workspace prev";
      "${mod}+shift+bracketright" = "move container to workspace next";
      "${mod}+shift+bracketleft" = "move container to workspace prev";
      "XF86AudioRaiseVolume" = "exec ${setVolume "-i 2"}";
      "XF86AudioLowerVolume" = "exec ${setVolume "-d 2"}";
      "XF86AudioMute" = "exec pamixer -t";
      "XF86AudioPlay" = "exec playerctl play-pause";
      "XF86AudioNext" = "exec playerctl next";
      "XF86AudioPrev" = "exec playerctl previous";
      "Shift+XF86AudioRaiseVolume" = "exec ${setMicVolume "-i 5"}";
      "Shift+XF86AudioLowerVolume" = "exec ${setMicVolume "-d 5"}";
      "XF86AudioMicMute" = "exec pamixer --default-source -t";
    };
    config.window = {
      border = 3;
      titlebar = true;
    };
    config.input."1133:50475:moused_virtual_device" = {
      scroll_method = "on_button_down";
      scroll_button = "button8";
      scroll_factor = "0.25";
      natural_scroll = "enabled";
    };
    config.input."1149:4128:Kensington_Expert_Mouse" = {
      natural_scroll = "enabled";
      scroll_method = "on_button_down";
      scroll_button = "button8";
      scroll_factor = "0.1";
    };
    config.input."type:touchpad" = {
      natural_scroll = "enabled";
      middle_emulation = "enabled";
      scroll_method = "two_finger";
      click_method = "clickfinger";
      scroll_factor = "0.25";
    };
    config.input."type:keyboard" = {
      xkb_layout = "us";
      # xkb_variant = "altgr-intl";
      # xkb_options = "nodeadkeys";
      repeat_delay = "250";
      repeat_rate = "20";
    };
    config.startup = [
      {
        command = "wal -n -R";
      }
      # { command = "systemctl --user start rclone-pcloud"; }
      {
        command =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &";
      }
      # Use clipman as a clipboard manager.
      {
        command =
          "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch clipman store";
      }
      # Enable noise-suppressed microphone output for built-in mic.
      # {
      #   command =
      #     "${pkgs.noisetorch}/bin/noisetorch -i alsa_input.pci-0000_00_1f.3.analog-stereo -t 95";
      # }
    ];
    config.fonts = {
      names = [ "sans" ];
      size = 8.0;
    };
    # config.bars = [ ];
    config.bars =
      [{ command = "${config.programs.waybar.package}/bin/waybar"; }];
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
      seat seat xcursor_theme ${config.home.pointerCursor.name} ${
        builtins.toString config.home.pointerCursor.size
      }
      include "$HOME/.cache/wal/colors-sway"
      titlebar_border_thickness 0
      client.unfocused $color7 $color7 $color7 $color2 $color7
      client.focused_inactive $color7 $color7 $color7 $color2 $color7
      client.focused $color3 $color3 $color3 $color4 $color3
      for_window [app_id="firefox"] inhibit_idle fullscreen
      for_window [app_id="firefox" title="^Picture-in-Picture$"] floating enable, sticky enable, move position center, resize set width 704 height 396
      for_window [app_id="pavucontrol"] floating enable, move position center
      for_window [title="Sharing\s+Indicator$"] floating enable, sticky enable, move position top
    '';
  };

}
