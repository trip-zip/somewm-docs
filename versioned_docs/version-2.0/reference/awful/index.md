---
sidebar_position: 1
title: awful
description: Window management, keybindings, layouts, and client rules
---

# awful

`awful` provides client and tag operations, layouts, input bindings, and application launching.

**Upstream documentation:** The `awful` library spans multiple sections in the AwesomeWM docs:
- [input_handling](https://awesomewm.org/apidoc/input_handling/awful.key.html) - keybindings, mouse bindings
- [libraries](https://awesomewm.org/apidoc/libraries/awful.spawn.html) - spawn, layout, completion
- [core_components](https://awesomewm.org/apidoc/core_components/screen.html) - screen, client, tag

## Key Modules

| Module | Purpose |
|--------|---------|
| `awful.key` | Define keyboard shortcuts |
| `awful.button` | Define mouse bindings |
| `ruled.client` | [Client rules](../../guides/client-rules.md). Replaces `awful.rules`, which is removed in 2.0 |
| [awful.layout](./layout) | Tiling layouts |
| `awful.tag` | Tag (workspace) management |
| `awful.client` | Client (window) operations |
| `awful.screen` | Screen management |
| `awful.spawn` | Launch applications |
| `awful.prompt` | Input prompts |
| `awful.menu` | Context menus |
| [awful.screenshot](./screenshot) | Screenshot capture and interactive snipping |

## SomeWM Extensions

| Module | Description |
|--------|-------------|
| [awful.input](./input) | Runtime input device configuration (pointer, keyboard) |
| [Carousel](./carousel) | Horizontal and vertical scrollable tiling |

## Behavioral Notes

SomeWM 2.0 removes legacy aliases and functional helpers. Use the [replacement list](../../getting-started/migrating.md#deprecated-apis-removed-in-somewm-20) when porting older configs. See [deviations](../deviations.md) for platform differences.
