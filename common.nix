{ config, lib, pkgs, inputs, ... }: {
  # Pass flake inputs to home-manager modules.
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  environment.systemPackages = [ pkgs.zlib pkgs.unrar ];

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
    inputs.nur.overlay
    # Provide nixpkgs-unstable for just a few packages.
    (self: super: {
      unstable = import inputs.nixpkgs-unstable {
        # required to inherit from top-level nixpkgs.
        system = super.system;
        config.allowUnfree = true;
        overlays = [ (import inputs.emacs-overlay) ];
      };
      fwupd = super.fwupd.overrideAttrs (old: {
        passthru.defaultDisabledPlugins = [];
	passthru.filesInstalledToEtc = lib.remove "fwupd/remotes.d/lvfs-testing.conf" old.passthru.filesInstalledToEtc;
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
    package = pkgs.gitAndTools.gitFull;
    lfs.enable = true;
  };
}
