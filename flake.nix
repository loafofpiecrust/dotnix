{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Contains Linux kernel 5.12, which I need for the framework laptop.
    nixpkgs-kernel.url =
      "github:nixos/nixpkgs/141439f6f11537ee349a58aaf97a5a5fc072365c";
    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.master.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home-manager = {
      url =
        "github:nix-community/home-manager/b0d769691cc379c9ab91d3acec5d14e75c02c02b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url =
        "github:nix-community/emacs-overlay/34624e82c790aa8c225aa9b7e98048cac289f505";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs = {
      url =
        "github:vlaci/nix-doom-emacs/fee14d217b7a911aad507679dafbeaa8c1ebf5ff";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
      inputs.straight.follows = "straight";
      inputs.doom-emacs.follows = "doom-emacs";
    };
    straight.url = "github:raxod502/straight.el";
    straight.flake = false;
    doom-emacs = {
      url = "github:hlissner/doom-emacs/develop";
      flake = false;
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, ... }@inputs:
    let
      specialArgs = { inherit inputs; };
      mkLinux = host: path: {
        "${host}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit (nixpkgs) lib;
          inherit specialArgs;
          modules = [ path { networking.hostName = host; } path ];
        };
      };
      mkDarwin = host: path: {
        "${host}" = darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [ path { networking.hostName = host; } ];
        };
      };
    in {
      # When you first setup a new machine, the hostname won't match yet.
      # $ darwin-rebuild switch --flake .#darwinConfigurations.careerbot13.system
      # After that:
      # $ darwin-rebuild switch --flake .
      darwinConfigurations =
        (mkDarwin "careerbot13" ./systems/laptop-outschool-macos.nix);

      nixosConfigurations =
        (mkLinux "portable-spudger" ./systems/framework-laptop.nix)
        // (mkLinux "loafofpiecrust" ./systems/laptop-720s.nix);
    };
}
