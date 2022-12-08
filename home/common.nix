{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ./emacs.nix ];

  home.stateVersion = "21.05";
  home.sessionPath = [
    "${config.home.homeDirectory}/.config/emacs/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];

  xdg.userDirs = {
    enable = true;
    # Can we create just some? I never use ~/desktop
    createDirectories = false;
    documents = "$HOME/documents";
    download = "$HOME/downloads";
    music = "$HOME/music";
    pictures = "$HOME/pictures";
    templates = "$HOME/templates";
    videos = "$HOME/videos";
    desktop = "$HOME/desktop";
  };

  # xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink ./doom;
  #xdg.configFile."emacs".source = ./doom-emacs;
  xdg.configFile."fontconfig/fonts.conf".source = ./gui/fonts.conf;
  home.file.".sbclrc".source = ./lisp/.sbclrc;
  home.file.".aspell.en.pws".source = ./spell/.aspell.en.pws;
  home.file."bin/get-password" = {
    executable = true;
    text = let rbw = "${config.programs.rbw.package}/bin/rbw";
    in ''
      #!/bin/sh
      rbw unlocked || rbw login
      rbw unlocked || rbw unlock
      rbw get "$1" "$2"
    '';
  };

  home.packages = with pkgs; [ unstable.spotify gparted ];

  # GPG agent handles locked files and SSH keys.
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60 * 60;
    defaultCacheTtlSsh = 60 * 60;
    # pinentryFlavor = "gnome3";
    extraConfig = ''
      display :0
    '';
  };

  # Enable project-local environments based on flakes.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Make my shell fancy.
  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      battery.disabled = true;
    };
  };

  # Manage my passwords with Bitwarden + rbw.
  programs.rbw = {
    enable = true;
    package = pkgs.unstable.rbw;
    settings = {
      email = "taylor@snead.xyz";
      # Keep the vault open for 6 hours.
      lock_timeout = 60 * 60 * 6;
      pinentry = "gnome3";
    };
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    mimeApps.defaultApplications = let
      images = [ "eom.desktop" ];
      web = [ "firefox.desktop" ];
    in lib.mkMerge [
      (lib.genAttrs [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "application/x-extension-html"
        "application/xhtml+xml"
      ] (_: web))
      (lib.genAttrs [ "image/png" "image/jpeg" ] (_: images))
      {
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          [ "writer.desktop" ];
        "x-scheme-handler/msteams" = [ "teams.desktop" ];
        "text/plain" = [ "emacsclient.desktop" ];
        "application/pdf" = [ "atril.desktop" "draw.desktop" ];
        "video/mp4" = [ "vlc.desktop" ];
      }
    ];
  };

  gtk = {
    enable = true;
    font.name = "sans";
    font.size = 12;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
    iconTheme = {
      package = pkgs.numix-icon-theme;
      name = "Numix";
    };
  };

  # Make QT match the GTK theme.
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata_Oil";
    size = 24;
    x11.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "loafofpiecrust";
    userEmail = "taylor@snead.xyz";
    delta.enable = true;
    lfs.enable = true;
    # signing = {
    #   key = null;
    #   signByDefault = true;
    # };
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      core.editor = "emacsclient";
      core.askPass = "";
      github.user = "loafofpiecrust";
    };
  };
}
