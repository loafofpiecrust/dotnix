{ config, lib, pkgs, ... }: {
  imports = [
    ../common.nix
    ../email.nix
    ../firefox.nix
    ../chromium.nix
    ../fish.nix
    ../sway.nix
    ../hyprland.nix
    ../zsh.nix
    ../emacs.nix
  ];
  home.packages = with pkgs; [
    unstable.zoom-us
    unstable.discord
    # teams
    krita
    slack
    # deluge
    transmission-gtk
    zotero
    calibre # ebook manager
    rclone
    ledger

    # Music collection management
    strawberry # pretty good music player
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
      # background_opacity = 0.8;
      font.normal.family = "monospace";
      font.size = 11;
      window.padding = {
        x = 8;
        y = 8;
      };
    };
  };

  gtk.gtk3.bookmarks = [ "file:///home/snead/cloud" ];
  systemd.user.services.rclone-pcloud = {
    Unit = {
      After = [ "multi-user.target" ];
      Wants = [ "multi-user.target" ];
      Description = "Pcloud storage mounted as drive";
    };
    Install.WantedBy = [ "multi-user.target" ];
    Service = {
      Type = "simple";
      StateDirectory = "rclone/pcloud";
      CacheDirectory = "pcloud";
      ExecStart = let
        home = config.home.homeDirectory;
        script = pkgs.writeShellScript "mount-pcloud" ''
          ${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --allow-other --vfs-cache-mode full --no-modtime --dir-cache-time=30m --cache-dir=/tmp/rclone/vfs --cache-db-path=/tmp/rclone/db --cache-chunk-path=/tmp/rclone/chunks --cache-tmp-upload-path=/tmp/rclone/upload pcloud: $STATE_DIRECTORY
        '';
      in "${script}";
      Restart = "always";
      RestartSec = "240";
    };
  };

  systemd.user.services.rclone-pcloud-secret = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      Description = "Pcloud storage mounted as encrypted drive";
    };
    Install.WantedBy = [ "multi-user.target" ];
    Service = {
      Type = "simple";
      StateDirectory = "rclone/pcloud-secret";
      ExecStart = let
        home = config.home.homeDirectory;
        script = pkgs.writeShellScript "mount-pcloud" ''
          ${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --allow-other --vfs-cache-mode full --no-modtime --dir-cache-time=30m --cache-dir=/tmp/rclone/secret/vfs --cache-db-path=/tmp/rclone/secret/db --cache-chunk-path=/tmp/rclone/secret/chunks --cache-tmp-upload-path=/tmp/rclone/secret/upload pcloud-secret: $STATE_DIRECTORY
        '';
      in "${script}";
      Restart = "always";
      RestartSec = "60";
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
