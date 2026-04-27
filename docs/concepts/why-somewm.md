---
sidebar_position: 1
title: Why somewm
description: What somewm is, what it commits to, and what's open.
---

# Why somewm

## What somewm is

somewm is a Wayland compositor that runs AwesomeWM Lua configurations unchanged. If your `rc.lua` works in AwesomeWM, it works in somewm. The shape of the API is the same: `awful.*`, `gears.*`, `wibox.*`, `naughty.*`, `beautiful.*`, `ruled.*`, `menubar.*`. Same function signatures, same signal names, same property model, same default values.

The compositor underneath is new. Built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots), it speaks Wayland, uses the wlroots scene graph, and routes input through a Wayland-native pipeline. Wayland exposes things X11 didn't (real per-output scaling, hotplug as a first-class event, idle inhibition protocols), so somewm adds APIs for those without changing what already worked.

## The Prime Directive

> Preserve the public Lua API. Internals are fair game.

The public API is whatever your `rc.lua` touches:

- Function signatures in `awful.*`, `gears.*`, `wibox.*`, `naughty.*`, `beautiful.*`, `ruled.*`, `menubar.*`
- Signal names and the arguments they carry
- Property names on `client`, `screen`, `tag`, `drawin`
- Documented behavior existing configs rely on

Everything else is open. The C compositor, the Lua library internals, the build system, the file layout: all ours to rewrite. That's how somewm makes Wayland-grade decisions (different signal timing, scene-graph rendering, in-process restart, fractional scaling, hotplug-aware tags) without breaking anyone's config.

The litmus test: if a change could break an existing `rc.lua` without the user editing it, that change goes through the deviations process and lands documented. Otherwise, it doesn't need to be a deviation; it's just internal evolution.

## What this commits to

If your config does any of these, somewm guarantees it keeps working:

- Calls into the AwesomeWM Lua libraries by name (e.g., `awful.layout.suit.tile`, `wibox.widget.textclock`)
- Sets properties on `client`, `screen`, `tag`, `drawin`
- Connects to documented signals (`manage`, `unmanage`, `focus`, `request::*`, `property::*`, ...)
- Uses theme variables in `beautiful`
- Reads or writes `awesome.*` properties documented for AwesomeWM (e.g., `awesome.conffile`, `awesome.version`, `awesome.startup`)

If a method or property is documented in the [AwesomeWM API docs](https://awesomewm.org/apidoc/), assume it works in somewm unless [Deviations](../reference/deviations.md) says otherwise.

## What's open

These are not part of the API contract:

- The C source (`somewm.c`, `objects/*.c`, `luaa.c`)
- Internals of the Lua libraries (the implementation behind `awful.*`, `gears.*`, etc.)
- Wayland protocol handling and the scene graph
- Build system, packaging, file layout
- Internal signals and helpers that aren't documented as public

These can change between releases. Lua-level extensions and helpers that don't replicate AwesomeWM behavior are also open.

## Why deviate at all

Wayland is not X11. A few places force a behavioral difference no matter what:

- **Window mapping**: clients commit before they receive a configure, so the WM can't pre-tile the way X11 did
- **Tray icons**: the `_NET_SYSTEMTRAY` protocol is X11 only; somewm uses StatusNotifierItem D-Bus instead
- **Restart**: somewm rebuilds the Lua state in process while wlroots keeps running. An X11 `execvp`-style restart isn't possible because GPU state can't survive
- **Per-output scale**: Wayland has fractional scaling per output, so `screen.scale` is now a writable property

Every deviation is recorded in [Deviations](../reference/deviations.md) with the reason. If something there bites your config, that's the page to send a bug report against.

## See also

- [Deviations](../reference/deviations.md) - full reference of API and behavioral differences
- [AwesomeWM Compatibility](/docs/concepts/awesomewm-compat) - compatibility status and stubs
- [Wayland vs X11](/docs/concepts/wayland-vs-x11) - protocol-level background
- [Migrating from AwesomeWM](/docs/getting-started/migrating) - step-by-step migration
