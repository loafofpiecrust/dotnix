{ config, lib, pkgs, ... }: {
  imports = [
    ../common.nix
    ../email.nix
    ../firefox.nix
    ../chromium.nix
    ../fish.nix
    ../sway.nix
    ../spotify.nix
    ../hyprland.nix
    ../zsh.nix
    ../emacs.nix
  ];
  home.packages = with pkgs; [
    unstable.zoom-us
    # discord
    # teams
    krita
    slack
    # deluge
    transmission_4-gtk
    zotero
    calibre # ebook manager
    rclone
    ledger

    # Music collection management
    strawberry # pretty good music player
    deadbeef # simple backup music player, in case QT is broken.
    flacon # extracts disc files into individual tracks
    sox # resamples FLAC files
    mac # converts .ape files
    normalize # normalizes volume within a folder, good for making mix CDs
    wavpack
  ];

  programs.ranger = {
    enable = true;
    package = pkgs.ranger-plus;
    settings = {
      preview_images = false;
      preview_images_method = "kitty";
    };
    # Redirect file opening to xdg-open for some mime types.
    rifle = [
      {
        condition = "mime ^image|^video|^audio, has xdg-open, flag f";
        command = ''xdg-open "$1"'';
      }
      {
        condition =
          "ext iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has xdg-open";
        command = ''xdg-open "$1"'';
      }
    ];
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    shellIntegration.mode = "no-cursor";
    settings = {
      window_padding_width = 4;
      cursor_shape = "block";
      background_opacity = "0.8";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "monospace";
      font.size = 11;
      window.opacity = 0.8;
      window.padding = {
        x = 8;
        y = 8;
      };
    };
  };

  # gtk.gtk3.bookmarks = [ "file:///home/snead/cloud" ];
  systemd.user.services.mount-pcloud = {
    Unit = {
      # Wants = [ "multi-user.target" ];
      Description = "UNENCRYPTED cloud storage mounted as drive";
    };
    # Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      mountDir = "${home}/unencrypted-cloud";
    in {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --vfs-cache-mode full pcloud: ${mountDir}";
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountDir}";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
  };

  systemd.user.services.mount-pcrypt = {
    Unit = {
      # After = [ "network-online.target" ];
      # Wants = [ "network-online.target" ];
      Description = "Cloud storage mounted as encrypted drive";
    };
    # Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      mountDir = "${home}/cloud";
    in {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --vfs-cache-mode writes pcloud-secret: ${mountDir}";
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountDir}";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      # Restart = "always";
      # RestartSec = "60";
    };
  };

  systemd.user.services.mount-nas = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      Description = "NAS mounted as encrypted drive";
    };
    Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      mountDir = "${home}/nas";
    in {
      Type = "notify";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --vfs-cache-mode writes --vfs-read-chunk-streams 8 --vfs-read-chunk-size 64M --buffer-size 32M --vfs-cache-max-size 5G --transfers 8 --file-perms=0777 nas-secret: ${mountDir}";
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountDir}";
      Environment = [
        "PATH=/run/wrappers/bin/:$PATH"
        "SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh"
      ];
      # Restart = "always";
      # RestartSec = "60";
    };
  };

  # Sync notes folder every 30m and when local changes are made, debounced to
  # sync every 2m at most.
  systemd.user.services.sync-notes = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      Description = "Sync notes with encrypted cloud storage";
    };
    Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      notes = "${home}/documents/notes";
    in {
      Type = "exec";
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "sync-notes";
          runtimeInputs = with pkgs; [ rclone inotify-tools coreutils ];
          text = let
            doSync =
              "rclone bisync pcloud-secret:notes ${notes} --config ${home}/.config/rclone/rclone.conf --compare size,modtime,checksum --slow-hash-sync-only --resilient -MP --track-renames --conflict-resolve newer";
          in ''
            ${doSync}
            inotifywait -q -m -t 1800 --format "%w%f" ${notes} |\
            while read -r path; do
              echo "$path" changed
              echo "Skipping $(timeout 120 cat | wc -l) further changes"
              ${doSync}
            done
          '';
        };
      in "${script}/bin/sync-notes";
      Restart = "always";
      RestartSec = "30";
    };
  };

  # systemd.user.services.backup-home = {
  #   Unit = {
  #     Description = "Backup home folder";
  #   };
  # };

  programs.go = {
    enable = true;
    goPath = ".go";
  };
}
