{ config, lib, pkgs, systemConfig, inputs, ... }:
let
  theme = (import ./themes/dracula.nix) { colorizer = inputs.nix-colorizer; };
  dropHash = x: builtins.substring 1 10 x;
  generate-theme-files = (pkgs.writeShellApplication {
    name = "generate-theme-files";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      mustache-go
      mako
      config.programs.emacs.package
      config.wayland.windowManager.sway.package
      glib
    ];
    text = let
      addExtraVars = base:
        (base.colors // base.special // {
          commands = base.commands;
          # Add an extra set of the colors with no hash at the start.
          strip = (builtins.mapAttrs (k: v: builtins.substring 1 10 v)
            (base.colors // base.special));
        });
      lightTheme = builtins.toFile "light.json"
        (builtins.toJSON (addExtraVars theme.light));
      darkTheme =
        builtins.toFile "dark.json" (builtins.toJSON (addExtraVars theme.dark));
    in ''
      ${
        config.lib.meta.mkMutableSymlink ./scripts/generate-theme-files.sh
      } '${lightTheme}' '${darkTheme}' "$1"
    '';
  });
in {
  lib.meta.theme = theme;
  home.packages = with pkgs; [
    inputs.iwmenu.packages.${pkgs.system}.default
    inotify-tools
    sunwait
    mako
    wpgtk
    pamixer
    swww
    clipman
    rofi-wayland
    rofi-rbw-wayland
    bitwarden
    nwg-wrapper
    swaynotificationcenter
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
    hyprpicker
    generate-theme-files
    config.programs.swaylock.package
    dotool
    sway-audio-idle-inhibit
    zbar # scan QR codes
    wluma
    # (pkgs.writeShellScriptBin "set-backlight" ''
    #   light $@
    #   LIGHT=$(light -G)
    #   LIGHT=$(printf "%.0f" $LIGHT)
    #   ${pkgs.notify-send-sh}/bin/notify-send.sh "Brightness" -c overlay -h int:value:$LIGHT -R /tmp/overlay-notification
    # '')
    (pkgs.writeShellApplication {
      name = "generate-password";
      runtimeInputs = [ dotool rbw rofi-wayland ];
      text = builtins.readFile ./scripts/generate-password.sh;
    })
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
      cat ~/.cache/colors/sequences | tee /dev/pts/[0-9]* > /dev/null
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
            scale = 1.25;
            # Tried out text scaling instead but it has limited support...
            # scale = 1.0;
            status = "enable";
          })
        ];
        profile.exec = [ "${pkgs.systemd}/bin/systemctl --user restart swww" ];
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
              criteria = "Acer Technologies XV272U 0x1210BFCC";
              position = "1410,0";
              # mode = "2256x1440@143.999Hz";
            }
          ];
          exec = [ "${pkgs.systemd}/bin/systemctl --user restart swww" ];
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
              # mode = "2256x1440@143.999Hz";
            }
            {
              criteria = "Dell Inc. DELL U2717D";
              position = "0,0";
              transform = "270";
            }
          ];
          exec = [ "${pkgs.systemd}/bin/systemctl --user restart swww" ];
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
      modules-left = [ "custom/power" "hyprland/workspaces" "sway/workspaces" ];
      modules-right = [
        # "custom/player"
        "tray"
        # "custom/wallpaper"
        "custom/audio-idle-inhibitor"
        "idle_inhibitor"
        "custom/color-scheme"
        # "custom/vpn"
        "network"
        "cpu"
        "memory"
        "pulseaudio"
        "power-profiles-daemon"
        "battery"
        "clock"
      ];
      "custom/audio-idle-inhibitor" = {
        format = " {icon} ";
        exec = "sway-audio-idle-inhibit --dry-print-both-waybar";
        exec-if = "which sway-audio-idle-inhibit";
        return-type = "json";
        format-icons = {
          output = "";
          input = "";
          output-input = " ";
          none = "";
        };
      };
      "custom/power" = {
        format = "󰐥";
        on-click = "power-menu";
        tooltip = false;
      };
      "custom/color-scheme" = {
        format = "";
        on-click = "generate-theme-files toggle";
        tooltip = false;
      };
      power-profiles-daemon = {
        format = "{icon}";
        tooltip = true;
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };
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
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          "activated" = "󰈈";
          "deactivated" = "󰈉";
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
        full-at = 95;
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
          {essid} ({signalStrength}%)
          {ipaddr}'';
        # format-wifi = " {bandwidthDownBits}";
        format-wifi = "󰖩 {bandwidthDownBits}";
        # format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        # format-linked = " No IP";
        format-disconnected = "OFFLINE";
        tooltip = true;
        on-click = "iwmenu -m rofi";
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

  # Link to the generated mako config.
  xdg.configFile."mako/config".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.cache/colors/mako.conf";
  xdg.configFile."gtk-4.0/gtk-light.css".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.cache/colors/gtk4-light.css";

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

  # Automatically change screen color temperature throughout the day.
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

  xdg.configFile."colors/templates".source =
    config.lib.meta.mkMutableSymlink ./templates;

  xdg.configFile."wluma/config.toml".source =
    config.lib.meta.mkMutableSymlink ./wluma.toml;

  # systemd.user.services.wluma = {
  #   Install.WantedBy = [ "graphical-session.target" ];
  #   Unit = {
  #     Description =
  #       "Adjusting screen brightness based on screen contents and amount of ambient light";
  #     PartOf = [ "graphical-session.target" ];
  #     After = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.wluma}/bin/wluma";
  #     Restart = "always";
  #     EnvironmentFile = "-%E/wluma/service.conf";
  #     PrivateNetwork = true;
  #     PrivateMounts = false;
  #   };
  # };

  # Start wallpaper daemon with sway or hyprland.
  systemd.user.services.swww = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      After = [ "graphical-session.target" ];
      StartLimitIntervalSec = 200;
      StartLimitBurst = 5;
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 2;
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "swww-init";
          text = "swww-daemon";
          runtimeInputs = with pkgs; [ swww ];
        };
      in "${script}/bin/swww-init";
    };
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
          coreutils
          findutils
          sunwait
          coreutils
          generate-theme-files
        ];
      };
    in "${script}/bin/dynamic-wallpaper ${
      toString systemConfig.location.latitude
    }N ${
      toString (-systemConfig.location.longitude)
    }W '${systemConfig.lib.meta.dynamicBgRepo}/Dynamic_Wallpapers/Mojave/mojave_dynamic_'";
  };

  # Check for wallpaper updates every 15m.
  systemd.user.timers.dynamic-wallpaper = {
    Install.WantedBy = [ "timers.target" "post-resume.target" ];
    Unit.PartOf = [ "swww.service" ];
    Timer = {
      Unit = "dynamic-wallpaper.service";
      OnStartupSec = "2s";
      OnCalendar = "*:00,15,30,45:00";
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [{
      timeout = 300;
      command =
        "${systemConfig.programs.sway.package}/bin/swaymsg output '*' power off";
      resumeCommand =
        "${systemConfig.programs.sway.package}/bin/swaymsg output '*' power on";
    }
    # {
    #   timeout = 360;
    #   command = "${config.programs.swaylock.package}/bin/swaylock -fF";
    # }
      ];
    events = [{
      event = "before-sleep";
      command = "${config.programs.swaylock.package}/bin/swaylock -fF";
    }
    # Restarting kanshi after resume to make sure the screen configuration is
    # all set. Also fixes the bad font rendering issue!
    # {
    #   event = "after-resume";
    #   command = "${pkgs.systemd}/bin/systemctl --user restart kanshi";
    # }
      ];
    extraArgs = [ "idlehint" "420" ];
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
  xdg.configFile."keyd/app.conf".source =
    config.lib.meta.mkMutableSymlink ../keyboard/apps.conf;

  # Idle screen locker
  xdg.configFile."swaylock/config".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.cache/colors/swaylock.config";
  programs.swaylock = {
    enable = true;
    # package = pkgs.swaylock-effects;
    # settings = {
    #   # Use the current dynamic background.
    #   # image = "~/.wallpaper";
    #   # scaling = "fill";
    #   screenshots = true;
    #   effect-blur = "6x3";
    #   font = "sans";
    #   # font-size = 40;
    #   # Use theme colors for lock screen
    #   # TODO use wal template
    #   bs-hl-color = dropHash theme.light.colors.color6;
    #   key-hl-color = dropHash theme.light.colors.color5;
    #   layout-text-color = dropHash theme.light.special.foreground;
    #   ring-color = dropHash theme.light.colors.color7;
    #   ring-clear-color = dropHash theme.light.colors.color6;
    #   ring-ver-color = dropHash theme.light.colors.color13;
    #   ring-wrong-color = dropHash theme.light.colors.color14;
    #   text-color = dropHash theme.light.special.foreground;
    #   text-clear-color = dropHash theme.light.colors.color6;
    #   text-ver-color = dropHash theme.light.colors.color13;
    #   text-wrong-color = dropHash theme.light.colors.color14;
    #   inside-color = dropHash theme.light.special.background;
    #   inside-clear-color = dropHash theme.light.special.background;
    #   inside-ver-color = dropHash theme.light.special.background;
    #   inside-wrong-color = dropHash theme.light.special.background;
    #   separator-color = "00000000";
    #   line-color = "00000000";
    #   line-clear-color = "00000000";
    #   line-ver-color = "00000000";
    #   line-wrong-color = "00000000";
    # };
  };

  programs.foot = {
    enable = true;
    settings = {
      main.dpi-aware = false;
      main.font = "monospace:size=11";
      main.pad = "6x6";
      main.workers = 4;
      colors.alpha = 0.8;
      scrollback.lines = 3000;
      key-bindings = {
        scrollback-up-page = "Shift+Up";
        scrollback-down-page = "Shift+Down";
        search-start = "Control+f";
      };
    };
  };

  programs.fuzzel = {
    enable = false;
    package = pkgs.unstable.fuzzel;
    settings = {
      main = {
        include = toString (config.lib.meta.mkMutableSymlink ./fuzzel.ini);
        icon-theme = config.gtk.iconTheme.name;
      };
    };
  };

  # Automatically switch the power profile on plug and unplug if I'm using PPD
  systemd.user.services.auto-power-profile = {
    Install.WantedBy = [ "default.target" ];
    Service.Restart = "Always";
    Service.ExecStart = let
      script = pkgs.writeShellApplication {
        name = "auto-power-profile";
        text = builtins.readFile ./scripts/auto-power-profile.sh;
        runtimeInputs = with pkgs; [
          inotify-tools
          unstable.power-profiles-daemon
          coreutils
        ];
      };
    in "${script}/bin/auto-power-profile";
  };

  xdg.configFile."rofi/config.rasi".source =
    config.lib.meta.mkMutableSymlink ./rofi-config.rasi;
  xdg.configFile."rofi/theme.rasi".source =
    config.lib.meta.mkMutableSymlink ./rofi-theme.rasi;
  xdg.configFile."rofi-rbw.rc".source =
    config.lib.meta.mkMutableSymlink ./rofi-rbw.rc;
}
