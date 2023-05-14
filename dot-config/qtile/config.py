import os

from libqtile import bar, layout, widget, extension
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.log_utils import logger

mod = "mod4"
terminal = guess_terminal(['alacritty', 'kitty'])

# declare volume widget here so keyboard controls can be set up
volume_widget = widget.Volume(
    volume_app='pavucontrol',
)

is_laptop = 'laptop' in os.uname().nodename.lower()

# function to decrease brightness, but don't go below 10%
def dec_brightness(qt):
    try:
        with open('/sys/class/backlight/intel_backlight/brightness', 'r') as f:
            brightness = float(f.read().strip())
        with open('/sys/class/backlight/intel_backlight/max_brightness', 'r') as f:
            max_brightness = float(f.read().strip())
    except FileNotFoundException as e:
        logger.exception(e)

    brightness_pct = brightness / max_brightness
    if brightness_pct > 0.15:
        qt.cmd_spawn("brightnessctl set 10%-")


keys = [
    # Switch between windows
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc='Toggle floating'),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),

    # Launch a program:
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "p", lazy.spawn('rofi -show run')),

    # Volume controls:
    Key([], 'XF86AudioRaiseVolume', lazy.function(lambda qt: volume_widget.cmd_increase_vol())),
    Key([], 'XF86AudioLowerVolume', lazy.function(lambda qt: volume_widget.cmd_decrease_vol())),
    Key([], 'XF86AudioMute', lazy.function(lambda qt: volume_widget.cmd_mute())),

    # Brightness controls:
    Key([], 'XF86MonBrightnessUp', lazy.spawn("brightnessctl set 10%+")),
    Key([], 'XF86MonBrightnessDown', lazy.function(dec_brightness)),

    # Reload configuration
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
]

groups = [Group(i) for i in "123456789"]

for g in groups:
    i = g.name
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i, lazy.group[i].toscreen(), desc=f"Switch to group {i}"),
        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i, lazy.window.togroup(i, switch_group=True), desc=f"Switch to & move focused window to group {i}"),
    ])

layouts = [
    layout.Columns(
        # blue border for windows when more than one
        border_focus='#111188',
        border_normal='#000022',
        # green border indicates window is stacked
        border_focus_stack='#118811',
        border_normal_stack='#002200',
    ),
    layout.Max(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Systray(),
                # TODO figure out why this doesn't work...
                # widget.Backlight(brightness_file='intel_backlight'),
                volume_widget,
                # laptop-only, not sure if there is a better way to make this conditional...
                *([
                    widget.Battery(format="{char} {percent:2.0%}", charge_char='+', discharge_char='-', foreground='#a0a0ff')
                ] if is_laptop else []),
                widget.Clock(format="%Y-%m-%d %a  %H:%M", foreground='#c0ff90'), # 12-hour time: %I:%M %p    24-hour: %H:%M
                widget.QuickExit(foreground='#df5050', countdown_start=3),
            ],
            24,
        ),
        wallpaper="~/Pictures/wallpapers/nixos_logo.png",

        wallpaper_mode='fill',
        # wallpaper_mode='stretch',
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
