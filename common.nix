{ config, lib, pkgs, ... }:

{
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nixpkgs.config.allowUnfree = true;

  # TODO Pick a new TTY font.
  console = { keyMap = "us"; };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # I prefer ISO time and metric, which come with Danish English.
    extraLocaleSettings = let alt = "en_DK.UTF-8";
    in {
      LC_TIME = alt;
      LC_MEASUREMENT = alt;
    };
  };

  # Use pulseaudio for sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable networking. Use connman instead of networkmanager because it has
  # working iwd support. Saves battery and more reliable.
  networking.wireless.iwd.enable = true;

  # Allow other machines to ssh in.
  services.openssh.enable = true;
  # Remember ssh passwords for a few hours.
  # programs.ssh = {
  #   startAgent = false;
  #   agentTimeout = "2h";
  # };

  # Allow easy discovery of network devices (like printers).
  services = {
    avahi.enable = true;
    avahi.nssmdns = true;
    printing.enable = true;
  };

  # Add ~/bin to PATH for all users.
  environment.homeBinInPath = true;

  programs = {
    # Our two lovely shell choices, fish and zsh.
    fish.enable = true;
    dconf.enable = true;
    java.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
    # seahorse.enable = true; # GUI to manage keyring passwords.
  };

  # Clean up derivations older than a week and any garbage lying around.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Limit journal size
  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';

  # Hmm... Not sure why I explicitly set this.
  virtualisation.libvirtd.enable = false;

  environment.systemPackages = with pkgs; [
    # nixos necessities
    niv
    nix-prefetch-git

    # system tools
    binutils
    (ripgrep.override { withPCRE2 = true; })
    fd
    htop
    gksu
    zip
    unzip
    # ranger
    xfce.gvfs
    gnupg
    ncdu
    parted
    tree
    killall
    jmtpfs
    exfat
    moreutils
    gnutls

    # user tools
    stow
    fortune
    starship # shell prompt
    playerctl
    calc
    bitwarden-cli
  ];
}
