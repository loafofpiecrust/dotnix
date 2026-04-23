# Common NixOS / nix-darwin module: registry, overlays, hostname.
# Each flake input is optional beyond the small set every host declares; we only
# wire registry entries and overlays when the corresponding input exists.
host:
{ lib, config, pkgs, inputs, ... }: {
  nix.registry = {
    agenix.flake = inputs.agenix;
  } // lib.optionalAttrs (inputs ? nixos-hardware) {
    nixos-hardware.flake = inputs.nixos-hardware;
  } // lib.optionalAttrs (inputs ? nixpkgs-unstable) {
    nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
  } // lib.optionalAttrs (inputs ? nur) { nur.flake = inputs.nur; };

  nixpkgs.overlays =
    lib.optionals (inputs ? emacs-overlay) [ (import inputs.emacs-overlay) ]
    ++ lib.optionals (inputs ? nixpkgs-unstable) [
      (self: super: {
        unstable = import inputs.nixpkgs-unstable {
          system = super.system;
          config = config.nixpkgs.config;
          overlays = lib.optionals (inputs ? nixpkgs-wayland) [
            inputs.nixpkgs-wayland.overlay
          ];
        };
      })
    ]
    ++ lib.optionals (inputs ? nur) [ inputs.nur.overlays.default ];

  networking.hostName = host;
}
