---
sidebar_position: 4
title: Master and Stack
description: Tiling layouts put the first master_count clients of the creation-ordered client list in the master section and the rest in the stack. Four tag properties control the split.
---

# Master and Stack

A tiling layout reads the screen's clients in creation order. The first `master_count` of them go in the master section, the rest in the stack. In the default `tile` layout, master is the left half and the stack the right half: one window fills the screen, a second splits it, a third shares the stack with the second.

Position in the client list decides the section, never the z-order. `client.get(s)` returns that list; `c:to_primary_section()`, `c:to_secondary_section()` and `c:swap(other)` change it ([Client Stacking](./client-stack.md) has the stack, which layouts ignore).

## Tag properties

| Property | Default | Controls | Keybinding in the default config |
| --- | --- | --- | --- |
| `master_count` | 1 | how many clients are in the master section | `awful.tag.incnmaster(±1)`, Mod4+Shift+h / l |
| `master_width_factor` | 0.5 | master's share of the width, 0 to 1 | `awful.tag.incmwfact(±0.05)`, Mod4+l / h |
| `master_fill_policy` | `"expand"` | with no stack clients, `"expand"` fills the screen; `"master_width_factor"` keeps master's share and leaves the rest empty | |
| `column_count` | 1 | columns in the stack: 4 stack clients and `column_count = 2` make a 2 by 2 grid | `awful.tag.incncol(±1)`, Mod4+Ctrl+h / l |

Set them on the tag directly, `t.master_count = 2`, or at creation in `awful.tag`.

## New windows go to master

A new client is first in the list, so it becomes master and pushes the others down. To send new windows to the stack instead, add a callback to the default rule:

```lua
ruled.client.append_rule {
    rule = {},
    properties = { },
    callback = function(c) c:to_secondary_section() end,
}
```

The default config's Mod4+Ctrl+Return swaps the focused client with the current master:

```lua
awful.key {
    modifiers = { modkey, "Control" }, key = "Return",
    on_press = function(c) c:swap(awful.client.visible(c.screen)[1]) end,
}
```

The tasklist shows clients in list order, so master is leftmost and a client sent to the stack appears on the right.

## Which layouts use it

| Layout | Master and stack |
| --- | --- |
| `tile`, `tile.left`, `tile.bottom`, `tile.top` | yes; the name says where the stack is |
| `spiral`, `dwindle` | `master_width_factor` only; `master_count` is ignored |
| `magnifier` | the focused client is master, the others shrink behind it |
| `fair`, `fair.horizontal`, `max`, `floating` | no |
| `carousel`, `carousel.vertical` | no; columns with their own widths ([Scrollable tiling](./scrollable-tiling.md)) |

[Layout reference](../reference/awful/layout.md) has the `arrange` contract and every built-in layout; [Custom Layouts](../guides/custom-layouts.md) writes one.
