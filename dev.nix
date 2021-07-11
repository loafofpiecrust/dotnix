{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # tools of the trade
    git
    gitAndTools.gitFull
    git-lfs
    # gcc
    libgccjit # required for emacs native-comp
    gnumake
    cmake
    automake
    autoconf
    libtool
    neovim # backup editor of choice, after emacs ;)

    # publishing
    tectonic # lean latex builds
    pandoc

    # languages
    rustup
    sbcl
    nodejs
    yarn
    kotlin
    python3
    terraform # infrastructure as code
    terranix
    jq # transforms json documents

    # ocaml for compilers class
    ocaml
    opam # OCaml package manager
    ocamlformat # formatter
    ocamlPackages.ocp-indent # backup formatter
    ocamlPackages.ocaml-lsp
    ocamlPackages.merlin
    # ocamlPackages.utop # REPL

    # Spellcheck
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # fancy tools
    any-nix-shell
    awscli

    # formatters + language servers
    editorconfig-core-c
    nixfmt
    html-tidy
    pipenv
    python37Packages.python-language-server
    black
    nodePackages.typescript-language-server
    nodePackages.prettier
    rust-analyzer

    # dev apps
    # umlet # diagrams!
    plantuml # plain-text diagrams!

    # editing!
    emacsCustom
    zstd # compression for emacs session files
    pinentry_emacs
  ];

  nixpkgs.overlays = [
    (self: super: {
      emacsCustom = self.emacsGcc.override { withXwidgets = true; };
      # emacs = let
      #   myEmacs = pkgs.emacsGcc.override { withXwidgets = true; };
      #   emacsWithPackages =
      #     (pkgs.unstable.emacsPackagesGen myEmacs).emacsWithPackages;
      # in emacsWithPackages (epkgs:
      #   with epkgs; [
      #     # A few packages have native dependencies, so I need to add them here.
      #     vterm
      #     # undo-tree
      #     pdf-tools
      #     # org-pdftools
      #     # plantuml-mode
      #   ]);
    })
  ];

  # Shared Emacs server for :zap: speedy-macs
  # services.emacs = {
  #   enable = false;
  #   # Sets environment variables to make emacsclient the default editor.
  #   defaultEditor = true;
  #   package = pkgs.emacsCustom;
  # };

  # Android debugging.
  programs.adb.enable = true;

  # Persistent environment in shell execution!
  # services.lorri.enable = true;
}
