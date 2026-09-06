{ ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=12";
        pad = "12x12";
        dpi-aware = "yes";
      };
      scrollback.lines = 10000;
      colors-dark = {
        alpha = "0.96";
        background = "101418";
        foreground = "d8dee9";
        regular0 = "101418";
        regular1 = "e06c75";
        regular2 = "98c379";
        regular3 = "e5c07b";
        regular4 = "61afef";
        regular5 = "c678dd";
        regular6 = "56b6c2";
        regular7 = "d8dee9";
      };
    };
  };
}
