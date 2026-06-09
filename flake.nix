{
  description = "Aggregated NixOS / nix-darwin; each host under systems/ has its own flake + lock.";
  inputs = {
    panorama.url = "path:./systems/panorama";
    portable-spudger.url = "path:./systems/portable-spudger";
    kirby.url = "path:./systems/kirby";
    vivian.url = "path:./systems/vivian";
  };
  outputs =
    inputs@{ self, ... }:
    {
      darwinConfigurations = with inputs; panorama.darwinConfigurations;
      nixosConfigurations =
        with inputs;
        portable-spudger.nixosConfigurations // kirby.nixosConfigurations // vivian.nixosConfigurations;
    };
}
