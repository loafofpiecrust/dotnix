# Specific to snead user, only on framework laptop
{ config, lib, pkgs, ... }: {
  imports = [ ./snead.nix ../midi.nix ../music.nix ];

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
    qimgv

    fontforge-gtk
    transmission-remote-gtk

    whitesur-gtk-theme
    whitesur-cursors
    whitesur-icon-theme
    unstable.nwg-look

    pomodoro-gtk
    obsidian # note taking
    # darktable # photo editing
    unison
  ];

  # Don't use the server because it'll keep programs running after I close their window!
  # programs.foot.server.enable = true;
  # systemd.user.services.foot = {
  #   Service = {
  #     Restart = lib.mkForce "always";
  #     RestartSec = 2;
  #   };
  # };

  # No longer necessary with AMD board, they tweaked the speaker config!
  # It now amplifies loud enough and with better EQ.
  xdg.configFile."easyeffects/output/fw13-easy-effects.json".source =
    ../fw13-easy-effects.json;
  services.easyeffects = {
    enable = false;
    # preset = "fw13-easy-effects";
  };

  programs.git = {
    userName = "loafofpiecrust";
    userEmail = "shelby@snead.xyz";
    extraConfig = {
      github.user = "loafofpiecrust";
      # easy sign commits with ssh key
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      commit.gpgsign = true;
    };
  };

  services.gpg-agent.enableSshSupport = false;
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    controlMaster = "auto";
    forwardAgent = true;
    extraConfig = ''
      Host kirby
        IdentityFile ~/.ssh/id_ed25519
        User shelby
      # Automatically use LAN IP for my server when at home and public domain away from home.
      Match host kirby exec "iwctl station wlan0 show | rg 'Crows Use Tools'"
        Hostname 192.168.0.109
      Match host kirby
        Hostname server.snead.xyz
    '';
  };
}
