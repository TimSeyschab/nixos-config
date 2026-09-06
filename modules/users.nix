{ pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.tim = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
  };
}
