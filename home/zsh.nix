{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    plugins = [
      {
        name = "doas";
        src = builtins.fetchGit {
          url = "https://github.com/Senderman/doas-zsh-plugin";
          ref = "master";
          rev = "f5c58a34df2f8e934b52b4b921a618b76aff96ba";
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
          url = "https://github.com/zdharma/fast-syntax-highlighting";
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
      ${pkgs.fortune}/bin/fortune
    '';
    history.expireDuplicatesFirst = true;
    history.ignoreDups = true;
    dirHashes = { nixos = "/etc/nixos"; };
  };
  programs.direnv.enableZshIntegration = true;
  programs.starship.enableZshIntegration = true;
}
