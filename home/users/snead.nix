{ config, lib, pkgs, ... }: {
  imports = [
    ../common.nix
    ../email.nix
    ../firefox.nix
    ../fish.nix
    ../sway.nix
    # ../hyprland.nix
    ../zsh.nix
  ];
  home.packages = with pkgs; [
    unstable.zoom-us
    unstable.discord
    # teams
    unstable.krita
    unstable.slack
    # deluge
    transmission-gtk
    zotero
    unstable.ripcord
    calibre # ebook manager
    rclone
    ledger

    # Music collection management
    strawberry
    flacon
    mac
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      background_opacity = 0.8;
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
