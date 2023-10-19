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
    unstable.godot_4
    unstable.gdtoolkit
    aseprite-unfree

    # custom keyboards
    qmk
    qmk_hid

    obs-studio
  ];
}
