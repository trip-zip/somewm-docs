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

## Which config runs

kiln loads `~/.config/kiln/rc.lua` if it exists, and the installed default otherwise. `KILN_RC` overrides both; the full search order is in the [Environment and IPC reference](/kiln/reference/environment-and-ipc#config-search-order).

## What you see

The stock desktop is the default `rc.lua`:

- A top bar (32 px) of three equal regions: launcher button, taglist, and
  tasklist on the left, the clock centered in the middle, the system tray
  and layout indicator on the right. Hovering the clock shows the full
  date as a tooltip.
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
| `mod+p` | app launcher: every installed `.desktop` app, type to filter |
| `mod+shift+c` | close the focused client |
| `mod+1` .. `mod+9` | view tag by index |
| `mod+ctrl+r` | reload the config |
| `mod+shift+q` | quit kiln |

Everything else (focus, layouts, floating, media keys, screenshots, the
lock chord) is on the `mod+s` sheet, which never goes stale: it reads the
binding registry live.

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
