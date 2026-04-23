{
  description =
    "Aggregated NixOS / nix-darwin; each host under systems/ has its own flake + lock.";
  inputs = {
    ShelbySneadMB.url = "path:./systems/ShelbySneadMB";
    portable-spudger.url = "path:./systems/portable-spudger";
    kirby.url = "path:./systems/kirby";
    vivian.url = "path:./systems/vivian";
  };
  outputs = inputs@{ self, ... }: {
    darwinConfigurations = with inputs; ShelbySneadMB.darwinConfigurations;
    nixosConfigurations = with inputs;
      portable-spudger.nixosConfigurations // kirby.nixosConfigurations
      // vivian.nixosConfigurations;
  };
}
