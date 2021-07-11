{ config, lib, pkgs, ... }:

{
  home.stateVersion = "21.05";
  home.sessionPath = [ "~/.config/emacs/bin" "~/.cargo/bin" "~/.npm/bin" ];

  home.file.".config/doom".source = ./doom.d;
  #home.file.".config/emacs".source = ./emacs.d;
  home.file.".aspell.en.pws".source = ./spell/.aspell.en.pws;
  home.file.".config/fontconfig/fonts.conf".source = ./gui/fonts.conf;
  home.file."bin/get-password.sh" = {
    executable = true;
    text = let rbw = "${pkgs.rbw}/bin/rbw";
    in ''
      #!/bin/sh
      ${rbw} login
      ${rbw} unlock
      ${rbw} get "$1" "$2"
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      battery.disabled = true;
    };
  };

  programs.rbw = {
    enable = true;
    settings.email = "taylor@snead.xyz";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    mimeApps.defaultApplications = let
      images = [ "ristretto.desktop" ];
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
      package = pkgs.paper-icon-theme;
      name = "Paper";
    };
  };

  # Make QT match the GTK theme.
  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  xsession.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata_Oil";
    size = 24;
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



  programs.doom-emacs = {
    enable = false;
    doomPrivateDir = ./doom.d;
    emacsPackage = pkgs.emacsCustom;
    # Add some packages from unpublished git repositories.
    emacsPackagesOverlay = self: super:
      let
        mkGitPkg = { host, user, name, rev ? null }:
          self.trivialBuild {
            pname = name;
            version = if rev == null then "1.0.0" else rev;
            src = builtins.fetchGit {
              url = "https://${host}.com/${user}/${name}.git";
              rev = rev;
            };
          };
      in {
        org-cv = mkGitPkg {
          host = "gitlab";
          user = "loafofpiecrust";
          name = "org-cv";
          rev = "explicit-dates";
        };
        app-launcher = mkGitPkg {
          host = "github";
          user = "SebastienWae";
          name = "app-launcher";
          rev = "71fb5a501a646703c81783395ff46cdd043e173a";
        };
        exwm-outer-gaps = mkGitPkg {
          host = "github";
          user = "lucasgruss";
          name = "exwm-outer-gaps";
        };
        bitwarden = mkGitPkg {
          host = "github";
          user = "seanfarley";
          name = "emacs-bitwarden";
        };
        dired-show-readme = mkGitPkg {
          host = "gitlab";
          user = "kisaragi-hiu";
          name = "dired-show-readme";
        };
      };
  };
}
