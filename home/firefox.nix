{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ tridactyl-native ];
  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      ublock-origin
      tridactyl
      #adsum-notabs
    ];
    profiles.default = {
      settings = {
      	# Enable DRM
	"media.eme.enabled" = true;
        # Make scrolling a bit slower.
        "mousewheel.default.delta_multiplier_x" = 100;
        "mousewheel.default.delta_multiplier_y" = 100;
        "mousewheel.default.delta_multiplier_z" = 100;
        # Disable scroll momentum when I let go of the touchpad.
        "apz.gtk.kinetic_scroll.enabled" = false;
        "layout.css.devPixelsPerPx" = "-1.0";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        # Block trackers!
        "browser.contentblocking.category" = "strict";
        # Use a better password manager instead.
        "signon.rememberSignons" = false;
        # Set default search engine.
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        # MPRIS integration for media control
        "media.hardwaremediakeys.enabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.cache.disk.enable" = false;
        "browser.sessionstore.interval" = 60 * 1000;
        # Ask me where to save files every time.
        "browser.download.useDownloadDir" = false;
        # Some privacy settings.
        "network.http.sendSecureXSiteReferrer" = false;
        # "dom.event.clipboardevents.enabled" = false;
        "security.tls.version.min" = 1;
        "extensions.pocket.enabled" = false;
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        "beacon.enabled" = false;
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
      };
      userChrome = ''
        /* Hide the thin line between the tabs and the main viewport. */
        #navigator-toolbox {
          border-bottom: none !important;
        }
      '';
      # extraConfig = builtins.readFile
      #   /home/snead/dotfiles/firefox/.mozilla/firefox/profile/user.js;
    };
  };
}
