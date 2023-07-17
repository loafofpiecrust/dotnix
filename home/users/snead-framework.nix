# Specific to snead user, only on framework laptop
{ config, lib, pkgs, ... }: {
  imports = [ ./snead.nix ../midi.nix ];
  home.packages = with pkgs; [
    unstable.godot_4
    unstable.gdtoolkit
    aseprite-unfree
    wine
    winetricks
    freecad
    kicad
    nodePackages.surge
  ];
}
