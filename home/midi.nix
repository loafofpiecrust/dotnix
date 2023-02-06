# Configuration for users that do music production
{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ bitwig-studio ];
}
