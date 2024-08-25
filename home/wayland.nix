{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    swhkd
    wpgtk
    pywal
    pamixer
    swww
    clipman
    rofi-wayland
    wofi
    pamixer
    brightnessctl
    playerctl
    light
    foot
    grim
    slurp
    wdisplays
    wlr-randr
  ];

  programs.pywal.enable = true;

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
            scale = 1.333333;
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
              criteria = "Acer Technologies XV272U 0x1210BFCC";
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
        format = "SPKR {icon} {format_source}";
        format-headphone = "HDPN {icon} {format_source}";
        format-muted = "MUTE {icon} {format_source}";
        format-source = "MIC {volume}%";
        format-source-muted = "";
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
          <big>{:%B %Y}</big>
          <tt>{calendar}</tt>
        '';
        format = "{:%a, %m/%d/%Y  %I:%M %p}";
        format-alt = "{:%Y-%m-%d}";
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
        design-capacity = false;
        full-at = 80;
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
        # interface = "wlan0";
        tooltip-format = ''
          {essid}
          {ipaddr}'';
        # format-wifi = " {bandwidthDownBits}";
        format-wifi = "WIFI {bandwidthDownBits}";
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

  services.mako = {
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
    latitude = 37.820248;
    longitude = -122.284792;
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

  # Change color theme to light or dark based on time of day.
  xdg.configFile."gammastep/hooks/daynight-desktop" = {
    executable = true;
    text = let
      theme = import ./themes/catppuccin.nix;
      lightTheme = builtins.toFile "light.json" (builtins.toJSON theme.light);
      darkTheme = builtins.toFile "dark.json" (builtins.toJSON theme.dark);
    in ''
      #!/bin/sh
      PATH=${pkgs.pywal}/bin:${pkgs.glib}/bin:${config.programs.emacs.package}/bin:$PATH
      if [ "$1" = period-changed ]; then
        case $3 in
          daytime)
            wal -n -f ${lightTheme} &> /dev/null
            gsettings set org.gnome.desktop.interface color-scheme prefer-light
            emacsclient --eval '(load-theme +snead/theme-day t)';;
          night)
            wal -n -f ${darkTheme} &> /dev/null
            gsettings set org.gnome.desktop.interface color-scheme prefer-dark
            emacsclient --eval '(load-theme +snead/theme-night t)';;
          esac
      fi
    '';
  };

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
  systemd.user.services.dynamic-wallpaper = let
    dynamicBgRepo = pkgs.fetchgit {
      url = "https://github.com/saint-13/Linux_Dynamic_Wallpapers";
      rev = "8904f832affb667c2926061d8e52b9131687451b";
      # Avoid massive clone time by only fetching the wallpaper I use.
      sparseCheckout = [ "Dynamic_Wallpapers/Mojave" ];
      sha256 = "VW1xOSLtal6VGP7JHv8NKdu7YTXeAHRrwZhnJy+T9bQ=";
    };
    dynamicBg = index:
      "${dynamicBgRepo}/Dynamic_Wallpapers/Mojave/mojave_dynamic_${index}.jpeg";
  in {
    Install.WantedBy = [ "swww.service" ];
    Unit.PartOf = [ "swww.service" ];
    Service.Type = "oneshot";
    Service.ExecStart = let
      gs = config.services.gammastep;
      ll = "${builtins.toString gs.latitude},${builtins.toString gs.longitude}";
      script = pkgs.writeShellApplication {
        name = "dynamic-wallpaper";
        # SUN_HOUR=$(sundazel -l ${ll} | cut -d ':' -f 1 | xargs)
        text = ''
          SUN_HOUR=$(date +%H)
          SUN_NUM=$((SUN_HOUR * 16 / 24))
          SUN_HOUR_OFFSET=$(((16 + (SUN_NUM - 4)) % 16 + 1))
          swww img ${dynamicBg "$SUN_HOUR_OFFSET"} --transition-step 1
        '';
        runtimeInputs = with pkgs; [ swww wcslib coreutils-full findutils ];
      };
    in "${script}/bin/dynamic-wallpaper";
  };

  # Update the dynamic wallpaper hourly.
  systemd.user.timers.dynamic-wallpaper = {
    Install.WantedBy = [ "timers.target" ];
    Unit.PartOf = [ "swww.service" ];
    Timer = {
      Unit = "dynamic-wallpaper.service";
      OnStartupSec = "1s";
      OnCalendar = "*/30 * * * *";
    };
  };

  services.swayidle = let randr = "${pkgs.wlr-randr}/bin/wlr-randr";
  in {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 240;
        command = "${pkgs.sway} output '*' dpms off";
      }
      {
        timeout = 360;
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock";
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
    Service.Type = "normal";
    Service.ExecStart = let
      script = pkgs.writeShellApplication {
        name = "keyd-application-mapper";
        text = "keyd-application-mapper";
        runtimeInputs = with pkgs; [ keyd sway ];
      };
    in "${script}/bin/keyd-application-mapper";
  };
  xdg.configFile."keyd/app.conf".source = ../keyboard/apps.conf;

  programs.swaylock = {
    enable = true;

  };
}
