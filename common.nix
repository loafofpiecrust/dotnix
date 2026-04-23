{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./cachix.nix ./overrides.nix ];

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
  ] ++ lib.optionals (inputs ? emacs-overlay) [ (import inputs.emacs-overlay) ]
  ++ lib.optionals (inputs ? nur) [ inputs.nur.overlays.default ]
  ++ lib.optionals (inputs ? nixpkgs-unstable && inputs ? emacs-overlay) [
    (self: super: {
      unstable = import inputs.nixpkgs-unstable {
        system = super.system;
        config.allowUnfree = true;
        overlays = [ (import inputs.emacs-overlay) ];
      };
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
