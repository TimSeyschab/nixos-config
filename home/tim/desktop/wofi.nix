{ pkgs, ... }:

let
  palette = import ./palette.nix;
in

{
  home.packages = [
    pkgs.wofi
  ];

  xdg.configFile."wofi/config".text = ''
    show=drun
    allow_images=true
    insensitive=true
    prompt=Start
    width=760
    height=520
    term=foot
  '';

  xdg.configFile."wofi/style.css".text = ''
    window {
      margin: 0;
      border: 2px solid #${palette.base03};
      background-color: #${palette.base00}fa;
      font-family: Inter, sans-serif;
      font-size: 15px;
    }

    #input {
      margin: 12px;
      padding: 10px 12px;
      border: 1px solid #${palette.base03};
      color: #${palette.base06};
      background-color: #${palette.base01};
    }

    #inner-box, #outer-box, #scroll {
      margin: 0;
      background-color: transparent;
    }

    #entry {
      padding: 8px 12px;
      color: #${palette.base05};
    }

    #entry:selected {
      background-color: #${palette.base0D};
      color: #${palette.base07};
    }
  '';
}
