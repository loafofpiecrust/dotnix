{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    # defaultKeymap = "viins";

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
      # {
      #   name = "fzf-tab-completion";
      #   file = "zsh/fzf-zsh-completion.sh";
      #   src = builtins.fetchGit {
      #     url = "https://github.com/lincheney/fzf-tab-completion";
      #     ref = "master";
      #     rev = "774a6ff865cc233a9f7dd503df6feffbab653e03";
      #   };
      # }
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
          rev = "cf318e06a9b7c9f2219d78f41b46fa6e06011fd9";
        };
      }
      # {
      #   name = "zsh-history-substring-search";
      #   src = builtins.fetchGit {
      #     url = "https://github.com/zsh-users/zsh-history-substring-search";
      #     ref = "master";
      #     rev = "4abed97b6e67eb5590b39bcd59080aa23192f25d";
      #   };
      # }
      {
        name = "zsh-fzf-history-search";
        src = builtins.fetchGit {
          url = "https://github.com/joshskidmore/zsh-fzf-history-search";
          ref = "master";
          rev = "07c075c13938a7f527392dd73da2595a752cae6b";
        };
      }
    ];
    completionInit = ''
      autoload -U compinit && compinit
      autoload -U bashcompinit && bashcompinit
    '';
    initExtra = ''
      (cat ~/.cache/wal/base16-sequences &)
      bindkey ";3C" forward-word
      bindkey ";3D" backward-word
      # bindkey '^I' fzf_completion
      # bindkey '\e' vi-cmd-mode
      # zstyle ':completion:*' matcher-list "" \
      #   'm:{a-z\-}={A-Z\_}' \
      #   'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
      #   'r:|?=** m:{a-z\-}={A-Z\_}'

      # Bind shortcut for running arbitrary programs from nixpkgs!
      # This uses the same repository as my system, so downloads are minimal.
      function , {
        nix run nixpkgs#$1
      }

      export KEYTIMEOUT=1
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=20,bg=0"
      # set -o vi
      # zle -N zle-line-init
      # zle -N zle-keymap-select
      ${pkgs.fortune}/bin/fortune -s | ${pkgs.pokemonsay}/bin/pokemonsay -N
    '';
    history.expireDuplicatesFirst = true;
    # history.ignoreDups = true;
    historySubstringSearch.enable = true;
    # dirHashes = { nixos = "/etc/nixos"; };
  };
  programs.direnv.enableZshIntegration = true;
  programs.starship.enableZshIntegration = true;
}
