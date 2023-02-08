{ config, lib, pkgs, ... }: {
  hardware.bluetooth.package = pkgs.bluezFull;

  # Support media controls from bluetooth headsets.
  systemd.user.services = lib.mkIf config.hardware.bluetooth.enable {
    bluetooth-mpris-proxy = {
      wantedBy = [ "default.target" ];
      after = [ "network.target" "sound.target" ];
      script = "${config.hardware.bluetooth.package}/bin/mpris-proxy";
    };
  };
}
