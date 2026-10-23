---
sidebar_position: 3
title: Client Stacking
description: How visual stacking differs from focus and tiling order.
---

# Client Stacking

Stacking controls which overlapping clients appear in front. SomeWM keeps one client stack across screens and tags. Switching tags changes visibility without resetting that order.

## Stack, focus and layout are separate

| State | Controls | Changed by |
| --- | --- | --- |
| Client list | Order used by layouts and the default tasklist | Mapping, removal, swaps and section helpers |
| Stack | Visual overlap within band constraints | Mapping, removal, `raise` and `lower` |
| Focus | Keyboard input destination | Focus assignment or activation requests |

Mapping appends clients to the client list. Rules and methods such as `c:swap(other)` can reorder it. Raising a client does not make it master. See [master and stack](master-and-stack.md).

## Bands constrain the stack

`below`, `above`, `ontop` and fullscreen state determine the client's band. Raising a normal client cannot put it above an `ontop` client.

Within a band, clients follow stack order, with exceptions for `max` and `magnifier`: floating clients appear above the layout's tiled clients, and transients of those tiled clients also appear above the layout. See [scene order](scene-graph.md#stacking-within-a-band).

## What changes the stack

<span id="two-arrays" />
<span id="signals" />

| Action | Effect |
| --- | --- |
| New client maps | Added to the stack |
| Client closes | Removed |
| `c:raise()` | Raise within band constraints, account for transients, emit `raised` |
| `c:lower()` | Lower within band constraints, account for transients, emit `lowered` |
| `client.focus = c` | Change focus without explicitly raising |
| `c:swap(other)` | Swap client-list positions, leaving the stack unchanged |

A configuration can couple these operations. For example, a `focus` handler that calls `c:raise()` makes focus changes raise clients too.

## Reading each order

```lua
local awful = require("awful")
local s = awful.screen.focused()
local layout_order = client.get(s)
local stack_order = client.get(s, true)
local tiled = awful.client.tiled(s)
```

`client.get(s, true)` returns the stack from top to bottom. `awful.client.tiled(s)` filters the client list to visible clients eligible for tiling. Neither list is [focus history](focus-history.md).
