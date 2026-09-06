{ pkgs, ... }:

let
  palette = import ../home/tim/desktop/palette.nix;
in

{
  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    base16Scheme = builtins.removeAttrs palette [ "opacity" ];

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 32;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 11;
        desktop = 11;
        popups = 11;
        terminal = 12;
      };
    };

    targets = {
      console.enable = true;
      font-packages.enable = true;
      fontconfig.enable = true;
      gtk.enable = true;
    };
  };
}
