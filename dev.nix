{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # tools of the trade
    gnumake
    cmake
    automake
    autoconf
    libtool
    neovim # backup editor of choice, after emacs ;)

    # publishing
    tectonic # lean latex builds
    pandoc
    python39Packages.pygments

    # languages
    rustup
    sbcl
    nodejs
    yarn
    kotlin
    python3
    jq # transforms json documents

    # ocaml for compilers class
    ocaml
    ocamlformat # formatter
    ocamlPackages.ocp-indent # backup formatter
    ocamlPackages.ocaml-lsp
    ocamlPackages.merlin

    # Spellcheck
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # fancy tools
    awscli

    # formatters + language servers
    editorconfig-core-c
    nixfmt-classic
    html-tidy
    pipenv
    # python37Packages.python-language-server
    black
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.vscode-langservers-extracted
    rust-analyzer
    pgformatter
    python39Packages.sqlparse
    sqls
    clang-tools
    shfmt
    stylelint
    shellcheck
    emacs-lsp-booster

    # development apps
    plantuml # plain-text diagrams!

    # editing!
    zstd # compression for emacs session files
    pinentry-emacs
    sqlite
  ];

  fonts.packages = with pkgs; [ nerdfonts ];

  nixpkgs.overlays = [
    (self: super: {
      emacsCustom = super.emacs.override {
        withPgtk = true;
        withSQLite3 = true;
        # withWebP = true;
        withNativeCompilation = true;
      };
    })
  ];

  # Android debugging.
  programs.adb.enable = true;
}
