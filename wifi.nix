{ config, lib, pkgs, ... }:

{
  networking = {
    # Enable networking. Use connman instead of networkmanager because it has
    # working iwd support. Saves battery and more reliable.
    wireless.iwd.enable = lib.mkDefault true;
    nameservers = [ "8.8.8.8" ];

    # Use better DNS resolution service, networkd + resolved.
    # useNetworkd = true;
    # dhcpcd.enable = false;

    # Use DHCP only on specific network interfaces.
    useDHCP = false;
    firewall.enable = lib.mkDefault true;
  };

  # services.resolved.enable = true;
}
