---
sidebar_position: 1
title: awful
description: Window management, keybindings, layouts, and client rules
---

# awful

The `awful` library is the core of AwesomeWM's window management functionality. It handles keybindings, mouse bindings, client rules, layouts, tags, and more.

**Upstream documentation:** [awesomewm.org/apidoc/libraries/awful.html](https://awesomewm.org/apidoc/libraries/awful.html)

## Key Modules

| Module | Purpose |
|--------|---------|
| `awful.key` | Define keyboard shortcuts |
| `awful.button` | Define mouse bindings |
| `awful.rules` | Automatic client rules |
| `awful.layout` | Tiling layouts |
| `awful.tag` | Tag (workspace) management |
| `awful.client` | Client (window) operations |
| `awful.screen` | Screen management |
| `awful.spawn` | Launch applications |
| `awful.prompt` | Input prompts |
| `awful.menu` | Context menus |

## SomeWM Extensions

| Module | Description |
|--------|-------------|
| [awful.input](./input) | Runtime input device configuration (pointer, keyboard) |

## Behavioral Notes

SomeWM's `awful` implementation is fully compatible with AwesomeWM. See [Wayland vs X11](/concepts/wayland-vs-x11) for platform-specific differences that may affect some operations.
