{ config, lib, pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit =
      "${pkgs.fortune}/bin/fortune -s | ${pkgs.pokemonsay}/bin/pokemonsay -N";
    shellAliases = { grep = "rg"; };
    # plugins = with pkgs.fishPlugins; [ done ];
    functions = {
      vterm_printf.body = ''
        if [ -n "$TMUX" ]
            # tell tmux to pass the escape sequences through
            # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
            printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
        else if string match -q -- "screen*" "$TERM"
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$argv"
        else
            printf "\e]%s\e\\" "$argv"
        end
      '';
    };
  };
  programs.starship.enableFishIntegration = true;
}
