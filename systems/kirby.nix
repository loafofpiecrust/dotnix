{ config, lib, pkgs, inputs, ... }: {
  imports = let
    jovian = (
      # Put the most recent revision here:
      let revision = "d01c84e6e654685d202b11d16d65e4938521361c";
      in builtins.fetchTarball {
        url =
          "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
        # Update the hash as needed:
        sha256 = "sha256:06kc9pdrzrb3y91iv65hc83nccdc59g37hp5mfqa4k4nl5b0cni1";
      } + "/modules");
  in [
    ../desktop.nix
    "${jovian}/steamdeck"
    "${jovian}/overlay.nix"
    "${jovian}/steam.nix"
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
  ];

  system.stateVersion = "22.11";
  jovian.steam.enable = true;
  hardware.bluetooth.enable = true;
  # Steam network management requires network-manager, so I'm fine with using
  # that on this system instead of IWD.
  networking.networkmanager.enable = true;

  # hardware.fancontrol = {
  #   enable = true;
  # };

  boot = {
    plymouth.enable = true;
    # Use the zen kernel for a bit of extra performance.
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    initrd.kernelModules = [ "amdgpu" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
      "btusb"
      "amdgpu"
    ];
    kernelParams = [ "quiet" ];
  };

  networking.interfaces.wlan0.useDHCP = true;

  # Apps I want on my desktop machine
  environment.systemPackages = with pkgs; [
    gnome.gvfs
    vlc
    inkscape
    gimp
    mate.atril
    mate.caja
    mate.mate-system-monitor
    libreoffice
  ];

  nixpkgs.overlays = [
    (self: super: {
      kodi = super.kodi.withPackages (p: with p; [ netflix youtube ]);
    })
  ];

  location = {
    latitude = 37.820248;
    longitude = -122.284792;
  };
  time.timeZone = "America/Los_Angeles";

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # Do a monthly scrub of the btrfs volume.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = [ "/" ];
  fileSystems = let
    big-ssd = "/dev/disk/by-partlabel/trinity";
    small-ssd = "/dev/disk/by-partlabel/neo";
    subvolume = disk: name: {
      device = disk;
      fsType = "btrfs";
      options = [ "subvol=${name}" "compress=zstd" "noatime" ];
    };
  in {
    "/" = subvolume big-ssd "root";
    "/home" = subvolume big-ssd "home";
    "/nix" = subvolume big-ssd "nix";
    "/var/log" = subvolume big-ssd "log";
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
  };
}
