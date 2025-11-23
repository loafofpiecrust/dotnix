{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-bitwig.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.05";
    # Make sure the commit used here matches the one from jovian-nixos to ensure
    # a good build for Kirby, and avoiding using a too-new commit that has no
    # cached derivations yet.
    nixpkgs-kirby.url =
      "github:nixos/nixpkgs/b3d51a0365f6695e7dd5cdf3e180604530ed33b4";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs";
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    iwmenu = {
      url = "github:e-tho/iwmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colorizer.url = "github:nutsalhan87/nix-colorizer";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Jovian relies on the latest unstable version of NixOS. I don't love this
    # but it means Kirby relies on that too, unless I backtrack to an old
    # version of steam.
    jovian = {
      url =
        "github:Jovian-Experiments/Jovian-NixOS/6178d787ee61b8586fdb0ccb8644fbfd5317d0f3";
      inputs.nixpkgs.follows = "nixpkgs-kirby";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, mac-app-util, emacs-overlay
    , nixpkgs-unstable, nixpkgs-kirby, nur, ... }@inputs:
    let
      specialArgs = { inherit inputs; };
      sharedModule = host: nixpkgs: {
        nix.registry = {
          # nixpkgs.flake = inputs.nixpkgs;
          nixos-hardware.flake = inputs.nixos-hardware;
          nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
          nur.flake = inputs.nur;
        };
        nixpkgs.overlays = [
          (import emacs-overlay)
          # Provide nixpkgs-unstable for just a few packages.
          (self: super: {
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
      mkSystem = fn: nixpkgs: system: host: path: {
        "${host}" = fn {
          inherit system specialArgs;
          # inherit (nixpkgs) lib;
          modules = [ (sharedModule host nixpkgs) path ];
        };
      };
      mkDarwinSystem = fn: nixpkgs: system: host: path: {
        "${host}" = fn {
          inherit system specialArgs;
          # inherit (nixpkgs) lib;
          modules = [
            (sharedModule host nixpkgs)
            path
            mac-app-util.darwinModules.default
          ];
        };
      };
      mkLinux = nixpkgs: mkSystem nixpkgs.lib.nixosSystem nixpkgs;
      mkDarwin = mkSystem nix-darwin.lib.darwinSystem nixpkgs;
    in rec {
      # When you first setup a new machine, the hostname won't match yet.
      # $ darwin-rebuild switch --flake .#darwinConfigurations.careerbot13.system
      # After that:
      # $ darwin-rebuild switch --flake .
      darwinConfigurations = (mkDarwin "aarch64-darwin" "PE-NTWDXW2TJW"
        ./systems/laptop-panorama-macos.nix);

      nixosConfigurations = ((mkLinux nixpkgs) "x86_64-linux" "portable-spudger"
        ./systems/framework-laptop.nix)
        // ((mkLinux nixpkgs-kirby) "x86_64-linux" "kirby" ./systems/kirby.nix);

    };
}
