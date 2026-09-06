_:

let
  palette = import ./palette.nix;
in

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        pad = "12x12";
        dpi-aware = "yes";
      };
      scrollback.lines = 10000;
      colors-dark = {
        alpha = palette.opacity.terminal;
        background = palette.base00;
        foreground = palette.base05;
        regular0 = palette.base00;
        regular1 = palette.base08;
        regular2 = palette.base0B;
        regular3 = palette.base0A;
        regular4 = palette.base0D;
        regular5 = palette.base0E;
        regular6 = palette.base0C;
        regular7 = palette.base05;
      };
    };
  };
}
