{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    extraPackages = [
      pkgs.nftables
    ];
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
