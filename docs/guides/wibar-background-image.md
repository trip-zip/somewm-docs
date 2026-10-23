---
sidebar_position: 9
title: Put a PNG Texture on Your Wibar
description: Prepare a background image at the bar's size and assign it with bgimage.
---

# Put a PNG Texture on Your Wibar

Set `bgimage` to an image path or surface. SomeWM draws it once at its natural size in the top-left corner, scaled with the output. To cover the bar, prepare an image at the bar's logical dimensions. A function assigned to `bgimage` is ignored with a warning.

## Set it

Inside your screen decoration handler, replace the bar constructor with:

```lua
local awful = require("awful")
local gsurface = require("gears.surface")
local texture = gsurface.load(os.getenv("HOME") .. "/.config/somewm/theme/bar-texture.png")

s.mywibox = awful.wibar {
    position = "top", screen = s,
    bg = "#222222",        -- shows wherever the image does not
    bgimage = texture,
}
```

Or for every bar, `theme.wibar_bgimage = "/absolute/path.png"`. It is read when each bar is constructed, so a later change needs `s.mywibox.bgimage = ...`. `gears.surface.load` caches by path and does not error on a missing file: it logs and returns an empty surface, which draws nothing.

## Cover the bar

Make the image the bar's size, `s.geometry.width` by the bar's height, with any image tool:

```bash
magick -size 1280x32 tile:bar-texture.png bar-background.png     # tile
magick bar-texture.png -resize 1280x32! bar-background.png       # or stretch
```

Assign the prepared image to the existing bar:

```lua
s.mywibox.bgimage = gsurface.load(os.getenv("HOME") .. "/.config/somewm/theme/bar-background.png")
```

The bar's tree then holds one image element the bar's size:

```
WIBAR screen 1 1280x32+0+0 converted: 33 nodes, 4 images, radius 8 clip w=grow h=fixed(32) theme row box 0,0 1280x32
  3eba84d6     image image 1280x32 natural w=grow h=grow box 0,0 1280x32
```

The image's pixels are logical pixels, so one file covers the bar at any output scale.

## If the bar stays a solid colour

- The path: absolute, not `~`. The log has the load error.
- The image is small and under the first widget. Try a bright test image or remove the widgets for a moment.
- `theme.wibar_bgimage` was set after the bar was created.
- You set a function. The log says so.

[Wibar properties](../reference/wibox/wibar.md#background-image) lists the value types `bgimage` accepts.
