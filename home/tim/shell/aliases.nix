{ ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      d = "docker";
      dc = "docker compose";
      dps = "docker ps --format 'table {{.Names}}\\t{{.Image}}\\t{{.Status}}\\t{{.Ports}}'";
      h = "helm";
      k = "kubectl";
      kgp = "kubectl get pods -o wide";
      kctx = "kubectx";
      kns = "kubens";
      tf = "tofu";
      tma = "tmux attach -t";
      tml = "tmux list-sessions";
      tns = "tmux new-session -s";
    };
  };
}
