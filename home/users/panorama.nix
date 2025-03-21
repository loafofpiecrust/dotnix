{ config, lib, pkgs, inputs, ... }: {
  lib.meta = {
    configPath = "/Users/ssnead/nix";
    mkMutableSymlink = path:
      config.lib.file.mkOutOfStoreSymlink (config.lib.meta.configPath
        + lib.removePrefix (toString inputs.self) (toString path));
    monospaceFont = "Hack Nerd Font";
  };
  # imports = [ inputs.nix-doom-emacs.hmModule ];

  home.stateVersion = "24.11";

  home.homeDirectory = lib.mkForce "/Users/ssnead";
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
    autosuggestion.enable = true;
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
    userName = "Shelby Snead";
    userEmail = "shelby@snead.xyz";
    lfs.enable = true;
    delta.enable = true;
    #signing.key = "DAC12D13ED25377B7B1AE44C311B93DA14853F49";
    #signing.signByDefault = true;
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      core.editor = "emacsclient -r";
      github.user = "loafofpiecrust";
      # easy sign commits with ssh key
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      commit.gpgsign = true;
      # url."git@github.com:".insteadOf = "https://github.com/";
      # url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
    };
  };

  programs.kitty = {
    enable = true;
    darwinLaunchOptions = [ "--single-instance" ];
    font.name = config.lib.meta.monospaceFont;
    font.size = 13;
    shellIntegration.enableZshIntegration = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-macport;
    #extraPackages = emacsPackages: [ pkgs.coreutils ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = { enable = true; };
  };

  home.file.".aerospace.toml".source =
    config.lib.meta.mkMutableSymlink ../aerospace.toml;

}
