{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ tridactyl-native ];
  # TODO use the color values from my catpuccin nix file if possible, so that
  # the theme follows my system even if it's not catpuccin spec.
  # TODO use the CSS light-dark() function to make this theme adaptive to
  # day/night cycle.
  xdg.configFile."tridactyl/themes/shelby.css".source =
    config.lib.meta.mkMutableSymlink ./themes/catppuccin-tridactyl.css;
  xdg.configFile."tridactyl/tridactylrc".source =
    config.lib.meta.mkMutableSymlink ./tridactylrc;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = [ pkgs.tridactyl-native ];
    };
    # package = pkgs.firefox-bin;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
        tridactyl
        darkreader
        # translate-web-pages
        #adsum-notabs
      ];
      isDefault = true;
      # search.default = "Google";
      settings = {
        # Disable telemetry, copied all this from Arkenfox
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "app.normany.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;
        # Disable search suggestions
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searched" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.addons.featureGate" = false;
        "browser.urlbar.mdn.featureGate" = false;
        "browser.urlbar.pocket.featureGate" = false;
        "browser.urlbar.weather.featureGate" = false;
        "browser.urlbar.yelp.featureGate" = false;
        "extensions.getAddons.showPane" = false;
        # General privacy preferences
        "browser.startup.page" = 0; # use newtab page for browser start
        "browser.formfill.enable" = false;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "toolkit.winRegisterApplicationRestart" = false;
        # Enable DRM
        "media.eme.enabled" = true;
        # Make scrolling a bit slower.
        # "mousewheel.default.delta_multiplier_x" = 80;
        # "mousewheel.default.delta_multiplier_y" = 80;
        # "mousewheel.default.delta_multiplier_z" = 80;
        # Disable scroll momentum when I let go of the touchpad.
        "apz.gtk.kinetic_scroll.enabled" = false;
        "layout.css.devPixelsPerPx" = "-1.0";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        # Block trackers!
        "browser.contentblocking.category" = "strict";
        # Use a better password manager instead.
        "signon.rememberSignons" = false;
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
        # GPU acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        # Disable sharing pop-up because it duplicates the widget on the URL bar
        "privacy.webrtc.hideGlobalIndicator" = true;
        "privacy.webrtc.legacyGlobalIndicator" = false;
        # Unload tabs when memory is low, otherwise Firefox can EAT UP da ram.
        "browser.tabs.unloadOnLowMemory" = true;
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
