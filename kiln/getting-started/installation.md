---
title: Installation
description: Build Kiln with Odin and install its compositor, command client and Lua runtime.
sidebar_position: 1
---

# Installation

Kiln is written in Odin with Lua configuration and system graphics libraries.
The canonical source is [trip-zip/kiln](https://github.com/trip-zip/kiln).

```sh
git clone https://github.com/trip-zip/kiln.git
cd kiln
```

## Dependencies

The verified compiler is Odin `dev-2026-10-nightly:779c8c0`. Use GNU make,
Python 3, gcc and ar, with system libraries matching the bindings:

- wlroots 0.20.2 and its graphics/device dependencies
- wayland-server, libinput, xkbcommon
- LuaJIT 2.1, cairo, pango/pangocairo, gdk-pixbuf, GLib/GObject
- libsystemd, PAM, xcb, xcb-ewmh, xcb-icccm

XWayland is needed for X11 clients. The stock desktop uses `rsvg-convert`, fonts
and foot (or `$TERMINAL`). Media/screenshot bindings also use `wpctl`,
`brightnessctl`, `grim` and `slurp` when invoked.

This is Odin compositor code linked to C libraries. There is no bundled
wlroots fallback, Meson configuration or `-Dxwayland`/`-Ddbus`/`-Dpam` feature
switch in this build. Normal authentication uses PAM; fixture builds are only
for automated tests.

## Build

Keep an unmodified Clay checkout at the pinned revision. For a new dependency
checkout (skip this if your existing checkout already matches):

```sh
git clone https://github.com/nicbarker/clay.git "$HOME/tools/clay"
git -C "$HOME/tools/clay" checkout e6cc36941ab2af5d81107617039d6f527a1c660b
```

From the Kiln source directory:

```sh
make
```

Clay must be at `e6cc36941ab2af5d81107617039d6f527a1c660b`, with its matching
official Odin binding. `clay-dependency.json` pins both hashes. The build checks
these and builds the external header into `clay.a`; it does not patch Clay.
For another checkout path:

```sh
make CLAY_ROOT=/absolute/path/to/clay
```

The binaries are `build/kiln` and `build/kiln-client`. See
[First launch](/kiln/getting-started/first-launch) for a private nested session.
`make run` builds and starts Kiln under a D-Bus session using your normal
config and default IPC path. For a second nested instance, choose a private
socket as shown in [First launch](/kiln/getting-started/first-launch).
Logs go to the terminal.

## Install

```sh
make install prefix="$HOME/.local"
```

The installed command names are `kiln` and `kiln-client`. Installation
also supplies bash/zsh/fish completions, `share/wayland-sessions/kiln.desktop`
(labelled **Kiln**), and the default config plus Lua modules under
`share/kiln`. A user prefix does not guarantee display-manager discovery;
system login menus normally scan system session directories.

The default prefix is `/usr/local`, requiring write permissions there.
`prefix`, `bindir` and `datadir` can be set per invocation; no Meson reconfigure
step is needed. `DESTDIR` stages an install without changing its compiled runtime
paths. Uninstall with the same paths:

```sh
make uninstall prefix="$HOME/.local"
```

The manifest restricts removal to this installation's files. There is one
compositor command, `kiln`, and one CLI, `kiln-client`. MIT and dependency
notices are installed under `share/licenses/kiln`.

Keep an existing `~/.config/kiln/rc.lua` and theme. The new implementation uses
the same config directory and `require("kiln")`. For a new config, copy the
source `kilnrc.lua` or installed `share/kiln/rc.lua` into that directory
without overwriting an existing file.

## Other make targets

`make check` checks/vets packages, `make test` runs package tests and ABI/Clay
checks, and `make compat-test` runs the private compositor compatibility suite.
`make audit-soak` runs the longer combined fixture exercise. Comparison checks extract the retired C baseline from this repository's
preserved history into `build/c-baseline`; no separate C checkout is needed.
`make c-baseline` builds that pinned source. Use a full Git clone for tests.
The source repository's `TESTING.md` lists fixture tools and focused commands.
`make clean` removes the build directory.

## See also

- [First Launch](/kiln/getting-started/first-launch)
- [Environment and IPC](/kiln/reference/environment-and-ipc)
- [Limitations](/kiln/concepts/limitations)
