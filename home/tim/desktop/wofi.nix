{ pkgs, ... }:

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
      border: 2px solid #3b4252;
      background-color: rgba(16, 20, 24, 0.98);
      font-family: sans-serif;
      font-size: 15px;
    }

    #input {
      margin: 12px;
      padding: 10px 12px;
      border: 1px solid #4c566a;
      color: #e5e9f0;
      background-color: #1b2229;
    }

    #inner-box, #outer-box, #scroll {
      margin: 0;
      background-color: transparent;
    }

    #entry {
      padding: 8px 12px;
      color: #d8dee9;
    }

    #entry:selected {
      background-color: #2f5f8f;
      color: #ffffff;
    }
  '';
}
