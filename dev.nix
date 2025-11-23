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
    python312Packages.pygments

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
    python312Packages.sqlparse
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

    git-repo # for android dev
  ];

  fonts.packages = with pkgs.unstable.nerd-fonts; [
    hack
    overpass
    ubuntu
    ubuntu-mono
    jetbrains-mono
    fantasque-sans-mono
    fira-code
    hasklug
  ];

  nixpkgs.overlays = [
    (self: super: {
      emacsCustom = super.emacs.override {
        withPgtk = true;
        withSQLite3 = true;
        # withWebP = true;
        withNativeCompilation = true;
      };
      beets = (super.beets.override {
        # Must bump the version whenever config changes to actually apply the new
        # build in the system config.
        pluginOverrides = {
          alternatives = {
            enable = true;
            # WARNING: MAKE SURE TO SPELL PROPAGATED CORRECTLY! THIS IS NOT TYPE-CHECKED!
            propagatedBuildInputs = [ super.beetsPackages.alternatives ];
          };
          dynamicrange = {
            enable = true;
            propagatedBuildInputs = [
              (self.python3Packages.buildPythonApplication rec {
                pname = "beets-dynamicrange";
                version = "unstable-2022-08-15";

                # Use the branch that fixes FAT32 usage
                src = self.fetchFromGitHub {
                  owner = "auchter";
                  repo = "beets-dynamicrange";
                  rev = "62fc157f85293d1d2dcc36b5afa33d5322cc8c5f";
                  sha256 =
                    "sha256-ALNGrpZOKdUE3g4np8Ms+0s8uWi6YixF2IVHSgaQVj4=";
                };

                postPatch = ''
                  substituteInPlace beetsplug/dynamicrange.py \
                    --replace dr14_tmeter ${pkgs.dr14_tmeter}/bin/dr14_tmeter
                '';
                doCheck = false;

                nativeBuildInputs = with self; [ beetsPackages.beets-minimal ];

                propagatedBuildInputs = with self; [ dr14_tmeter ];
              })
            ];
          };
        };
      });
    })
  ];

  # Android debugging.
  programs.adb.enable = true;
}
