{ pkgs, ... }:

let
  palette = import ./palette.nix;
in

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
    font=Inter 12
    background-color=#${palette.base00}${palette.opacity.popup}
    text-color=#${palette.base06}ff
    border-color=#${palette.base03}ff
    progress-color=over #${palette.base0D}ff
    default-timeout=7000
  '';
}
