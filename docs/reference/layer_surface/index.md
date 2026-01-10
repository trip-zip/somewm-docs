---
sidebar_position: 1
title: layer_surface
description: Layer shell surface API reference
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# layer_surface <SomewmOnly />

Lua class for Wayland layer shell surfaces (panels, launchers, lock screens).

## Class Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `layer_surface.get()` | table | All active layer surfaces |
| `layer_surface.connect_signal(name, fn)` | - | Connect to class signal |
| `layer_surface.disconnect_signal(name, fn)` | - | Disconnect from class signal |

## Properties (read-only)

| Property | Type | Description |
|----------|------|-------------|
| `namespace` | string | App identifier ("waybar", "rofi", "wofi") |
| `layer` | string | "background", "bottom", "top", "overlay" |
| `keyboard_interactive` | string | "none", "exclusive", "on_demand" |
| `exclusive_zone` | number | Pixels reserved on screen edge |
| `anchor` | table | `{top=bool, bottom=bool, left=bool, right=bool}` |
| `margin` | table | `{top=n, bottom=n, left=n, right=n}` |
| `geometry` | table | `{x=n, y=n, width=n, height=n}` |
| `screen` | screen | Screen the surface is on |
| `mapped` | boolean | Whether surface is visible |
| `pid` | number | Process ID |
| `valid` | boolean | Whether Lua object is alive |
| `focusable` | boolean | Whether `keyboard_interactive ~= "none"` |

## Properties (read/write)

| Property | Type | Description |
|----------|------|-------------|
| `has_keyboard_focus` | boolean | Grant or revoke keyboard focus |

## Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `request::manage` | `l, context, hints` | Surface appeared |
| `request::unmanage` | `l, context, hints` | Surface closing |
| `request::keyboard` | `l, context, hints` | Surface wants keyboard |
| `property::has_keyboard_focus` | `l` | Focus state changed |

## Layers

| Layer | Z-order | Typical use |
|-------|---------|-------------|
| `background` | lowest | Wallpaper widgets |
| `bottom` | - | Desktop icons |
| `top` | - | Panels, docks |
| `overlay` | highest | Launchers, lock screens |

## ruled.layer_surface

| Method | Description |
|--------|-------------|
| `append_rule(rule)` | Add a rule |
| `remove_rule(id)` | Remove rule by ID |
| `apply(l)` | Apply rules to surface |

### Rule matching properties

`namespace`, `layer`, `keyboard_interactive`, `screen`, `pid`, `focusable`

### Rule example

```lua
ruled.layer_surface.append_rule {
    rule_any = { namespace = { "rofi", "wofi" } },
    properties = { has_keyboard_focus = true },
}
```

## Default behavior

- Grants keyboard to `exclusive` surfaces on `top`/`overlay` layers
- Restores focus to previous client when surface closes
- Click-to-refocus on layer surfaces

## See Also

- [Signals Reference](/reference/signals) - Layer surface signals
- [wlr-layer-shell protocol](https://wayland.app/protocols/wlr-layer-shell-unstable-v1)
