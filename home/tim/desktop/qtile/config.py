import os
import subprocess

from libqtile import bar, hook, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from qtile_extras import widget as extra_widget

from theme import bar_size, border_width, font, font_size, margin, palette, wallpaper

mod = "mod4"
terminal = "foot"
launcher = "wofi --show drun"
browser = "firefox"


def sh(command):
    try:
        return subprocess.check_output(
            command,
            shell=True,
            text=True,
            timeout=2,
        ).strip()
    except Exception:
        return "-"


def spawn_once(command, marker):
    if subprocess.call(f"pgrep -u $USER -f '{marker}' >/dev/null", shell=True) != 0:
        subprocess.Popen(command, shell=True)


@hook.subscribe.startup_once
def autostart():
    subprocess.Popen("qtile-apply-display-scale", shell=True)
    subprocess.Popen("sh -c 'sleep 2; qtile cmd-obj -o cmd -f to_screen -a 1'", shell=True)
    subprocess.Popen(f"swaybg -i {os.path.expanduser(wallpaper)} -m fill", shell=True)
    spawn_once("mako", "mako")
    spawn_once("nm-applet --indicator", "nm-applet")
    spawn_once("qtile-polkit-agent", "polkit-gnome-authentication-agent-1")
    spawn_once(
        "swayidle -w "
        "timeout 600 'swaylock -f -c 101418' "
        "timeout 900 'systemctl suspend' "
        "before-sleep 'swaylock -f -c 101418'",
        "swayidle",
    )


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
    Key([mod, "control"], "q", lazy.spawn("qtile-power-menu"), desc="Power menu"),
    Key([mod], "Escape", lazy.spawn("swaylock -f -c 101418"), desc="Lock"),
    Key([mod, "shift"], "s", lazy.spawn("qtile-lock-and-suspend"), desc="Suspend"),

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

    Key([], "Print", lazy.spawn("qtile-screenshot-area"), desc="Screenshot area"),
    Key(["shift"], "Print", lazy.spawn("qtile-screenshot-full"), desc="Screenshot full"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), desc="Volume up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), desc="Volume down"),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), desc="Mute"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5%"), desc="Brightness up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-"), desc="Brightness down"),
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
    layout.MonadTall(
        margin=margin,
        border_width=border_width,
        border_focus=palette["blue"],
        border_normal=palette["border"],
    ),
    layout.Columns(
        margin=margin,
        border_width=border_width,
        border_focus=palette["green"],
        border_normal=palette["border"],
    ),
    layout.Max(),
]

widget_defaults = dict(
    font=font,
    fontsize=font_size,
    padding=8,
    foreground=palette["fg"],
    background=palette["bg"],
)
extension_defaults = widget_defaults.copy()


def sep():
    return widget.TextBox(" | ", foreground=palette["border"], padding=2)


def make_bar(primary=False):
    widgets = [
        widget.GroupBox(
            active=palette["fg"],
            inactive=palette["muted"],
            highlight_method="line",
            highlight_color=[palette["bg"], palette["bg_alt"]],
            this_current_screen_border=palette["blue"],
            this_screen_border=palette["green"],
            urgent_border=palette["red"],
            rounded=False,
            padding=5,
        ),
        sep(),
        widget.CurrentLayout(foreground=palette["yellow"]),
        sep(),
        widget.WindowName(empty_group_string="", max_chars=100, foreground=palette["fg"]),
        widget.Spacer(length=bar.STRETCH),
        widget.GenPollText(func=lambda: sh("qtile-network-status"), update_interval=10, foreground=palette["green"]),
        sep(),
        widget.GenPollText(func=lambda: sh("qtile-docker-status"), update_interval=15, foreground=palette["blue"]),
        sep(),
        widget.GenPollText(func=lambda: sh("qtile-kube-status"), update_interval=30, foreground=palette["yellow"], max_chars=42),
        sep(),
    ]

    if primary:
        widgets.extend(
            [
                extra_widget.StatusNotifier(
                    icon_size=18,
                    padding=4,
                    menu_background=palette["bg"],
                    menu_foreground=palette["fg"],
                    menu_foreground_disabled=palette["muted"],
                    menu_foreground_highlighted=palette["bg"],
                    menu_background_highlighted=palette["blue"],
                    menu_border=palette["border"],
                    menu_border_width=0,
                    menu_font=font,
                    menu_fontsize=font_size,
                ),
                sep(),
            ]
        )

    widgets.extend(
        [
            widget.CPU(format="CPU {load_percent}%", foreground=palette["green"]),
            sep(),
            widget.Memory(format="RAM {MemUsed:.0f}{mm}", foreground=palette["blue"]),
            sep(),
            widget.PulseVolume(fmt="VOL {}", foreground=palette["yellow"]),
            sep(),
            widget.Clock(format="%a %d.%m. %H:%M", foreground=palette["fg"]),
        ]
    )

    return bar.Bar(widgets, bar_size, background=palette["bg"], opacity=0.98)


screens = [
    Screen(top=make_bar(), background=palette["bg"]),
    Screen(top=make_bar(primary=True), background=palette["bg"]),
]

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

floating_layout = layout.Floating(
    border_focus=palette["blue"],
    border_normal=palette["border"],
    border_width=border_width,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
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
