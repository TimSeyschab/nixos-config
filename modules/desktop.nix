{ pkgs, ... }:

let
  qtile = (
    pkgs.python312Packages.qtile.override {
      extraPackages = [ ];
    }
  ).overridePythonAttrs (_old: {
    doCheck = false;
    doInstallCheck = false;
  });

  qtileWaylandSession =
    (pkgs.writeTextDir
      "share/wayland-sessions/qtile-wayland.desktop"
      ''
        [Desktop Entry]
        Name=Qtile (Wayland)
        Comment=Qtile Wayland Session
        Exec=${qtile}/bin/qtile start -b wayland
        Type=Application
        DesktopNames=Qtile
      ''
    ).overrideAttrs (_: {
      passthru.providedSessions = [ "qtile-wayland" ];
    });

in
{
  services.displayManager.sessionPackages = [
    qtileWaylandSession
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    qtile
    foot
    alacritty
    waybar
    wofi
    wl-clipboard
    grim
    slurp
    swaybg
    xdg-utils
  ];

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
