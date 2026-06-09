{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  lib.meta = {
    configPath = "/Users/ssnead/nix";
    mkMutableSymlink =
      path:
      config.lib.file.mkOutOfStoreSymlink (
        config.lib.meta.configPath + lib.removePrefix (toString inputs.self) (toString path)
      );
    monospaceFont = "Lilex Nerd Font";
  };

  home.stateVersion = "24.11";

  home.homeDirectory = lib.mkForce "/Users/ssnead";
  # home.file."Other Applications".source = let
  #   apps = pkgs.buildEnv {
  #     name = "home-manager-applications";
  #     paths = config.home.packages;
  #     pathsToLink = "/Applications";
  #   };
  # in lib.mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";

  home.packages =
    (with pkgs; [
      cursor-agent-acp
      kubetui
      neovim-remote
      fzf
      lazygit
      tree-sitter
    ])
    ++ (with pkgs.unstable; [
      lunar
      code-cursor
      cursor-cli
    ]);

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
    autosuggestion.enable = false;
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
    initContent = ''
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.ssh = {
    enable = false;
    extraConfig = ''
      Host cs.animated-space-umbrella-7prxqr6pr7fxgr9.develop
      	User codespace
      	ProxyCommand /run/current-system/sw/bin/gh cs ssh -c animated-space-umbrella-7prxqr6pr7fxgr9 --stdio -- -i /Users/ssnead/.ssh/codespaces.auto
      	UserKnownHostsFile=/dev/null
      	StrictHostKeyChecking no
      	LogLevel quiet
      	ControlMaster auto
      	IdentityFile /Users/ssnead/.ssh/codespaces.auto
    '';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    #signing.key = "DAC12D13ED25377B7B1AE44C311B93DA14853F49";
    #signing.signByDefault = true;
    ignores = [ ".projectile-cache.eld" ];
    settings = {
      user.name = "Shelby Snead";
      user.email = "shelby.snead@panoramaed.com";
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # programs.ghostty.enable = true;

  programs.kitty = {
    enable = true;
    darwinLaunchOptions = [ "--single-instance" ];
    font.name = config.lib.meta.monospaceFont;
    font.size = 13;
    shellIntegration.enableZshIntegration = true;
    shellIntegration.enableBashIntegration = true;
    settings = {
      update_check_interval = 0;
      notify_on_cmd_finish = "unfocused";
      confirm_os_window_close = 0;
    };
    keybindings = {
      "cmd+s" = "send_key ctrl+s";
      "cmd+enter" = "send_key ctrl+enter";
      "cmd+i" = "send_key ctrl+i";
      "cmd+o" = "send_key ctrl+o";
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-macport;
    # extraPackages = epkgs:
    #   with epkgs; [
    #     tree-sitter
    #     # tree-sitter-langs
    #     # treesit-grammars.with-all-grammars
    #     # vterm
    #     emacsql
    #     emojify
    #   ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv = {
      enable = true;
    };
    config.global.log_filter = "^(un)?loading";
  };
  # programs.direnv-instant.enable = true;

  home.file.".aerospace.toml".source = config.lib.meta.mkMutableSymlink ../../../aerospace.toml;

  home.file."bin/doom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/emacs/bin/doom";

  xdg.configFile."nvim/init.lua".source = lib.mkForce (
    config.lib.meta.mkMutableSymlink ../../../home/neovim/init.lua
  );
  xdg.configFile."nvim/lua".source = config.lib.meta.mkMutableSymlink ../../../home/neovim/lua;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    package = pkgs.neovim-unwrapped;

    plugins = with pkgs.unstable.vimPlugins; [
      # Eager (start/) - loaded immediately
      which-key-nvim
      lualine-nvim
      mini-nvim
      flash-nvim
      gitsigns-nvim
      todo-comments-nvim
      yanky-nvim
      indent-blankline-nvim
      faster-nvim
      (pkgs.unstable.vimUtils.buildVimPlugin {
        pname = "direnv.nvim";
        version = "unstable";
        src = builtins.fetchGit {
          url = "https://github.com/NotAShelf/direnv.nvim";
          ref = "main";
          rev = "8962b7fe3f6267db9dd8b2a49f2c6175b7980210";
        };
        doCheck = false;
      })
      persistence-nvim
      plenary-nvim
      snacks-nvim
      nvim-web-devicons
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      fff-nvim
      oil-nvim
      (pkgs.unstable.vimUtils.buildVimPlugin {
        pname = "snacks-fff.nvim";
        version = "unstable";
        src = builtins.fetchGit {
          url = "https://github.com/so1ve/snacks-fff.nvim";
          ref = "main";
          rev = "6c511f77fa1ee1e6ee682968b03d210ea5d162c8";
        };
        doCheck = false;
      })
      (pkgs.unstable.vimUtils.buildVimPlugin {
        pname = "registers.nvim";
        version = "unstable";
        src = builtins.fetchGit {
          url = "https://codeberg.org/fosk/registers.nvim";
          ref = "main";
          rev = "c217f8f369e0886776cda6c94eab839b30a8940d";
        };
        doCheck = false;
      })
      render-markdown-nvim
      (pkgs.unstable.vimUtils.buildVimPlugin {
        pname = "helm-ls.nvim";
        version = "unstable";
        src = builtins.fetchGit {
          url = "https://github.com/qvalentin/helm-ls.nvim";
          ref = "main";
          rev = "20df43509b02a3ce3c6b3eee254d6e2bffa9a370";
        };
        doCheck = false;
      })

      # Colorschemes
      catppuccin-nvim
      gruvbox-nvim
      everforest
      kanagawa-nvim
      bamboo-nvim
      rose-pine

      # Deferred (opt/) - loaded via autocmds in Lua
      {
        plugin = nvim-lspconfig;
        optional = true;
      }
      {
        plugin = blink-cmp;
        optional = true;
      }
      {
        plugin = conform-nvim;
        optional = true;
      }
      {
        plugin = nvim-lint;
        optional = true;
      }
      {
        plugin = noice-nvim;
        optional = true;
      }
      {
        plugin = nui-nvim;
        optional = true;
      }
      {
        plugin = trouble-nvim;
        optional = true;
      }
      {
        plugin = neogit;
        optional = true;
      }
      {
        plugin = diffview-nvim;
        optional = true;
      }
    ];

    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nixd
      gopls
      terraform-ls
      yaml-language-server
      helm-ls
      ruby-lsp
      rust-analyzer
      pyright
      typescript-language-server
      vscode-langservers-extracted
      bash-language-server
      clang-tools

      # Linters
      statix
      shellcheck
      sqlfluff
      tflint

      # Formatters
      nixfmt
      gofumpt
      prettierd
      rustfmt
      ruff
      shfmt
      stylua
    ];
  };
}
