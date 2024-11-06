{ config, lib, pkgs, ... }: {
  programs.fish = {
    enable = false;
    # interactiveShellInit = ''
    #   cat ~/.cache/wal/sequences
    #   ${pkgs.fortune}/bin/fortune -s | ${pkgs.pokemonsay}/bin/pokemonsay -N
    # '';
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
  programs.starship.enableBashIntegration = true;
  programs.starship.enableFishIntegration = true;
  programs.bash = {
    enable = true;
    # shellAliases = { grep = "rg"; };
    initExtra = ''
      cat ~/.cache/wal/sequences
      source ${pkgs.blesh}/share/blesh/ble.sh --rcfile ~/.config/.blerc
      ${pkgs.fortune}/bin/fortune -s | ${pkgs.pokemonsay}/bin/pokemonsay -N
    '';
  };

  xdg.configFile.".blerc".text = ''
    set -o vi
    ble-face -s argument_error            'fg=red,underline'
    ble-face -s auto_complete             'fg=black,bg=silver'
    ble-face -s cmdinfo_cd_cdpath         'fg=navy,bg=yellow'
    ble-face -s command_directory         'fg=blue,underline'
    ble-face -s command_function          'fg=magenta'
    ble-face -s disabled                  'fg=silver'
    ble-face -s filename_directory        'fg=blue,underline'
    ble-face -s filename_directory_sticky 'fg=white,bg=blue,underline'
    ble-face -s filename_orphan           'fg=cyan,bg=brown,underline'
    ble-face -s filename_setgid           'fg=black,bg=lime,underline'
    ble-face -s filename_setuid           'fg=black,bg=yellow,underline'
    ble-face -s overwrite_mode            'fg=black,bg=cyan'
    ble-face -s prompt_status_line        'fg=white,bg=gray'
    ble-face -s region                    'fg=white,bg=navy'
    ble-face -s region_insert             'fg=blue,bg=silver'
    ble-face -s region_match              'fg=white,bg=navy'
    ble-face -s region_target             'fg=black,bg=cyan'
    ble-face -s syntax_brace              'fg=teal,bold'
    ble-face -s syntax_comment            'fg=silver'
    ble-face -s syntax_document           'fg=olive'
    ble-face -s syntax_document_begin     'fg=olive,bold'
    ble-face -s syntax_error              'fg=white'
    ble-face -s syntax_expr               'fg=blue'
    ble-face -s syntax_function_name      'fg=magenta,bold'
    ble-face -s syntax_glob               'fg=magenta,bold'
    ble-face -s syntax_history_expansion  'fg=white,bg=brown'
    ble-face -s syntax_param_expansion    'fg=magenta'
    ble-face -s syntax_tilde              'fg=blue,bold'
    ble-face -s syntax_varname            'fg=olive'
    ble-face -s varname_array             'fg=olive,bold'
    ble-face -s varname_empty             'fg=teal'
    ble-face -s varname_export            'fg=megenta,bold'
    ble-face -s varname_expr              'fg=blue,bold'
    ble-face -s varname_hash              'fg=green,bold'
    ble-face -s varname_number            'fg=olive'
    ble-face -s varname_readonly          'fg=magenta'
    ble-face -s varname_transform         'fg=teal,bold'
    ble-face -s varname_unset             'fg=silver'
    ble-face -s vbell_erase               'bg=silver'
  '';
}
