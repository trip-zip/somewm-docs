---
sidebar_position: 1.5
title: awful.layout
description: Layout protocol, arrange contract, and layout registration
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# awful.layout

The `awful.layout` module manages tiling layouts. Each layout supplies an `arrange(p)` function that assigns client geometries.

## Deviations from AwesomeWM

The `arrange(p)` interface follows AwesomeWM. The workarea differences are documented below. SomeWM adds two scrollable layouts under `awful.layout.suit`:

| Addition | Notes |
|----------|-------|
| `awful.layout.suit.carousel` <SomewmOnly /> | Scrollable horizontal-column layout. [Reference](/docs/2.0/reference/awful/carousel). |
| `awful.layout.suit.carousel.vertical` <SomewmOnly /> | Vertical variant. |

## Layout Table Structure

A layout is a plain table with these fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Layout identifier used to look up `beautiful.layout_<name>` icons |
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
| `p.clients` | table | Array from `awful.client.tiled(screen)`, in client order, which can change after swaps |
| `p.workarea` | table | `{x, y, width, height}` usable screen area. Struts are already subtracted. In 2.0, the screen method ignores the requested padding and outer gap margin. |
| `p.geometries` | table | Empty weak-keyed table. Write `p.geometries[c] = {x, y, width, height}` for each client. |
| `p.screen` | number | Screen index |
| `p.geometry` | table | Full screen geometry, including areas reserved by struts |
| `p.padding` | table | Screen padding |
| `p.useless_gap` | number | Effective gap in logical pixels, after the single-client gap policy |

### What `arrange` must do

Write a geometry entry into `p.geometries` for each client in `p.clients`:

```lua
my_layout.arrange = function(p)
    for _, c in ipairs(p.clients) do
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

After `arrange(p)`, `awful.layout` adjusts each geometry using `g = p.useless_gap`:

- Add `g` to `x` and `y`.
- Subtract `2 * c.border_width + 2 * g` from width and height, clamping each to at least 1.
- Apply the result through `c:geometry()`.

Use the supplied workarea without subtracting those borders or gaps again.

## Tag Properties

The selected tag is `screen[p.screen].selected_tag`. There is no `p.tag` field. See [Master and Stack](/docs/2.0/concepts/master-and-stack) for details.

| Property | Default | Description |
|----------|---------|-------------|
| `master_count` | 1 | Number of clients in the primary section |
| `master_width_factor` | 0.5 | Proportion of width for the primary section (0.0 to 1.0) |
| `column_count` | 1 | Number of columns in the secondary section |
| `master_fill_policy` | `"expand"` | `"expand"` fills screen when stack is empty, `"master_width_factor"` uses only its share |
| `gap` | `beautiful.useless_gap` or 0 | Gap size override for this tag (becomes `p.useless_gap`) |

Your layout is free to ignore these properties or interpret them differently.

## Registering Layouts

A layout can be assigned directly to `tag.layout`. Registration adds it to the default layout cycle.

```lua
local awful = require("awful")

-- Append a single layout
awful.layout.append_default_layout(my_layout)

-- Append multiple layouts at once
awful.layout.append_default_layouts({
    my_layout,
    awful.layout.suit.tile,
})

-- Remove a layout
awful.layout.remove_default_layout(my_layout)
```

The registered layout list is stored in `awful.layout.layouts`. Replace the existing `request::default_layouts` handler in `rc.lua` to choose a different list:

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.max,
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

`awful.layout.inc(1)` and `awful.layout.inc(-1)` use the selected tag’s `layouts` list, falling back to `awful.layout.layouts` when it is empty. If the current layout is absent from the list, cycling does nothing.

## Built-in Layouts

All built-in layouts live under `awful.layout.suit`:

| Layout | Name | Description |
|--------|------|-------------|
| `suit.tile` | `"tile"` | Master left, stack right |
| `suit.tile.left` | `"tileleft"` | Master right, stack left |
| `suit.tile.bottom` | `"tilebottom"` | Master top, stack bottom |
| `suit.tile.top` | `"tiletop"` | Master bottom, stack top |
| `suit.fair` | `"fairv"` | Equal-sized grid, filled vertically |
| `suit.fair.horizontal` | `"fairh"` | Equal-sized grid, filled horizontally |
| `suit.spiral` | `"spiral"` | Fibonacci spiral |
| `suit.spiral.dwindle` | `"dwindle"` | Fibonacci dwindle |
| `suit.max` | `"max"` | Clients overlap in the workarea |
| `suit.max.fullscreen` | `"fullscreen"` | Clients fill `p.geometry`, ignoring workarea reservations. Border and gap adjustments still apply |
| `suit.magnifier` | `"magnifier"` | Focused client large in center, others behind |
| `suit.floating` | `"floating"` | No automatic tiling |
| `suit.corner.nw` | `"cornernw"` | Master top-left corner |
| `suit.corner.ne` | `"cornerne"` | Master top-right corner |
| `suit.corner.sw` | `"cornersw"` | Master bottom-left corner |
| `suit.corner.se` | `"cornerse"` | Master bottom-right corner |
| `suit.carousel` | `"carousel"` | Scrollable horizontal columns ([reference](/docs/2.0/reference/awful/carousel)) |
| `suit.carousel.vertical` | `"carousel.vertical"` | Scrollable vertical columns ([reference](/docs/2.0/reference/awful/carousel)) |

## `skip_gap(nclients, tag)`

Called only when `tag.gap_single_client` is `false`. Returning `true` makes `p.useless_gap` zero. Without this function, gaps are skipped when fewer than two clients are tiled.

| Parameter | Type | Description |
|-----------|------|-------------|
| `nclients` | number | Number of tiled clients |
| `tag` | tag | The tag being arranged |

Example:

```lua
my_layout.skip_gap = function(nclients, tag)
    return nclients == 1
end
```

The built-in `max` layout returns `true`. It still receives gaps when `tag.gap_single_client` is `true`.

## Utility Functions

| Function | Description |
|----------|-------------|
| `awful.layout.get(screen)` | Get the current layout for a screen |
| `awful.layout.set(layout, tag)` | Set layout on a tag |
| `awful.layout.inc(i)` | Cycle layouts on the focused tag |
| `awful.layout.arrange(screen)` | Schedule a layout pass on a screen |
| `awful.layout.getname(layout)` | Get a layout's name string |
| `awful.layout.append_default_layout(layout)` | Add a layout to the default list |
| `awful.layout.remove_default_layout(layout)` | Remove a layout from the default list |

## See Also

- **[Custom Layouts Guide](/docs/2.0/guides/custom-layouts)** - Step-by-step guide to writing your own layout
- **[Master and Stack](/docs/2.0/concepts/master-and-stack)** - How master/stack layouts divide the screen
- **[AwesomeWM awful.layout docs](https://awesomewm.org/apidoc/libraries/awful.layout.html)** - Full upstream API reference
