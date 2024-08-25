# Configuration for users that do music production
{ pkgs, inputs, ... }: {
  # Use a separate input to lock my bitwig version at 5.0.11, since that's the
  # latest version my license supports.
  nixpkgs.overlays = [
    (self: super: {
      bitwig-studio = (import inputs.nixpkgs-bitwig {
        system = super.system;
        config = super.config;
      }).bitwig-studio;
    })
  ];
  home.packages = with pkgs; [ bitwig-studio ];
}
