{ config, lib, pkgs, ... }: {
  # GUI control center for bluetooth, if enabled.
  services.blueman.enable = true;

  hardware.bluetooth.disabledPlugins = [ "sap" ];

  # systemd.services.bluetooth.serviceConfig = {
  #   ConfigurationDirectoryMode = "0755";
  # };

  # Support media controls from bluetooth headsets.
  systemd.user.services = lib.mkIf config.hardware.bluetooth.enable {
    bluetooth-mpris-proxy = {
      wantedBy = [ "default.target" ];
      after = [ "network.target" "sound.target" ];
      script = "${config.hardware.bluetooth.package}/bin/mpris-proxy";
    };
  };
}
