{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ chromium tridactyl-native ];
  programs.firefox = {
    enable = true;
    # package = pkgs.firefox-bin;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
        tridactyl
        darkreader
        translate-web-pages
        #adsum-notabs
      ];
      isDefault = true;
      # search.default = "DuckDuckGo";
      settings = {
        # Enable DRM
        "media.eme.enabled" = true;
        "media.eme.hdcp-policy-check.enabled" = true;
        # Make scrolling a bit slower.
        "mousewheel.default.delta_multiplier_x" = 80;
        "mousewheel.default.delta_multiplier_y" = 80;
        "mousewheel.default.delta_multiplier_z" = 80;
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
        "media.rdd-ffmpeg.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        "media.ffvpx.enabled" = false;
        "media.rdd-process.enabled" = false;
        # Disable sharing pop-up because it duplicates the widget on the URL bar
        "privacy.webrtc.hideGlobalIndicator" = true;
        "privacy.webrtc.legacyGlobalIndicator" = false;
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
