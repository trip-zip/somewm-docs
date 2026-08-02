---
title: Installation
description: Build kiln from source with meson and ninja, run it from the tree, and install it system-wide.
sidebar_position: 1
---

# Installation

kiln builds from source with meson and ninja. A thin `make` wrapper drives the
whole cycle: configure, build, run, install.

## Dependencies

You need `meson` and `ninja`, plus these libraries with development headers:

- wlroots 0.20
- wayland-server, wayland-client
- wayland-protocols
- wayland-scanner
- xkbcommon
- libinput
- pixman-1
- luajit
- cairo
- pangocairo
- gdk-pixbuf-2.0

wlroots 0.20 is used from the system if present. If your distribution does not
ship it, the build falls back to the vendored subproject
(`subprojects/wlroots.wrap`) and builds wlroots itself, so any machine builds
reproducibly with no extra setup.

## Build

```bash
git clone https://github.com/trip-zip/kiln.git
cd kiln
make
```

`make` configures `build/` on the first run, then builds. It is a thin wrapper
over meson; this is exactly equivalent:

```bash
meson setup build && ninja -C build
```

The binary lands at `./build/kiln`, alongside the `kiln-client` CLI.

Three features are on by default and can be disabled at configure time
(`meson setup build -D<flag>=disabled`, or via `MESON_OPTS` with the make
wrapper):

| Flag | On by default | Off means |
|---|---|---|
| `xwayland` | X11 clients run; needs xcb and xcb-ewmh headers | No X11 clients |
| `dbus` | Notifications and the system tray; needs libsystemd or basu | Both are absent entirely, not stubbed |
| `pam` | Real lock-screen authentication | The lock screen accepts a fixed test password |

## Run from the source tree

```bash
make run
```

This builds, then launches kiln under a D-Bus session bus with its log at
`~/.cache/kiln.log` (the previous run's log is kept as `kiln.log.old`). Run it
from inside your existing desktop session and kiln opens as a nested window.
See [First Launch](/kiln/getting-started/first-launch) for what happens next.

## Install

```bash
sudo make install
```

Installs to `/usr/local` by default: the `kiln` binary, plus the default
`rc.lua` and its Lua library under `<prefix>/share/kiln`. Override the prefix:

```bash
make prefix=$HOME/.local
make prefix=$HOME/.local install
```

`prefix` and the build type are fixed at configure time. To change them after a
first build, run `make reconfigure` (which wipes and reconfigures `build/`)
with the new values. Persistent overrides go in `.local.mk`, for example
`echo 'buildtype := debug' > .local.mk`.

## Other make targets

`make run` builds and runs the daily session on the default IPC socket. `make dev` and `make headless` run nested or invisible instances on private sockets, so they never steal the live session's IPC socket; they matter once you start iterating on a config ([Reload and Debugging](/kiln/guides/reload-and-debugging), [Testing Headless](/kiln/guides/testing-headless)). The rest (`uninstall`, `clean`, `reconfigure`) are the standard meson wrappers.

## See also

- [First Launch](/kiln/getting-started/first-launch)
- [Testing headless](/kiln/guides/testing-headless)
- [IPC and scripting](/kiln/guides/ipc-and-scripting)
