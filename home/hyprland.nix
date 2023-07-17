{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./wayland.nix inputs.hyprland.homeManagerModules.default ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.hidpi = true;
    extraConfig = ''
      exec-once = waybar
      bind=SUPER,Q,exec,foot
      monitor=,preferred,auto,1
      monitor=eDP1,2256x1504@60,0x0,1.25
      monitor=desc:Acer Technologies XV272U 0x0000BFCC,2560x1440@144,2256x0,1
      workspace = 1, monitor:eDP-1, default: true
      workspace = 2, monitor:eDP-1
      workspace = 3, monitor:eDP-1
      workspace = 4, monitor:eDP-1
      workspace = 5, monitor:DP-4, default: true
      workspace = 6, monitor:DP-4
      workspace = 7, monitor:DP-4
      workspace = 8, monitor:DP-4
      workspace = 9, monitor:DP-4
      workspace = 10, monitor:DP-4
      general {
        resize_on_border = true
        gaps_in = 8
        gaps_out = 8
        border_size = 2
      }
      decoration {
        rounding = 4
      }
      misc {
        disable_autoreload = true
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }
      dwindle {
        preserve_split = true
        pseudotile = true
      }
      input {
        kb_layout = us
        repeat_delay = 300
        repeat_rate = 20
        follow_mouse = 1

        touchpad {
          natural_scroll = true
          middle_button_emulation = true
          clickfinger_behavior = true
          scroll_factor = 0.25
        }
      }
      device:Kensington_Expert_Mouse {
        natural_scroll = true
        scroll_method = on_button_down
        scroll_button = 8
        scroll_factor = 0.1
      }
    '';
  };
}
