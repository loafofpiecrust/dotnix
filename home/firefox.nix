{ config, lib, pkgs, ... }:

{
  # Install firefox for migration purposes as I try alternative browsers.
  home.packages = [ pkgs.firefox ];
  # TODO use the color values from my catpuccin nix file if possible, so that
  # the theme follows my system even if it's not catpuccin spec.
  # TODO use the CSS light-dark() function to make this theme adaptive to
  # day/night cycle.
  xdg.configFile."tridactyl/themes/shelby.css".source =
    config.lib.meta.mkMutableSymlink ./themes/catppuccin-tridactyl.css;
  xdg.configFile."tridactyl/tridactylrc".source =
    config.lib.meta.mkMutableSymlink ./tridactylrc;
  # Override search engine config which gets written to once FF starts.
  # home.file.".mozilla/firefox/default/search.json.mozlz4".force =
  #
  #   lib.mkForce true;
  home.file.".floorp/default/search.json.mozlz4".force = lib.mkForce true;
  programs.floorp = {
    enable = true;
    nativeMessagingHosts = [ pkgs.tridactyl-native pkgs.fx-cast-bridge ];
    # package = pkgs.firefox-bin;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # bitwarden
        ublock-origin
        # tridactyl
        darkreader
        # translate-web-pages
        #adsum-notabs
      ];
      isDefault = true;
      search.default = "Kagi";
      search.engines = {
        "Brave" = {
          urls =
            [{ template = "https://search.brave.com/search?q={searchTerms}"; }];
        };
        "Kagi" = {
          urls = [{ template = "https://kagi.com/search?q={searchTerms}"; }];
        };
        "GitHub" = {
          urls = [{
            template =
              "https://github.com/search?q={searchTerms}&type=repositories";
          }];
          definedAliases = [ "!gh" ];
        };
        "Amazon" = {
          urls = [{ template = "https://www.amazon.com/s?k={searchTerms}"; }];
          definedAliases = [ "!a" ];
        };
        "YouTube" = {
          urls = [{
            template =
              "https://www.youtube.com/results?search_query={searchTerms}";
          }];
          definedAliases = [ "!y" ];
        };
        "Wikipedia" = {
          urls = [{
            template =
              "https://en.wikipedia.org/wiki/Special:Search?go=Go&search={searchTerms}&ns0=1";
          }];
          definedAliases = [ "!w" ];
        };
        "StackOverflow" = {
          urls = [{
            template = "https://stackoverflow.com/search?q={searchTerms}";
          }];
          definedAliases = [ "!so" ];
        };
        "Google".metaData.alias = "!g";
      };
      settings = {
        # Disable telemetry, copied all this from Arkenfox
        # "toolkit.telemetry.unified" = false;
        # "toolkit.telemetry.enabled" = false;
        # "toolkit.telemetry.server" = "data:,";
        # "toolkit.telemetry.archive.enabled" = false;
        # "toolkit.telemetry.newProfilePing.enabled" = false;
        # "toolkit.telemetry.shutdownPingSender.enabled" = false;
        # "toolkit.telemetry.updatePing.enabled" = false;
        # "toolkit.telemetry.bhrPing.enabled" = false;
        # "toolkit.telemetry.firstShutdownPing.enabled" = false;
        # "toolkit.telemetry.coverage.opt-out" = true;
        # "toolkit.coverage.opt-out" = true;
        # "toolkit.coverage.endpoint.base" = "";
        # "browser.newtabpage.activity-stream.telemetry" = false;
        # "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        # "app.normany.enabled" = false;
        # "app.shield.optoutstudies.enabled" = false;
        # "network.captive-portal-service.enabled" = false;
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
        # "browser.cache.disk.enable" = false;
        "browser.sessionstore.interval" = 60 * 1000;
        # Ask me where to save files every time.
        "browser.download.useDownloadDir" = false;
        # Some privacy settings.
        # "network.http.sendSecureXSiteReferrer" = false;
        # "dom.event.clipboardevents.enabled" = false;
        "security.tls.version.min" = 1;
        # "extensions.pocket.enabled" = false;
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        # "beacon.enabled" = false;
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

        # Configure some browser settings for colors to match my theme.
        "browser.display.background_color" =
          config.lib.meta.theme.light.special.background;
        "browser.display.background_color.dark" =
          config.lib.meta.theme.dark.special.background;
        "browser.display.foreground_color" =
          config.lib.meta.theme.light.special.foreground;
        "browser.display.foreground_color.dark" =
          config.lib.meta.theme.dark.special.foreground;
        "browser.anchor_color" = config.lib.meta.theme.light.colors.blue;
        "browser.anchor_color.dark" = config.lib.meta.theme.dark.colors.blue;
        "browser.visited_color" = config.lib.meta.theme.light.colors.magenta;
        "browser.visited_color.dark" =
          config.lib.meta.theme.dark.colors.magenta;
      };

      # Tweak the Firefox controls themselves to save space and match my system
      # color scheme.
      userChrome = let
        light = config.lib.meta.theme.light;
        dark = config.lib.meta.theme.dark;
      in ''
        :root {
          --toolbar-field-focus-background-color: light-dark(${light.colors.surface2}, ${dark.colors.surface2}) !important;
          --tab-selected-bgcolor: light-dark(${light.colors.surface2}, ${dark.colors.surface2}) !important;
          --tab-block-margin: 3px !important;
          --color-accent-primary: light-dark(${light.colors.focus}, ${dark.colors.focus}) !important;
        }
        #navigator-toolbox {
          background-color: light-dark(${light.special.background}, ${dark.special.background}) !important;
          color: light-dark(${light.special.foreground}, ${dark.special.foreground}) !important;
          /* Hide the thin line between the tabs and the main viewport. */
          border-bottom: none !important;
        }
        #nav-bar {
          background-color: light-dark(${light.colors.surface1}, ${dark.colors.surface1}) !important;
        }
        .tab-label-container {
          height: 2.2em !important;
        }
      '';
      # extraConfig = builtins.readFile
      #   /home/snead/dotfiles/firefox/.mozilla/firefox/profile/user.js;
    };
  };

  home.file.".librewolf/profiles.ini".force = lib.mkForce true;
  # home.file.".librewolf/gpeavn0d.default/search.json.mozlz4".force =
  # lib.mkForce true;
  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [ pkgs.tridactyl-native pkgs.fx-cast-bridge ];
    # package = pkgs.firefox-bin;
    profiles.default = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # bitwarden
        ublock-origin
        # tridactyl
        darkreader
        # translate-web-pages
        #adsum-notabs
      ];
      isDefault = true;
      search.default = "Kagi";
      search.engines = {
        "Brave" = {
          urls =
            [{ template = "https://search.brave.com/search?q={searchTerms}"; }];
        };
        "Kagi" = {
          urls = [{ template = "https://kagi.com/search?q={searchTerms}"; }];
        };
        "GitHub" = {
          urls = [{
            template =
              "https://github.com/search?q={searchTerms}&type=repositories";
          }];
          definedAliases = [ "!gh" ];
        };
        "Amazon" = {
          urls = [{ template = "https://www.amazon.com/s?k={searchTerms}"; }];
          definedAliases = [ "!a" ];
        };
        "YouTube" = {
          urls = [{
            template =
              "https://www.youtube.com/results?search_query={searchTerms}";
          }];
          definedAliases = [ "!y" ];
        };
        "Wikipedia" = {
          urls = [{
            template =
              "https://en.wikipedia.org/wiki/Special:Search?go=Go&search={searchTerms}&ns0=1";
          }];
          definedAliases = [ "!w" ];
        };
        "StackOverflow" = {
          urls = [{
            template = "https://stackoverflow.com/search?q={searchTerms}";
          }];
          definedAliases = [ "!so" ];
        };
        "Google".metaData.alias = "!g";
      };
      settings = {
        # Disable search suggestions
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searched" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.addons.featureGate" = false;
        "browser.urlbar.mdn.featureGate" = false;
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
        "layout.css.devPixelsPerPx" = "-1.0";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Block trackers!
        "browser.contentblocking.category" = "strict";
        # Use a better password manager instead.
        "signon.rememberSignons" = false;
        # MPRIS integration for media control
        "media.hardwaremediakeys.enabled" = true;
        "browser.shell.checkDefaultBrowser" = false;
        # "browser.cache.disk.enable" = false;
        "browser.sessionstore.interval" = 60 * 1000;
        # Ask me where to save files every time.
        "browser.download.useDownloadDir" = false;
        # Some privacy settings.
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
        # GPU acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        # Disable sharing pop-up because it duplicates the widget on the URL bar
        # "privacy.webrtc.hideGlobalIndicator" = true;
        # "privacy.webrtc.legacyGlobalIndicator" = false;
        # Unload tabs when memory is low, otherwise Firefox can EAT UP da ram.
        "browser.tabs.unloadOnLowMemory" = true;

        # Configure some browser settings for colors to match my theme.
        "browser.display.background_color" =
          config.lib.meta.theme.light.special.background;
        "browser.display.background_color.dark" =
          config.lib.meta.theme.dark.special.background;
        "browser.display.foreground_color" =
          config.lib.meta.theme.light.special.foreground;
        "browser.display.foreground_color.dark" =
          config.lib.meta.theme.dark.special.foreground;
        "browser.anchor_color" = config.lib.meta.theme.light.colors.blue;
        "browser.anchor_color.dark" = config.lib.meta.theme.dark.colors.blue;
        "browser.visited_color" = config.lib.meta.theme.light.colors.magenta;
        "browser.visited_color.dark" =
          config.lib.meta.theme.dark.colors.magenta;
      };

      # Tweak the Firefox controls themselves to save space and match my system
      # color scheme.
      userChrome = let
        light = config.lib.meta.theme.light;
        dark = config.lib.meta.theme.dark;
      in ''
        :root {
          --toolbar-field-focus-background-color: light-dark(${light.colors.surface2}, ${dark.colors.surface2}) !important;
          --tab-selected-bgcolor: light-dark(${light.colors.surface2}, ${dark.colors.surface2}) !important;
          --tab-block-margin: 3px !important;
          --color-accent-primary: light-dark(${light.colors.focus}, ${dark.colors.focus}) !important;
        }
        #navigator-toolbox {
          background-color: light-dark(${light.special.background}, ${dark.special.background}) !important;
          color: light-dark(${light.special.foreground}, ${dark.special.foreground}) !important;
          /* Hide the thin line between the tabs and the main viewport. */
          border-bottom: none !important;
        }
        #nav-bar {
          background-color: light-dark(${light.colors.surface1}, ${dark.colors.surface1}) !important;
        }
        .tab-label-container {
          height: 2.2em !important;
        }
      '';
      # extraConfig = builtins.readFile
      #   /home/snead/dotfiles/firefox/.mozilla/firefox/profile/user.js;
    };
  };
}
