{ colorizer }:
let
  darken = color: percent:
    colorizer.oklchToHex
    (colorizer.darken (colorizer.hexToOklch color) percent);
  lighten = color: percent:
    colorizer.oklchToHex
    (colorizer.lighten (colorizer.hexToOklch color) percent);
in rec {
  dark = rec {
    commands = { emacs = "(load-theme 'modus-vivendi-tinted)"; };
    alpha = "100";
    # Theme-specific color names?
    # Pulled all the values from the Dracula spec: https://spec.draculatheme.com/

    # Pulled from preview screenshots of Dracula Pro
    # I know, I'm a thief and a pirate.
    dracula = {
      background = "#22212C";
      foreground = "#F8F8F3";
      selection = "#44475a";
      comment = "#7970A9";
      red = "#E64747";
      orange = "#FFCA81";
      yellow = "#FFFF80";
      green = "#7ADD74";
      purple = "#9580FF";
      cyan = "#81FFEA";
      pink = "#FF80BF";
    };
    special = {
      foreground = dracula.foreground;
      background = dracula.background;
      cursor = dracula.foreground;
    };
    colors = {
      # 16 terminal colors? Standard ANSI order?
      color0 = "#282936";
      color1 = "#3a3c4e";
      color2 = "#4d4f68";
      color3 = "#626483";
      color4 = "#62d6e8";
      color5 = "#e9e9f4";
      color6 = "#f1f2f8";
      color7 = "#f7f7fb";
      color8 = "#ea51b2";
      color9 = "#b45bcf";
      color10 = "#00f769";
      color11 = "#ebff87";
      color12 = "#a1efe4";
      color13 = "#62d6e8";
      color14 = "#b45bcf";
      color15 = "#00f769";

      # ANSI color names. Follows the spec, except I put orange in the ANSI
      # yellow slot and yellow in the ANSI brightyellow slot.
      black = "#21222c";
      red = dracula.red;
      green = dracula.green;
      yellow = dracula.orange;
      blue = dracula.purple;
      magenta = dracula.pink;
      cyan = dracula.cyan;
      white = dracula.foreground;
      brightblack = dracula.comment;
      brightred = "#ff6e6e";
      brightgreen = "#69ff94";
      brightyellow = dracula.yellow;
      brightblue = "#d6acff";
      brightmagenta = "#ff92df";
      brightcyan = "#a4ffff";
      brightwhite = "#ffffff";

      # 1-2 extra surface colors?
      surface1 = "#3a3c4e";
      surface2 = "#4d4f68";

      # Theme-dependent semantic references, all themes should use the same variable names.
      focus = dracula.pink;
      comment = dracula.comment;
    };
  };
  # Fill this in later.
  light = rec {
    # TODO setup adaptive emacs theme for daytime.
    commands = { emacs = "(load-theme 'modus-operandi)"; };
    alpha = "100";
    # Theme-specific color names?
    # Pulled all the values from the Dracula spec: https://spec.draculatheme.com/

    dracula = {
      background = "#F5F5F5";
      foreground = "#2A2A2A";
      selection = "#EBEBEF"; # light
      comment = "#7771A4"; # light
      red = "#AF3665"; # light
      orange = "#A95925"; # light
      yellow = "#ACA06E"; # light
      green = "#488D40"; # light
      purple = "#635D97";
      cyan = "#277CA3";
      pink = "#BF6085";
    };
    special = {
      foreground = dracula.foreground;
      background = dracula.background;
      cursor = dracula.foreground;
    };
    colors = {
      # 16 terminal colors? Standard ANSI order?
      color0 = "#282936";
      color1 = "#3a3c4e";
      color2 = "#4d4f68";
      color3 = "#626483";
      color4 = "#62d6e8";
      color5 = "#e9e9f4";
      color6 = "#f1f2f8";
      color7 = "#f7f7fb";
      color8 = "#ea51b2";
      color9 = "#b45bcf";
      color10 = "#00f769";
      color11 = "#ebff87";
      color12 = "#a1efe4";
      color13 = "#62d6e8";
      color14 = "#b45bcf";
      color15 = "#00f769";

      # ANSI color names. Follows the spec, except I put orange in the ANSI
      # yellow slot and yellow in the ANSI brightyellow slot.
      # TODO fill in the rest of the values using lightening functions.
      black = "#ffffff";
      red = dracula.red;
      green = dracula.green;
      yellow = dracula.orange;
      blue = dracula.purple;
      magenta = dracula.pink;
      cyan = dracula.cyan;
      white = dracula.foreground;
      brightblack = dracula.comment;
      brightred = darken colors.red 10;
      brightgreen = darken colors.green 10;
      brightyellow = dracula.yellow;
      brightblue = darken colors.blue 10;
      brightmagenta = darken colors.magenta 10;
      brightcyan = darken colors.cyan 10;
      brightwhite = "#000000";

      # 1-2 extra surface colors?
      surface1 = darken dracula.background 4;
      surface2 = darken dracula.background 8;

      # Theme-dependent semantic references, all themes should use the same variable names.
      focus = dracula.pink;
      comment = dracula.comment;
    };
  };
}
