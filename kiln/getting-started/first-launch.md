---
title: First Launch
description: Start kiln nested or on a TTY, understand the config search order, and learn the stock desktop and its default keybindings.
sidebar_position: 2
---

# First Launch

kiln picks its backend automatically. Launched from inside an existing Wayland
or X session it opens as a nested window, which is the comfortable way to
explore. Launched from a bare TTY it runs directly on DRM as your session.

## Starting kiln

```bash
dbus-run-session ./build/kiln     # or simply: make run
```

Run it under a session bus. The bus serves two things: clients you spawn
(portals, apps that expect D-Bus), and kiln's own D-Bus integrations, which is
how desktop notifications and system tray items reach the compositor. Without
a bus, apps still run but anything D-Bus-shaped is missing. `make run` wraps
this for you and logs to `~/.cache/kiln.log`.

Flags and environment:

- `-s <command>` runs a startup command once the compositor is up. Useful for
  launching a terminal or a session script on a TTY boot.
- `KILN_RC=<path>` loads an explicit config file, overriding the search order.

## The config search order

First hit wins:

1. `KILN_RC`
2. `$XDG_CONFIG_HOME/kiln/rc.lua` (falling back to `~/.config/kiln/rc.lua`)
3. the installed default under `<prefix>/share/kiln/rc.lua`
4. `rc.lua` in the working directory (how it runs from the source tree)

## What you see

The stock desktop is the default `rc.lua`:

- A top bar (28 px) carrying, left to right: a taglist, a layout indicator,
  a menu button, a tasklist, and a clock on the right. Hovering the clock
  shows the full date as a tooltip.
- Four tags per screen: `term`, `web`, `chat`, `media`, on the tile, spiral,
  fair, and carousel layouts respectively. The first tag is selected.
- A wallpaper, if the `KILN_WALLPAPER` environment variable points at an
  image file. Unset, the background is the theme's base color.

Clients tile into the selected tag's layout as you open them. Clicking a
client focuses it, and focus also follows the mouse.

## Default keybindings

The modkey is `alt`. Press `alt+s` at any time to pop up the built-in cheat
sheet, which is generated from these same bindings.

| Chord | Action |
|---|---|
| `alt+Return` | open a terminal (`$TERMINAL`, falling back to ghostty) |
| `alt+b` | open a browser (firefox) |
| `alt+c` | open chat (slack) |
| `alt+r` | run prompt (type a command, Enter to spawn) |
| `alt+t` | spawn a terminal with an activation token |
| `alt+q` | close the focused client |
| `alt+space` | toggle floating |
| `alt+f` | toggle fullscreen |
| `alt+m` | toggle maximized |
| `alt+n` | minimize (restore by clicking its tasklist entry) |
| `alt+Tab` | focus the previously focused client |
| `alt+o` | send the focused client to the next screen |
| `alt+1` .. `alt+9` | view tag by index |
| `alt+shift+1` .. `alt+shift+9` | move the focused client to a tag |
| `alt+period` | next layout |
| `alt+comma` | pick a layout from a menu |
| `alt+l` | lock the session |
| `alt+s` | show the hotkeys popup |
| `alt+Escape` | quit kiln |

Mouse bindings:

| Gesture | Action |
|---|---|
| `alt` + left drag | move a window |
| `alt` + right drag | resize from the nearest corner |
| click | focus |

## Make it yours

Copy the default config into place and edit it:

```bash
mkdir -p ~/.config/kiln
cp rc.lua ~/.config/kiln/rc.lua     # from the source tree
# or, after make install:
cp /usr/local/share/kiln/rc.lua ~/.config/kiln/rc.lua
```

Everything above (keys, tags, layouts, the bar, the wallpaper, the theme) is
plain Lua in that one file.

## See also

- [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy)
- [Basics tutorial](/kiln/tutorials/basics)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
