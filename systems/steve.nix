{ inputs, config, lib, pkgs, ... }:

# To do the initial installation:
# 1. nix build .#images.steve
# 2. Plug in the micro SD card, find where it's at like /dev/sda
# 3. sudo dd if=result/sd-image/nixos-rpi-server-etc.img of=/dev/sda bs=64K status=progress

# To do a remote update (replace 'snead' with your user):
# nixos-rebuild switch --target-host snead@steve.local --build-host localhost --flake .#steve --fast --use-remote-sudo

# To reboot:
# sudo shutdown -r now
let
  updateProject = let git = "${pkgs.git}/bin/git";
  in pkgs.writeShellScript "update-project.sh" ''
    mkdir -p /mnt
    [ -d "/mnt/$1" ] || ${git} clone $2 "/mnt/$1" --single-branch
    cd "/mnt/$1"
    ${git} fetch origin
    [ "$(${git} rev-parse HEAD)" = "$(${git} rev-parse @{u})" ] || ${git} merge @{u}
  '';
  serverBuilder = host: repo: {
    description = "Fetch and build ${host}";
    wantedBy = [ "update-projects.service" ];
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ git systemd nix ];
    script = let git = "${pkgs.git}/bin/git";
    in ''
      mkdir -p /mnt
      [ -d "/mnt/${host}" ] || ${git} clone ${repo} "/mnt/${host}" --single-branch
      cd "/mnt/${host}"
      ${git} fetch origin
      [ "$(${git} rev-parse HEAD)" = "$(${git} rev-parse @{u})" ] || (${git} merge @{u} && ${pkgs.nix}/bin/nix build && ${pkgs.systemd}/bin/systemctl restart ${host})
    '';
  };
  mkServer = host: repo: prefix: {
    "${host}" = {
      after = [ "network.target" "${host}-build.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ git nix ];
      script = "${prefix} ${pkgs.nix}/bin/nix run /mnt/${host}";
      serviceConfig = {
        KillSignal = "SIGINT";
        Restart = "always";
        RestartSec = 30;
      };
      unitConfig = {
        StartLimitInterval = 100;
        StartLimitBurst = 5;
      };
    };

    "${host}-build" = (serverBuilder host repo);
  };
in {
  imports = [ ../headless-rpi3.nix ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;

  system.stateVersion = "22.11";

  # Prevent changes to users from the machine itself, they can only be changed
  # with a system update.
  users.mutableUsers = false;

  # Setup all users with fixed passwords
  users.users.snead = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword =
      "$6$PFZjyXdf7W2cu3$55Iw6UjpcdB29fb4RIPcaYFY5Ehtuc9MFZaJBa9wlRbgYxRrDAP0tlApOiIsQY7hoeO9XG7xxiIcsjGYc9QXu1";
    # Allow logins from my personal laptop.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVldsHCxoEpdN9K+cr9EKxS5dhvUBuCuhyLht3+8CJ2 snead@loafofpiecrust"
    ];
  };

  # Keep logs in memory to avoid extra wear on the SD card. It'll last longer
  # with fewer writes.
  services.journald.extraConfig = ''
    Storage=volatile
  '';

  # TODO Remove once on ethernet
  networking.wireless.enable = true;
  networking.wireless.networks = {
    rhymenoceros = { psk = "my beats are fat"; };
  };

  networking.firewall = { allowedTCPPorts = [ 80 443 3009 ]; };

  # Allow the server to be resolved by hostname on the local network ('steve.local')
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  # Services!!
  users.users.lighttpd = {
    group = "lighttpd";
    description = "lighttpd web server privilege separation user";
    uid = config.ids.uids.lighttpd;
  };

  users.groups.lighttpd.gid = config.ids.gids.lighttpd;

  # Accept all incoming HTTP requests on port 80 and route them to the
  # appropriate service based on host name.
  # https://deanlongstaff.com/haproxy-ubuntu/
  services.haproxy = {
    enable = true;
    config = ''
      global
          maxconn 30000

      defaults
          timeout connect 5s
          timeout client 50s
          timeout server 50s

      frontend www-http
          bind :443
          bind :80
          mode http
          use_backend glg-http if { hdr(host) -i grandlakegames.com }
          use_backend glg-http if { hdr(host) -i www.grandlakegames.com }
          use_backend snead-website if { hdr(host) -i steve.local }

      backend glg-http
          mode http
          server glg-http-web 127.0.0.1:8080

      backend snead-website
          mode http
          server snead-website 127.0.0.1:8081
    '';
  };

  # systemd.services.snead-website = let
  #   configFile = pkgs.writeText "lighttpd.conf" ''
  #     server.document-root = "/mnt/grandlakegames.com"
  #     server.port = 8080
  #     server.username = "lighttpd"
  #     server.groupname = "lighttpd"
  #     server.errorlog-use-syslog = "enable"
  #     index-file.names = ("index.html")
  #     server.modules = (
  #           "mod_access",
  #           "mod_alias",
  #           "mod_compress",
  #           "mod_redirect",
  #     )
  #     include "${pkgs.lighttpd}/share/lighttpd/doc/config/conf.d/mime.conf"
  #   '';
  # in {
  #   description = "Snead's personal website snead.xyz";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.ExecStart =
  #     "${pkgs.lighttpd}/sbin/lighttpd -D -f ${configFile}";
  #   # SIGINT => graceful shutdown
  #   serviceConfig.KillSignal = "SIGINT";
  #   unitConfig.CPUQuota = "200%";
  # };

  systemd.services = lib.mkMerge [
    (mkServer "grandlakegames.com"
      "https://git.sr.ht/~loafofpiecrust/grandlakegames-site" "")
    (mkServer "snead-website" "https://git.sr.ht/~loafofpiecrust/website"
      "PORT=8081")
    {
      # Updates all projects together
      update-projects = {
        description = "Update all projects built here";
        serviceConfig.Type = "oneshot";
        serviceConfig.ExecStart = "${pkgs.hello}/bin/hello";
      };
    }
  ];

  # Update projects every 5 minutes.
  systemd.timers.update-projects = {
    wantedBy = [ "timers.target" ];
    partOf = [ "update-projects.service" ];
    timerConfig = {
      Unit = "update-projects.service";
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
    };
  };
}
