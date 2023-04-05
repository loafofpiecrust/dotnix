{ config, lib, pkgs, inputs, ... }: {
  imports = [ ./wayland.nix inputs.hyprland.homeManagerModules.default ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.hidpi = true;
    extraConfig = ''
      bind=SUPER,Q,exec,foot
      monitor=,preferred,auto,1
      general {
        resize_on_border = true
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
    '';
  };
}
