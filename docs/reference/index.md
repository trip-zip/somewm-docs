---
title: Reference
description: Every library, object and command, with what SomeWM does differently from AwesomeWM.
---

# Reference

Reference pages state what exists and what it does: properties, methods, signals, defaults and limits. For how to do something, use the [how-to guides](../guides/index.md).

## Libraries

| Library | Covers | Upstream |
| --- | --- | --- |
| [awful](./awful/index.md) | Window management, keybindings, layouts, the bar and popups | [AwesomeWM docs](https://awesomewm.org/apidoc/) |
| [beautiful](./beautiful/index.md) | Theme variables and appearance | [AwesomeWM docs](https://awesomewm.org/apidoc/theme_related_libraries/beautiful.html) |
| [gears](./gears/index.md) | Timers, shapes, colors, files and other utilities | [AwesomeWM docs](https://awesomewm.org/apidoc/) |
| [naughty](./naughty/index.md) | Notifications | [AwesomeWM docs](https://awesomewm.org/apidoc/libraries/naughty.html) |
| [wibox](./wibox/index.md) | Widgets, containers, layouts and the window that shows them | [AwesomeWM docs](https://awesomewm.org/apidoc/popups_and_bars/wibox.html) |

The [compatibility page](./deviations.md) lists what SomeWM removes, adds and changes against AwesomeWM.

## Objects

| Object | Covers |
| --- | --- |
| [screen](./screen.md) | Geometry, scale, workarea and lifecycle |
| [output](./output.md) | The physical connector behind a screen |
| [layer_surface](./layer_surface/index.md) | External panels and launchers using layer shell |

## Everything else

| Page | Covers |
| --- | --- |
| [All keysyms](./key-names-all.md) | Every key name SomeWM accepts |
| [Anatomy of rc.lua](./rc-lua-anatomy.md) | A map of the default config, section by section |
| [AwesomeWM compatibility](./deviations.md) | Removed, added and changed behavior |
| [Default keybindings](./default-keybindings.md) | Every shortcut in the default config |
| [Key names](./key-names.md) | Modifiers and the common key names |
| [Lock, idle and DPMS](./lock.md) | Session locking and display power |
| [Lockscreen module](./lockscreen.md) | The bundled lock screen module |
| [Shadows](./shadows.md) | Shadow properties on clients and wiboxes |
| [Signals](./signals.md) | Every signal by object, with its arguments |
| [somewm-client](./somewm-client.md) | Every IPC command |
| [Tag persistence](./tag-persistence.md) | Saved tag state and its signals |
| [Wayland protocols](./wayland-protocols.md) | Protocols and versions SomeWM advertises |
