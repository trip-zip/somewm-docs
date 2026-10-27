---
sidebar_position: 4
title: Master and stack
description: How tile assigns clients to primary and secondary areas.
---

# Master and stack

The `tile` layout divides the workarea into a master area and a secondary area called the stack. This stack is a layout region, separate from [visual stacking order](client-stack.md).

The first `master_count` eligible clients occupy the master area. The rest occupy the secondary area. With the default settings, master is on the left and the secondary area is on the right. When there are no secondary clients, master fills the workarea.

## Client order

The layout uses visible, non-floating clients in client-list order. Mapping appends to that list. Rules, swaps and section helpers can rearrange it. Keyboard focus and raising do not determine the master client.

| Method | Effect |
| --- | --- |
| `c:to_primary_section()` | Move towards the front of the screen's client list |
| `c:to_secondary_section()` | Move towards its end |
| `c:swap(other)` | Exchange two client-list positions |

The default **Mod4 + Ctrl + Return** binding swaps the target client with the first entry in `awful.client.visible(c.screen)`. That list includes floating clients, so its first entry is not necessarily the first tiled client.

## Tag properties

<span id="new-windows-go-to-master" />
<span id="which-layouts-use-it" />

| Property | Default | Effect in `tile` | Default shortcut |
| --- | --- | --- | --- |
| `master_count` | 1 | Number of master clients | Mod4+Shift+h adds one, Mod4+Shift+l removes one |
| `master_width_factor` | 0.5 | Master's share along the split axis | Mod4+l increases by 0.05, Mod4+h decreases |
| `master_fill_policy` | `"expand"` | Fill the workarea when the secondary area is empty. `"master_width_factor"` retains the split | None |
| `column_count` | 1 | Columns in the secondary area | Mod4+Ctrl+h adds one, Mod4+Ctrl+l removes one |

Theme and tag settings can override these defaults. With four secondary clients, `column_count = 2` makes two columns of two clients.

## Which layouts use the split

| Layout | Arrangement |
| --- | --- |
| `tile` / `tile.right` | Master left, secondary area right |
| `tile.left` | Master right, secondary area left |
| `tile.bottom` | Master top, secondary area bottom |
| `tile.top` | Master bottom, secondary area top |
| `spiral`, `spiral.dwindle` | Repeated splits using `master_width_factor`, without a master-count region |
| `magnifier` | Focused client enlarged over the others |
| `fair`, `fair.horizontal`, `max`, `floating` | No master/secondary split |
| `carousel`, `carousel.vertical` | Scrollable columns with independent widths |

## Tasklist order

The default tasklist uses client-list order, filtered to the clients it displays. Moving a client to the secondary section also moves it later in that tasklist. Custom tasklists can choose another order.

See [client layouts](clients-in-the-tree.md) for how layout rules become Clay declarations, or [custom layouts](../guides/custom-layouts.md) to write your own.
