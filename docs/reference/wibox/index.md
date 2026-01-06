---
sidebar_position: 1
title: wibox
description: Widgets, containers, and the wibar
---

# wibox

The `wibox` library provides the widget system for AwesomeWM/SomeWM. It includes primitive widgets, containers, layouts, and the `wibar` (status bar).

**Upstream documentation:** [awesomewm.org/apidoc/libraries/wibox.html](https://awesomewm.org/apidoc/libraries/wibox.html)

## Key Modules

| Module | Purpose |
|--------|---------|
| `wibox.widget` | Base widget functionality |
| `wibox.widget.textbox` | Text display |
| `wibox.widget.imagebox` | Image display |
| `wibox.widget.progressbar` | Progress indicators |
| `wibox.widget.slider` | Slider controls |
| `wibox.widget.systray` | System tray |
| `wibox.container` | Widget containers (margin, background, etc.) |
| `wibox.layout` | Layout containers (horizontal, vertical, etc.) |
| `awful.wibar` | The status bar |

## Reference

| Reference | Description |
|-----------|-------------|
| [Wibar Properties](./wibar) | Wibar positioning and configuration |

## Behavioral Notes

SomeWM uses the SNI (StatusNotifierItem) protocol for the system tray instead of X11's XEmbed. See [Wayland vs X11](/concepts/wayland-vs-x11) for details.
