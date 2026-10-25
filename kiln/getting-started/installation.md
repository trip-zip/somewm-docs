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

Kiln builds with Odin nightly dev-2026-10 (779c8c0), GNU make, gcc and ar.
`make test` also needs Python 3. The system libraries match the bindings:

- Mesa: EGL, GLES 2 and GBM
- libinput, xkbcommon
- LuaJIT 2.1, cairo, pango/pangocairo, gdk-pixbuf, GLib/GObject
- libsystemd (sd-bus, for the logind session, notifications and the tray),
  PAM (authentication), xcb, xcb-ewmh

Kiln speaks Wayland, DRM and logind itself. Running on hardware needs a logind session (seatd is not
supported) and a GPU with atomic mode setting. XWayland is needed for X11
clients. The stock desktop uses `rsvg-convert`, the `Sans` font through fontconfig,
and foot (or `$TERMINAL`). Media/screenshot bindings also use `wpctl`, `brightnessctl`,
`grim` and `slurp` when invoked.

## Build

From the Kiln source directory:

```sh
make
```

Clay is vendored in `clay/` and `make` builds it. The binaries are `build/kiln` and `build/kiln-client`. See
[First launch](/kiln/getting-started/first-launch) for a private nested session.
`make run` starts Kiln under `dbus-run-session` with your normal config and a
private socket, so it does not collide with a running Kiln. Logs go to the
terminal.

## Install

```sh
make && sudo make install
```

Build as your normal user. Installation copies that build to `/usr/local`
without invoking Odin or rebuilding Clay as root. Reinstalling leaves the
running compositor on its existing executable; the next launch uses the update.

Then start `kiln` from a free TTY; see
[First launch](/kiln/getting-started/first-launch).

The installed command names are `kiln` and `kiln-client`. Installation
also supplies bash/zsh/fish completions, `share/wayland-sessions/kiln.desktop`
(labelled **Kiln**), and the default config plus Lua modules under
`share/kiln`. A user prefix does not guarantee display-manager discovery;
system login menus normally scan system session directories.

For a user prefix, use matching build and install settings. Run `make clean`
first if you already built with another prefix:

```sh
make prefix="$HOME/.local"
make install prefix="$HOME/.local"
```

`prefix`, `bindir` and `datadir` are configurable. The install datadir must match
the build because the Lua runtime path is compiled into the executable.
`DESTDIR` stages an install without changing those runtime paths.
Uninstall with the same paths:

```sh
make uninstall prefix="$HOME/.local"
```

`make uninstall` removes the two binaries, `$(datadir)/kiln`, the session
file, the completions and the licence directory. MIT and dependency notices
are installed under `share/licenses/kiln`.

For a new config, copy `kilnrc.lua` (or the installed `share/kiln/rc.lua`) to
`~/.config/kiln/rc.lua`; `cp -n` will not overwrite an existing one.

## Other make targets

`make check` typechecks and vets every package. `make test` runs every
package's tests, then boots a headless instance and drives it over IPC.
`make test-nested` runs that same driven suite as a window in the desktop
you run it from. `make protocols` regenerates the Odin protocol tables from
the vendored XML. `make clean` removes the build directory.

## See also

- [First Launch](/kiln/getting-started/first-launch)
- [Environment and IPC](/kiln/reference/environment-and-ipc)
- [Limitations](/kiln/concepts/limitations)
