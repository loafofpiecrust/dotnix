{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-bitwig.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs = {
      url = "github:vlaci/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
      # inputs.straight.follows = "straight";
      inputs.doom-emacs.follows = "doom-emacs";
    };
    straight.url = "github:raxod502/straight.el";
    straight.flake = false;
    doom-emacs = {
      url = "github:hlissner/doom-emacs/develop";
      flake = false;
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    iwmenu = {
      url = "github:e-tho/iwmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    swayfx = {
      url = "github:WillPower3309/swayfx";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colorizer.url = "github:nutsalhan87/nix-colorizer";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-beets = {
      url = "github:nixos/nixpkgs/88195a94f390381c6afcdaa933c2f6ff93959cb4";
    };
  };

  outputs = { self, nixpkgs, darwin, emacs-overlay, nixpkgs-unstable
    , nixpkgs-beets, nur, ... }@inputs:
    let
      specialArgs = { inherit inputs; };
      sharedModule = host: {
        nix.registry = {
          nixpkgs.flake = nixpkgs;
          nixos-hardware.flake = inputs.nixos-hardware;
          nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
          # nixpkgs-old.flake = inputs.nixpkgs-old;
          nur.flake = inputs.nur;
        };
        nixpkgs.overlays = [
          # Import my local package definitions.
          (import ./pkgs)
          (import emacs-overlay)
          # Provide nixpkgs-unstable for just a few packages.
          (self: super: {
            custom-beets = import nixpkgs-beets {
              system = super.system;
              config = super.config;
              overlays = [
                # (self: super: {
                #   beets = with super;
                #     beets-unstable.override {
                #       version = "2.0.0-240807";
                #       # extraNativeBuildInputs = [ self.unstable.python3Packages.setuptools ];
                #       pluginOverrides = {
                #         copyartifacts = {
                #           enable = true;
                #           propogatedBuildInputs =
                #             [ beetsPackages.copyartifacts ];
                #         };
                #         # extrafiles = {
                #         #   enable = true;
                #         #   propagatedBuildInputs = [ self.unstable.beetsPackages.extrafiles ];
                #         # };
                #         alternatives = {
                #           enable = true;
                #           propagatedBuildInputs = [
                #             (python3Packages.buildPythonApplication rec {
                #               pname = "beets-alternatives";
                #               version = "unstable-2024-08-07";
                #               format = "pyproject";

                #               # Use the branch that fixes FAT32 usage
                #               src = fetchFromGitHub {
                #                 repo = "beets-alternatives";
                #                 owner = "loafofpiecrust";
                #                 rev =
                #                   "f6260da3081ecec1bd4f13acbdf45a20c1e863ea";
                #                 sha256 =
                #                   "sha256-OyMefC+Qua5rn5jZWk8Zt07vMcnlhfqoLUrgxNfqorg=";
                #               };

                #               postPatch = ''
                #                 substituteInPlace pyproject.toml \
                #                   --replace 'addopts = "--cov --cov-report=term --cov-report=html"' ""
                #               '';
                #               preCheck = ''
                #                 export HOME=$(mktemp -d)
                #               '';

                #               nativeBuildInputs = [ beets-unstable poetry ]
                #                 ++ (with python3Packages; [
                #                   poetry-core
                #                   typeguard
                #                 ]);

                #               nativeCheckInputs = with python3Packages; [
                #                 pytestCheckHook
                #                 mock
                #                 typeguard
                #                 poetry-core
                #               ];
                #             })
                #           ];
                #         };
                #         # I have to manually enable some new plugins
                #         limit = {
                #           enable = true;
                #           builtin = true;
                #         };
                #         substitute = {
                #           enable = true;
                #           builtin = true;
                #         };
                #         autobpm = {
                #           enable = true;
                #           builtin = true;
                #         };
                #         advancedrewrite = {
                #           enable = true;
                #           builtin = true;
                #         };
                #       };
                #     };
                # })
              ];
            };
            unstable = import nixpkgs-unstable {
              # required to inherit from top-level nixpkgs.
              system = super.system;
              config = super.config;
              overlays = [ inputs.nixpkgs-wayland.overlay ];
            };
            old = import inputs.nixpkgs-old {
              system = super.system;
              config = super.config;
            };
          })
          nur.overlays.default
        ];
        networking.hostName = host;
      };
      mkSystem = fn: system: host: path: {
        "${host}" = fn {
          inherit system specialArgs;
          # inherit (nixpkgs) lib;
          modules = [ (sharedModule host) path ];
        };
      };
      mkLinux = mkSystem nixpkgs.lib.nixosSystem;
      mkUnstableLinux = mkSystem nixpkgs-unstable.lib.nixosSystem;
      mkDarwin = mkSystem darwin.lib.darwinSystem;
    in rec {
      # When you first setup a new machine, the hostname won't match yet.
      # $ darwin-rebuild switch --flake .#darwinConfigurations.careerbot13.system
      # After that:
      # $ darwin-rebuild switch --flake .
      darwinConfigurations = (mkDarwin "x86_64-darwin" "careerbot13"
        ./systems/laptop-outschool-macos.nix);

      nixosConfigurations = (mkLinux "x86_64-linux" "portable-spudger"
        ./systems/framework-laptop.nix)
        // (mkLinux "x86_64-linux" "kirby" ./systems/kirby.nix);

    };
}
