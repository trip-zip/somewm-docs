---
title: How-to guides
description: One task per page, with the steps and the expected result.
---

# How-to guides

Each guide solves one task on a configuration that already works. It gives the steps and what you should see, and assumes the [tutorials](../tutorials/index.md) or an existing `rc.lua`.

## Bar and widgets

| Guide | Task |
| --- | --- |
| [Create or port a custom widget](custom-widgets.md) | A reusable widget with its own methods, or an old `draw` widget on 2.1 |
| [Update widgets from timers and commands](widget-timers.md) | Timers, shell commands and signals as sources of change |
| [Put a PNG texture on your wibar](wibar-background-image.md) | A background image at the bar's size |
| [Configure notifications](notifications.md) | Position, timeout, look and rules for naughty |
| [Animate clients, popups and widgets](animation.md) | Entrance, exit and property animations |

## Windows and layouts

| Guide | Task |
| --- | --- |
| [Write client rules](client-rules.md) | Where windows open and how they behave |
| [Control where focus goes](focus.md) | Recent windows, fallback on close, utility windows |
| [React to client lifecycle](react-to-client-lifecycle.md) | Code on open, focus, state change and close |
| [Round client corners](rounded-corners.md) | A radius by rule, without the square border |
| [Add shadows](shadows.md) | Compositor shadows on windows and wiboxes |
| [Write a client layout](custom-layouts.md) | Your own tiling layout |
| [Carousel: set column widths](carousel-column-widths.md) | Resize and cycle column widths |
| [Carousel: center the viewport](carousel-centering.md) | What the viewport follows |
| [Carousel: scroll with gestures](carousel-gestures.md) | Touchpad scrolling |
| [Carousel: stack windows in a column](carousel-stacking.md) | Stack, split and rearrange |

## Input

| Guide | Task |
| --- | --- |
| [Organize keybindings](keybinding-patterns.md) | Media keys, tag groups, mouse bindings, modules |
| [Switch keyboard layouts](keyboard-layouts.md) | Several layouts and a switch key |
| [Configure input devices](input-devices.md) | Pointer and keyboard settings at runtime |

## Displays

| Guide | Task |
| --- | --- |
| [Set up multiple monitors](multi-monitor.md) | Screens, outputs and what goes where |
| [Scale a HiDPI display](fractional-scaling.md) | Fractional output scale |
| [Keep tags across monitor hotplug](tag-persistence.md) | Save and restore tags when a monitor reconnects |

## Session

| Guide | Task |
| --- | --- |
| [Start applications at login](autostart.md) | Programs that start with SomeWM |
| [Set up the lock screen](lockscreen.md) | Locking, idle timeouts and DPMS |
| [Take screenshots](screenshots.md) | Desktop, screen, client and region captures |

## Config and debugging

| Guide | Task |
| --- | --- |
| [Replace a default handler](replace-default-handler.md) | Your own behavior on a `request::*` signal |
| [Defer startup with request::rules](defer-startup-with-request-rules.md) | Startup rules from modules, in order |
| [Control SomeWM from the command line](cli-control.md) | `somewm-client` from scripts and the shell |
| [Debug your config](debugging.md) | Find and fix Lua errors |
| [Test in a nested compositor](testing-with-nested-compositor.md) | Try changes without touching your session |
