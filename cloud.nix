{ config, lib, pkgs, ... }:

{
  # systemd.user.services.rclone-pcloud = {
  #   enable = false;
  #   wantedBy = [ "graphical-session.target" ];
  #   after = [ "network.target" ];
  #   description = "Mount my PCloud storage as a drive";
  #   # unitConfig = { AssertPathIsDirectory = "~/.pcloud"; };
  #   path = with pkgs; [ rclone fuse ];
  #   restartIfChanged = true;
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "snead";
  #     # Group = "snead";
  #     ExecStart =
  #       "rclone mount --config=/home/snead/.config/rclone/rclone.conf --allow-other --vfs-cache-mode full --no-modtime --dir-cache-time=30m --cache-dir=/tmp/rclone/vfs --cache-db-path=/tmp/rclone/db --cache-chunk-path=/tmp/rclone/chunks --cache-tmp-upload-path=/tmp/rclone/upload pcloud: /home/snead/pcloud";
  #   };
  # };
}
