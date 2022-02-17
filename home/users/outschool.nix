{ config, lib, pkgs, inputs, ... }: {
  # imports = [ inputs.nix-doom-emacs.hmModule ];

  home.homeDirectory = lib.mkForce "/Users/taylor@outschool.com";
  # home.file."Other Applications".source = let
  #   apps = pkgs.buildEnv {
  #     name = "home-manager-applications";
  #     paths = config.home.packages;
  #     pathsToLink = "/Applications";
  #   };
  # in lib.mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";

  home.packages = with pkgs; [ fzf ];

  programs.zsh = {
    enable = true;
    envExtra = ''
      ulimit -n 10240
    '';
    # shellAliases = {
    #   docker = "podman";
    #   docker-compose = "podman-compose";
    # };
    history.ignoreDups = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    plugins = [
      {
        name = "sudo";
        file = "plugins/sudo/sudo.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/ohmyzsh/ohmyzsh";
          ref = "master";
          rev = "190325049ef93731ab28295dbedf36d44ab33d7a";
        };
      }
      {
        name = "fzf-tab";
        src = builtins.fetchGit {
          url = "https://github.com/Aloxaf/fzf-tab";
          ref = "master";
          rev = "220bee396dd3c2024baa54015a928d5915e4f48f";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = builtins.fetchGit {
          url = "https://github.com/zdharma-continuum/fast-syntax-highlighting";
          ref = "master";
          rev = "817916dfa907d179f0d46d8de355e883cf67bd97";
        };
      }
      {
        name = "zsh-history-substring-search";
        file = "zsh-history-substring-search.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-history-substring-search";
          ref = "master";
          rev = "4abed97b6e67eb5590b39bcd59080aa23192f25d";
        };
      }
      # {
      #   name = "zsh-notify";
      #   file = "notify.plugin.zsh";
      #   src = builtins.fetchGit {
      #     url = "https://github.com/marzocchi/zsh-notify";
      #     ref = "master";
      #     rev = "eb389765cb1bd3358e88ac31939ef2edfd539825";
      #   };
      # }
    ];
    initExtra = ''
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ssh.enable = true;

  programs.git = {
    enable = true;
    userName = "Taylor Snead";
    userEmail = "taylor@outschool.com";
    lfs.enable = true;
    delta.enable = true;
    signing.key = "DAC12D13ED25377B7B1AE44C311B93DA14853F49";
    signing.signByDefault = true;
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      core.editor = "emacsclient";
      "sourcehut".user = "loafofpiecrust";
      github.user = "loafofpiecrust";
      gitlab.user = "taylorsnead-outschool";

      # url."git@github.com:".insteadOf = "https://github.com/";
      # url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
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
    enable = false;
    package = pkgs.emacsMacport;
    extraPackages = emacsPackages: [ pkgs.coreutils ];
  };

  # programs.doom-emacs = {
  #   enable = false;
  #   doomPrivateDir = ../doom;
  #   emacsPackage = pkgs.emacsCustom;
  #   emacsPackagesOverlay = self: super:
  #     let
  #       mkGitPkg = { host, user, name, rev ? null }:
  #         self.trivialBuild {
  #           pname = name;
  #           version = if rev == null then "1.0.0" else rev;
  #           src = builtins.fetchGit {
  #             url = "https://${host}.com/${user}/${name}.git";
  #             rev = rev;
  #           };
  #         };
  #     in {
  #       yaml = mkGitPkg {
  #         host = "github";
  #         user = "yoshiki";
  #         name = "yaml-mode";
  #         rev = "63b637f846411806ae47e63adc06fe9427be1131";
  #       };

  #       org-cv = mkGitPkg {
  #         host = "gitlab";
  #         user = "loafofpiecrust";
  #         name = "org-cv";
  #         rev = "explicit-dates";
  #       };
  #       app-launcher = mkGitPkg {
  #         host = "github";
  #         user = "SebastienWae";
  #         name = "app-launcher";
  #         rev = "71fb5a501a646703c81783395ff46cdd043e173a";
  #       };
  #       exwm-outer-gaps = mkGitPkg {
  #         host = "github";
  #         user = "lucasgruss";
  #         name = "exwm-outer-gaps";
  #       };
  #       bitwarden = mkGitPkg {
  #         host = "github";
  #         user = "seanfarley";
  #         name = "emacs-bitwarden";
  #       };
  #       dired-show-readme = mkGitPkg {
  #         host = "gitlab";
  #         user = "kisaragi-hiu";
  #         name = "dired-show-readme";
  #       };
  #       all-the-icons-completion = mkGitPkg {
  #         host = "github";
  #         user = "iyefrat";
  #         name = "all-the-icons-completion";
  #       };
  #     };
  # };

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
      passwordCommand =
        "security find-generic-password -a 'taylor@outschool.com' -s accounts.google.com -w";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
    };
  };

}
