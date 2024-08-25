{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./common.nix ];

  # IMPORTANT! Allows system to load firmware directly from hardware devices.
  hardware.enableRedistributableFirmware = true;

  time.timeZone = lib.mkDefault "America/Los_Angeles";

  # TODO Pick a new TTY font.
  console = { keyMap = "us"; };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # TODO Remove this? I used to be weirdly convinced of using ISO measurements.
    # I prefer ISO time and metric, which come with Danish English.
    # extraLocaleSettings = let alt = "en_DK.UTF-8";
    # in {
    #   LC_TIME = alt;
    #   LC_MEASUREMENT = alt;
    # };
  };

  # Go back to sudo from doas, since it's the ubiquitous standard and the 2021
  # CVE has been resolved.
  security.sudo = {
    enable = true;
    execWheelOnly = true; # Fixes the 2021 CVE
    wheelNeedsPassword = lib.mkDefault true;
  };

  # Add an alias so that I can ask my computer to PLEASE do stuff.
  environment.shellAliases = { please = "sudo"; };

  # Use pipewire for sound, emulating ALSA and PulseAudio servers.
  services.pipewire = {
    enable = lib.mkDefault true;
    audio.enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # config.pipewire = {
    #   "context.properties" = {
    #     "default.clock.rate" = 44100;
    #     #"default.clock.quantum" = 2048;
    #     #"default.clock.min-quantum" = 1024;
    #     #"default.clock.max-quantum" = 4096;
    #   };
    # };
  };
  security.rtkit.enable = true;

  # Allow other machines to ssh in.
  # services.openssh.enable = true;
  # Remember ssh passwords for a few hours.

  # Allow easy discovery of network devices (like printers).
  services = {
    avahi.enable = true;
    avahi.nssmdns4 = true;
    avahi.openFirewall = true;
    printing.enable = lib.mkDefault true;
    printing.drivers = with pkgs; [ hplip gutenprint ];
  };

  # Add ~/bin to PATH for all users.
  environment.homeBinInPath = true;

  programs = {
    # Use fish for my shell.
    fish.enable = lib.mkDefault true;
    # seahorse.enable = true; # GUI to manage keyring passwords.
  };

  programs.zsh = {
    enable = lib.mkDefault false;
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
    sshfs

    # user tools
    playerctl
    pulseaudio
    calc
  ];

  # Allow OTA firmware updates from the testing channel.
  services.fwupd.enable = lib.mkDefault true;
  environment.etc."fwupd/remotes.d/lvfs-testing.conf" = {
    source = ./fwupd-lvfs-testing.conf;
  };
  environment.etc."fwupd/uefi_capsule.conf".source =
    lib.mkForce ./fwupd-uefi-capsule.conf;

  # TODO Figure out what the hell package uses python 2.7 still.
  nixpkgs.config.permittedInsecurePackages = [ "python-2.7.18.6" ];
}
