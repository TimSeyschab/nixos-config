{ pkgs, pkgsUnstable, ... }:

let
  autoPatchelfPy312 = pkgsUnstable.auto-patchelf.override {
    python3 = pkgs.python312;
  };

  autoPatchelfHookPy312 = pkgsUnstable.autoPatchelfHook.override {
    auto-patchelf = autoPatchelfPy312;
  };

  citrixWorkspace = pkgsUnstable."citrix-workspace".override {
    autoPatchelfHook = autoPatchelfHookPy312;
  };
in
{
  home.packages = [
    citrixWorkspace
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-ica" = [ "wfica.desktop" ];
    };
    associations.added = {
      "application/x-ica" = [ "wfica.desktop" ];
    };
  };
}
