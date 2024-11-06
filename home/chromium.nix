{ config, lib, pkgs, ... }:

{
  # home.packages = [ pkgs.chromium ];
  programs.brave = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # {
      #   # Ublock origin
      #   id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
      # }
      {
        # Bitwarden
        id = "nngceckbapebfimnlniiiahkandclblb";
      }
      {
        # Vimium
        id = "dbepggeogbaibhgnhhndojpepiihcmeb";
      }
    ];
  };
}
