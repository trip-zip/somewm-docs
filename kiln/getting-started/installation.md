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
- wayland-server
- wayland-protocols
- wayland-scanner
- xkbcommon
- luajit
- cairo
- pangocairo
- gdk-pixbuf-2.0

wlroots 0.20 is used from the system if present. If your distribution does not
ship it, the build falls back to the vendored subproject
(`subprojects/wlroots.wrap`) and builds wlroots itself, so any machine builds
reproducibly with no extra setup.

## Build

The kiln repository is not public yet; these steps assume you have a checkout.

```bash
cd kiln
make
```

`make` configures `build/` on the first run, then builds. It is a thin wrapper
over meson; this is exactly equivalent:

```bash
meson setup build && ninja -C build
```

The binary lands at `./build/kiln`.

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

| Target | What it does |
|---|---|
| `make run` | Build, then run the daily session: default IPC socket, log at `~/.cache/kiln.log` |
| `make dev` | Build, then run a nested dev instance on a private socket (`/tmp/kiln-dev-N.sock`), so it never steals the live session's IPC socket. Prints the socket and log paths |
| `make headless` | Build, then run an invisible instance for IPC-driven testing, same private-socket scheme |
| `make install` | `meson install -C build` |
| `make uninstall` | Remove the installed files |
| `make clean` | Remove `build/` |
| `make reconfigure` | Wipe and reconfigure `build/` (needed after changing `prefix` or `buildtype`) |

The convention the targets encode: the daily session owns the default socket,
so every script works against it with no environment variables; dev and
headless instances get private sockets.

## See also

- [First Launch](/kiln/getting-started/first-launch)
- [Testing headless](/kiln/guides/testing-headless)
- [IPC and scripting](/kiln/guides/ipc-and-scripting)
