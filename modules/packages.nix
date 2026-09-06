{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    curl
    git
    tree
    vim
    wget
  ];
}
