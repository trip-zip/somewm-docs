---
sidebar_position: 1
title: gears
description: Utility functions and helpers
---

# gears

The `gears` library provides utility functions used throughout AwesomeWM/SomeWM. It includes timers, shapes, color manipulation, filesystem helpers, and more.

**Upstream documentation:** The `gears` library spans multiple sections in the AwesomeWM docs:
- [theme_related_libraries](https://awesomewm.org/apidoc/theme_related_libraries/gears.shape.html) - shape, color
- [utility_libraries](https://awesomewm.org/apidoc/) - timer, filesystem, string, table

## Key Modules

| Module | Purpose |
|--------|---------|
| `gears.timer` | Periodic and one-shot timers |
| `gears.shape` | Drawing shapes (rounded rectangles, circles, etc.) |
| `gears.color` | Color parsing and manipulation |
| `gears.surface` | Cairo surface helpers |
| `gears.filesystem` | File and directory utilities |
| `gears.string` | String manipulation |
| `gears.table` | Table utilities |
| `gears.math` | Math helpers |

`gears.wallpaper` was removed in SomeWM 2.0. Set wallpapers with
[`awful.wallpaper`](https://awesomewm.org/apidoc/popups_and_bars/awful.wallpaper.html).

## Common Patterns

### Timers

```lua
local gears = require("gears")

-- Repeating timer
local mytimer = gears.timer({
    timeout = 60,
    autostart = true,
    callback = function()
        -- runs every 60 seconds
    end
})

-- One-shot delayed call
gears.timer.delayed_call(function()
    -- runs once on next iteration
end)
```

### Shapes

```lua
local gears = require("gears")

-- Rounded rectangle
widget.shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 8)
end
```

### Surfaces

`gears.surface` turns image files into cairo surfaces, used by `bgimage`, wallpapers, and icons:

```lua
local gsurface = require("gears.surface")

local img = gsurface.load("/path/to/image.png")            -- cached by path
local img2 = gsurface.load_uncached("/path/to/image.png")  -- fresh copy, no cache
local w, h = gsurface.get_size(img)                        -- pixel dimensions
```

Behavior worth knowing:

- `load` caches surfaces by file path, so loading the same file twice is free. Use `load_uncached` if you modify the surface in place.
- A path that fails to load is **not an error**: an error is printed to the log and an empty 0x0 surface is returned, which draws nothing. If an image silently does not appear, check the log.
- Passing an existing cairo surface returns it unchanged, so APIs built on `gears.surface` accept either a path or a surface.

## Behavioral Notes

SomeWM's `gears` implementation is fully compatible with AwesomeWM.
