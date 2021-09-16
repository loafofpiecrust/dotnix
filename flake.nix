{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Contains Linux kernel 5.12, which I need for the framework laptop.
    nixpkgs-kernel.url =
      "github:nixos/nixpkgs/9f952205d0c2074c993ecfbfdf62b5eebe0cc6f4";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url =
        "github:nix-community/home-manager/b0d769691cc379c9ab91d3acec5d14e75c02c02b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url =
        "github:nix-community/emacs-overlay/34624e82c790aa8c225aa9b7e98048cac289f505";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs = {
      url =
        "github:vlaci/nix-doom-emacs/fee14d217b7a911aad507679dafbeaa8c1ebf5ff";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
      inputs.straight.follows = "straight";
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
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-kernel, darwin
    , nixos-hardware, emacs-overlay, home-manager, nur, nix-doom-emacs, ... }:
    let
      mkUser = path: _: { imports = [ nix-doom-emacs.hmModule path ]; };
      sharedModule = {
        nixpkgs.overlays = [
          # Import my local package definitions.
          (import ./pkgs)
          (import emacs-overlay)
          # Provide nixpkgs-unstable for just a few packages.
          (self: super: {
            unstable = import nixpkgs-unstable {
              # required to inherit from top-level nixpkgs.
              system = super.system;
              config.allowUnfree = super.config.allowUnfree;
            };
            framework-kernel = import nixpkgs-kernel { system = super.system; };
          })
          nur.overlay
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };
    in {
      # When you first setup a new machine, the hostname won't match yet.
      # $ darwin-rebuild switch --flake .#darwinConfigurations.careerbot13.system
      # After that:
      # $ darwin-rebuild switch --flake .
      darwinConfigurations."careerbot13" = darwin.lib.darwinSystem {
        modules = [
          ./laptop-outschool-macos.nix
          home-manager.darwinModules.home-manager
          sharedModule
          {
            # TODO Only type the host name once.
            networking.hostName = "careerbot13";
            home-manager.users."taylor@outschool.com" =
              mkUser ./home/users/outschool.nix;
          }
        ];
      };

      nixosConfigurations."loafofpiecrust" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit (nixpkgs) lib;
        modules = [
          ./laptop-720s.nix
          home-manager.nixosModules.home-manager
          sharedModule
          {
            home-manager.users.snead = mkUser ./home/users/snead.nix;
            home-manager.users.work = mkUser ./home/users/work.nix;
          }
        ];
      };

      nixosConfigurations."portable-spudger" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit (nixpkgs) lib;
        modules = [
          ./laptop-framework.nix
          home-manager.nixosModules.home-manager
          sharedModule
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel
          { home-manager.users.snead = mkUser ./home/users/snead.nix; }
        ];
      };
    };
}
