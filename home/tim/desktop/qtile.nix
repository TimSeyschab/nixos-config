{ pkgs, ... }:

let
  applyDisplayScale = pkgs.writeShellScript "qtile-apply-display-scale" ''
    set -eu

    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      exit 0
    fi

    sleep 1
    ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --scale 1.25 --pos 0,0 || true
    ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --scale 1 --pos 3072,0 || true
  '';

  screenshotArea = pkgs.writeShellScript "qtile-screenshot-area" ''
    set -eu

    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
    geometry="$(${pkgs.slurp}/bin/slurp || true)"

    [ -n "$geometry" ] || exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
  '';

  screenshotFull = pkgs.writeShellScript "qtile-screenshot-full" ''
    set -eu

    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

    ${pkgs.grim}/bin/grim "$file"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
  '';

  powerMenu = pkgs.writeShellScript "qtile-power-menu" ''
    set -eu

    choice="$(printf "Lock\nSuspend\nReboot\nPoweroff\nLogout\n" | ${pkgs.wofi}/bin/wofi --dmenu --prompt Power || true)"

    case "$choice" in
      Lock)
        ${pkgs.swaylock}/bin/swaylock -f -c 101418
        ;;
      Suspend)
        ${pkgs.swaylock}/bin/swaylock -f -c 101418 &
        sleep 1
        ${pkgs.systemd}/bin/systemctl suspend
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

  lockAndSuspend = pkgs.writeShellScript "qtile-lock-and-suspend" ''
    set -eu

    ${pkgs.swaylock}/bin/swaylock -f -c 101418 &
    sleep 1
    ${pkgs.systemd}/bin/systemctl suspend
  '';

  networkStatus = pkgs.writeShellScript "qtile-network-status" ''
    set -eu

    ${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE,STATE device status \
      | ${pkgs.gawk}/bin/awk -F: '$3 == "connected" && $2 != "loopback" { print toupper($2) " " $1; found=1; exit } END { if (!found) print "NET down" }'
  '';

  dockerStatus = pkgs.writeShellScript "qtile-docker-status" ''
    set -eu

    if ! ${pkgs.docker}/bin/docker info >/dev/null 2>&1; then
      echo "DKR off"
      exit 0
    fi

    running="$(${pkgs.docker}/bin/docker ps -q 2>/dev/null | ${pkgs.coreutils}/bin/wc -l)"
    echo "DKR $running"
  '';

  kubeStatus = pkgs.writeShellScript "qtile-kube-status" ''
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
    brightnessctl
    grim
    slurp
    swaybg
    swayidle
    swaylock
    wl-clipboard
    wlr-randr
  ];

  xdg.configFile."qtile/config.py".text = ''
    import subprocess

    from libqtile import bar, hook, layout, widget
    from libqtile.config import Click, Drag, Group, Key, Match, Screen
    from libqtile.lazy import lazy

    mod = "mod4"
    terminal = "${pkgs.foot}/bin/foot"
    launcher = "${pkgs.wofi}/bin/wofi --show drun"
    browser = "${pkgs.firefox}/bin/firefox"

    colors = {
        "bg": "#101418",
        "bg_alt": "#1b2229",
        "fg": "#d8dee9",
        "muted": "#8f9ba8",
        "blue": "#61afef",
        "green": "#98c379",
        "yellow": "#e5c07b",
        "red": "#e06c75",
        "border": "#3b4252",
    }

    def sh(command):
        try:
            return subprocess.check_output(command, shell=True, text=True, timeout=2).strip()
        except Exception:
            return "-"

    @hook.subscribe.startup_once
    def autostart():
        for command in (
            "${applyDisplayScale}",
            "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill",
            "${pkgs.mako}/bin/mako",
            "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator",
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1",
            "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f -c 101418' timeout 900 '${pkgs.systemd}/bin/systemctl suspend' before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 101418'",
        ):
            subprocess.Popen(command, shell=True)

    keys = [
        Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
        Key([mod], "d", lazy.spawn(launcher), desc="Launcher"),
        Key([mod], "b", lazy.spawn(browser), desc="Browser"),
        Key([mod], "q", lazy.window.kill(), desc="Close window"),
        Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Fullscreen"),
        Key([mod, "shift"], "space", lazy.window.toggle_floating(), desc="Floating"),
        Key([mod], "space", lazy.layout.next(), desc="Next window"),
        Key([mod], "Tab", lazy.next_layout(), desc="Next layout"),
        Key([mod, "control"], "r", lazy.reload_config(), desc="Reload Qtile"),
        Key([mod, "control"], "q", lazy.spawn("${powerMenu}"), desc="Power menu"),
        Key([mod], "Escape", lazy.spawn("${pkgs.swaylock}/bin/swaylock -f -c 101418"), desc="Lock"),
        Key([mod, "shift"], "s", lazy.spawn("${lockAndSuspend}"), desc="Suspend"),

        Key([mod], "h", lazy.layout.left(), desc="Focus left"),
        Key([mod], "l", lazy.layout.right(), desc="Focus right"),
        Key([mod], "j", lazy.layout.down(), desc="Focus down"),
        Key([mod], "k", lazy.layout.up(), desc="Focus up"),
        Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move left"),
        Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move right"),
        Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move down"),
        Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move up"),
        Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow left"),
        Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow right"),
        Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow down"),
        Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow up"),
        Key([mod], "n", lazy.layout.normalize(), desc="Normalize"),

        Key([], "Print", lazy.spawn("${screenshotArea}"), desc="Screenshot area"),
        Key(["shift"], "Print", lazy.spawn("${screenshotFull}"), desc="Screenshot full"),
        Key([], "XF86AudioRaiseVolume", lazy.spawn("${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), desc="Volume up"),
        Key([], "XF86AudioLowerVolume", lazy.spawn("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), desc="Volume down"),
        Key([], "XF86AudioMute", lazy.spawn("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), desc="Mute"),
        Key([], "XF86MonBrightnessUp", lazy.spawn("${pkgs.brightnessctl}/bin/brightnessctl set +5%"), desc="Brightness up"),
        Key([], "XF86MonBrightnessDown", lazy.spawn("${pkgs.brightnessctl}/bin/brightnessctl set 5%-"), desc="Brightness down"),
    ]

    for vt in range(1, 8):
        keys.append(
            Key(
                ["control", "mod1"],
                f"f{vt}",
                lazy.core.change_vt(vt),
                desc=f"Switch to VT{vt}",
            )
        )

    groups = [Group(str(i)) for i in range(1, 10)]

    for group in groups:
        keys.extend(
            [
                Key([mod], group.name, lazy.group[group.name].toscreen(), desc=f"Workspace {group.name}"),
                Key([mod, "shift"], group.name, lazy.window.togroup(group.name, switch_group=True), desc=f"Move to workspace {group.name}"),
            ]
        )

    layouts = [
        layout.MonadTall(margin=8, border_width=2, border_focus=colors["blue"], border_normal=colors["border"]),
        layout.Columns(margin=8, border_width=2, border_focus=colors["green"], border_normal=colors["border"]),
        layout.Max(),
    ]

    widget_defaults = dict(
        font="sans",
        fontsize=15,
        padding=8,
        foreground=colors["fg"],
        background=colors["bg"],
    )
    extension_defaults = widget_defaults.copy()

    def make_bar():
        return bar.Bar(
            [
                widget.GroupBox(
                    active=colors["fg"],
                    inactive=colors["muted"],
                    highlight_method="line",
                    highlight_color=[colors["bg"], colors["bg_alt"]],
                    this_current_screen_border=colors["blue"],
                    this_screen_border=colors["green"],
                    urgent_border=colors["red"],
                    rounded=False,
                    padding=5,
                ),
                widget.CurrentLayout(foreground=colors["yellow"]),
                widget.WindowName(empty_group_string="", max_chars=120),
                widget.Spacer(length=bar.STRETCH),
                widget.GenPollText(func=lambda: sh("${networkStatus}"), update_interval=10, foreground=colors["green"]),
                widget.GenPollText(func=lambda: sh("${dockerStatus}"), update_interval=15, foreground=colors["blue"]),
                widget.GenPollText(func=lambda: sh("${kubeStatus}"), update_interval=30, foreground=colors["yellow"]),
                widget.StatusNotifier(),
                widget.CPU(format="CPU {load_percent}%"),
                widget.Memory(format="RAM {MemUsed:.0f}{mm}"),
                widget.PulseVolume(fmt="VOL {}"),
                widget.Clock(format="%a %d.%m. %H:%M"),
            ],
            36,
            background=colors["bg"],
        )

    screens = [
        Screen(top=make_bar(), background=colors["bg"]),
        Screen(top=make_bar(), background=colors["bg"]),
    ]

    mouse = [
        Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
        Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
        Click([mod], "Button2", lazy.window.bring_to_front()),
    ]

    floating_layout = layout.Floating(
        border_focus=colors["blue"],
        border_normal=colors["border"],
        border_width=2,
        float_rules=[
            *layout.Floating.default_float_rules,
            Match(wm_class="confirmreset"),
            Match(wm_class="makebranch"),
            Match(wm_class="maketag"),
            Match(wm_class="ssh-askpass"),
            Match(title="branchdialog"),
            Match(title="pinentry"),
        ],
    )

    dgroups_key_binder = None
    dgroups_app_rules = []
    follow_mouse_focus = True
    bring_front_click = False
    floats_kept_above = True
    cursor_warp = False
    auto_fullscreen = True
    focus_on_window_activation = "smart"
    reconfigure_screens = True
    auto_minimize = False
    wl_input_rules = None
    wl_xcursor_theme = None
    wl_xcursor_size = 32
    wmname = "LG3D"
  '';
}
