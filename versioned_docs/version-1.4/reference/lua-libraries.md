---
sidebar_position: 1
title: Lua Libraries
description: Overview of AwesomeWM's Lua libraries
---

# Lua Libraries

SomeWM 1.4 uses AwesomeWM’s Lua libraries with Wayland-specific changes. Use the [AwesomeWM API documentation](https://awesomewm.org/apidoc/) alongside the [1.4 deviations](deviations.md) and references below.

## Core Libraries

| Library | Purpose | Docs |
|---------|---------|------|
| [awful](./awful/) | Window management, keybindings, layouts, client rules | [AwesomeWM docs](https://awesomewm.org/apidoc/) ¹ |
| [beautiful](./beautiful/) | Theming and appearance | [AwesomeWM docs](https://awesomewm.org/apidoc/theme_related_libraries/beautiful.html) |
| [wibox](./wibox/) | Widgets, containers, and the wibar | [AwesomeWM docs](https://awesomewm.org/apidoc/popups_and_bars/wibox.html) |
| [naughty](./naughty/) | Notifications | [AwesomeWM docs](https://awesomewm.org/apidoc/libraries/naughty.html) |
| [gears](./gears/) | Utilities (timers, shapes, colors, filesystem) | [AwesomeWM docs](https://awesomewm.org/apidoc/) ¹ |

¹ *awful and gears span multiple categories in the AwesomeWM docs (input_handling, libraries, core_components, etc.)*

## SomeWM Extensions

These APIs are unique to SomeWM and not available in AwesomeWM:

| API | Purpose |
|-----|---------|
| [awful.input](./awful/input) | Runtime input device configuration |
| [somewm-client](./somewm-client) | IPC command-line tool |
| [Carousel](./awful/carousel) | Scrollable tiling layouts |
| [output](./output) | Monitor configuration and lifecycle |
| [Lock, idle, and DPMS](./lock) | Session locking and display power |
| [Shadows](./shadows) | Client and wibox shadows |
| [layer_surface](./layer_surface/) | External panels and launchers |

## Other References

| Reference | Description |
|-----------|-------------|
| [Key Names](./key-names) | Modifier keys and key name reference |
| [Signals](./signals) | Event signals by object type |
| [Default Keybindings](./default-keybindings) | Shortcuts in the default config |
