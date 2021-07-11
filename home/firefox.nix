{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ tridactyl-native ];
  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      ublock-origin
      tridactyl
      adsum-notabs
    ];
    profiles.default = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        # "layout.css.devPixelsPerPx" = 1.1;
        # Block trackers!
        "browser.contentblocking.category" = "strict";
        # Use a better password manager instead.
        "signin.rememberSignOns" = false;
        # Set default search engine.
        "browser.urlbar.placeholderName" = "Startpage";
        # MPRIS integration for media control
        "media.hardwaremediakeys.enabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
      };
      # extraConfig = builtins.readFile
      #   /home/snead/dotfiles/firefox/.mozilla/firefox/profile/user.js;
    };
  };
}
