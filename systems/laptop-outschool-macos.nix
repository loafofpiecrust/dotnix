{ config, pkgs, ... }:

{
  imports = [ ../darwin.nix ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    _1password
    vim
    nur.repos.toonn.apps.firefox
    ripgrep
    fd
    dune_2
    heroku
    jq
    nodejs-14_x
    yarn
    awscli
    aws-vault
    postgresql
    nixfmt
    shfmt
    cmake
    libtool
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (self: super: { emacsCustom = self.emacsGcc; }) ];
  nix.useSandbox = true;

  # Details of the yabai configuration: https://cmacr.ae/post/2020-05-13-yabai-module-in-nix-darwin-now-generally-available/
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
    config = {
      layout = "bsp";
      window_gap = 8;
      bottom_padding = 8;
      left_padding = 8;
      right_padding = 8;
      split_ratio = "0.50";
      mouse_modifier = "fn";
    };
    # Emacs requires an extra rule to be tiled.
    # TODO Firefox popup windows need the opposite rule.
    extraConfig = ''
      yabai -m rule --add app=Emacs manage=on
      yabai -m config --space 1 layout float
    '';
  };

  time.timeZone = "America/Los_Angeles";

  system.keyboard.remapCapsLockToEscape = true;
  system.defaults = {
    dock = {
      tilesize = 32;
      autohide = true;
      orientation = "bottom";
      minimize-to-application = true;
      mru-spaces = false;
      show-recents = false;
    };
    NSGlobalDomain = {
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
    };
  };

  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [ fira-code overpass emacs-all-the-icons-fonts ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  home-manager.users."taylor@outschool.com" = ../home/users/outschool.nix;
}
