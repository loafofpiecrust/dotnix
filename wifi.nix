{ config, lib, pkgs, ... }:

{
  networking = {
    # Enable networking. Use connman instead of networkmanager because it has
    # working iwd support. Saves battery and more reliable.
    wireless.iwd.enable = lib.mkDefault true;
    # Cloudflare DNS!
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    # Use better DNS resolution service, networkd + resolved.
    # useNetworkd = true;
    # dhcpcd.enable = false;

    # Use DHCP only on specific network interfaces.
    useDHCP = false;
    firewall.enable = lib.mkDefault true;

    # Use faster more local time servers.
    timeServers = [ "time.google.com" "pool.ntp.org" ];
  };

  # services.resolved.enable = true;
}
