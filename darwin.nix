{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./common.nix inputs.home-manager.darwinModules.home-manager ];
}
