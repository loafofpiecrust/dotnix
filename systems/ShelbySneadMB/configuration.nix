{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];
  system.primaryUser = "ssnead";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."ssnead" = ./users/ssnead.nix;
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
    gh
    solargraph
    rclone
    sshfs
    # Kubernetes tools
    minikube
    kubectl
    kubectx
    awscli2
    ssm-session-manager-plugin
    # Use emacs v30 (stable) with MacOS patches from emacs-plus. Builds from
    # source so hopefully it performs optimally on my machine.
    # Should output a correctly linked Application with the mac-app-util
    emacs-30
    # lunar
  ];
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.darwin-emacs.overlays.emacs
    # Copied from https://github.com/billimek/dotfiles/commit/eed207e535ec8d923ab7ccdec5d10972fe77d800
    # Workaround for aarch64-darwin codesigning bug (nixpkgs#208951 / #507531):
    # fish binaries from the binary cache occasionally have invalid ad-hoc
    # signatures on Apple Silicon. Forcing a local rebuild ensures codesigning
    # is applied on this machine with a valid signature.
    (_final: prev: {
      fish = prev.fish.overrideAttrs (_old: {
        # Bust the cache key so fish is always built locally rather than
        # substituted from the binary cache where the signature may be stale.
        NIX_FORCE_LOCAL_REBUILD = "darwin-codesign-fix";
      });
    })
  ];
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
  fonts.packages = with pkgs; [ nerd-fonts.hack fira-code overpass ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.trusted-users = [ "@wheel" ];
  nix.optimise.automatic = true;
  nix.gc.automatic = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  security.pam.services.sudo_local.touchIdAuth = true;

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
    casks = [
      "lunar"
      "macdroid"
      "bitwarden"
      "docker-desktop"
      "spotify"
      "macfuse"
      "leapp"
      "cursor"
      "aws-vpn-client"
    ];
    taps = [ ];
    onActivation.autoUpdate = true;
    # onActivation.upgrade = true;
  };

  # services.tailscale.enable = true;

  services.emacs = {
    enable = false;
    package = pkgs.emacs-macport;
    # socketActivation.enable = true;
  };
}
