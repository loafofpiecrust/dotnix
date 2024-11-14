{ config, lib, pkgs, ... }:

{
  imports = [ ./nixos.nix ];
  # Disable UI stuff
  environment.noXlibs = true;
  services.udisks2.enable = lib.mkDefault false;
  xdg.autostart.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
  xdg.icons.enable = false;
  services.fwupd.enable = false;

  # Disable extra shells, servers should normally use bash.
  # fish adds a big extra build step of generating completions from man pages,
  # which is only worth it on desktops.
  programs.fish.enable = false;
  programs.zsh.enable = false;

  # Servers don't usually need to print.
  services.printing.enable = false;
  hardware.sane.enable = false;

  # Turn off X
  services.xserver.enable = false;

  # Allow SSH connections in.
  services.openssh.enable = true;

  networking.firewall.enable = true;

  # Ignore lid events, in case this is a laptop server.
  services.logind.lidSwitch = "ignore";

  # Turn OFF any bluetooth hardware for servers.
  hardware.bluetooth.enable = false;

  # Turn off audio hardware for servers.
  sound.enable = false;
  services.pipewire.enable = false;

  # Allow the server to be resolved by hostname on the local network ('steve.local')
  services.avahi.publish = {
    enable = true;
    addresses = true;
    domain = true;
  };
}
