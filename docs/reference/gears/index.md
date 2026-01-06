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
| `gears.wallpaper` | Wallpaper setting |

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

## Behavioral Notes

SomeWM's `gears` implementation is fully compatible with AwesomeWM.
