{ config, lib, pkgs, ... }:

{
  imports = [ ../common.nix ../email.nix ../firefox.nix ../fish.nix ];
  home.packages = with pkgs; [
    zoom-us
    discord
    ledger
    krita
    calibre # ebook manager
    deluge
  ];

  systemd.user.services.rclone-pcloud = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      Description = "Mount my PCloud storage as a drive";
    };
    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount --config=${config.home.homeDirectory}/.config/rclone/rclone.conf --allow-other --vfs-cache-mode full --no-modtime --dir-cache-time=30m --cache-dir=/tmp/rclone/vfs --cache-db-path=/tmp/rclone/db --cache-chunk-path=/tmp/rclone/chunks --cache-tmp-upload-path=/tmp/rclone/upload pcloud: ${config.home.homeDirectory}/pcloud
      '';
    };
  };

  programs.go = {
    enable = true;
    goPath = ".go";
  };

  home.file.".sbclrc".source = ../lisp/.sbclrc;
}
