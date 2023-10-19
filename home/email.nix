{ config, lib, pkgs, ... }:

{
  programs.mbsync.enable = true;
  programs.mu.enable = true;
  programs.msmtp.enable = true;
  services.imapnotify.enable = false;
  services.mbsync = {
    enable = false;
    postExec = ''
      ${pkgs.mu}/bin/mu index
    '';
  };

  home.packages = [ pkgs.davmail ];

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
      passwordCommand = "get-password mailbox.org ${address}";
      imap.host = "imap.mailbox.org";
      # imapnotify = {
      #   enable = true;
      #   boxes = [ "Inbox" ];
      #   #onPost = ''
      #   #  ${pkgs.isync}/bin/mbsync personal
      #   #'';
      # };
      smtp = {
        host = "smtp.mailbox.org";
        port = 587;
        tls.useStartTls = true;
      };
    };

    accounts.neu = let address = "snead.t@northeastern.edu";
    in {
      inherit mbsync mu msmtp thunderbird address realName;
      flavor = "gmail.com";
      userName = address;
      imap.host = "imap.gmail.com";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
    };

    accounts.classcompanion = let address = "snead@classcompanion.com";
    in {
      inherit mbsync mu msmtp address realName;
      flavor = "gmail.com";
      userName = address;
      passwordCommand = "get-password google.com ${address}";
      imap.host = "imap.gmail.com";
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.useStartTls = true;
      };
      thunderbird.enable = true;
    };
  };
}
