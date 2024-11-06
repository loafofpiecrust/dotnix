{ config, lib, pkgs, systemConfig, inputs, ... }:
let
  theme = import ./themes/catppuccin.nix;
  dropHash = x: builtins.substring 1 10 x;
in {
  home.packages = with pkgs; [
    inputs.iwmenu.packages.${pkgs.system}.default
    sunwait
    mako
    swhkd
    wpgtk
    pywal
    pamixer
    swww
    clipman
    rofi-wayland
    rofi-rbw-wayland
    nwg-wrapper
    swaynotificationcenter
    wofi
    pamixer
    brightnessctl
    playerctl
    light
    grim
    slurp
    wdisplays
    wev
    notify-send-sh
    wl-clipboard
    # (pkgs.writeShellScriptBin "set-backlight" ''
    #   light $@
    #   LIGHT=$(light -G)
    #   LIGHT=$(printf "%.0f" $LIGHT)
    #   ${pkgs.notify-send-sh}/bin/notify-send.sh "Brightness" -c overlay -h int:value:$LIGHT -R /tmp/overlay-notification
    # '')
    (pkgs.writeShellScriptBin "set-volume" ''
      pamixer $@
      VOLUME=$(pamixer --get-volume)
      notify-send.sh "Volume" -c overlay -h int:value:$VOLUME -R /tmp/overlay-notification
    '')
    (pkgs.writeShellScriptBin "set-mic-volume" ''
      pamixer --default-source $@
      VOLUME=$(pamixer --default-source --get-volume)
      notify-send.sh "Microphone" -c overlay -h int:value:$VOLUME -R /tmp/overlay-notification
    '')
    (pkgs.writeShellScriptBin "take-screenshot" ''
      mkdir -p $HOME/pictures/screenshots
      IMG_FILENAME="$HOME/pictures/screenshots/$(date).png"
      grim "$IMG_FILENAME"
      notify-send.sh "Screenshot taken" "$IMG_FILENAME" -i "$IMG_FILENAME" -t 2000
    '')
    (pkgs.writeShellScriptBin "take-screenshot-region" ''
      mkdir -p $HOME/pictures/screenshots
      IMG_FILENAME="$HOME/pictures/screenshots/$(date).png"
      grim -g "$(slurp)" "$IMG_FILENAME"
      notify-send.sh "Screenshot taken" "$IMG_FILENAME" -i "$IMG_FILENAME" -t 2000
    '')
    (pkgs.writeShellScriptBin "update-shell-colors" ''
      cat ~/.cache/wal/base16-sequences | tee /dev/pts/[0-9]* > /dev/null
    '')
  ];

  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = let
      laptop-screen = {
        criteria = "eDP-1";
        mode = "2256x1504@60Hz";
        position = "0,300";
      };
    in [
      {
        profile.name = "undocked";
        profile.outputs = [
          (laptop-screen // {
            scale = 1.3333;
            status = "enable";
          })
        ];
        profile.exec =
          [ "${pkgs.systemd}/bin/systemctl --user restart dynamic-wallpaper" ];
      }
      {
        profile = {
          name = "docked";
          outputs = [
            (laptop-screen // {
              scale = 1.6;
              status = "enable";
            })
            {
              # criteria = "Acer Technologies XV272U 0x1210BFCC";
              criteria = "DP-4";
              position = "1410,0";
            }
          ];
          exec = [
            "${pkgs.systemd}/bin/systemctl --user restart dynamic-wallpaper"
          ];
        };
      }
      {
        profile = {
          name = "double-docked";
          outputs = [
            (laptop-screen // {
              scale = 1.6;
              status = "disable";
            })
            {
              criteria = "Acer Technologies XV272U 0x1210BFCC";
              position = "1440,500";
            }
            {
              criteria = "Dell Inc. DELL U2717D";
              position = "0,0";
              transform = "270";
            }
          ];
          exec = [
            "${pkgs.systemd}/bin/systemctl --user restart dynamic-wallpaper"
          ];
        };
      }
    ];
  };

  programs.waybar = {
    enable = true;
    # systemd.enable = true;
    settings = [{
      id = "1";
      ipc = true;
      position = "top";
      layer = "top";
      height = 30;
      modules-left = [ # "custom/power"
        "hyprland/workspaces"
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
        # format-source indicates microphone volume
        scroll-step = 0.5;
        # smooth-scrolling-threshold = 2;
        format = "󰕾 {volume}% {format_source}";
        format-headphone = "󰋋 {volume}% {format_source}";
        format-muted = "󰝟 {volume}% {format_source}";
        format-source = "󰍬 {volume}%";
        format-source-muted = "󰍭 MUT";
        format-icons.default = [
          "░░░░░░░░░░"
          "▌░░░░░░░░░"
          "█░░░░░░░░░"
          "█▌░░░░░░░░"
          "██░░░░░░░░"
          "██▌░░░░░░░"
          "███░░░░░░░"
          "███▌░░░░░░"
          "████░░░░░░"
          "████▌░░░░░"
          "█████░░░░░"
          "█████▌░░░░"
          "██████░░░░"
          "██████▌░░░"
          "███████░░░"
          "███████▌░░"
          "████████░░"
          "████████▌░"
          "█████████░"
          "█████████▌"
          "██████████"
        ];
        on-click = "${pkgs.pamixer}/bin/pamixer -t";
        on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      "sway/mode".format = ''<span style="italic">{}</span>'';
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          "activated" = "󰔫";
          "deactivated" = "󰔫";
        };
        tooltip = false;
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      clock = {
        tooltip-format = ''
          <tt>{calendar}</tt>
        '';
        format = "{:%a, %m/%d/%Y  %I:%M %p}";
        # format-alt = "{:%Y-%m-%d}";
        justify = "left";
        # on-scroll-up = "shift_up";
        # on-scroll-down = "shift_down";
        calendar = {
          mode = "month";
          format = {
            # months = "<span color='#ffead3'><b>{}</b></span>";
            # days = "<span color='#ecc6d9'><b>{}</b></span>";
            # weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            # weekdays = "<span color='#ffcc66'>{}</span>";
            # today = "<span color='${theme.light.colors.color4}'><b><u>{}</u></b></span>";
          };
        };
      };
      cpu = {
        format = "  {usage}%";
        tooltip = false;
      };
      memory = { format = "  {}%"; };
      backlight = {
        format = "{icon} {percent}%";
        # format-icons = [ "" "" ];
      };
      battery = {
        states.warning = 30;
        states.critical = 10;
        design-capacity = false;
        full-at = 80;
        format = "{icon}";
        format-charging = "{icon}";
        format-plugged = "{icon}";

        format-icons = [
          "󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰛞󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰛞󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋕󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰛞󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋕󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰛞󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋕󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰛞󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋕󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰛞󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋕󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰛞󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋕󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰛞󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋕󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰛞󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋕"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰛞"
          "󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑󰋑"
          # ""
          # ""
          # ""
          # ""
          # ""
          # ""
          # ""
          # ""
          # ""
          # ""
          # ""
        ];
      };

      network = {
        # interface = "wlan0";
        tooltip-format = ''
          {essid}
          {ipaddr}'';
        # format-wifi = " {bandwidthDownBits}";
        format-wifi = "󰖩 {bandwidthDownBits}";
        # format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        # format-linked = " No IP";
        format-disconnected = "OFFLINE";
        tooltip = true;
        on-click = "iwmenu -m fuzzel";
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
    style = config.lib.meta.mkMutableSymlink ./waybar.css;
  };

  # Link to the wal-generated mako config.
  xdg.configFile."wal/templates/mako.conf".source =
    config.lib.meta.mkMutableSymlink ./mako.conf;
  # FIXME figure out how to remove the absolute path from here.
  xdg.configFile."mako/config".source =
    config.lib.file.mkOutOfStoreSymlink "/home/snead/.cache/wal/mako.conf";
  services.mako = {
    enable = false;
    font = "monospace 11";
    backgroundColor = theme.dark.special.background;
    borderColor = theme.dark.colors.color4;
    borderRadius = 3;
    borderSize = 1;
    defaultTimeout = 4000;
    extraConfig = ''
      text-color=${theme.dark.special.foreground}
      progress-color=over ${theme.dark.colors.color4}

      [category=overlay]
      default-timeout=1000
      ignore-timeout=1
      history=0
      anchor=center
      layer=overlay
      text-color=${theme.dark.special.background}

      [anchor=center]
      max-visible=1

      [body~="Battery charging"]
      invisible=1

      [body~="Battery discharging"]
      invisible=1

      [body~="Battery pending charge"]
      invisible=1
    '';
  };

  # Enables power status notifications when using Sway.
  # services.poweralertd.enable = true;
  # systemd.user.services.poweralertd = {
  #   Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
  #   # TODO I might not need to change Unit.PartOf
  #   Unit.PartOf = lib.mkForce [ "graphical-session.target" ];
  # };

  services.udiskie = {
    enable = true;
    # Don't write access times to USB drives, it's just a waste of their lifespan.
    settings = { device_config = [{ options = [ "noatime" ]; }]; };
  };
  services.blueman-applet.enable = true;

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = systemConfig.location.latitude;
    longitude = systemConfig.location.longitude;
    temperature = {
      day = 5500;
      night = 3500;
    };
  };

  xdg.configFile."wal/templates/zsh-fsh.ini".source = ./themes/zsh-fsh.ini;
  xdg.configFile."wal/templates/base16-sequences".text =
    "]4;0;{color0}\\]4;1;{color8}\\]4;2;{color11}\\]4;3;{color10}\\]4;4;{color13}\\]4;5;{color14}\\]4;6;{color12}\\]4;7;{color5}\\]4;8;{color3}\\]4;9;{color8}\\]4;10;{color11}\\]4;11;{color10}\\]4;12;{color13}\\]4;13;{color14}\\]4;14;{color12}\\]4;15;{color7}\\]4;16;{color9}\\]4;17;{color15}\\]4;18;{color1}\\]4;19;{color2}\\]4;20;{color4}\\]4;21;{color6}\\]10;{foreground}\\]11;{background}\\]12;{cursor}\\]13;{foreground}\\]17;{foreground}\\]19;{background}\\]4;232;{background}\\]4;256;{foreground}\\]708;{background}\\";
  xdg.configFile."wal/templates/colors-waybar.css".text = ''
    @define-color foreground {foreground};
    @define-color background {background};
    @define-color cursor {cursor};

    @define-color color0 {color0};
    @define-color color1 {color1};
    @define-color color2 {color2};
    @define-color color3 {color3};
    @define-color color4 {color4};
    @define-color color5 {color5};
    @define-color color6 {color6};
    @define-color color7 {color7};
    @define-color color8 {color8};
    @define-color color9 {color9};
    @define-color color10 {color10};
    @define-color color11 {color11};
    @define-color color12 {color12};
    @define-color color13 {color13};
    @define-color color14 {color14};
    @define-color color15 {color15};
  '';
  xdg.configFile."wal/templates/fuzzel.ini".text = ''
    [colors]
    background={background.strip}ff
    text={foreground.strip}ff
    selection={color7.strip}ff
    selection-text={color1.strip}ff
    selection-match={background.strip}ff
    match={color6.strip}ff
    border={color10.strip}ff
  '';

  # Change color theme to light or dark based on time of day.
  # xdg.configFile."gammastep/hooks/daynight-desktop" = {
  #   executable = true;
  #   text = let
  #     lightTheme = builtins.toFile "light.json" (builtins.toJSON theme.light);
  #     darkTheme = builtins.toFile "dark.json" (builtins.toJSON theme.dark);
  #   in ''
  #     #!/usr/bin/env bash
  #     PATH=${pkgs.pywal}/bin:${pkgs.glib}/bin:${config.programs.emacs.package}/bin:${pkgs.coreutils}/bin:${pkgs.mako}/bin:$PATH
  #     if [ "$1" = period-changed ]; then
  #       case $3 in
  #         daytime)
  #           gsettings set org.gnome.desktop.interface color-scheme prefer-light
  #           wal -n -s -f ${lightTheme} &> /dev/null
  #           cat ~/.cache/wal/base16-sequences | tee /dev/pts/[0-9]* > /dev/null
  #           makoctl reload
  #           emacsclient --eval "(+snead/load-theme 'daytime)" || true;;
  #         night)
  #           gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  #           wal -n -s -f ${darkTheme} &> /dev/null
  #           cat ~/.cache/wal/base16-sequences | tee /dev/pts/[0-9]* > /dev/null
  #           makoctl reload
  #           emacsclient --eval "(+snead/load-theme 'night)" || true;;
  #       esac
  #     fi
  #   '';
  # };

  # Start wallpaper daemon with sway.
  systemd.user.services.swww = {
    Install.WantedBy = [ "graphical-session.target" ];
    Service.Type = "forking";
    Service.ExecStart = let
      script = pkgs.writeShellApplication {
        name = "swww-init";
        text = "swww init";
        runtimeInputs = with pkgs; [ swww ];
      };
    in "${script}/bin/swww-init";
  };

  # Set the wallpaper based on the angle of the sun where I live.
  systemd.user.services.dynamic-wallpaper = {
    # Install.WantedBy = [ "multi-user.target" ];
    # Unit.PartOf = [ "swww.service" ];
    Service.Type = "oneshot";
    Service.ExecStart = let
      script = pkgs.writeShellApplication {
        name = "dynamic-wallpaper";
        text = builtins.readFile ./scripts/dynamic-wallpaper.sh;
        runtimeInputs = with pkgs; [
          swww
          coreutils-full
          findutils
          sunwait
          pywal
          glib
          config.programs.emacs.package
          coreutils
          mako
        ];
      };
      lightTheme = builtins.toFile "light.json" (builtins.toJSON theme.light);
      darkTheme = builtins.toFile "dark.json" (builtins.toJSON theme.dark);
    in "${script}/bin/dynamic-wallpaper ${
      toString systemConfig.location.latitude
    }N ${
      toString (-systemConfig.location.longitude)
    }W '${systemConfig.lib.meta.dynamicBgRepo}/Dynamic_Wallpapers/Mojave/mojave_dynamic_' '${lightTheme}' '${darkTheme}'";
  };

  # Update the dynamic wallpaper hourly.
  systemd.user.timers.dynamic-wallpaper = {
    Install.WantedBy = [ "timers.target" ];
    Unit.PartOf = [ "swww.service" ];
    Timer = {
      Unit = "dynamic-wallpaper.service";
      OnStartupSec = "2s";
      OnCalendar = "*/15 * * * *";
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 240;
        command = "${pkgs.sway} output '*' dpms off";
      }
      {
        timeout = 360;
        command = "${config.programs.swaylock.package}/bin/swaylock -fF";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${config.programs.swaylock.package}/bin/swaylock -fF";
      }
      {
        event = "after-resume";
        command = "${pkgs.sway}/bin/swaymsg output '*' dpms on";
      }
    ];
    extraArgs = [ "idlehint" "360" ];
  };

  systemd.user.services.keyd-application-mapper = {
    Install.WantedBy = [ "graphical-session.target" ];
    Service.Type = "simple";
    Service.ExecStart = let
      script = pkgs.writeShellApplication {
        name = "keyd-application-mapper";
        text = "keyd-application-mapper";
        runtimeInputs = with pkgs; [ keyd sway ];
      };
    in "${script}/bin/keyd-application-mapper";
  };
  xdg.configFile."keyd/app.conf".source = ../keyboard/apps.conf;

  # Idle screen locker
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      # Use the current dynamic background.
      # image = "~/.wallpaper";
      # scaling = "fill";
      screenshots = true;
      effect-blur = "6x3";
      font = "sans";
      # font-size = 40;
      # Use theme colors for lock screen
      # TODO use wal template
      bs-hl-color = dropHash theme.light.colors.color6;
      key-hl-color = dropHash theme.light.colors.color5;
      layout-text-color = dropHash theme.light.special.foreground;
      ring-color = dropHash theme.light.colors.color7;
      ring-clear-color = dropHash theme.light.colors.color6;
      ring-ver-color = dropHash theme.light.colors.color13;
      ring-wrong-color = dropHash theme.light.colors.color14;
      text-color = dropHash theme.light.special.foreground;
      text-clear-color = dropHash theme.light.colors.color6;
      text-ver-color = dropHash theme.light.colors.color13;
      text-wrong-color = dropHash theme.light.colors.color14;
      inside-color = dropHash theme.light.special.background;
      inside-clear-color = dropHash theme.light.special.background;
      inside-ver-color = dropHash theme.light.special.background;
      inside-wrong-color = dropHash theme.light.special.background;
      separator-color = "00000000";
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
    };
  };

  programs.hyprlock = {
    enable = false;
    package = pkgs.unstable.hyprlock;
    extraConfig = ''
      general {
        disable_loading_bar = true
      }
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main.dpi-aware = false;
      main.font = "monospace:size=11";
      colors.alpha = 0.8;
      main.pad = "6x6";
    };
  };

  programs.fuzzel = {
    enable = true;
    package = pkgs.unstable.fuzzel;
    settings = {
      main = {
        include = toString (config.lib.meta.mkMutableSymlink ./fuzzel.ini);
        icon-theme = config.gtk.iconTheme.name;
      };
    };
  };
}
