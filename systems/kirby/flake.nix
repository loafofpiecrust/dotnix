{
  description = "NixOS host kirby (separate nixpkgs / Jovian lock)";
  inputs = {
    jovian.url =
      "github:Jovian-Experiments/Jovian-NixOS/6178d787ee61b8586fdb0ccb8644fbfd5317d0f3";
    nixpkgs.follows = "jovian/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    nur.inputs.nixpkgs.follows = "nixpkgs";
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
  };
  outputs = inputs@{ self, nixpkgs, ... }:
    let
      repoRoot = ../../.;
      inputs' = inputs // { self = repoRoot; };
      sharedModule = import ../../lib/shared-host-module.nix "kirby";
    in {
      nixosConfigurations.kirby = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inputs = inputs'; };
        modules = [ ./nixpkgs-insecure.nix sharedModule ./default.nix ];
      };
    };
}
