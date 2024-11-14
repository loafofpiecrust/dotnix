{
  light = let
    base16 = {
      # color0 = "#dce0e8"; # crust (instead of base)
      # color1 = "#e6e9ef"; # mantle
      # color2 = "#ccd0da"; # surface0
      # color3 = "#bcc0cc"; # surface1
      # color4 = "#9ca0b0"; # overlay0 (instead of surface2)
      # color5 = "#4c4f69"; # text
      color0 = "#dce0e8"; # crust (instead of base)
      color1 = "#e6e9ef"; # mantle
      color2 = "#ccd0da"; # surface0
      color3 = "#bcc0cc"; # surface1
      color4 = "#04a5e5"; # sky
      color5 = "#ea76cb"; # pink!
      color6 = "#dc8a78"; # rosewater
      color7 = "#7287fd"; # lavender

      color8 = "#d20f39"; # red
      color9 = "#fe640b"; # peach
      color10 = "#df8e1d"; # yellow
      color11 = "#40a02b"; # green
      color12 = "#179299"; # teal
      color13 = "#1e66f5"; # blue
      color14 = "#8839ef"; # mauve
      color15 = "#dd7878"; # flamingo
    };
  in { # catppuccin latte
    emacs = "(+snead/load-theme 'daytime)";
    alpha = "100";
    special = {
      background = "#eff1f5";
      foreground = "#4c4f69";
      cursor = "#4c4f69";
    };
    colors = base16;
    legacycolors = {
      color0 = base16.color0;
      color1 = base16.color8;
      color2 = base16.color11;
      color3 = base16.color10;
      color4 = base16.color13;
      color5 = base16.color14;
      color6 = base16.color12;
      color7 = base16.color5;
      color8 = base16.color3;
      color9 = base16.color8;
      color10 = base16.color11;
      color11 = base16.color10;
      color12 = base16.color13;
      color13 = base16.color14;
      color14 = base16.color12;
      color15 = base16.color7;
    };
  };

  dark = { # catppuccin macchiato
    emacs = "(+snead/load-theme 'night)";
    alpha = "100";
    special = {
      background = "#24273a";
      foreground = "#cad3f5";
      cursor = "#cad3f5";
    };
    colors = {
      # color0 = "#24273a"; # base
      # color1 = "#1e2030"; # mantle
      # color2 = "#363a4f"; # surface0
      # color3 = "#494d64"; # surface1
      # color4 = "#5b6078"; # surface2
      # color5 = "#cad3f5"; # text
      color0 = "#1e2030"; # mantle
      color1 = "#363a4f"; # surface0
      color2 = "#494d64"; # surface1
      color3 = "#5b6078"; # surface2
      color4 = "#91d7e3"; # sky!
      color5 = "#f5bde6"; # pink!
      color6 = "#f4dbd6"; # rosewater
      color7 = "#b7bdf8"; # lavender

      color8 = "#ed8796"; # red
      color9 = "#f5a97f"; # peach
      color10 = "#eed49f"; # yellow
      color11 = "#a6da95"; # green
      color12 = "#8bd5ca"; # teal
      color13 = "#8aadf4"; # blue
      color14 = "#c6a0f6"; # mauve
      color15 = "#f0c6c6"; # flamingo
    };
  };
}
