{ config, lib, pkgs, inputs, ... }:
let home = config.home.homeDirectory;
in {
  imports = [ ../common.nix inputs.agenix.homeManagerModules.default ];

  home.stateVersion = lib.mkDefault "25.11";

  # Install some utils for myself
  home.packages = with pkgs; [ beets ];

  # Import encrypted passwords for various services
  age = {
    identityPaths = [ "${home}/.ssh/id_ed25519" ];
    secrets.pcloud-access-token.file = ../../secrets/pcloud-access-token.age;
    secrets.rclone-crypt-password1.file =
      ../../secrets/rclone-crypt-password1.age;
    secrets.rclone-crypt-password2.file =
      ../../secrets/rclone-crypt-password2.age;
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
        ExecStart = let
          config = "${home}/.config/rclone/rclone.conf";
          script = pkgs.writeShellApplication {
            name = "sync-files";
            runtimeInputs = with pkgs; [ rclone coreutils ];
            text = ''
              rclone bisync nas-union: pcloud-secret: --config ${config} --compare size,modtime,checksum --recover -MP --track-renames --conflict-resolve newer
            '';
          };
        in "${script}/bin/sync-files";
      };
    };
    timers.sync-files = {
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        Unit = "sync-files.service";
        Persistent = "true";
        OnCalendar = "daily";
        RandomizedDelaySec = "3600";
      };
    };
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
      nas-secret = {
        config = {
          type = "crypt";
          remote = "/media/pool/Secret";
        };
        secrets = {
          password = config.age.secrets.rclone-crypt-password1.path;
          password2 = config.age.secrets.rclone-crypt-password2.path;
        };
      };
      nas-union.config = {
        type = "union";
        upstreams = "nas-secret: /media/pool/Public";
        action_policy = "epall";
        create_policy = "epff";
        search_policy = "epff";
      };
    };
  };
}
