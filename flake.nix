{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs = {
      url = "github:vlaci/nix-doom-emacs/fix-gccemacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, emacs-overlay, home-manager, nur
    , nix-doom-emacs }: {
      nixosConfigurations.loafofpiecrust = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit (nixpkgs) lib;
        modules = [
          ({ pkgs, lib, ... }: {
            # system.configurationRevision =
            #   inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
            nixpkgs.overlays = [
              # Import my local package definitions.
              (import ./pkgs)
              (import emacs-overlay)
              # Provide nixpkgs-unstable for just a few packages.
              (self: super: {
                unstable = import nixpkgs-unstable {
                  # required to inherit from top-level nixpkgs.
                  system = super.system;
                  config.allowUnfree = super.config.allowUnfree;
                };
              })
              nur.overlay
            ];
          })
          ./laptop-720s.nix
          home-manager.nixosModules.home-manager
          ({ lib, ... }:
            let
              mkUser = path: _: { imports = [ nix-doom-emacs.hmModule path ]; };
            in {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.snead = mkUser ./home/users/snead.nix;
              home-manager.users.work = mkUser ./home/users/work.nix;
            })
        ];
      };
    };
}
