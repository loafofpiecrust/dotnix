{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./cachix.nix ];

  environment.systemPackages = with pkgs; [
    zlib
    unrar
    cowsay
    pokemonsay
    usbutils
    pciutils
    atool
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # Clean up derivations older than a week and any garbage lying around.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: { ripgrep = super.ripgrep.override { withPCRE2 = true; }; })
    # Import my local package definitions.
    (import ./pkgs)
    (import inputs.emacs-overlay)
    inputs.nur.overlays.default
    # Provide nixpkgs-unstable for just a few packages.
    (self: super: {
      unstable = import inputs.nixpkgs-unstable {
        # required to inherit from top-level nixpkgs.
        system = super.system;
        config.allowUnfree = true;
        overlays = [ (import inputs.emacs-overlay) ];
      };
      fwupd = super.fwupd.overrideAttrs (old: {
        passthru.defaultDisabledPlugins = [ ];
        passthru.filesInstalledToEtc =
          lib.remove "fwupd/remotes.d/lvfs-testing.conf"
          old.passthru.filesInstalledToEtc;
      });
    })
  ];

  # Ensure postgres can create a lockfile where it expects
  system.activationScripts = {
    postgresqlMkdir = {
      text = "mkdir -p /run/postgresql && chmod o+w /run/postgresql";
      deps = [ ];
    };
  };

  programs.git = {
    enable = true;
    # package = pkgs.gitAndTools.gitFull;
    lfs.enable = true;
  };
}
