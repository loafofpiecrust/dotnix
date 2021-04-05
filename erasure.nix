{ config, lib, pkgs, modulesPath, ... }: {
  # Save these files between boots by putting them on /persist
  systemd.tmpfiles.rules = map (x: "L ${x} - - - - /persist/${x}") [
    "/var/lib/iwd"
    "/var/lib/upower"
    "/var/lib/bluetooth"
  ];
  environment.etc = {
    machine-id.source = "/persist/etc/machine-id";
    adjtime.source = "/persist/etc/adjtime";
    nixos.source = "/persist/etc/nixos";
    NIXOS.source = "/persist/etc/NIXOS";
  };

  services.openssh.hostKeys = [
    { path = "/persist/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    { path = "/persist/etc/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
  ];

}
