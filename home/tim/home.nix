{ pkgs, ... }:

{
  imports = [
    ./apps/citrix.nix
    ./desktop/foot.nix
    ./desktop/mako.nix
    ./desktop/qtile.nix
    ./desktop/wofi.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    adwaita-icon-theme
    networkmanagerapplet
    pavucontrol
    playerctl
    waybar
    xdg-utils
  ];

  home.sessionVariables = {
    XCURSOR_SIZE = "32";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_ENABLE_HIGHDPI_SCALING = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
