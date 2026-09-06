{ pkgs, ... }:

{
  home.packages = [
    pkgs.mako
  ];

  xdg.configFile."mako/config".text = ''
    anchor=top-right
    width=420
    height=120
    margin=16
    padding=12
    border-size=2
    border-radius=6
    font=sans 12
    background-color=#101418f2
    text-color=#e5e9f0ff
    border-color=#3b4252ff
    progress-color=over #2f5f8fff
    default-timeout=7000
  '';
}
