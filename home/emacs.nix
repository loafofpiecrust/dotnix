{ config, lib, pkgs, inputs, ... }:

{
  # imports = [ inputs.nix-doom-emacs.hmModule ];

  home.packages = with pkgs; [ mu ];
  programs.emacs = {
    enable = true;
    package = pkgs.emacsCustom;
    extraPackages = epkgs:
      with epkgs; [
        emojify
        vterm
        emacsql
        emacsql-sqlite
        mu4e
        pkgs.mu
      ];
  };

  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    package = config.programs.emacs.finalPackage;
    # socketActivation.enable = true;
  };

  # The service option doesn't seem to be working.
  home.sessionVariables = { EDITOR = lib.mkForce "emacsclient -r"; };
  # programs.doom-emacs = {
  #   enable = false;
  #   doomPrivateDir = ./doom;
  #   emacsPackage = pkgs.emacsCustom;
  #   # Add some packages from unpublished git repositories.
  #   emacsPackagesOverlay = self: super:
  #     let
  #       mkGitPkg = { host, user, name, rev ? null }:
  #         self.trivialBuild {
  #           pname = name;
  #           version = if rev == null then "1.0.0" else rev;
  #           src = builtins.fetchGit {
  #             url = "https://${host}.com/${user}/${name}.git";
  #             rev = rev;
  #           };
  #         };
  #     in {
  #       org-cv = mkGitPkg {
  #         host = "gitlab";
  #         user = "loafofpiecrust";
  #         name = "org-cv";
  #         rev = "explicit-dates";
  #       };
  #       app-launcher = mkGitPkg {
  #         host = "github";
  #         user = "SebastienWae";
  #         name = "app-launcher";
  #         rev = "71fb5a501a646703c81783395ff46cdd043e173a";
  #       };
  #       exwm-outer-gaps = mkGitPkg {
  #         host = "github";
  #         user = "lucasgruss";
  #         name = "exwm-outer-gaps";
  #       };
  #       bitwarden = mkGitPkg {
  #         host = "github";
  #         user = "seanfarley";
  #         name = "emacs-bitwarden";
  #       };
  #       dired-show-readme = mkGitPkg {
  #         host = "gitlab";
  #         user = "kisaragi-hiu";
  #         name = "dired-show-readme";
  #       };
  #     };
  # };
}
