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

- A top bar (32 px) carrying, left to right: a launcher button, a taglist,
  a tasklist, a system tray, a layout indicator, and a clock floated in the
  center. Hovering the clock shows the full date as a tooltip.
- Five tags per screen: `dev`, `web`, `chat`, `files`, `media`, all on the
  tile layout. The first tag is selected.
- A generated wallpaper: a gradient in the theme's colors with the kiln mark
  centered, rendered per output (this needs `rsvg-convert` on your PATH). Set
  `KILN_WALLPAPER` to an image path to use that instead.
- The catppuccin palette. The main menu (`mod+w`, or right-click the desktop)
  has a theme submenu with gruvbox and nord as well; the choice persists to
  `~/.config/kiln/theme` across restarts.

Clients tile into the selected tag's layout as you open them. Clicking a
client focuses it, and focus also follows the mouse.

## Default keybindings

The modkey is `super` (the stdlib default is `alt`; the shipped config
overrides it). Press `mod+s` at any time to pop up the built-in cheat sheet,
which is generated from the live bindings and always complete. The essentials:

| Chord | Action |
|---|---|
| `mod+Return` | open a terminal (`$TERMINAL`, falling back to foot) |
| `mod+r` | run prompt (type a command with Tab completion, Enter to spawn) |
| `mod+p` | app launcher: every installed `.desktop` app, type to filter |
| `mod+w` | main menu (theme switcher, lock, quit, ...) |
| `mod+s` | hotkeys sheet |
| `mod+shift+c` | close the focused client |
| `mod+j` / `mod+k` | focus next / previous client |
| `mod+Tab` | focus the previously focused client |
| `mod+1` .. `mod+9` | view tag by index |
| `mod+shift+1` .. `mod+shift+9` | move the focused client to a tag |
| `mod+Left` / `mod+Right` | view previous / next tag |
| `mod+space` | next layout |
| `mod+h` / `mod+l` | shrink / grow the master area |
| `mod+ctrl+space` | toggle floating |
| `mod+f` / `mod+m` / `mod+n` | fullscreen / maximize / minimize |
| `mod+o` | send the focused client to the next screen |
| `mod+shift+Escape` | lock the session |
| `mod+ctrl+r` | reload the config |
| `mod+shift+i` | toggle the [Clay inspector](/kiln/guides/inspector) |
| `mod+shift+q` | quit kiln |

The config also binds the media keys (volume and microphone via `wpctl`,
brightness via `brightnessctl`) and screenshots (`Print` for the full output,
`shift+Print` for a region via `slurp` and `grim`).

Mouse bindings:

| Gesture | Action |
|---|---|
| `mod` + left drag | move a window |
| `mod` + right drag | resize from the nearest corner |
| right-click the desktop | main menu |
| click | focus |

## Make it yours

Copy the default config into place and edit it:

```bash
mkdir -p ~/.config/kiln
cp kilnrc.lua ~/.config/kiln/rc.lua     # from the source tree
# or, after make install:
cp /usr/local/share/kiln/rc.lua ~/.config/kiln/rc.lua
```

Everything above (keys, tags, layouts, the bar, the wallpaper, the theme) is
plain Lua in that one file.

## See also

- [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy)
- [Basics tutorial](/kiln/tutorials/basics)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
