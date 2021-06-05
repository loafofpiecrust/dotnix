{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = inputs: {
    nixosConfigurations.loafofpiecrust = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit (inputs.nixpkgs) lib;
      modules = [
        ({ pkgs, lib, ... }: {
          # system.configurationRevision =
          #   inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
          nixpkgs.overlays = [
            # Import my local package definitions.
            (import ./pkgs)
            (import inputs.emacs-overlay)
            # Provide nixpkgs-unstable for just a few packages.
            (self: super: {
              unstable = import inputs.nixpkgs-unstable {
                # required to inherit from top-level nixpkgs.
                system = self.system;
                config.allowUnfree = self.config.allowUnfree;
              };
            })
          ];
        })

        ./laptop-720s.nix
      ];

    };
  };
}
