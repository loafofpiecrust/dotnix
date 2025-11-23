{ config, lib, pkgs, inputs, ... }:

{
  # imports = [ inputs.hyprland.nixosModules.default ];
  # programs.hyprland = {
  #   enable = false;
  #   # package = pkgs.unstable.hyprland;
  #   # portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
  #   withUWSM = true;
  #   # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  #   # portalPackage =
  #   #   inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  # };
  # programs.uwsm.enable = false;
  environment.systemPackages = with pkgs; [
    file-roller # provides all archive formats
    p7zip
    pavucontrol
    xdg-utils
    glib
    ddcutil

    # desktop environment
    # gnome3.gtk
    polkit_gnome
    # rofi-menugen
    #wpgtk
    gsettings-desktop-schemas
    # farge # color picker
    # gcolor3

    # gtk themes
    # arc-theme
    # paper-icon-theme
    bibata-cursors

    # system tools
    libnotify
    # xdg-desktop-portal
    imagemagick
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    overpass
    inter
    noto-fonts
    noto-fonts-cjk-sans
    # noto-fonts-emoji
    noto-fonts-extra
    google-fonts
    merriweather
    liberation_ttf
    ubuntu_font_family
    # migu
    # dejavu_fonts

    # Multilingual and IPA fonts
    charis-sil
    doulos-sil
    andika

    # symbols
    # symbola
    emacs-all-the-icons-fonts
    font-awesome

    # programming fonts
    fira-code
    ibm-plex
    jetbrains-mono
    source-code-pro
    mononoki
    cascadia-code
    hack-font

    # Add user fonts to ~/.local/share/fonts
  ];

  fonts.fontconfig = {
    defaultFonts = {
      monospace = [
        "Hack Nerd Font" # Main preference, changes often.
        "Source Code Pro" # Provides almost all of the IPA symbols.
        "Noto Sans Mono CJK SC"
        "Noto Emoji"
        # "Material Design Icons"
      ];
      sansSerif = [
        "Overpass"
        # "Overpass Nerd Font Propo"
        "Noto Sans"
        "FreeSans"
        # "Material Design Icons"
      ];
      serif = [ "Merriweather" "Liberation Serif" ];
      # emoji = [ "Noto Color Emoji" ];
    };
    # hinting.style = "slight";
    # hinting.enable = false;
  };

  nixpkgs.overlays = [
    (self: super: {
      # Latest has some fixes I need!! In particular, a fix for OrcaSlicer dropdowns.
      # hyprland = super.unstable.hyprland;
      # Add extra dependencies for ranger to have improved file previews.
      ranger-plus = super.ranger.overrideAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs
          ++ (with super; [ ueberzugpp mediainfo poppler_utils bat ]);
      });

      xfce.xfburn = super.xfce.xfburn.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ (with super; [
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
        ]);
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
      # polybar = super.polybar.override { pulseSupport = true; };
      # Remove google tracking from chromium.
      # chromium = super.ungoogled-chromium.override {
      #   enableWideVine = true;
      #   proprietaryCodecs = true;
      # };

      # swhkd = pkgs.rustPlatform.buildRustPackage rec {
      #   pname = "swhkd";
      #   version = "1.3.0";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "waycrate";
      #     repo = pname;
      #     rev = "3b19fc33b32efde88311579152a1078a8004397c";
      #     sha256 = "245Y3UicW33hrQ6Mtf07I9vsWSpuijIEoEhxIKtjVQE=";
      #   };
      #   cargoLock = { lockFile = "${src}/Cargo.lock"; };
      #   nativeBuildInputs = with pkgs; [ pkg-config makeWrapper ];
      #   buildInputs = with pkgs; [ gnumake polkit ];
      #   postInstall = ''
      #     mkdir -p $out/share/polkit-1/actions
      #     ./scripts/build-polkit-policy.sh --policy-path=com.github.swhkd.pkexec.policy --swhkd-path=$out/bin/swhkd
      #     install -Dm 644 ./com.github.swhkd.pkexec.policy -t $out/share/polkit-1/actions
      #   '';
      #   postFixup = ''
      #     wrapProgram $out/bin/swhkd --prefix PATH : ${
      #       lib.makeBinPath [ pkgs.polkit ]
      #     }
      #     wrapProgram $out/bin/swhks --prefix PATH : ${
      #       lib.makeBinPath [ pkgs.polkit ]
      #     }
      #   '';
      #   doCheck = false;
      # };

      whitesur-gtk-theme = super.whitesur-gtk-theme.override {
        themeVariants = [ "default" "pink" "orange" ];
      };
      whitesur-icon-theme = super.whitesur-icon-theme.override {
        themeVariants = [ "default" "pink" "orange" ];
      };
    })
  ];

  # Run swhkd system daemon to manage keybindings across all environments!
  # systemd.services.swhkd = {
  #   # Launches ASAP
  #   wantedBy = [ "default.target" ];
  #   serviceConfig.ExecStart = "${pkgs.swhkd}/bin/swhkd";
  #   serviceConfig.Type = "forking";
  # };

  programs.xwayland.enable = true;
  # Configure sway if I happen to want it in my setup.
  programs.sway = {
    package = pkgs.unstable.swayfx;
    # package = pkgs.unstable.sway;
    # enable = true;
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
    ];
    extraSessionCommands = ''
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

  environment.sessionVariables = {
    XDG_DATA_DIRS = with pkgs; [
      "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
      "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    ];
  };

  environment.pathsToLink = [ "/share" ];

  # Provide default settings for any X11 sessions.
  services.xserver = {
    enable = lib.mkDefault true;
    xkb.layout = "us";
    xkb.options = "compose:ralt, terminate:ctrl_alt_bksp";
    enableCtrlAltBackspace = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 30; # ms between key repeats
    # I don't use caps lock enough, swap it with escape!
  };

  services.libinput = {
    enable = true;
    touchpad = {
      scrollMethod = "twofinger";
      naturalScrolling = true;
      tapping = false;
      clickMethod = "clickfinger";
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
    xdg-desktop-portal-gtk
    xdg-desktop-portal-xapp
  ];
  xdg.portal.wlr = { enable = true; };
  # xdg.portal.xdgOpenUsePortal = true;
  # xdg.portal.config = {
  #   common = {
  #     default = [ "wlr" "gtk" ];
  #     "org.freedesktop.impl.portal.Settings" = [ "xapp" "gtk" ];
  #   };
  # };

  # Enable full OpenGL support.
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  nixpkgs.config.chromium.enableWideVine = true;
  nixpkgs.config.chromium.proprietaryCodecs = true;
  nixpkgs.config.ungoogled-chromium.enableWideVine = true;
  nixpkgs.config.ungoogled-chromium.proprietaryCodecs = true;
  hardware.graphics = {
    enable = true;
    # driSupport = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };

  # Support pinentry-gnome3 on non-Gnome DEs.
  services.dbus.packages = [ pkgs.gcr ];

  # Send media control events to the most recently active media.
  systemd.user.services.playerctld = {
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${pkgs.playerctl}/bin/playerctld daemon";
    serviceConfig.Type = "forking";
  };

  security.polkit.enable = true;
}
