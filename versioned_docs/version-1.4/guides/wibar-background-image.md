---
sidebar_position: 9
title: Put a PNG Texture on Your Wibar
description: Load an image and use it as a wibar background, tiled or stretched
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Put a PNG Texture on Your Wibar

<YouWillLearn>

- How to load a PNG into a cairo surface with `gears.surface`
- How `bgimage` draws by default, and why a small texture "disappears"
- How to tile or stretch the image across the whole bar

</YouWillLearn>

## Load the Image Once

Load the file into a cairo surface once, at the top of your config or widget module, and reuse it:

```lua
local gsurface = require("gears.surface")

local texture = gsurface.load(os.getenv("HOME") .. "/.config/somewm/theme/bar-texture.png")
```

`gears.surface.load` caches by path, so repeated loads of the same file are free. If the path is wrong you get **no error**: it prints a message to the log and returns an empty surface, which draws nothing. If your bar looks like the image was ignored, check the log and the path first.

## Set It as the Bar Background

Either pass it when you create the bar:

```lua
s.mywibox = awful.wibar {
    position = "top",
    screen = s,
    bg = "#222222",   -- shows wherever the image does not cover
    bgimage = texture,
}
```

Or set it for all bars from your theme file:

```lua
-- theme.lua
theme.wibar_bgimage = os.getenv("HOME") .. "/.config/somewm/theme/bar-texture.png"
```

The theme variable is read once, when each wibar is constructed. Changing it after the bar exists does nothing; assign `s.mywibox.bgimage = ...` to update a live bar.

## What You Get by Default

The image is painted **once, at its native pixel size, in the top-left corner** of the bar. It is not tiled and not stretched. A 20x20 texture on a 1920-wide bar covers 20 pixels and the rest of the bar shows the plain `bg` color, so it is easy to think nothing happened, especially if a widget sits on top of that corner.

To cover the whole bar, use the function form of `bgimage`. The function runs on every repaint and receives a cairo context plus the bar's current size.

## Tile the Texture

Wrap the surface in a cairo pattern and set its `extend` mode to `REPEAT`:

```lua
local cairo = require("lgi").cairo
local gsurface = require("gears.surface")

local texture = gsurface.load(os.getenv("HOME") .. "/.config/somewm/theme/bar-texture.png")

s.mywibox = awful.wibar {
    position = "top",
    screen = s,
    bgimage = function(_, cr, width, height)
        local pattern = cairo.Pattern.create_for_surface(texture)
        pattern.extend = cairo.Extend.REPEAT
        cr:set_source(pattern)
        cr:rectangle(0, 0, width, height)
        cr:fill()
    end,
}
```

`cairo.Extend.REFLECT` mirrors every other tile instead of repeating, which hides seams in non-tileable textures.

## Stretch the Image

To scale one image across the whole bar, scale the context to the ratio between the bar and the image:

```lua
s.mywibox = awful.wibar {
    position = "top",
    screen = s,
    bgimage = function(_, cr, width, height)
        local img_w, img_h = gsurface.get_size(texture)
        cr:scale(width / img_w, height / img_h)
        cr:set_source_surface(texture, 0, 0)
        cr:paint()
    end,
}
```

## Troubleshooting

### The image only shows in one corner

That is the default draw behavior, not a bug. Use the tiled or stretched function form above.

### The bar is just a solid color

- Wrong file path: `gears.surface.load` logs an error and draws nothing. Check the log and use an absolute path (`os.getenv("HOME") .. "/..."`, not `~/...`).
- The image loaded but is small and hidden under the leftmost widget. Try a bright test image, or temporarily remove the bar's widgets.
- You set `theme.wibar_bgimage` after the bar was already created. Set it before `awful.wibar` runs, or assign `s.mywibox.bgimage` directly.

## See Also

- [Wibar Properties: Background Image](/docs/reference/wibox/wibar#background-image) - reference for `bgimage` value types and semantics
- [Theme tutorial](/docs/tutorials/theme) - setting up `theme.lua` and `beautiful.init()`
