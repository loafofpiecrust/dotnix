{
  description = "MacBook Pro for work";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-emacs = {
      url = "github:nix-giant/nix-darwin-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-emacs-packages = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # mac-app-util.url = "github:hraban/mac-app-util";
    # mac-app-util.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    direnv-instant.url = "github:Mic92/direnv-instant";
    lazyvim.url = "github:pfassina/lazyvim-nix";
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      sharedModule = import ../../lib/shared-host-module.nix "ShelbySneadMB";
    in
    {
      darwinConfigurations.ShelbySneadMB = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inputs = inputs // {
            self = ../..;
          };
        };
        modules = [
          sharedModule
          ./configuration.nix
          # inputs.mac-app-util.darwinModules.default
        ];
      };
    };
}
