---
sidebar_position: 1.5
title: awful.layout
description: Layout protocol, arrange contract, and layout registration
---

# awful.layout

The `awful.layout` module manages tiling layouts. A layout is a Lua table that tells the compositor how to position tiled clients on screen.

**Upstream documentation:** [AwesomeWM awful.layout docs](https://awesomewm.org/apidoc/libraries/awful.layout.html)

## Layout Table Structure

A layout is a plain table with these fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Display name shown in the layoutbox widget |
| `arrange` | function | Yes | Called to position clients (see below) |
| `skip_gap` | function | No | Returns `true` when gaps should not be applied |
| `mouse_resize_handler` | function | No | Custom mouse-resize behavior for the layout |

Minimal example:

```lua
local my_layout = {
    name = "my_layout",
    arrange = function(p) end,
}
```

## The `arrange(p)` Contract

When a tag needs laying out (client added/removed, tag properties changed, screen resized), the compositor calls `arrange(p)` with a single parameter table `p`.

### Fields in `p`

| Field | Type | Description |
|-------|------|-------------|
| `p.clients` | table | Array of tiled clients in creation order |
| `p.workarea` | table | `{x, y, width, height}` usable screen area. Wibars, padding, and struts are already subtracted. |
| `p.geometries` | table | Empty weak-keyed table. Write `p.geometries[c] = {x, y, width, height}` for each client. |
| `p.screen` | number | Screen index |
| `p.tag` | tag | The tag being arranged |
| `p.useless_gap` | number | Gap size in pixels (from `tag.gap` or `beautiful.useless_gap`) |

### What `arrange` must do

Write a geometry entry into `p.geometries` for each client in `p.clients`:

```lua
arrange = function(p)
    for i, c in ipairs(p.clients) do
        p.geometries[c] = {
            x = p.workarea.x,
            y = p.workarea.y,
            width = p.workarea.width,
            height = p.workarea.height,
        }
    end
end
```

Clients not assigned a geometry in `p.geometries` are left at their current position.

## Post-Arrange Processing

After `arrange()` returns, the compositor applies additional adjustments before setting actual window geometry. You do not need to account for these in your layout:

1. **Border subtraction.** The client's `border_width` is subtracted from the width and height so the total footprint (content + borders) matches your geometry.
2. **Gap application.** `p.useless_gap` is applied between clients (unless `skip_gap` returns `true`).
3. **`c:geometry()` call.** The final computed geometry is applied to each client.

This means your `arrange` function should use the full `p.workarea` dimensions. Borders and gaps are handled for you.

## Tag Properties

Layouts can read tag properties from `p.tag` to control their behavior. The master/stack layouts use these extensively. See [Master and Stack](/concepts/master-and-stack) for details.

| Property | Default | Description |
|----------|---------|-------------|
| `master_count` | 1 | Number of clients in the primary section |
| `master_width_factor` | 0.5 | Proportion of width for the primary section (0.0 to 1.0) |
| `column_count` | 1 | Number of columns in the secondary section |
| `master_fill_policy` | `"expand"` | `"expand"` fills screen when stack is empty, `"master_width_factor"` uses only its share |
| `gap` | 0 | Gap size override for this tag (becomes `p.useless_gap`) |

Your layout is free to ignore these properties or interpret them differently.

## Registering Layouts

Layouts must be registered before they can be assigned to tags.

```lua
local awful = require("awful")

-- Append a single layout
awful.layout.append_default_layout(my_layout)

-- Append multiple layouts at once
awful.layout.append_default_layouts({
    my_layout_a,
    my_layout_b,
})

-- Remove a layout
awful.layout.remove_default_layout(my_layout)
```

The registered layout list is stored in `awful.layout.layouts`. The default `rc.lua` populates this with the built-in layouts:

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.max,
        -- ...
    })
end)
```

### Assigning a layout to a tag

```lua
-- Set layout when creating tags
awful.tag({ "1", "2", "3" }, s, my_layout)

-- Change layout on an existing tag
local t = awful.screen.focused().selected_tag
t.layout = my_layout
```

### Cycling layouts

`awful.layout.inc(1)` and `awful.layout.inc(-1)` cycle through `awful.layout.layouts` on the current tag. Your custom layout must be in this list to appear in the cycle.

## Built-in Layouts

All built-in layouts live under `awful.layout.suit`:

| Layout | Name | Description |
|--------|------|-------------|
| `suit.tile` | `"tile"` | Master left, stack right (default) |
| `suit.tile.left` | `"tileleft"` | Master right, stack left |
| `suit.tile.bottom` | `"tilebottom"` | Master top, stack bottom |
| `suit.tile.top` | `"tiletop"` | Master bottom, stack top |
| `suit.fair` | `"fairv"` | Equal vertical split |
| `suit.fair.horizontal` | `"fairh"` | Equal horizontal split |
| `suit.spiral` | `"spiral"` | Fibonacci spiral |
| `suit.spiral.dwindle` | `"dwindle"` | Fibonacci dwindle |
| `suit.max` | `"max"` | Focused client fills screen |
| `suit.max.fullscreen` | `"fullscreen"` | Focused client fills screen (no border/gap) |
| `suit.magnifier` | `"magnifier"` | Focused client large in center, others behind |
| `suit.floating` | `"floating"` | No automatic tiling |
| `suit.corner.nw` | `"cornernw"` | Master top-left corner |
| `suit.corner.ne` | `"cornerne"` | Master top-right corner |
| `suit.corner.sw` | `"cornersw"` | Master bottom-left corner |
| `suit.corner.se` | `"cornerse"` | Master bottom-right corner |

## `skip_gap(nclients, tag)`

Optional function that returns `true` when the gap should not be applied. The compositor calls this before applying `useless_gap`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `nclients` | number | Number of tiled clients |
| `tag` | tag | The tag being arranged |

Common pattern: skip gaps when there is only one client (no visible gap between windows anyway) or for max-style layouts where clients overlap:

```lua
my_layout.skip_gap = function(nclients, tag)
    return nclients == 1
end
```

The built-in `max` layout always returns `true` since clients fill the entire screen.

## Utility Functions

| Function | Description |
|----------|-------------|
| `awful.layout.get(screen)` | Get the current layout for a screen |
| `awful.layout.set(layout, tag)` | Set layout on a tag |
| `awful.layout.inc(i)` | Cycle layouts on the focused tag |
| `awful.layout.arrange(screen)` | Force re-layout on a screen |
| `awful.layout.getname(layout)` | Get a layout's name string |
| `awful.layout.append_default_layout(layout)` | Add a layout to the default list |
| `awful.layout.remove_default_layout(layout)` | Remove a layout from the default list |

## See Also

- **[Custom Layouts Guide](/guides/custom-layouts)** - Step-by-step guide to writing your own layout
- **[Master and Stack](/concepts/master-and-stack)** - How master/stack layouts divide the screen
- **[AwesomeWM awful.layout docs](https://awesomewm.org/apidoc/libraries/awful.layout.html)** - Full upstream API reference
