{ inputs, config, lib, pkgs, ... }:

{
  # Allow this config to be built as an SD-card installation image.
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  # Install extra convenience packages
  environment.systemPackages = with pkgs; [ htop vim git powertop ];

  # Options for the initial installation image
  sdImage = {
    imageBaseName = "nixos-rpi-server";
    compressImage = false;
  };

  # Enable OpenSSH so we can connect to it!
  services.openssh.enable = true;

  # Allow non-free firmware
  hardware.enableRedistributableFirmware = true;

  # Selected pieces of minimal profile
  environment.noXlibs = true;
  services.udisks2.enable = false;
  xdg.autostart.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
  xdg.icons.enable = false;

  # Limit journal size
  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';

  boot.loader.raspberryPi.version = 3;
  boot.loader.timeout = 5;

  # Enable basic ALSA audio
  sound.enable = false;
  # Enables audio and allows booting without HDMI
  boot.loader.raspberryPi.firmwareConfig = ''
    disable_splash=1
    boot_delay=0
    dtparam=audio=off
    hdmi_force_hotplug=1
    hdmi_blanking=2
    dtoverlay=pi3-disable-bt
  '';
  boot.kernelParams = [ "console=ttyS1,115200n8" "psi=1" "quiet" ];
  boot.blacklistedKernelModules = [ "btusb" ];

  nix.settings = {
    # Trust sudo users to send nix packages over
    trusted-users = [ "@wheel" ];
    # Limit nix to 2 cores in case of long rebuilds
    max-jobs = 2;
    auto-optimise-store = true;
  };
  nix.daemonCPUSchedPolicy = "batch";
  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';

  # Allow sudo without password to let remote builds come through easier.
  security.sudo.wheelNeedsPassword = false;

  # Always use a firewall!!
  networking.firewall.enable = true;

  # Setup default filesystems as per SD installation
  fileSystems = {
    # TODO May need optimization for running a server.
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      neededForBoot = true;
      options = [ "defaults" "noatime" ];
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "nofail" "noauto" ];
    };
  };
}
