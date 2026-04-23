{
  description = "MacBook Pro for work";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    direnv-instant.url = "github:Mic92/direnv-instant";
  };
  outputs = inputs@{ self, nixpkgs, ... }:
    let sharedModule = import ../../lib/shared-host-module.nix "ShelbySneadMB";
    in {
      darwinConfigurations.ShelbySneadMB = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inputs = inputs // { self = ../..; }; };
        modules = [
          sharedModule
          ./default.nix
          inputs.mac-app-util.darwinModules.default
        ];
      };
    };
}
