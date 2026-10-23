---
sidebar_position: 4
title: Master and Stack
description: How tile assigns clients to master and secondary areas.
---

# Master and Stack

The `tile` layout divides the workarea between a master area and a secondary area called the stack. Here, stack means a layout region, not [visual stacking order](client-stack.md).

## The Two Sections

With the default `tile` settings, one master client occupies the left half and secondary clients share the right half. If there are no secondary clients, the master area expands across the workarea.

The master client is determined by layout order. It does not automatically follow keyboard focus.

## Client List Order Determines Position

The layout receives visible, non-floating clients in client-list order. The first `master_count` clients enter the master area, and the rest enter the secondary area.

```lua
local awful = require("awful")
local s = awful.screen.focused()
local clients = awful.client.tiled(s)
```

`client.get(s)` also includes clients that may be hidden, minimised or floating, so it is not the layout's final input. Mapping appends clients to the list, while swaps, rules and section helpers can reorder them. Raising a client changes visual stacking only.

## Tag Properties

| Property | Default | Effect in `tile` |
| --- | --- | --- |
| `master_count` | 1 | Number of master clients |
| `master_width_factor` | 0.5 | Fraction of the workarea allocated to master along the split axis |
| `master_fill_policy` | `"expand"` | Expand master when there are no secondary clients |
| `column_count` | 1 | Number of columns in the secondary area |

These defaults can be changed by theme or tag settings.

### master_count

With two master clients and five tiled clients, the first two share the master area and the remaining three share the secondary area. The default shortcuts are **Mod4 + Shift + h** to add a master slot and **Mod4 + Shift + l** to remove one.

### master_width_factor

`0.5` splits the workarea evenly. `0.66` gives master about two-thirds. **Mod4 + l** increases the factor by 0.05, and **Mod4 + h** decreases it.

### master_fill_policy

`"expand"` uses the full workarea when the secondary area is empty. `"master_width_factor"` retains the configured split and leaves the other area empty.

### column_count

Two columns with four secondary clients produce two clients per column. **Mod4 + Ctrl + h** adds a column, and **Mod4 + Ctrl + l** removes one.

## Moving Clients Between Sections

| Method | Effect |
| --- | --- |
| `c:to_primary_section()` | Move toward the front of the screen's client list |
| `c:to_secondary_section()` | Move toward its end |
| `c:swap(other)` | Exchange two client-list positions |

### Making New Windows Go to the Stack

To explicitly place new clients at the end, call `c:to_secondary_section()` from a client-rule callback. Whether a new window otherwise becomes master depends on the list and configuration. It is not a consequence of raising or focusing it.

### Swap Master with Focused Client

The default **Mod4 + Ctrl + Return** client binding swaps that client with the first entry returned by `awful.client.visible(c.screen)`. That list includes floating clients, so the first entry is not necessarily the first tiled client.

## Which Layouts Use Master and Stack

| Layout | Arrangement |
| --- | --- |
| `tile` / `tile.right` | Master left, secondary area right |
| `tile.left` | Master right, secondary area left |
| `tile.bottom` | Master top, secondary area bottom |
| `tile.top` | Master bottom, secondary area top |
| `spiral`, `spiral.dwindle` | Repeated splits using `master_width_factor`, without a master-count region |
| `fair`, `fair.horizontal` | Approximately equal cells |
| `max` | Clients overlap across the workarea |
| `magnifier` | Focused client enlarged over the others |
| `floating` | No automatic tiling |
| `carousel`, `carousel.vertical` | Scrollable columns with independent sizes |

## Tasklist Order

The default tasklist uses client-list order, filtered to the clients it displays. Moving a client to the secondary section also moves it later in that tasklist. Custom tasklists can use another ordering.

## See Also

- [Layout Protocol](../reference/awful/layout.md)
- [Custom Layouts](../guides/custom-layouts.md)
- [Client Rules](../guides/client-rules.md)
- [Scrollable Tiling](scrollable-tiling.md)
