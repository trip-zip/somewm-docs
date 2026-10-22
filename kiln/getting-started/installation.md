---
title: Installation
description: Build and install the Odin implementation of Kiln.
sidebar_position: 1
---

# Installation

Kiln's development direction is the Odin implementation. This page is a local
transition draft: the public source destination has not been selected yet.
The existing `trip-zip/kiln` repository still contains C Kiln. Start from the
Odin checkout supplied by the maintainer; do not expect an Odin Makefile from
that public clone yet.

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

From the Odin checkout, with an unmodified Clay checkout at `~/tools/clay`:

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

The binaries are `build/kiln-odin` and `build/kiln-client`. See
[First launch](/kiln/getting-started/first-launch) for a private nested session.
`make run` simply builds and starts the binary; it does not create a private
D-Bus session, private IPC path or log rotation.

## Install

```sh
make install prefix="$HOME/.local"
```

The installed command names are `kiln-odin` and `kiln-odin-client`. Installation
also supplies bash/zsh/fish completions, `share/wayland-sessions/kiln-odin.desktop`
(labelled **kiln Odin**), and the default config plus Lua modules under
`share/kiln-odin`. A user prefix does not guarantee display-manager discovery;
system login menus normally scan system session directories.

The default prefix is `/usr/local`, requiring write permissions there.
`prefix`, `bindir` and `datadir` can be set per invocation; no Meson reconfigure
step is needed. `DESTDIR` stages an install without changing its compiled runtime
paths. Uninstall with the same paths:

```sh
make uninstall prefix="$HOME/.local"
```

The manifest restricts removal to this installation's files. Existing C
commands have separate names. Canonical `kiln` aliases are a later migration
step, not installed by this build.

Keep an existing `~/.config/kiln/rc.lua` and theme. The new implementation uses
the same config directory and `require("kiln")`. For a new config, copy the
source `kilnrc.lua` or installed `share/kiln-odin/rc.lua` into that directory
without overwriting an existing file.

## Other make targets

`make check` checks/vets packages, `make test` runs package tests and ABI/Clay
checks, and `make compat-test` runs the private compositor compatibility suite.
`make audit-soak` runs the longer combined fixture exercise. These checks use
the historical C checkout as an oracle; they are not prerequisites for exploring
the desktop. There are no `make dev`, `make headless` or `make reconfigure`
targets in the Odin build. `make clean` removes its build directory.

## See also

- [First Launch](/kiln/getting-started/first-launch)
- [Environment and IPC](/kiln/reference/environment-and-ipc)
- [Limitations](/kiln/concepts/limitations)
