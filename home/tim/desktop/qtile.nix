{ pkgs, ... }:

let
  applyDisplayScale = pkgs.writeShellScriptBin "qtile-apply-display-scale" ''
    set -eu

    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      exit 0
    fi

    sleep 1
    ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --scale 1 --pos 0,0 || true
    ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --scale 1.25 --pos 1920,0 || true
  '';

  screenshotArea = pkgs.writeShellScriptBin "qtile-screenshot-area" ''
    set -eu

    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
    geometry="$(${pkgs.slurp}/bin/slurp || true)"

    [ -n "$geometry" ] || exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
  '';

  screenshotFull = pkgs.writeShellScriptBin "qtile-screenshot-full" ''
    set -eu

    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

    ${pkgs.grim}/bin/grim "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
  '';

  powerMenu = pkgs.writeShellScriptBin "qtile-power-menu" ''
    set -eu

    choice="$(printf "Lock\nSuspend\nReboot\nPoweroff\nLogout\n" | ${pkgs.wofi}/bin/wofi --dmenu --prompt Power || true)"

    case "$choice" in
      Lock)
        ${pkgs.swaylock}/bin/swaylock -f -c 101418
        ;;
      Suspend)
        qtile-lock-and-suspend
        ;;
      Reboot)
        ${pkgs.systemd}/bin/systemctl reboot
        ;;
      Poweroff)
        ${pkgs.systemd}/bin/systemctl poweroff
        ;;
      Logout)
        /run/current-system/sw/bin/qtile cmd-obj -o root -f shutdown || true
        ;;
    esac
  '';

  lockAndSuspend = pkgs.writeShellScriptBin "qtile-lock-and-suspend" ''
    set -eu

    ${pkgs.swaylock}/bin/swaylock -f -c 101418 &
    sleep 1
    ${pkgs.systemd}/bin/systemctl suspend
  '';

  networkStatus = pkgs.writeShellScriptBin "qtile-network-status" ''
    set -eu

    ${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE,STATE device status \
      | ${pkgs.gawk}/bin/awk -F: '$3 == "connected" && $2 != "loopback" { print toupper($2) " " $1; found=1; exit } END { if (!found) print "NET down" }'
  '';

  dockerStatus = pkgs.writeShellScriptBin "qtile-docker-status" ''
    set -eu

    if ! ${pkgs.docker}/bin/docker info >/dev/null 2>&1; then
      echo "DKR off"
      exit 0
    fi

    running="$(${pkgs.docker}/bin/docker ps -q 2>/dev/null | ${pkgs.coreutils}/bin/wc -l)"
    echo "DKR $running"
  '';

  kubeStatus = pkgs.writeShellScriptBin "qtile-kube-status" ''
    set -eu

    context="$(${pkgs.kubectl}/bin/kubectl config current-context 2>/dev/null || true)"
    if [ -z "$context" ]; then
      echo "K8S noctx"
      exit 0
    fi

    namespace="$(${pkgs.kubectl}/bin/kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || true)"
    [ -n "$namespace" ] || namespace="default"
    echo "K8S $context/$namespace"
  '';

  polkitAgent = pkgs.writeShellScriptBin "qtile-polkit-agent" ''
    set -eu

    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
  '';

  wallpaper = pkgs.runCommand "valdore-wallpaper.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    ${pkgs.imagemagick}/bin/magick -size 5120x2160 gradient:'#101418'-'#16212b' \
      -fill '#61afef22' -draw 'rectangle 0,1680 5120,1710' \
      -fill '#98c37918' -draw 'rectangle 0,1718 5120,1730' \
      -fill '#e5c07b14' -draw 'rectangle 0,1736 5120,1742' \
      $out
  '';
in
{
  home.packages = with pkgs; [
    applyDisplayScale
    brightnessctl
    dockerStatus
    grim
    kubeStatus
    lockAndSuspend
    networkStatus
    polkit_gnome
    polkitAgent
    powerMenu
    procps
    screenshotArea
    screenshotFull
    slurp
    swaybg
    swayidle
    swaylock
    wireplumber
    wl-clipboard
    wlr-randr
  ];

  xdg.configFile."qtile/config.py".source = ./qtile/config.py;
  xdg.configFile."qtile/theme.py".source = ./qtile/theme.py;
  xdg.configFile."qtile/README.md".source = ./qtile/README.md;
  xdg.configFile."qtile/wallpaper.png".source = wallpaper;
}
