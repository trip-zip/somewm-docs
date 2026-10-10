---
sidebar_position: 1
title: awful
description: Window management, keybindings, layouts, and client rules
---

# awful

The `awful` library is the core of AwesomeWM's window management functionality. It handles keybindings, mouse bindings, client rules, layouts, tags, and more.

**Upstream documentation:** The `awful` library spans multiple sections in the AwesomeWM docs:
- [input_handling](https://awesomewm.org/apidoc/input_handling/awful.key.html) - keybindings, mouse bindings
- [libraries](https://awesomewm.org/apidoc/libraries/awful.spawn.html) - spawn, layout, completion
- [core_components](https://awesomewm.org/apidoc/core_components/screen.html) - screen, client, tag

## Key Modules

| Module | Purpose |
|--------|---------|
| `awful.key` | Define keyboard shortcuts |
| `awful.button` | Define mouse bindings |
| [awful.layout](./layout) | Tiling layouts |
| `awful.tag` | Tag (workspace) management |
| `awful.client` | Client (window) operations |
| `awful.screen` | Screen management |
| `awful.spawn` | Launch applications |
| `awful.prompt` | Input prompts |
| `awful.menu` | Context menus |
| [awful.screenshot](./screenshot) | Screenshot capture and interactive snipping |

Client rules live in `ruled.client`, not `awful`. SomeWM 2.0 deleted the `awful.rules` compatibility shim. See [Client Rules](../../guides/client-rules.md).

## SomeWM Extensions

| Module | Description |
|--------|-------------|
| [awful.input](./input) | Runtime input device configuration (pointer, keyboard) |

## Behavioral Notes

SomeWM 2.0 removed legacy module aliases and functional helpers, including `awful.rules` and several `awful.tag` and `awful.client` wrappers. See [removed API replacements](../../getting-started/migrating.md#deprecated-apis-removed-in-somewm-20). [Wayland vs X11](../../concepts/wayland-vs-x11.md) explains platform differences that also affect some operations.
