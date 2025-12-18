{ config, lib, pkgs, ... }:

{

  xdg.configFile."beets/config.yaml".source =
    config.lib.meta.mkMutableSymlink ./beets.yaml;

  xdg.configFile."ncmpcpp/config".source =
    config.lib.meta.mkMutableSymlink ./ncmpcpp.conf;

  home.packages = with pkgs; [
    # simple cli for mpd management
    mpc
    # Classic terminal mpd player
    ncmpcpp
    # Newer terminal mpd player with album art support
    rmpc
    mediainfo
    ffmpegthumbnailer
    # GTK player focused on album covers
    plattenalbum

    # Music collection management
    strawberry # pretty good music player
    # deadbeef # simple backup music player, in case QT is broken.
    flacon # extracts disc files into individual tracks
    sox # resamples FLAC files
    monkeysAudio # converts .ape files
    normalize # normalizes volume within a folder, good for making mix CDs
    wavpack
  ];

  # Default port should be localhost:6600
  # Run MPD for a standard music server that builds a secondary database of my
  # music for listening, which can move to other devices since I think it uses
  # relative paths. Plus it's very capable of handling large libraries and runs
  # in the background unlike Strawberry.
  services.mpd = {
    enable = true;
    extraConfig = ''
      follow_inside_symlinks "yes"
      follow_outside_symlinks "yes"
      auto_update "no"
      save_absolute_paths_in_playlists "yes"
      restore_paused "yes"
      replaygain "auto"
    '';
    musicDirectory = "/mnt/music";
    playlistDirectory = "${config.home.homeDirectory}/music/playlists";
    # Bind to a socket rather than a TCP port to allow playing random local
    # files. Bonus to reduce network surface, a unix socket is more efficient
    # than TCP.
    network = { listenAddress = "${config.services.mpd.dataDir}/socket"; };
  };

  systemd.user.services.mpd.Unit.After = [ "mount-nas.service" ];
  systemd.user.services.mpd.Unit.Requires = [ "mount-nas.service" ];

  # Support standard system media controls for the MPD server
  services.mpd-mpris = {
    enable = true;
    mpd = {
      useLocal = false;
      host = config.services.mpd.network.listenAddress;
      network = "unix";
    };
  };
}
