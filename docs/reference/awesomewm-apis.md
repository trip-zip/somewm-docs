---
sidebar_position: 5
title: AwesomeWM API Reference
description: Links to AwesomeWM documentation with SomeWM notes
---

# AwesomeWM API Reference

SomeWM maintains compatibility with AwesomeWM's Lua API. For most APIs, refer to the official AwesomeWM documentation.

## Core Modules

| Module | AwesomeWM Docs | SomeWM Notes |
|--------|---------------|--------------|
| `awful.client` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.client.html) | Full compatibility |
| `awful.screen` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.screen.html) | Full compatibility |
| `awful.tag` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.tag.html) | Full compatibility |
| `awful.layout` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.layout.html) | Full compatibility |
| `awful.key` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.key.html) | Full compatibility |
| `awful.button` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.button.html) | Full compatibility |
| `awful.spawn` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.spawn.html) | Full compatibility |
| `awful.rules` | [Documentation](https://awesomewm.org/doc/api/libraries/awful.rules.html) | Full compatibility |

## Widget Modules

| Module | AwesomeWM Docs | SomeWM Notes |
|--------|---------------|--------------|
| `wibox` | [Documentation](https://awesomewm.org/doc/api/classes/wibox.html) | Full compatibility |
| `wibox.widget` | [Documentation](https://awesomewm.org/doc/api/libraries/wibox.widget.html) | Full compatibility |
| `wibox.container` | [Documentation](https://awesomewm.org/doc/api/libraries/wibox.container.html) | Full compatibility |
| `wibox.layout` | [Documentation](https://awesomewm.org/doc/api/libraries/wibox.layout.html) | Full compatibility |

## Utility Modules

| Module | AwesomeWM Docs | SomeWM Notes |
|--------|---------------|--------------|
| `gears.timer` | [Documentation](https://awesomewm.org/doc/api/libraries/gears.timer.html) | Full compatibility |
| `gears.shape` | [Documentation](https://awesomewm.org/doc/api/libraries/gears.shape.html) | Full compatibility |
| `gears.filesystem` | [Documentation](https://awesomewm.org/doc/api/libraries/gears.filesystem.html) | Full compatibility |
| `beautiful` | [Documentation](https://awesomewm.org/doc/api/libraries/beautiful.html) | Full compatibility |
| `naughty` | [Documentation](https://awesomewm.org/doc/api/libraries/naughty.html) | Full compatibility |

## APIs with Deviations

These APIs work but have known differences from AwesomeWM:

| API | Status | Notes |
|-----|--------|-------|
| `awesome.register_xproperty()` | Stub | X11 properties don't exist on Wayland |
| `awesome.get_xproperty()` | Stub | Returns nil |
| `awesome.set_xproperty()` | Stub | No-op |
| `root.fake_input()` | Stub | Requires virtual input protocol |
| `awesome.restart()` | No-op | Wayland compositor can't restart in place |
| `wibox.widget.systray` | Different | Uses SNI D-Bus protocol, not X11 embed |

## SomeWM-Only Extensions

These APIs are unique to SomeWM:

| Module | Description | Documentation |
|--------|-------------|---------------|
| `awful.input` | Input device configuration | [Reference](/reference/awful-input) |

## See Also

- [Wayland vs X11](/concepts/wayland-vs-x11) - Why some APIs differ
- [AwesomeWM Compatibility](/concepts/awesomewm-compat) - Full compatibility status
