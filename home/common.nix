{ config, lib, pkgs, inputs, ... }:
# Define common configuration for any desktop or server user.
{
  lib.meta = {
    # Plain string so string concat in mkMutableSymlink never sees lib.mkDefault's
    # internal merge representation.
    configPath = "/etc/nixos";
    mkMutableSymlink = path:
      config.lib.file.mkOutOfStoreSymlink (config.lib.meta.configPath
        + lib.removePrefix (toString inputs.self) (toString path));
  };

  xdg.userDirs = {
    enable = true;
    # Can we create just some? I never use ~/desktop
    createDirectories = false;
  };

  # xdg.configFile."doom".source = config.lib.file.mkOutOfStoreSymlink ./doom;
  #xdg.configFile."emacs".source = ./doom-emacs;
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

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      pull.rebase = true;
      init.defaultBranch = "main";
      core.askPass = "";
    };
  };

  # Nice git diffs with syntax highlighting
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
