{ config, lib, pkgs, inputs, ... }: {
  home.packages = with pkgs; [ wpgtk pamixer ];

  wayland.windowManager.sway = {
    enable = true;
    # config.menu = "${pkgs.sirula}/bin/sirula";
    config.output = {
      # Framework Laptop screen
      "Unknown 0x095F 0x00000000" = {
        mode = "2256x1504@60Hz";
        # Use a scale that'll frequently give me whole numbers.
        # 4 => 5; 8 => 10; 12 => 15; 16 => 20
        scale = "1.25";
      };
    };
    config.gaps = {
      outer = 0;
      inner = 10;
    };
    config.modifier = "Mod4";
    config.terminal = "${pkgs.foot}/bin/foot";
    config.keybindings = let
      mod = config.wayland.windowManager.sway.config.modifier;
      brightness = "${pkgs.brightnessctl}/bin/brightnessctl";
      light = "${pkgs.light}/bin/light";
      pamixer = "${pkgs.pamixer}/bin/pamixer";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      setLight = pkgs.writeShellScript "set-light" ''
        ${light} $@
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
      "XF86MonBrightnessUp" = "exec ${setLight} -A 5";
      "XF86MonBrightnessDown" = "exec ${setLight} -U 5";
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
      "${mod}+n" = "exec caja";
      "${mod}+d" = "exec ${pkgs.rofi-wayland}/bin/rofi -show drun";
      "${mod}+bracketright" = "workspace next";
      "${mod}+bracketleft" = "workspace prev";
      "${mod}+shift+bracketright" = "move container to workspace next";
      "${mod}+shift+bracketleft" = "move container to workspace prev";
      "XF86AudioRaiseVolume" = "exec ${setVolume "-i 5"}";
      "XF86AudioLowerVolume" = "exec ${setVolume "-d 5"}";
      "XF86AudioMute" = "exec ${pamixer} -t";
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
      modules-left = [ # "custom/power"
        "sway/workspaces"
      ];
      modules-right = [
        # "custom/player"
        "tray"
        # "custom/wallpaper"
        "idle_inhibitor"
        # "custom/vpn"
        "network"
        "cpu"
        "memory"
        "pulseaudio"
        "battery"
        "clock"
      ];
      pulseaudio = {
        scroll-step = 1;
        smooth-scrolling-threshold = 2;
        format = " {icon} {format_source}";
        format-headphone = " {icon} {format_source}";
        format-muted = " {icon} {format_source}";
        format-source = "";
        format-source-muted = "";
        format-icons.default = [
          "▒▒▒▒▒▒▒▒▒▒"
          "█▒▒▒▒▒▒▒▒▒"
          "██▒▒▒▒▒▒▒▒"
          "███▒▒▒▒▒▒▒"
          "████▒▒▒▒▒▒"
          "█████▒▒▒▒▒"
          "██████▒▒▒▒"
          "███████▒▒▒"
          "████████▒▒"
          "█████████▒"
          "██████████"
        ];
        on-click = "${pkgs.pamixer}/bin/pamixer -t";
        on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      "sway/mode".format = ''<span style="italic">{}</span>'';
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          # "activated" = "";
          # "deactivated" = "";
        };
        tooltip = false;
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      clock = {
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt>{calendar}</tt>
        '';
        format = " {:%a %I:%M %p}";
        format-alt = " {:%Y-%m-%d}";
      };
      cpu = {
        format = "CPU {usage}%";
        tooltip = false;
      };
      memory = { format = "MEM {}%"; };
      backlight = {
        format = "{icon} {percent}%";
        # format-icons = [ "" "" ];
      };
      battery = {
        states.warning = 30;
        states.critical = 10;
        format = "{icon}";
        format-charging = "{icon}";
        format-plugged = "{icon}";

        format-icons = [
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
        ];
      };

      network = {
        interface = "wlan0";
        tooltip-format = ''
          {essid}
          {ipaddr}'';
        format-wifi = " {bandwidthDownBits}";
        # format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        # format-linked = " No IP";
        # format-disconnected = "";
        tooltip = true;
      };

      "custom/vpn" = {
        format = "{icon} {}";
        format-icons = {
          # connected = "🔐";
          # none = "🔓";
        };

        escape = true;
        interval = 5;
        return-type = "json";
      };
    }];
    style = ./waybar.css;
  };

  programs.mako = {
    enable = true;
    font = "monospace 11";
    extraConfig = ''
      default-timeout=4000

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
