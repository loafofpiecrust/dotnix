{
  description = "Home server";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, ... }:
    let sharedModule = import ../../lib/shared-host-module.nix "vivian";
    in {
      nixosConfigurations.vivian = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inputs = inputs // { self = ../..; }; };
        modules = [ sharedModule ./default.nix ];
      };
    };
}
