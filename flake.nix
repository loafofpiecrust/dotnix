{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-bitwig.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.05";
    # Make sure the commit used here matches the one from jovian-nixos to ensure
    # a good build for Kirby, and avoiding using a too-new commit that has no
    # cached derivations yet.
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
    # Jovian relies on the latest unstable version of NixOS. I don't love this
    # but it means Kirby relies on that too, unless I backtrack to an old
    # version of steam.
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self, nixpkgs, darwin, emacs-overlay, nixpkgs-unstable, nur, ... }@inputs:
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
      mkLinux = mkSystem nixpkgs.lib.nixosSystem nixpkgs;
      mkUnstableLinux =
        mkSystem nixpkgs-unstable.lib.nixosSystem nixpkgs-unstable;
      mkDarwin = mkSystem darwin.lib.darwinSystem nixpkgs;
    in rec {
      # When you first setup a new machine, the hostname won't match yet.
      # $ darwin-rebuild switch --flake .#darwinConfigurations.careerbot13.system
      # After that:
      # $ darwin-rebuild switch --flake .
      darwinConfigurations = (mkDarwin "x86_64-darwin" "careerbot13"
        ./systems/laptop-outschool-macos.nix);

      nixosConfigurations = (mkLinux "x86_64-linux" "portable-spudger"
        ./systems/framework-laptop.nix)
        // (mkUnstableLinux "x86_64-linux" "kirby" ./systems/kirby.nix);

    };
}
