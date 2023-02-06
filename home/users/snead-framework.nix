# Specific to snead user, only on framework laptop
{ config, lib, pkgs, ... }: {
  imports = [ ./snead.nix ../midi.nix ];
  home.packages = with pkgs; [ aseprite-unfree wine winetricks ];
}
