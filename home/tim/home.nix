{ pkgs, ... }:

{
  imports = [
    ./apps/citrix.nix
    ./apps/engineering.nix
    ./apps/jetbrains.nix
    ./desktop/foot.nix
    ./desktop/mako.nix
    ./desktop/qtile.nix
    ./desktop/wofi.nix
    ./programs/neovim.nix
    ./programs/tmux.nix
    ./shell/aliases.nix
    ./shell/zsh.nix
  ];

  home = {
    username = "tim";
    homeDirectory = "/home/tim";
    stateVersion = "26.05";

    packages = with pkgs; [
      adwaita-icon-theme
      networkmanagerapplet
      pavucontrol
      playerctl
      waybar
      xdg-utils
    ];

    sessionVariables = {
      XCURSOR_SIZE = "32";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_ENABLE_HIGHDPI_SCALING = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  stylix.targets = {
    font-packages.enable = true;
    fontconfig.enable = true;
    gtk.enable = true;
    qt.enable = true;

    foot.enable = false;
    tmux.enable = false;
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
