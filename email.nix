{ config, lib, pkgs, ... }: {
  # We use mu4e, which requires mu.
  # mu4e automatically syncs using isync so I don't need a constantly
  # running service.
  environment.systemPackages = with pkgs; [ mu davmail ];

  # Use davmail to manage Outlook accounts, mainly my university email.
  # systemd.user.services.davmail = {
  #   enable = true;
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     type = "simple";
  #     ExecStart =
  #       "${pkgs.davmail}/bin/davmail $XDG_CONFIG_HOME/davmail/.properties";
  #     Restart = "on-failure";
  #     LogsDirectory = "davmail";
  #   };
  # };
  # services.davmail = {
  #   enable = true;
  #   config.davmail = {
  #     mode = "O365Manual";
  #     allowRemote = false;
  #     enableKeepAlive = false;
  #     oauth.persistToken = true;
  #   };
  #   url = "https://outlook.office365.com/EWS/Exchange.asmx";
  # };
}
