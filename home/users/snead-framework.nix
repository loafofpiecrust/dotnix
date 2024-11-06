# Specific to snead user, only on framework laptop
{ config, lib, pkgs, ... }: {
  imports = [ ./snead.nix ../midi.nix ];

  xdg.mime.enable = true;
  xdg.mimeApps.enable = false;
  home.packages = with pkgs; [
    # Run ANYTHING one-off without installing it!
    # comma

    praat
    wine
    winetricks
    # nodePackages.surge

    # 3d modeling
    freecad
    openscad-unstable
    kicad-small
    orca-slicer

    # game dev
    godot_4
    gdtoolkit
    # aseprite-unfree

    # custom keyboards
    qmk
    qmk_hid
    rockbox-utility

    obs-studio
    mp3val
    flac
    filezilla

    fontforge-gtk

    pomodoro-gtk
  ];

  programs.foot.server.enable = true;
}
