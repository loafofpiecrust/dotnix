{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./nixos.nix inputs.home-manager.nixosModules.home-manager ];

  # Home Manager setup
  home-manager.extraSpecialArgs = {
    inherit inputs;
    systemConfig = config;
  };
  home-manager.backupFileExtension = "bak";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Disable UI stuff
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
  services.printing.enable = lib.mkDefault false;
  hardware.sane.enable = lib.mkDefault false;

  # Turn off X
  services.xserver.enable = false;

  # Allow SSH connections in.
  services.openssh.enable = true;

  networking.firewall.enable = true;

  # Ignore lid events, in case this is a laptop server.
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # Turn OFF any bluetooth hardware for servers.
  hardware.bluetooth.enable = lib.mkDefault false;

  # Turn off audio hardware for servers.
  services.pipewire.enable = false;

  # Allow the server to be resolved by hostname on the local network ('steve.local')
  services.avahi.publish = {
    enable = lib.mkDefault true;
    addresses = true;
    domain = true;
  };
}
