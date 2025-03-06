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
    obsidian # note taking
    # darktable # photo editing
  ];

  # Don't use the server because it'll keep programs running after I close their window!
  # programs.foot.server.enable = true;
  # systemd.user.services.foot = {
  #   Service = {
  #     Restart = lib.mkForce "always";
  #     RestartSec = 2;
  #   };
  # };

  xdg.configFile."easyeffects/output/fw13-easy-effects.json".source =
    ../fw13-easy-effects.json;
  services.easyeffects = {
    enable = true;
    # preset = "fw13-easy-effects";
  };
}
