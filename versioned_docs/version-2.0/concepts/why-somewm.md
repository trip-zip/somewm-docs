---
sidebar_position: 1
title: Why somewm
description: What somewm is, what it commits to, and what's open.
---

# Why somewm

## What somewm is

SomeWM 2.x builds on AwesomeWM's Lua configuration model and develops its APIs independently. Existing configurations may require changes. SomeWM 1.4 remains the line focused on upstream AwesomeWM compatibility.

Built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots), SomeWM speaks Wayland, uses the wlroots scene graph, and routes input through a Wayland-native pipeline. Its Lua configuration uses familiar libraries such as `awful`, `gears`, `wibox`, `naughty`, `beautiful`, and `ruled`.

## API direction {#the-prime-directive}

SomeWM 2.x can change its public Lua APIs as well as its implementation. Changes may reflect Wayland requirements or independent design decisions, including removing deprecated APIs.

The shared configuration model includes client and tag properties, signal handlers, widgets, and theme variables. Shared names and ancestry do not guarantee identical behaviour, defaults, or signal timing across SomeWM and AwesomeWM.

## Using the API {#what-this-commits-to}

Use the SomeWM documentation for your release to check supported APIs and behaviour. The [AwesomeWM API docs](https://awesomewm.org/apidoc/) provide background on inherited APIs, but may also describe APIs that SomeWM has changed or removed.

For example, SomeWM 2.0 removed `naughty.notify()` and the bare `manage` and `unmanage` signals. The [migration guide](../getting-started/migrating.md#deprecated-apis-removed-in-somewm-20) lists replacements for removed APIs. [AwesomeWM Compatibility](awesomewm-compat.md) explains the relationship between the release lines.

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

The [Compatibility reference](../reference/deviations.md) describes differences from AwesomeWM, including Wayland-specific behaviour. Consult the affected API reference for SomeWM behaviour in this release.

## See also

- [Compatibility reference](../reference/deviations.md) - API and behavioural differences from AwesomeWM
- [AwesomeWM Compatibility](awesomewm-compat.md) - compatibility status and stubs
- [Wayland vs X11](wayland-vs-x11.md) - protocol-level background
- [Migrating from AwesomeWM](../getting-started/migrating.md) - step-by-step migration
