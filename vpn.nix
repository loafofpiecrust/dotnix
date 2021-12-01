{ config, lib, pkgs, ... }: {
  services.openvpn.servers = {
    panama = {
      autoStart = false;
      # TODO put vpn files somewhere better or move config here.
      config = "config /home/snead/downloads/ovpn-files/UDP/at2-ovpn-udp.ovpn";
    };
  };
}
