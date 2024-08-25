{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    plugins = [
      {
        name = "sudo";
        src = builtins.fetchGit {
          url = "https://github.com/ohmyzsh/ohmyzsh";
          ref = "master";
          rev = "fb4213c34ff8ec83cbe6251f432fdac383378562";
        };
        file = "plugins/sudo/sudo.plugin.zsh";
      }
      {
        name = "fzf-tab-completion";
        file = "zsh/fzf-zsh-completion.sh";
        src = builtins.fetchGit {
          url = "https://github.com/lincheney/fzf-tab-completion";
          ref = "master";
          rev = "774a6ff865cc233a9f7dd503df6feffbab653e03";
        };
      }
      # {
      #   name = "fzf-tab";
      #   src = builtins.fetchGit {
      #     url = "https://github.com/Aloxaf/fzf-tab";
      #     ref = "master";
      #     rev = "220bee396dd3c2024baa54015a928d5915e4f48f";
      #   };
      # }
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
        src = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-history-substring-search";
          ref = "master";
          rev = "4abed97b6e67eb5590b39bcd59080aa23192f25d";
        };
      }
      {
        name = "zsh-fzf-history-search";
        src = builtins.fetchGit {
          url = "https://github.com/joshskidmore/zsh-fzf-history-search";
          ref = "master";
          rev = "07c075c13938a7f527392dd73da2595a752cae6b";
        };
      }
      {
        name = "nix-zsh-completions";
        src = builtins.fetchGit {
          url = "https://github.com/spwhitt/nix-zsh-completions";
          ref = "master";
          rev = "468d8cf752a62b877eba1a196fbbebb4ce4ebb6f";
        };
      }
    ];
    completionInit = ''
      autoload -U compinit && compinit
      autoload -U bashcompinit && bashcompinit
    '';
    initExtra = ''
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^I' fzf_completion
      zstyle ':completion:*' matcher-list "" \
        'm:{a-z\-}={A-Z\_}' \
        'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
        'r:|?=** m:{a-z\-}={A-Z\_}'

      # Bind shortcut for running arbitrary programs from nixpkgs!
      # This uses the same repository as my system, so downloads are minimal.
      function , {
        nix run nixpkgs#$1
      }

      ${pkgs.fortune}/bin/fortune -s | ${pkgs.pokemonsay}/bin/pokemonsay -N
    '';
    history.expireDuplicatesFirst = true;
    history.ignoreDups = true;
    dirHashes = { nixos = "/etc/nixos"; };
  };
  programs.direnv.enableZshIntegration = true;
  programs.starship.enableZshIntegration = true;
}
