{ config, lib, pkgs, inputs, ... }:
let home = config.home.homeDirectory;
in {
  imports =
    [ ../../../home/common.nix inputs.agenix.homeManagerModules.default ];

  home.stateVersion = lib.mkDefault "25.11";

  # Install some utils for myself
  home.packages = with pkgs; [ beets ];

  # Required for mutable symlinks to work
  lib.meta.configPath = "/home/shelby/nix";
  xdg.configFile."beets/config.yaml".source =
    config.lib.meta.mkMutableSymlink ../../../home/beets.yaml;

  # Import encrypted passwords for various services
  age = {
    identityPaths = [ "${home}/.ssh/id_ed25519" ];
    secrets.pcloud-access-token.file = ../../../secrets/pcloud-access-token.age;
    secrets.rclone-crypt-password1.file =
      ../../../secrets/rclone-crypt-password1.age;
    secrets.rclone-crypt-password2.file =
      ../../../secrets/rclone-crypt-password2.age;
  };

  # Enable SSH client so age can decrypt secrets
  # programs.ssh = {
  #   enable = true;
  #   addKeysToAgent = "yes";
  # };

  systemd.user = {
    # Daily sync personal files between local and cloud storage
    services.sync-files = {
      Service = {
        Type = "oneshot";
        ExecStart = let rclone = pkgs.lib.getExe pkgs.rclone;
        in "${rclone} bisync /mnt/personal pcloud-secret: --config %h/.config/rclone/rclone.conf --recover -MP --conflict-resolve newer";
      };
    };

    # Re-enable once initial sync is done.
    # Sync state stored at ~/.cache/rclone
    # timers.sync-files = {
    #   Install.WantedBy = [ "timers.target" ];
    #   Timer = {
    #     Unit = "sync-files.service";
    #     Persistent = "true";
    #     OnCalendar = "daily";
    #     RandomizedDelaySec = "3600";
    #   };
    # };
  };

  programs.rclone = {
    enable = true;
    remotes = {
      pcloud = {
        config = {
          type = "pcloud";
          hostname = "api.pcloud.com";
        };
        secrets = { token = config.age.secrets.pcloud-access-token.path; };
      };
      pcloud-secret = {
        config = {
          type = "crypt";
          remote = "pcloud:secret";
        };
        secrets = {
          password = config.age.secrets.rclone-crypt-password1.path;
          password2 = config.age.secrets.rclone-crypt-password2.path;
        };
      };
    };
  };
}
