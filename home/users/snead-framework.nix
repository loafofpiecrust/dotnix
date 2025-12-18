# Specific to snead user, only on framework laptop
{ config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.agenix.homeManagerModules.default
    ../gui.nix
    ../common.nix
    ../email.nix
    ../firefox.nix
    ../chromium.nix
    ../fish.nix
    ../sway.nix
    ../spotify.nix
    ../hyprland.nix
    ../zsh.nix
    ../emacs.nix
    ../midi.nix
    ../music.nix
  ];

  home.stateVersion = lib.mkDefault "21.05";

  # Let me run globally installed stuff from package managers, and doom CLI
  home.sessionPath = [
    "${config.home.homeDirectory}/.config/emacs/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];

  xdg.userDirs = {
    # TODO Change these back to default title case, why does everything have to
    # be casual lowercase?
    documents = "$HOME/documents";
    download = "$HOME/downloads";
    music = "$HOME/music";
    pictures = "$HOME/pictures";
    templates = "$HOME/templates";
    videos = "$HOME/videos";
    desktop = "$HOME/desktop";
  };

  programs.ranger = {
    enable = true;
    package = pkgs.ranger-plus;
    settings = {
      preview_images = false;
      preview_images_method = "kitty";
    };
    # Redirect file opening to xdg-open for some mime types.
    rifle = [
      {
        condition = "mime ^image|^video|^audio, has xdg-open, flag f";
        command = ''xdg-open "$1"'';
      }
      {
        condition =
          "ext iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has xdg-open";
        command = ''xdg-open "$1"'';
      }
    ];
  };

  programs.kitty = {
    enable = true;
    font.name = "monospace";
    shellIntegration.enableZshIntegration = true;
    shellIntegration.mode = "no-cursor";
    settings = {
      scrollback_lines = 3000;
      window_padding_width = 4;
      cursor_shape = "block";
      background_opacity = "0.8";
    };
  };

  programs.alacritty = {
    enable = false;
    settings = {
      font.normal.family = "monospace";
      font.size = 11;
      window.opacity = 0.8;
      window.padding = {
        x = 8;
        y = 8;
      };
    };
  };

  # gtk.gtk3.bookmarks = [ "file:///home/snead/cloud" ];
  systemd.user.services.mount-pcloud = {
    Unit = {
      # Wants = [ "multi-user.target" ];
      Description = "UNENCRYPTED cloud storage mounted as drive";
    };
    # Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      mountDir = "${home}/unencrypted-cloud";
    in {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --vfs-cache-mode full pcloud: ${mountDir}";
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountDir}";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
  };

  systemd.user.services.mount-pcrypt = {
    Unit = {
      # After = [ "network-online.target" ];
      # Wants = [ "network-online.target" ];
      Description = "Cloud storage mounted as encrypted drive";
    };
    # Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      mountDir = "${home}/cloud";
    in {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --vfs-cache-mode writes pcloud-secret: ${mountDir}";
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountDir}";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      # Restart = "always";
      # RestartSec = "60";
    };
  };

  systemd.user.services.mount-nas = {
    Unit = {
      After = [ "network-online.target" "ssh-agent.service" ];
      Requires = [ "ssh-agent.service" ];
      Wants = [ "network-online.target" ];
      Description = "NAS mounted as an encrypted drive";
      StartLimitBurst = "5";
      StartLimitIntervalSec = "60";
    };
    Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      mountDir = "${home}/nas";
    in {
      Type = "notify";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount --config=${home}/.config/rclone/rclone.conf --vfs-cache-mode full --vfs-read-chunk-streams 8 --vfs-read-chunk-size 64M --buffer-size 32M --vfs-cache-max-size 5G --transfers 8 --checkers 10 --file-perms=0777 --dir-cache-time 1m nas-combined: ${mountDir}";
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountDir}";
      Environment = [
        "PATH=/run/wrappers/bin/:$PATH"
        "SSH_AUTH_SOCK=/run/user/1000/ssh-agent"
      ];
      Restart = "on-failure";
      RestartSec = "20";
    };
  };

  # Sync notes folder every 30m and when local changes are made, debounced to
  # sync every 2m at most.
  systemd.user.services.sync-notes = {
    Unit = {
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      Description = "Sync notes with encrypted cloud storage";
    };
    Install.WantedBy = [ "default.target" ];
    Service = let
      home = config.home.homeDirectory;
      notes = "${home}/documents/notes";
    in {
      Type = "exec";
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "sync-notes";
          runtimeInputs = with pkgs; [ rclone inotify-tools coreutils ];
          text = let
            doSync =
              "rclone bisync pcloud-secret:Notes ${notes} --config ${home}/.config/rclone/rclone.conf --compare size,modtime,checksum --recover -MP --track-renames --conflict-resolve newer";
          in ''
            ${doSync}
            inotifywait -q -m -t 1800 --format "%w%f" ${notes} |\
            while read -r path; do
              echo "$path" changed
              echo "Skipping $(timeout 120 cat | wc -l) further changes"
              ${doSync}
            done
          '';
        };
      in "${script}/bin/sync-notes";
      Restart = "always";
      RestartSec = "30";
    };
  };

  systemd.user.services.backup-files = {
    Service = let
      home = config.home.homeDirectory;
      original = "${home}/.backup";
    in {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "backup-files";
          runtimeInputs = with pkgs; [ rclone coreutils ];
          text = ''
            rclone copy ${original} pcloud-secret:'Backups/Framework Laptop' --config ${home}/.config/rclone/rclone.conf -L -u --ignore-checksum
          '';
        };
      in "${script}/bin/backup-files";
    };
  };
  systemd.user.timers.backup-files = {
    Install.WantedBy = [ "timers.target" "network-online.target" ];
    Timer = {
      Unit = "backup-files.service";
      Persistent = "true";
      OnCalendar = "daily";
      RandomizedDelaySec = "60";
    };
  };

  # systemd.user.services.backup-home = {
  #   Unit = {
  #     Description = "Backup home folder";
  #   };
  # };

  programs.go = {
    enable = true;
    goPath = ".go";
  };

  # Import encrypted passwords for various services
  age = {
    identityPaths = [ "/home/snead/.ssh/id_ed25519" ];
    secrets.pcloud-access-token.file = ../../secrets/pcloud-access-token.age;
    secrets.rclone-crypt-password1.file =
      ../../secrets/rclone-crypt-password1.age;
    secrets.rclone-crypt-password2.file =
      ../../secrets/rclone-crypt-password2.age;
  };

  xdg.mime.enable = true;
  xdg.mimeApps.enable = false;
  home.packages = with pkgs; [
    unstable.zoom-us
    # discord
    # teams
    krita
    slack
    # deluge
    # transmission_4-gtk
    zotero
    calibre # ebook manager
    rclone
    ledger

    # Run ANYTHING one-off without installing it!
    # comma

    praat
    wine
    winetricks
    # nodePackages.surge

    # 3d modeling
    freecad
    openscad-unstable
    kicad-small
    orca-slicer
    blender

    # game dev
    godot_4
    # aseprite-unfree

    # custom keyboards
    qmk
    qmk_hid
    rockbox-utility

    obs-studio
    mp3val
    flac
    filezilla
    qimgv
    dbeaver-bin
    asunder # CD ripping

    fontforge-gtk
    transmission-remote-gtk

    whitesur-gtk-theme
    whitesur-cursors
    whitesur-icon-theme
    nwg-look

    pomodoro-gtk
    obsidian # note taking
    # darktable # photo editing
    unison
  ];

  # Don't use the server because it'll keep programs running after I close their window!
  # programs.foot.server.enable = true;
  # systemd.user.services.foot = {
  #   Service = {
  #     Restart = lib.mkForce "always";
  #     RestartSec = 2;
  #   };
  # };

  # No longer necessary with AMD board, they tweaked the speaker config!
  # It now amplifies loud enough and with better EQ.
  xdg.configFile."easyeffects/output/fw13-easy-effects.json".source =
    ../fw13-easy-effects.json;
  services.easyeffects = {
    enable = false;
    # preset = "fw13-easy-effects";
  };

  programs.git = {
    userName = "loafofpiecrust";
    userEmail = "shelby@snead.xyz";
    extraConfig = {
      github.user = "loafofpiecrust";
      # easy sign commits with ssh key
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      commit.gpgsign = true;
    };
  };

  services.gpg-agent.enableSshSupport = false;
  services.ssh-agent.enable = true;

  home.file.".ssh/config".source = config.lib.meta.mkMutableSymlink ../ssh.conf;

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
      nas.config = {
        type = "sftp";
        host = "192.168.0.109";
        user = "shelby";
        shell_type = "unix";
        md5sum_command = "md5sum";
        sha1sum_command = "sha1sum";
      };
      nas-secret = {
        config = {
          type = "crypt";
          remote = "nas:/media/pool/Secret";
        };
        secrets = {
          password = config.age.secrets.rclone-crypt-password1.path;
          password2 = config.age.secrets.rclone-crypt-password2.path;
        };
      };
      nas-combined.config = {
        type = "combine";
        upstreams =
          "Public=nas:/media/pool/Public Private=nas-secret: Root=nas:/";
      };
      nas-union.config = {
        type = "union";
        upstreams = "nas-secret: nas:/media/pool/Public";
        action_policy = "epall";
        create_policy = "epff";
        search_policy = "epff";
      };
    };
  };
}
