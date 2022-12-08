{ config, lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # tools of the trade
    # gcc
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
    # terranix
    jq # transforms json documents

    # ocaml for compilers class
    ocaml
    # opam # OCaml package manager
    ocamlformat # formatter
    ocamlPackages.ocp-indent # backup formatter
    ocamlPackages.ocaml-lsp
    ocamlPackages.merlin
    # ocamlPackages.utop # REPL

    # Spellcheck
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))

    # fancy tools
    # any-nix-shell
    awscli

    # formatters + language servers
    editorconfig-core-c
    nixfmt
    html-tidy
    pipenv
    # python37Packages.python-language-server
    black
    nodePackages.typescript-language-server
    nodePackages.prettier
    rust-analyzer
    unstable.pgformatter
    python39Packages.sqlparse

    # dev apps
    # umlet # diagrams!
    plantuml # plain-text diagrams!

    # editing!
    zstd # compression for emacs session files
    pinentry_emacs
  ];

  nixpkgs.overlays = [ (self: super: { emacsCustom = self.emacsPgtkGcc; }) ];

  # Android debugging.
  programs.adb.enable = true;
}
