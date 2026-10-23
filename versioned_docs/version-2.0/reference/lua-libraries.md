---
sidebar_position: 1
title: Lua Libraries
description: Overview of AwesomeWM's Lua libraries
---

# Lua Libraries

SomeWM 2.0 uses AwesomeWM-style Lua APIs with its own extensions and removals. Use this version's reference alongside the [compatibility list](deviations.md).

## Core Libraries

| Library | Purpose | Docs |
|---------|---------|------|
| [awful](./awful/) | Window management, keybindings and layouts | [AwesomeWM docs](https://awesomewm.org/apidoc/) ¹ |
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
| [Tag Persistence](./tag-persistence) | Saved state and monitor reconnection |
| [Lockscreen Module](./lockscreen) | Bundled Lua lockscreen UI |
| [Carousel](./awful/carousel) | Scrollable tiling layouts |
| [output](./output) | Monitor configuration and lifecycle |
| [Lock, idle, and DPMS](./lock) | Session locking and display power |
| [Shadows](./shadows) | Client and wibox shadows |
| [layer_surface](./layer_surface/) | External panels and launchers |

## Other References

| Reference | Description |
|-----------|-------------|
| [Screen](./screen) | Geometry, scaling and lifecycle |
| [Wayland Protocols](./wayland-protocols) | Advertised protocol versions |
| [Config Anatomy](./rc-lua-anatomy) | Map of the default config |
| [Key Names](./key-names) | Modifier keys and key name reference |
| [Signals](./signals) | Event signals by object type |
| [Default Keybindings](./default-keybindings) | Shortcuts in the default config |
