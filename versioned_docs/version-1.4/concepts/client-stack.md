---
sidebar_position: 3
title: Client Stacking
description: How visual stacking differs from focus and tiling order.
---

# Client Stacking

Stacking controls which overlapping clients appear in front. It is separate from keyboard focus and the client order used by tiling layouts.

## The Global Stack

SomeWM keeps one client stack across all screens and tags. Selecting a different tag changes visibility without resetting that order.

## Stack, Focus, and Layout: Three Different Things

| State | Controls | Changed by |
| --- | --- | --- |
| Client list | Order used by layouts and the default tasklist | Mapping, removal, `swap` and section helpers |
| Stack | Visual overlap within layer constraints | Mapping, removal, `raise` and `lower` |
| Focus | Keyboard input destination | Focus assignment or activation requests |

The client list starts in mapping order but can be rearranged. Calling it creation order after swaps would be misleading.

## Client Layers

Properties constrain the stack. `below`, `above`, `ontop` and active fullscreen state select different scene layers. Raising a normal client does not move it above an `ontop` client.

Fullscreen uses its elevated layer when the client is focused, when no client is focused, or when focus is on another screen. Transient dialogs normally stack with their parent. See [Scene Graph](scene-graph.md) for the layer order and property precedence.

## Stack Operations

<span id="methods" />
<span id="what-changes-the-stack" />

| Operation | Effect |
| --- | --- |
| `c:raise()` | Raise the client within its layer, accounting for transients, and emit `raised` |
| `c:lower()` | Lower it within its layer, accounting for transients, and emit `lowered` |
| `client.focus = c` | Change focus without explicitly raising |
| `c:swap(other)` | Swap client-list positions without changing the stack |
| `c:activate { context = "my_config", raise = true }` | Request focus and raising through the activation policy |

Configuration handlers can add behaviour. For example, a handler connected to `focus` can call `raise`, so a configured focus change may also change the stack.

## The Two Client Arrays

<span id="why-this-matters" />

The C core stores the layout list in `globalconf.clients` and the stack in `globalconf.stack`. Lua exposes both:

```lua
local awful = require("awful")
local s = awful.screen.focused()
local layout_order = client.get(s, false)
local stack_order = client.get(s, true)
local tiled = awful.client.tiled(s)
```

`client.get(s, true)` returns stack order from top to bottom. `awful.client.tiled(s)` filters the client list to visible clients eligible for tiling. It does not sort by visual overlap.

## When Stack Order Matters

Floating, maximised and fullscreen clients can overlap. Tiled clients can also overlap in layouts such as `max` or `magnifier`. In each case, stacking decides which content is visible where their rectangles overlap.

## When Stack Order Doesn't Matter

A tiled layout's slot assignment uses client-list order. Raising a client does not move it to the master slot. Use `c:to_primary_section()` or `c:swap(other)` to change that order.

## Practical Examples

<span id="basic-raiselower" />
<span id="keep-a-window-always-on-top" />
<span id="reacting-to-stack-changes" />

### Auto-raise on focus (optional behavior)

```lua
client.connect_signal("focus", function(c)
    c:raise()
end)
```

This changes every focus event into a raise as well. Omit the handler to keep those actions independent.

## See Also

- [Master and Stack](master-and-stack.md)
- [Scene Graph](scene-graph.md)
- [Focus History](focus-history.md)
