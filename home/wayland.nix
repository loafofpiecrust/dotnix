{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    wpgtk
    pywal
    pamixer
    unstable.swww
    clipman
    rofi-wayland
    pamixer
    brightnessctl
    playerctl
    light
    foot
    grim
    slurp
  ];

  programs.pywal.enable = true;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
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
    '';
  };

  # Enables power status notifications when using Sway.
  services.poweralertd.enable = true;
  systemd.user.services.poweralertd = {
    Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    # TODO I might not need to change Unit.PartOf
    Unit.PartOf = lib.mkForce [ "graphical-session.target" ];
  };

  services.udiskie = { enable = true; };
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
        runtimeInputs = with pkgs; [ unstable.swww ];
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
      setWallpaper = file: ''
        ln -sf ${file} ~/.wallpaper
        swww img ${file} -t simple --transition-step 1
      '';
      script = pkgs.writeShellApplication {
        name = "dynamic-wallpaper";
        # SUN_HOUR=$(sundazel -l ${ll} | cut -d ':' -f 1 | xargs)
        text = ''
          SUN_HOUR=$(date +%H)
          SUN_HOUR_OFFSET=$((SUN_HOUR * 16 / 24 + 1))
          swww img ${dynamicBg "$SUN_HOUR_OFFSET"} --transition-step 1
        '';
        runtimeInputs = with pkgs; [
          unstable.swww
          wcslib
          coreutils-full
          findutils
        ];
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
      OnCalendar = "hourly";
    };
  };
}
