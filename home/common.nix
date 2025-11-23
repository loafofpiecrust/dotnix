{ config, lib, pkgs, inputs, ... }:

{
  home.stateVersion = lib.mkDefault "21.05";
  home.sessionPath = [
    "${config.home.homeDirectory}/.config/emacs/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];

  lib.meta = {
    configPath = "/etc/nixos";
    mkMutableSymlink = path:
      config.lib.file.mkOutOfStoreSymlink (config.lib.meta.configPath
        + lib.removePrefix (toString inputs.self) (toString path));
  };

  xdg.userDirs = {
    enable = true;
    # Can we create just some? I never use ~/desktop
    createDirectories = false;
    documents = "$HOME/documents";
    download = "$HOME/downloads";
    music = "$HOME/music";
    pictures = "$HOME/pictures";
    templates = "$HOME/templates";
    videos = "$HOME/videos";
    desktop = "$HOME/desktop";
  };

  # xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink ./doom;
  #xdg.configFile."emacs".source = ./doom-emacs;
  xdg.configFile."fontconfig/fonts.conf".source = ./gui/fonts.conf;
  home.file.".sbclrc".source = ./lisp/.sbclrc;
  home.file.".aspell.en.pws".source =
    config.lib.meta.mkMutableSymlink ./spell/.aspell.en.pws;
  home.file."bin/get-password" = {
    executable = true;
    text = ''
      #!/bin/sh
      export PATH=${config.programs.rbw.package}/bin:$PATH
      rbw unlocked || rbw login
      rbw unlocked || rbw unlock
      rbw get "$1" "$2"
    '';
  };
  home.file."bin/light-notify".source = ./scripts/light-notify.sh;
  home.file."bin/power-menu".source = ./scripts/power-menu.sh;

  # GPG agent handles locked files and SSH keys.
  services.gpg-agent = {
    enable = true;
    enableSshSupport = lib.mkDefault true;
    defaultCacheTtl = 60 * 60;
    defaultCacheTtlSsh = 60 * 60;
    pinentry.package = pkgs.pinentry-gnome3;
    extraConfig = ''
      display :0
    '';
  };

  # Enable project-local environments based on flakes.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Make my shell fancy.
  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      battery.disabled = true;
      directory.read_only = " 󰌾";
      git_branch.symbol = " ";
      git_commit.tag_symbol = "  ";
      hostname.ssh_symbol = " ";
      nix_shell.symbol = " ";
      nodejs.symbol = " ";
      package.symbol = "󰏗 ";
      python.symbol = " ";
      rust.symbol = "󱘗 ";
      ruby.symbol = " ";
      java.symbol = " ";
      golang.symbol = " ";
      docker_context.symbol = " ";
    };
  };

  # Manage my passwords with Bitwarden + rbw.
  programs.rbw = {
    enable = true;
    package = pkgs.unstable.rbw;
    settings = {
      email = "shelby@snead.xyz";
      # Keep the vault open for 3 hours, making me login 2-3 times per day.
      lock_timeout = 60 * 60 * 3;
      pinentry = pkgs.pinentry-gnome3;
    };
  };

  # xdg.configFile."mimeapps.list".source =
  #   config.lib.meta.mkMutableSymlink ./mimeapps.list;
  xdg = {
    enable = true;
    mime.enable = lib.mkDefault false;
    mimeApps.enable = lib.mkDefault false;
  };

  xdg.configFile."beets/config.yaml".source =
    config.lib.meta.mkMutableSymlink ./beets.yaml;

  gtk = {
    enable = true;
    font.name = "sans";
    font.size = 13;
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-Light";
    };
    iconTheme = {
      package = pkgs.whitesur-icon-theme;
      name = "WhiteSur-light";
    };
  };

  # Make QT match the GTK theme.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    lfs.enable = true;
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      core.editor = "emacsclient -r";
      core.askPass = "";
    };
  };
}
