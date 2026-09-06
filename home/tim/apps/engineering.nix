{ pkgs, ... }:

{
  home.packages = with pkgs; [
    dive
    jq
    k9s
    kubectl
    kubectx
    kubernetes-helm
    opentofu
    stern
    yq-go
  ];
}
