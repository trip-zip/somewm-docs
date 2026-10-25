---
title: First Launch
description: Start kiln nested or on a TTY, understand the config search order, and learn the stock desktop and its default keybindings.
sidebar_position: 2
---

# First Launch

kiln picks its backend automatically. Launched from inside an existing Wayland
session it opens as a nested window titled `kiln`, which is the comfortable
way to explore. Launched from a bare TTY it takes your logind session and
runs directly on DRM.

## Starting kiln

```bash
kiln_demo=$(mktemp -d /tmp/kiln-demo.XXXXXX)
KILN_SOCK="$kiln_demo/eval.sock" KILN_RC="$PWD/kilnrc.lua" \
  dbus-run-session -- ./build/kiln -s foot
```

`dbus-run-session` gives kiln and its clients a session bus. Notifications,
the tray and portals need it. Run this from the source checkout; logs go to
the terminal. `make run` also wraps D-Bus, with your normal config and a
private socket.

Installed: run `kiln` from a free TTY (wrap it in `dbus-run-session` if your
login provides no bus).

`./run-tty` builds kiln and starts it on DRM with your `~/.config/kiln/rc.lua`
(or `$KILN_RC`), a private bus and socket, and `-s foot`. Output goes to
`/tmp/kiln-seat-trial.*/server.log`; the directory name is saved in
`build/last-tty-trial`. Use it on a free seat only.

Flags and environment:

- `-s <command>` runs a startup command once the compositor is up. Useful for
  launching a terminal or a session script on a TTY boot.
- `KILN_RC=<path>` loads an explicit config file, overriding the search order.
- `KILN_SOCK=<path>` sets the IPC socket path (default
  `$XDG_RUNTIME_DIR/kiln.sock`).
- `KILN_BACKEND` overrides the choice (`headless`, `nested`, `drm`); `nested`
  is used when `WAYLAND_DISPLAY` is set, otherwise `drm`.

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
  has a `kiln` submenu whose `theme` entry offers gruvbox and nord as well;
  the choice persists to `~/.config/kiln/theme` across restarts.

Clients tile into the selected tag's layout as you open them. Clicking a
client focuses it, and focus also follows the mouse.

## Default keybindings

The modkey is `super` (the stdlib default is `alt`; the shipped config
overrides it). Press `mod+s` at any time to pop up the built-in cheat sheet,
which is generated from the live bindings. The essentials:

| Chord | Action |
|---|---|
| `mod+Return` | open a terminal (`$TERMINAL`, falling back to foot) |
| `mod+p` | app launcher: every installed `.desktop` app, type to filter |
| `mod+shift+c` | close the focused client |
| `mod+1` .. `mod+9` | view tag by index |
| `mod+j` / `mod+k` | focus next / previous client |
| `mod+space` | next layout |
| `mod+f` / `mod+m` | toggle fullscreen / maximised |
| `mod+n` / `mod+ctrl+n` | minimise / restore |
| `mod+shift+i` | open or close the Clay inspector |
| `mod+x` | Lua prompt; try `6*7` |
| `mod+ctrl+r` | reload the config |
| `mod+shift+q` | quit kiln |
| `alt+Escape` | also quits kiln |

Everything else (focus, layouts, floating, media keys, screenshots, the
lock chord) is on the `mod+s` sheet.

Mouse bindings:

| Gesture | Action |
|---|---|
| `mod` + left drag | move a window |
| `mod` + right drag | resize from the nearest corner |
| right-click the desktop | main menu |
| click | focus |

## Make it yours

Keep an existing config. For a new one, copy the default without overwriting:

```bash
mkdir -p ~/.config/kiln
cp -n kilnrc.lua ~/.config/kiln/rc.lua  # a new config only
# or, after make install:
cp -n /usr/local/share/kiln/rc.lua ~/.config/kiln/rc.lua
```

Everything above (keys, tags, layouts, the bar, the wallpaper, the theme) is
plain Lua in that one file.

## See also

- [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy)
- [Basics tutorial](/kiln/tutorials/basics)
- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
