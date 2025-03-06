{ config, lib, pkgs, ... }:

let
  update-mu-index = pkgs.writeShellApplication {
    name = "update-mu-index";
    runtimeInputs = with pkgs; [ config.programs.emacs.package ];
    text = "(emacsclient -e '(mu4e-update-index)') || (mu index) || true";
  };
  import-invites = pkgs.writeShellApplication {
    name = "import-invites";
    text = ./import-invites.sh;
    runtimeInputs = with pkgs; [ coreutils mu khal ];
  };
  sync-calendar = pkgs.writeShellApplication {
    name = "sync-calendar";
    runtimeInputs = with pkgs; [ vdirsyncer rbw ];
    text = "vdirsyncer sync";
  };
in {

  programs.mbsync.enable = true;
  programs.mu.enable = false;
  programs.msmtp.enable = true;
  services.imapnotify.enable = false;
  services.mbsync = {
    enable = false;
    postExec = let
      script = pkgs.writeShellScript "mbsync-post" ''
        ${update-mu-index}/bin/update-mu-index
      '';
    in "${script} 2> /dev/null";
  };
  systemd.user.services.mbsync = { Service.Type = lib.mkForce "simple"; };

  programs.thunderbird = {
    enable = true;
    profiles.default = { isDefault = true; };
    settings = {
      "privacy.donottrackheader.enabled" = true;
      "mail.openMessageBehavior" = 1;
      "mailnews.wraplength" = 80;
      # Don't add hard line breaks to my emails please!
      "mail.wrap_long_lines" = false;
      "plain_text.wrap_long_lines" = false;
    };
  };

  # TODO Setup davmail server from backed up settings file.
  home.packages = with pkgs; [ davmail khal vdirsyncer ];

  xdg.configFile."khal/config".source = ./khal.conf;
  xdg.configFile."vdirsyncer/config".source = ./vdirsyncer.conf;

  # accounts.contact = {
  #   personal = {
  #     remote = {
  #       type = "carddav";
  #       url = "https://dav.mailbox.org/carddav";
  #       userName = "shelby@snead.xyz";
  #       passwordCommand = "rbw get mailbox.org shelby@snead.xyz";
  #     };
  #   };
  # };

  accounts.email = let
    mbsync = {
      enable = false;
      create = "both";
      expunge = "both";
      extraConfig.channel = {
        CopyArrivalDate = true;
        # SyncState = "*";
      };
      extraConfig.account = {
        Timeout = 40;
        PipelineDepth = 50;
      };
    };
    mu = { enable = false; };
    msmtp = { enable = false; };
    thunderbird = { enable = true; };
    realName = "Shelby Snead";
  in {
    maildirBasePath = ".mail";
    certificatesFile = "/etc/ssl/certs/ca-certificates.crt";

    accounts.personal = let address = "shelby@snead.xyz";
    in {
      inherit mbsync mu msmtp thunderbird address realName;
      primary = true;
      userName = address;
      passwordCommand = "rbw get mailbox.org shelby@snead.xyz";
      imap.host = "imap.mailbox.org";
      imap.tls.useStartTls = true;
      imapnotify = {
        enable = false;
        boxes = [ "Inbox" ];
        onNotify = ''
          ${pkgs.isync}/bin/mbsync personal --pull-new
        '';
        # onNotifyPost = "${update-mu-index}/bin/update-mu-index";
      };
      smtp = {
        host = "smtp.mailbox.org";
        port = 587;
        tls.useStartTls = true;
      };
    };

    # accounts.neu = let address = "snead.t@northeastern.edu";
    # in {
    #   inherit mu msmtp address realName;
    #   userName = address;
    #   imap.host = "localhost";
    #   imap.port = 1143;
    #   imap.tls.enable = false;
    #   passwordCommand = "echo x";
    #   mbsync =
    #     lib.mkMerge [ mbsync { extraConfig.account.AuthMechs = "LOGIN"; } ];
    #   imapnotify = {
    #     enable = true;
    #     boxes = [ "Inbox" ];
    #     #onPost = ''
    #     #  ${pkgs.isync}/bin/mbsync neu
    #     #'';
    #   };
    #   smtp = {
    #     host = "localhost";
    #     port = 1025;
    #     tls.enable = false;
    #   };
    # };

    accounts.gmail = let address = "taylorsnead@gmail.com";
    in {
      inherit mbsync mu msmtp thunderbird address realName;
      flavor = "gmail.com";
      userName = address;
      passwordCommand = "rbw get google.com taylorsnead@gmail.com-sync";
      imap.host = "imap.gmail.com";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
    };

    accounts.classcompanion = let address = "snead@classcompanion.com";
    in {
      inherit mbsync mu msmtp thunderbird address realName;
      flavor = "gmail.com";
      userName = address;
      passwordCommand = "rbw get google.com snead@classcompanion.com-sync";
      imap.host = "imap.gmail.com";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
    };
  };
}
