---
sidebar_position: 1
title: Why somewm
description: SomeWM is a wlroots compositor that runs AwesomeWM's Lua configuration model on Wayland. 1.4 mirrors AwesomeWM master; 2.x develops the API independently where Wayland or design asks for it.
---

# Why somewm

SomeWM is a Wayland compositor built on [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots) that runs AwesomeWM's Lua configuration model: `awful`, `gears`, `wibox`, `naughty`, `beautiful` and `ruled`, the same objects, properties, signals and declarative widget tables. Two release lines:

| Line | Relationship to AwesomeWM |
| --- | --- |
| 1.4 | mirrors AwesomeWM master and is maintained indefinitely as the compatible line |
| 2.x | keeps the configuration model and develops the libraries and compositor independently; public Lua APIs can change, and deprecated ones are removed |

A shared name does not promise identical behaviour, defaults or signal timing. Check the SomeWM reference for your release; the [AwesomeWM API docs](https://awesomewm.org/apidoc/) explain inherited APIs but also describe ones SomeWM changed or removed. [Migrating](../getting-started/migrating.md#deprecated-apis-removed-in-somewm-20) lists the replacements, and [Deviations](../reference/deviations.md) every behavioural difference.

## Not part of the API

The C source, the internals of the Lua libraries, Wayland protocol handling, the scene, the build and file layout, and any signal or helper not documented as public. These change between releases.

## Where Wayland forces a difference

- **Mapping.** A client commits before it receives a configure, so the compositor cannot pre-tile the way X11 did.
- **Tray.** `_NET_SYSTEMTRAY` is X11; SomeWM uses StatusNotifierItem over D-Bus.
- **Restart.** `awesome.restart()` rebuilds the Lua state in process while wlroots keeps running, because GPU state cannot survive an exec.
- **Scale.** Wayland scales per output, so `screen.scale` is a writable property.

[AwesomeWM Compatibility](./awesomewm-compat.md) is the compatibility contract; [Wayland vs X11](./wayland-vs-x11.md) the protocol background.
