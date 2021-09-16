{ config, lib, pkgs, ... }:

{
  programs.mbsync.enable = true;
  programs.mu.enable = true;
  programs.msmtp.enable = true;
  services.imapnotify.enable = false;
  services.mbsync = {
  enable = true;
  postExec = ''
    ${pkgs.mu}/bin/mu index
  '';
  };

  accounts.email = let
    mbsync = {
      enable = true;
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
    mu = { enable = true; };
    msmtp = { enable = true; };
    realName = "Taylor Snead";
  in {
    maildirBasePath = ".mail";
    certificatesFile = "/etc/ssl/certs/ca-certificates.crt";

    accounts.personal = let address = "taylor@snead.xyz";
    in {
      inherit mbsync mu msmtp address realName;
      primary = true;
      userName = address;
      passwordCommand = "get-password.sh mailbox.org ${address}";
      imap.host = "imap.mailbox.org";
      imapnotify = {
        enable = true;
        boxes = [ "Inbox" ];
        #onPost = ''
        #  ${pkgs.isync}/bin/mbsync personal
        #'';
      };
      smtp = {
        host = "smtp.mailbox.org";
        port = 587;
        tls.useStartTls = true;
      };
    };

    accounts.neu = let address = "snead.t@northeastern.edu";
    in {
      inherit mu msmtp address realName;
      userName = address;
      imap.host = "localhost";
      imap.port = 1143;
      imap.tls.enable = false;
      passwordCommand = "echo x";
      mbsync =
        lib.mkMerge [ mbsync { extraConfig.account.AuthMechs = "LOGIN"; } ];
      imapnotify = {
        enable = true;
        boxes = [ "Inbox" ];
        #onPost = ''
        #  ${pkgs.isync}/bin/mbsync neu
        #'';
      };
      smtp = {
        host = "localhost";
        port = 1025;
        tls.enable = false;
      };
    };

    accounts.gmail = let address = "taylorsnead@gmail.com";
    in {
      inherit mbsync mu msmtp address realName;
      flavor = "gmail.com";
      userName = address;
      passwordCommand = "get-password.sh google.com ${address}";
      imap.host = "imap.gmail.com";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
    };
  };
}
