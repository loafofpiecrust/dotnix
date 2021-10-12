{ config, lib, pkgs, inputs, ... }: {
  home.packages = with pkgs; [ wpgtk ];

  wayland.windowManager.sway = {
    enable = true;
    # config.menu = "${pkgs.sirula}/bin/sirula";
    config.output = {
      # Framework Laptop screen
      "Unknown 0x095F 0x00000000" = {
        mode = "2256x1504@60Hz";
        scale = "1.35";
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
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Volume" -c overlay -h int:value:$VOLUME -R /tmp/overlay-notification -i ${pkgs.numix-icon-theme}/share/icons/Numix/64/devices/audio-headphones.svg
        '';
      screenshot = withRegion:
        pkgs.writeShellScript "take-screenshot" ''
          IMG_FILENAME="$HOME/Pictures/screenshots/$(date).png"
          ${pkgs.grim}/bin/grim ${
            if withRegion then "-g $(${pkgs.slurp}/bin/slurp)" else ""
          } "$IMG_FILENAME"
          ${pkgs.notify-send-sh}/bin/notify-send.sh "Screenshot taken" "$IMG_FILENAME" -i "$IMG_FILENAME" -t 2000
        '';
    in lib.mkOptionDefault {
      "XF86MonBrightnessUp" = "exec ${setLight "-A 5"}";
      "XF86MonBrightnessDown" = "exec ${setLight "-U 5"}";
      "Ctrl+Alt+Backspace" = "exit";
      "Print" = "exec ${screenshot false}";
      "Shift+Print" = "exec ${screenshot true}";
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
      scroll_factor = "0.25";
    };
    config.input."type:keyboard" = {
      xkb_options = "caps:swapescape";
      repeat_delay = "250";
      repeat_rate = "20";
    };
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
    config.bars =
      [{ command = "${config.programs.waybar.package}/bin/waybar"; }];
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
        icon-size = 20;
        spacing = 8;
      };
    }];
    # style = ''
    #   * {
    #     font-family: Overpass;
    #   }
    # '';
  };

  programs.mako = {
    enable = true;
    font = "monospace 11";
    extraConfig = ''
      default-timmeout=4000

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
}
