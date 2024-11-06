{ config, lib, pkgs, inputs, ... }:

{
  home.stateVersion = lib.mkDefault "21.05";
  home.sessionPath = [
    "${config.home.homeDirectory}/.config/emacs/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];

  lib.meta = {
    configPath = "/etc/nixos";
    mkMutableSymlink = path:
      config.lib.file.mkOutOfStoreSymlink (config.lib.meta.configPath
        + lib.removePrefix (toString inputs.self) (toString path));
  };

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
  home.file.".aspell.en.pws".source =
    config.lib.meta.mkMutableSymlink ./spell/.aspell.en.pws;
  home.file."bin/get-password" = {
    executable = true;
    text = ''
      #!/bin/sh
      export PATH=${config.programs.rbw.package}/bin:$PATH
      rbw unlocked || rbw login
      rbw unlocked || rbw unlock
      rbw get "$1" "$2"
    '';
  };
  home.file."bin/light-notify".source = ./scripts/light-notify.sh;

  home.packages = with pkgs; [ gparted gnome.simple-scan ];

  # GPG agent handles locked files and SSH keys.
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 60 * 60;
    defaultCacheTtlSsh = 60 * 60;
    pinentryPackage = pkgs.pinentry-gnome3;
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
    package = pkgs.rbw;
    settings = {
      email = "taylor@snead.xyz";
      # Keep the vault open for 6 hours.
      lock_timeout = 60 * 60 * 6;
      # FIXME must be a package definition
      pinentry = pkgs.pinentry-gnome3;
    };
  };

  xdg = {
    enable = true;
    mime.enable = lib.mkDefault false;
    mimeApps.enable = lib.mkDefault false;
    mimeApps.defaultApplications = lib.mkMerge [
      (lib.genAttrs [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "application/x-extension-html"
        "application/xhtml+xml"
      ] (_: [ "brave.desktop" ]))
      (lib.genAttrs [ "image/png" "image/jpeg" ] (_: [ "eom.desktop" ]))
      (lib.genAttrs [ "video/mp4" "video/quicktime" ] (_: [ "vlc.desktop" ]))
      {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          [ "writer.desktop" ];
        "x-scheme-handler/msteams" = [ "teams.desktop" ];
        "text/plain" = [ "emacsclient.desktop" ];
        "application/pdf" = [ "atril.desktop" "draw.desktop" ];
      }
    ];
  };

  gtk = {
    enable = true;
    font.name = "sans";
    font.size = 13;
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
    platformTheme.name = "gtk";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
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
