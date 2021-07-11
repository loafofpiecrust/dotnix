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

  security.doas.enable = true;
  security.sudo.enable = false;

  # Use pulseaudio for sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    config.pipewire = {
      "context.properties" = {
        "default.clock.quantum" = 2048;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 4096;
      };
    };
  };
  security.rtkit.enable = true;

  # Enable networking. Use connman instead of networkmanager because it has
  # working iwd support. Saves battery and more reliable.
  networking.wireless.iwd.enable = true;
  services.resolved.enable = true;
  networking.nameservers = ["8.8.8.8"];

  # Allow other machines to ssh in.
  # services.openssh.enable = true;
  # Remember ssh passwords for a few hours.

  # Allow easy discovery of network devices (like printers).
  services = {
    avahi.enable = true;
    avahi.nssmdns = true;
    printing.enable = true;
    printing.drivers = with pkgs; [ hplipWithPlugin gutenprint ];
  };

  # Add ~/bin to PATH for all users.
  environment.homeBinInPath = true;

  programs = {
    # Use fish for my shell.
    fish.enable = true;
    dconf.enable = true;
    java.enable = true;
    # GPG agent handles locked files and SSH keys.
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
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.fuse.userAllowOther = true;

  # Limit journal size
  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';

  # Hmm... Not sure why I explicitly set this.
  virtualisation.libvirtd.enable = false;

  nixpkgs.overlays = [
    (self: super: { ripgrep = super.ripgrep.override { withPCRE2 = true; }; })
  ];

  environment.systemPackages = with pkgs; [
    # nixos necessities
    nix-prefetch-git
    cachix

    # system tools
    binutils
    ripgrep
    fd
    htop
    gksu
    zip
    unzip
    # ranger
    # xfce.gvfs
    gnupg
    ncdu # disk usage analyzer
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
    bitwarden-cli # password manager
    rbw
  ];
}
