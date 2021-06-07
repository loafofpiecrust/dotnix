{ config, lib, pkgs, ... }:

{
  systemd.user.services.rclone-pcloud = {
    enable = true;
    reloadIfChanged = true;
    wantedBy = [ "graphical-session.target" ];
    after = [ "network.target" ];
    description = "Mount my PCloud storage as a drive";
    serviceConfig = {
      Type = "forking";
      User = "snead";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount pcloud: ~/pcloud --vfs-cache-mode full --no-modtime";
    };
  };
}
