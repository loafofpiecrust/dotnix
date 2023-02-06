{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./common.nix inputs.home-manager.nixosModules.home-manager ];

  # IMPORTANT! Allows system to load firmware directly from hardware devices.
  hardware.enableRedistributableFirmware = true;

  time.timeZone = lib.mkDefault "America/Los_Angeles";

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

  # Use doas instead of sudo.
  security.doas.enable = true;
  security.sudo.enable = false;

  # Use pipewire for sound, emulating ALSA and PulseAudio servers.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    config.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 44100;
        #"default.clock.quantum" = 2048;
        #"default.clock.min-quantum" = 1024;
        #"default.clock.max-quantum" = 4096;
      };
    };
  };
  security.rtkit.enable = true;

  # Allow other machines to ssh in.
  # services.openssh.enable = true;
  # Remember ssh passwords for a few hours.

  # Allow easy discovery of network devices (like printers).
  services = {
    avahi.enable = true;
    avahi.nssmdns = true;
    printing.enable = true;
    printing.drivers = with pkgs.unstable; [ hplipWithPlugin gutenprint ];
  };

  # Add ~/bin to PATH for all users.
  environment.homeBinInPath = true;

  programs = {
    # Use fish for my shell.
    fish.enable = true;
    dconf.enable = true;
    java.enable = true;
    # seahorse.enable = true; # GUI to manage keyring passwords.
  };

  programs.zsh = {
    enable = true;
    # Leave pretty much everything up to home-manager.
    # Enable completion here to get bash completions and ensure it's kosher with
    # installed packages.
    enableCompletion = true;
    enableGlobalCompInit = false;
    promptInit = "";
  };

  programs.fuse.userAllowOther = true;

  # Limit journal size
  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';

  # Hmm... Not sure why I explicitly set this.
  # virtualisation.libvirtd.enable = false;

  environment.systemPackages = with pkgs; [
    # nixos necessities
    nix-prefetch-git
    cachix
    fzf

    # system tools
    binutils
    ripgrep
    fd
    htop
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
    playerctl
    pulseaudio
    calc
  ];
}
