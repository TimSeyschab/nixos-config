{ pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 uapsd_disable=3 disable_11ax=1
    options iwlmvm power_scheme=1
  '';

  environment.etc."NetworkManager/conf.d/wifi-powersave.conf".text = ''
    [connection]
    wifi.powersave=2
  '';

  environment.systemPackages = with pkgs; [
    iw
  ];

  networking.networkmanager = {
    enable = true;
    wifi.scanRandMacAddress = false;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "tim" ];
      MaxAuthTries = 3;
    };
  };
}
