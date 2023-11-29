# Specific to snead user, only on framework laptop
{ config, lib, pkgs, ... }: {
  imports = [ ./snead.nix ../midi.nix ];
  home.packages = with pkgs; [
    praat
    wine
    winetricks
    nodePackages.surge

    # 3d modeling
    freecad
    kicad
    prusa-slicer

    # game dev
    godot_4
    gdtoolkit
    aseprite-unfree

    # custom keyboards
    qmk
    qmk_hid

    obs-studio
  ];
}
