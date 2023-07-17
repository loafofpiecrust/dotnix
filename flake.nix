{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
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
    kmonad = {
      url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self, nixpkgs, darwin, emacs-overlay, nixpkgs-unstable, nur, ... }@inputs:
    let
      specialArgs = { inherit inputs; };
      sharedModule = host: {
        nix.registry = {
          nixpkgs.flake = nixpkgs;
          nixos-hardware.flake = inputs.nixos-hardware;
          nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
          nur.flake = inputs.nur;
        };
        nixpkgs.overlays = [
          # Import my local package definitions.
          (import ./pkgs)
          (import emacs-overlay)
          # Provide nixpkgs-unstable for just a few packages.
          (self: super: {
            unstable = import nixpkgs-unstable {
              # required to inherit from top-level nixpkgs.
              system = super.system;
              config = super.config;
              overlays = [ inputs.nixpkgs-wayland.overlay ];
            };
          })
          nur.overlay
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
        // (mkLinux "x86_64-linux" "loafofpiecrust" ./systems/laptop-720s.nix)
        // (mkLinux "x86_64-linux" "kirby" ./systems/kirby.nix);
    };
}
