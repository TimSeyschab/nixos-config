{ pkgs, ... }:

let
  qtile = pkgs.python3Packages.qtile.override {
    extraPackages = [ pkgs.python3Packages.qtile-extras ];
  };

  qtileWaylandSession =
    (pkgs.writeTextDir "share/wayland-sessions/qtile-wayland.desktop" ''
      [Desktop Entry]
      Name=Qtile (Wayland)
      Comment=Qtile Wayland Session
      Exec=${qtile}/bin/qtile start -b wayland
      Type=Application
      DesktopNames=Qtile
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "qtile-wayland" ];
      });

in
{
  # SDDM discovers the GNOME session alongside the custom Qtile session.
  services.desktopManager.gnome.enable = true;

  services.displayManager = {
    sessionPackages = [
      qtileWaylandSession
    ];
    defaultSession = "qtile-wayland";

    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  programs.firefox.enable = true;

  environment.systemPackages = [ qtile ];

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];

    config.common.default = [
      "wlr"
      "gtk"
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
