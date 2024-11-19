{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];
  programs.spicetify =
    let spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in {
      # Suddenly stopped working after resuming from suspend...?
      enable = false;
      theme = spicePkgs.themes.dracula;
      # enabledExtensions = with spicePkgs.extensions; [ keyboardShortcuts ];
      customColorScheme = let
        theme = config.lib.meta.theme.dark;
        dropHash = x: builtins.substring 1 10 x;
      in {
        text = dropHash theme.colors.brightwhite;
        subtext = dropHash theme.special.foreground;
        extratext = dropHash theme.colors.magenta;
        main = dropHash theme.special.background;
        sidebar = dropHash theme.colors.surface1;
        player = dropHash theme.colors.surface1;
        sec-player = dropHash theme.colors.comment;
        card = dropHash theme.colors.red;
        sec-card = dropHash theme.colors.comment; # 44475a
        shadow = "000000";
        selected-row = dropHash theme.colors.blue; # "bd93f9"
        button = dropHash theme.special.foreground;
        button-active = dropHash theme.colors.green;
        button-disabled = "6272a4";
        button-knob = dropHash theme.colors.yellow;
        tab-active = dropHash theme.colors.yellow;
        notification = dropHash theme.colors.yellow;
        notification-error = dropHash theme.colors.brightred;
        misc = dropHash theme.colors.green;
      };
    };
  # Fallback to unspiced spotify
  home.packages = lib.mkIf (!config.programs.spicetify.enable) [ pkgs.spotify ];
}
