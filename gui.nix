{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome3.file-roller # provides all archive formats
    alacritty
    pavucontrol
    ffmpeg

    # desktop environment
    # gnome3.gtk
    notify-send-sh
    polkit_gnome
    picom # compositor
    # polybar
    dunst # notifications
    # rofi # MENUS!
    # rofi-menugen
    feh # wallpapers
    wpgtk
    # caffeine-ng # prevent screen from sleeping sometimes
    gsettings-desktop-schemas
    # farge # color picker
    scrot
    xorg.xmodmap
    stalonetray
    gcolor3

    # gtk themes
    # arc-theme
    # paper-icon-theme
    bibata-cursors

    # apps I want everywhere
    # chromium
    # unstable.firefox # primary browser
    tridactyl-native

    # system tools
    libnotify
    xdg-desktop-portal
    imagemagick
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    google-fonts
    ubuntu_font_family
    migu
    dejavu_fonts

    # Multilingual and IPA fonts
    charis-sil
    doulos-sil
    andika

    # symbols
    material-design-icons
    symbola
    emacs-all-the-icons-fonts

    # programming fonts
    fira-code
    ibm-plex
    jetbrains-mono
    source-code-pro
    mononoki
    cascadia-code

    # Add user fonts to ~/.local/share/fonts
  ];

  fonts.fontconfig = {
    defaultFonts = {
      monospace = [
        "JetBrains Mono" # Main preference, changes often.
        "Source Code Pro" # Provides almost all of the IPA symbols.
        "Noto Sans Mono CJK SC"
        "Noto Emoji"
        "Material Design Icons"
      ];
      sansSerif = [ "Overpass" "Noto Sans" "FreeSans" "Material Design Icons" ];
      serif = [ "Merriweather" "Liberation Serif" ];
    };
  };

  nixpkgs.overlays = [
    (self: super: {
      # Patch picom to support rounded corners in any X11 window manager.
      picom = super.picom.overrideAttrs (old: {
        src = builtins.fetchurl {
          url =
            "https://github.com/ibhagwan/picom/archive/68c8f1b5729dfd3c0259b3bbb225193c9ecdb526.tar.gz";
          sha256 = "07g8b62s0mxx4599lb46nkzfxjwp2cv2g0f2n1qrxb7cc80yj1nb";
        };
      });
      # Patch rofi to support wayland.
      rofi-wayland = super.rofi.overrideAttrs (old: {
        src = builtins.fetchurl {
          url =
            "https://github.com/lbonn/rofi/archive/a97ba40bc7aca7e375c500d574cac930a0b3473d.tar.gz";
          sha256 = "13v4l5hw14i5nh26lh4hr6jckpba6pyyvx5nydn2h1vkgs0lz4v4";
        };
      });
      # Patch libnotify to support replacing existing notifications.
      # libnotify = super.libnotify.overrideAttrs (old: {
      #   src = builtins.fetchGit {
      #     url = "https://gitlab.gnome.org/matthias.sweertvaegher/libnotify.git";
      #     ref = "replace";
      #     rev = "190576778ceec9d30f516bcad83846de5c1a6306";
      #   };
      # });
      # Build notify-send.sh, a libnotify alternative supporting more options.
      notify-send-sh = self.stdenv.mkDerivation {
        pname = "notify-send.sh";
        version = "1.2";
        src = builtins.fetchGit {
          url = "https://github.com/vlevit/notify-send.sh";
          ref = "master";
          rev = "684a754daafdbc3d4fdf815989104208d2bdac6c";
        };
        propagatedBuildInputs = with self; [ bash glib ];
        installPhase = ''
          mkdir -p $out/bin
          cp *.sh $out/bin/
        '';
      };
      # Support pulseaudio in bar programs.
      # TODO Maybe remove this now that I use pipewire? Alsa should be fine.
      polybar = super.polybar.override { pulseSupport = true; };
      waybar = super.waybar.override { pulseSupport = true; };
      # Remove google tracking from chromium.
      chromium = super.ungoogled-chromium;
    })
  ];

  # Configure sway if I happen to want it in my setup.
  programs.sway = {
    extraPackages = with pkgs; [
      swaylock
      swayidle
      xwayland
      mako
      kanshi
      qt5.qtwayland
      grim
      wl-clipboard
      # wf-recorder
      # firefox-wayland
    ];
    extraSessionCommands = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export MOZ_ENABLE_WAYLAND=1
      export MOZ_DBUS_REMOTE=1
      export GDK_BACKEND=wayland
    '';
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
  };

  # Provide default settings for any X11 sessions.
  services.xserver = {
    enable = true;
    layout = "us";
    enableCtrlAltBackspace = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 30; # ms between key repeats
    # I don't use caps lock enough, swap it with escape!
    xkbOptions = "caps:swapescape, compose:ralt, terminate:ctrl_alt_bksp";

    # Only applies in X sessions, not wayland.
    libinput = {
      enable = true;
      touchpad = {
        scrollMethod = "twofinger";
        naturalScrolling = true;
        tapping = false;
        clickMethod = "clickfinger";
      };
    };
  };

  # I type in other languages often enough.
  i18n.inputMethod = {
    enabled = null;
    # ibus.engines = with pkgs.ibus-engines; [
    #   libpinyin
    #   anthy
    #   table
    #   table-others
    # ];
  };

  # Give Firefox precise touchpad scrolling and wayland support.
  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Enable better XDG integration.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
  xdg.portal.gtkUsePortal = true;
}
