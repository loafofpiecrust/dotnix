{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."ssnead" = ../home/users/panorama.nix;
  # Pass flake inputs down to home manager.
  home-manager.extraSpecialArgs = {
    inherit inputs;
    systemConfig = config;
  };
  home-manager.sharedModules =
    [ inputs.mac-app-util.homeManagerModules.default ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    #_1password
    nixfmt-classic
    tableplus
    tailscale
    emacs-lsp-booster
    karabiner-elements
    # unstable.monitorcontrol
    ripgrep
    gnugrep
    fd
    fzf
    libreoffice-bin
    jq
    shfmt
    libtool
    gnupg
    nodePackages.typescript-language-server
    sqls
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
  ];
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;
  #nix.useSandbox = false;

  # Enable zsh completion on system packages.
  environment.pathsToLink = [ "/share/zsh" ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # time.timeZone = "America/Los_Angeles";

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

  #fonts.enableFontDir = true;
  fonts.packages = with pkgs; [ unstable.nerd-fonts.hack fira-code overpass ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  nix.useDaemon = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.gc.automatic = true;
  nix.gc.user = "ssnead";

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  security.pam.enableSudoTouchIdAuth = true;

  services.aerospace = {
    enable = true;
    package = pkgs.unstable.aerospace;
    settings = {
      mode.main.binding = {
        alt-enter = "exec-and-forget open -a Kitty";
        alt-e = "exec-and-forget open -a Emacs";
        alt-h = "focus --boundaries-action wrap-around-the-workspace left";
        alt-j = "focus --boundaries-action wrap-around-the-workspace down";
        alt-k = "focus --boundaries-action wrap-around-the-workspace up";
        alt-l = "focus --boundaries-action wrap-around-the-workspace right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        "alt-leftSquareBracket" = "workspace prev";
        "alt-rightSquareBracket" = "workspace next";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";

        # alt-r = "mode resize";
        alt-s = "layout floating tiling"; # 'floating toggle' in i3
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
      };
      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "9" = "secondary";
        "10" = "secondary";
      };
    };
  };

  homebrew = {
    enable = true;
    casks = [ "lunar" "macdroid" "bitwarden" ];
  };

  # services.tailscale.enable = true;

  services.emacs = {
    enable = false;
    package = pkgs.emacs-macport;
    # socketActivation.enable = true;
  };
}
