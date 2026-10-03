{ pkgs, ... }:

let
  qtileExtras = pkgs.python3Packages.qtile-extras.overridePythonAttrs (_old: {
    version = "0.36.0";
    src = pkgs.fetchFromGitHub {
      owner = "elParaguayo";
      repo = "qtile-extras";
      tag = "v0.36.0";
      hash = "sha256-H2A5Y+ukTkUqjQB5eQVuOMYpf7T8RgQlNlQ25wlWwr8=";
    };
    doCheck = false;
    pythonImportsCheck = [ ];
  });

  qtile =
    (pkgs.python3Packages.qtile.override {
      extraPackages = [
        qtileExtras
      ];
    }).overridePythonAttrs
      (_old: {
        version = "0.36.0";
        src = pkgs.fetchFromGitHub {
          owner = "qtile";
          repo = "qtile";
          tag = "v0.36.0";
          hash = "sha256-yFh9h3djV52zdZjPYwOWaMzN9ZNhFdZYyxFJreoJBCk=";
        };
        postInstall = "install -Dm644 resources/qtile.desktop $out/share/xsessions/qtile.desktop; install -Dm644 resources/qtile-wayland.desktop $out/share/wayland-sessions/qtile.desktop; ";
        doCheck = false;
        doInstallCheck = false;
      });

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
