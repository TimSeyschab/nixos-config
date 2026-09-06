let
  aliases = {
    cat = "bat -p";
    d = "docker";
    dc = "docker compose";
    dps = "docker ps --format 'table {{.Names}}\\t{{.Image}}\\t{{.Status}}\\t{{.Ports}}'";
    h = "helm";
    jc = "java-check";
    k = "kubectl";
    kgp = "kubectl get pods -o wide";
    kctx = "kubectx";
    kns = "kubens";
    kv = "kube-validate";
    kd = "kube-doctor";
    goc = "go-check";
    l = "eza -lah --git --group-directories-first";
    la = "eza -la --git --group-directories-first";
    ll = "eza -lh --git --group-directories-first";
    ls = "eza --group-directories-first";
    rgf = "rg --files";
    tf = "tofu";
    tma = "tmux attach -t";
    tml = "tmux list-sessions";
    tns = "tmux new-session -s";
    v = "nvim";
  };
in

{
  programs.bash = {
    enable = true;
    shellAliases = aliases;
  };

  programs.zsh = {
    enable = true;
    shellAliases = aliases;
  };
}
