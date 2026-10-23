---
sidebar_position: 9
title: Put a PNG Texture on Your Wibar
description: Load an image and use it as a wibar background, tiled or stretched
---

# Put a PNG Texture on Your Wibar

Set `bgimage` on an `awful.wibar`. A plain image paints once at its native size. Use a drawing function to tile or stretch it.

## Load the Image Once

Load the texture before creating bars:

```lua
local gsurface = require("gears.surface")
local texture = gsurface.load(
    os.getenv("HOME") .. "/.config/somewm/theme/bar-texture.png")
```

Use an existing absolute path. `gears.surface.load` logs failures and returns an empty fallback surface. Its path cache can reuse an image while the cached surface remains available.

## Set It as the Bar Background

<span id="what-you-get-by-default" />

Inside your screen decoration handler:

```lua
s.mywibox = awful.wibar {
    position = "top",
    screen = s,
    bg = "#222222",
    bgimage = texture,
}
```

The image paints at the top-left. A small image leaves most of the bar showing its `bg` colour.

Set `theme.wibar_bgimage` to the image path in your theme file to use it for all bars created afterward. Existing bars need a direct assignment to `s.mywibox.bgimage`.

## Tile the Texture

Instead of assigning the surface directly, create a repeating pattern and assign a drawing function:

```lua
local cairo = require("lgi").cairo
local pattern = cairo.Pattern.create_for_surface(texture)
pattern.extend = cairo.Extend.REPEAT
s.mywibox.bgimage = function(_, cr, width, height)
    cr:set_source(pattern)
    cr:rectangle(0, 0, width, height)
    cr:fill()
end
```

Use `cairo.Extend.REFLECT` to mirror alternating tiles.

## Stretch the Image

Alternatively, scale the image to fill the bar:

```lua
s.mywibox.bgimage = function(_, cr, width, height)
    local image_width, image_height = gsurface.get_size(texture)
    if image_width <= 0 or image_height <= 0 then return end
    cr:save()
    cr:scale(width / image_width, height / image_height)
    cr:set_source_surface(texture, 0, 0)
    cr:paint()
    cr:restore()
end
```

This stretches width and height independently and can distort the image.

## Troubleshooting

<span id="the-image-only-shows-in-one-corner" />
<span id="the-bar-is-just-a-solid-color" />

- **Image only in one corner:** use the tile or stretch function.
- **Solid-colour bar:** check the image path and compositor log. A widget with an opaque background can also cover the image.
- **Theme change has no effect:** `wibar_bgimage` is read when the bar is constructed. Set the live bar's `bgimage` or reload the config.

## See Also

- [Wibar Background Image](../reference/wibox/wibar.md#background-image)
- [Theme Tutorial](../tutorials/theme.md)
