{ config, lib, pkgs, ... }: {
  services.openvpn.servers = {
    bahamas = {
      autoStart = false;
      config = ''
        config /home/snead/documents/pia/bahamas.ovpn
        auth-user-pass /home/snead/documents/pia/user-pass.txt
      '';
    };
  };
}
