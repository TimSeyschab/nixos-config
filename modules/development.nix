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
    python3
    nodejs
    docker-compose
  ];
}
