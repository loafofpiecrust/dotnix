{ config, lib, pkgs, ... }: {
  home.homeDirectory = lib.mkForce "/Users/taylor@outschool.com";
  home.file."Other Applications".source = let
    apps = pkgs.buildEnv {
      name = "home-manager-applications";
      paths = config.home.packages;
      pathsToLink = "/Applications";
    };
  in lib.mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";

  programs.zsh = { enable = true; };

  programs.git = {
    enable = true;
    userName = "taylorsnead-outschool";
    userEmail = "taylor@outschool.com";
    lfs.enable = true;
    delta.enable = true;
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      core.editor = "emacsclient";
      #github.user = "loafofpiecrust";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "Fira Code";
      font.size = 14;
      window.padding = {
        x = 4;
        y = 4;
      };
    };
  };

   programs.emacs = {
     enable = true;
     package = pkgs.emacsCustom;
   };

  programs.doom-emacs = {
    enable = false;
    doomPrivateDir = ../doom;
    emacsPackage = pkgs.emacsCustom;
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
        yaml = mkGitPkg {
          host = "github";
          user = "yoshiki";
          name = "yaml-mode";
          rev = "63b637f846411806ae47e63adc06fe9427be1131";
        };

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
        all-the-icons-completion = mkGitPkg {
          host = "github";
          user = "iyefrat";
          name = "all-the-icons-completion";
        };
      };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

  programs.mbsync.enable = true;
  programs.mu.enable = true;
  programs.msmtp.enable = true;
  accounts.email = let
    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      extraConfig.channel = {
        CopyArrivalDate = true;
        # SyncState = "*";
      };
      extraConfig.account = {
        Timeout = 40;
        PipelineDepth = 50;
      };
    };
    mu = { enable = true; };
    msmtp = { enable = true; };
    realName = "Taylor Snead";
  in {
    maildirBasePath = ".mail";
    accounts.outschool = let address = "taylor@outschool.com";
    in {
      inherit mbsync mu msmtp address realName;
      primary = true;
      userName = address;
      flavor = "gmail.com";
      imap.host = "imap.gmail.com";
      passwordCommand = "security find-generic-password -a 'taylor@outschool.com' -s accounts.google.com -w";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
    };
  };

}
