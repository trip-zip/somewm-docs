---
sidebar_position: 4
title: Master and Stack
description: How tiling layouts divide the screen into primary and secondary sections
---

# Master and Stack

When you open three windows in a tiling layout, how does SomeWM decide which one gets the big left area and which ones stack on the right?

## The Two Sections

Most tiling layouts split the screen into two sections:

| Section | Also called | Role |
|---------|-------------|------|
| **Master** | Primary | The prominent area, usually larger. Holds your main focus window. |
| **Stack** | Secondary | The remaining area. Holds everything else. |

In the default tile layout, master is the left half and the stack is the right half. Open one window and it fills the screen. Open a second and the screen splits: first window in master, second in the stack. Open a third and it shares the stack area with the second.

## Client List Order Determines Position

The key concept: **position in the client list determines which section a window lands in**.

The compositor maintains a list of all clients in creation order (see [Client Stacking](/concepts/client-stack#the-two-client-arrays) for how this differs from visual z-order). When a layout runs, it reads this list and assigns windows to sections:

- The first `master_count` clients go to the **master** section
- All remaining clients go to the **stack** section

With the default `master_count` of 1, the first client in the list is master and everything else is stack.

```lua
-- Get clients in layout order (creation order, not z-order)
local clients = client.get(s)

-- clients[1]              -> master (first master_count clients)
-- clients[2], clients[3]  -> stack  (everything else)
```

This is why raising a window to the top of the z-order doesn't make it master. Layouts ignore z-order entirely.

## Tag Properties

These properties are set on a **tag** and control how layouts divide space. Change them at runtime with keybindings or set defaults in your tag configuration.

| Property | Default | What it controls |
|----------|---------|------------------|
| `master_count` | 1 | Number of clients in the master section |
| `master_width_factor` | 0.5 | Proportion of screen width for master (0.0 to 1.0) |
| `master_fill_policy` | `"expand"` | What master does when the stack is empty |
| `column_count` | 1 | Number of columns in the stack section |

### master_count

How many clients belong in the master section. The rest go to the stack.

```lua
-- Set on a tag
awful.tag.incnmaster(1)   -- Add one master slot (Mod4+Shift+l)
awful.tag.incnmaster(-1)  -- Remove one master slot (Mod4+Shift+h)

-- Or set directly
t.master_count = 2
```

With `master_count = 2` and 5 windows open, the first 2 fill the master area (split vertically between them) and the remaining 3 share the stack.

### master_width_factor

How much screen width master gets, as a fraction. `0.5` means an even split. `0.66` gives master two-thirds of the width.

```lua
-- Adjust with keybindings (default rc.lua)
awful.tag.incmwfact(0.05)   -- Mod4+l: master wider
awful.tag.incmwfact(-0.05)  -- Mod4+h: master narrower

-- Or set directly
t.master_width_factor = 0.66
```

### master_fill_policy

Controls what happens when there are no stack clients. With `"expand"` (the default), a single window fills the entire screen. With `"master_width_factor"`, a single window only takes its proportional share, leaving empty space where the stack would be.

### column_count

How many columns to use in the stack section. With `column_count = 2` and 4 stack clients, they form a 2x2 grid in the stack area.

```lua
awful.tag.incncol(1)   -- Add a stack column (Mod4+Ctrl+l)
awful.tag.incncol(-1)  -- Remove a stack column (Mod4+Ctrl+h)
```

## Moving Clients Between Sections

You can move a client to the master or stack section by changing its position in the client list:

| Method | Effect |
|--------|--------|
| `c:to_primary_section()` | Move to master (front of client list) |
| `c:to_secondary_section()` | Move to stack (end of client list) |
| `c:swap(other)` | Swap positions with another client |

### New Windows Always Go to Stack

By default, new clients become master, pushing everything else down. This surprises most people. To make new windows go to the stack instead, add a callback to your default rule:

```lua
ruled.client.append_rule {
    rule = {},
    properties = {
        -- your existing default properties
    },
    callback = function(c)
        c:to_secondary_section()
    end,
}
```

### Swap Master with Focused Client

The default keybinding **Mod4+Return** (with Shift, if using the default `rc.lua`) swaps the focused client with the current master:

```lua
awful.key({ modkey, "Shift" }, "Return", function(c)
    c:swap(awful.client.getmaster())
end)
```

## Which Layouts Use Master and Stack

Not all layouts use the master/stack model:

| Layout | Uses master/stack? | Notes |
|--------|--------------------|-------|
| `tile.right` | Yes | Master left, stack right (default) |
| `tile.left` | Yes | Master right, stack left |
| `tile.bottom` | Yes | Master top, stack bottom |
| `tile.top` | Yes | Master bottom, stack top |
| `spiral` | Partial | Uses `master_width_factor` for proportions, ignores `master_count` |
| `dwindle` | Partial | Same as spiral but splits in alternating directions |
| `fair` | No | All clients get equal space |
| `fair.horizontal` | No | All clients get equal space, horizontal split |
| `max` | No | Focused client fills the screen |
| `magnifier` | Special | Focused client is always "master", others shrink behind it |
| `floating` | No | No automatic tiling at all |

## Tasklist Order

The [tasklist widget](https://awesomewm.org/apidoc/widgets/awful.widget.tasklist.html) in the wibar displays clients in the same order as the client list. Master appears leftmost, stack clients appear to the right. If you use `to_secondary_section()` to send new windows to the stack, they also appear on the right side of the tasklist.

## See Also

- [Layout Protocol Reference](/reference/awful/layout) - The `arrange(p)` contract and built-in layouts
- [Custom Layouts Guide](/guides/custom-layouts) - Write your own tiling layout from scratch
- [Client Stacking](/concepts/client-stack) - Z-order and visual overlap (different from layout order)
- [Client Rules](/guides/client-rules) - Automatically set properties when windows open
- [Focus History](/concepts/focus-history) - What determines focus when a client closes
- [AwesomeWM layout docs](https://awesomewm.org/apidoc/libraries/awful.layout.html) - Full layout API reference
