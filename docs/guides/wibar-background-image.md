---
sidebar_position: 9
title: Put a PNG Texture on Your Wibar
description: "bgimage paints an image once, at its own size, in the bar's top-left corner. To cover the bar, prepare an image the bar's size and set that."
---

# Put a PNG Texture on Your Wibar

A wibox's `bgimage` is one image element that fills the bar, and the renderer paints the file at its own pixel size in that element's top-left corner, scaled only by the output. It is not tiled and not stretched. A 20 by 20 texture on a 1280-wide bar covers 20 pixels and the rest shows `bg`, usually under the leftmost widget, so it looks as if nothing happened. A function as `bgimage`, which older configs used to tile, is not drawn and warns `wibox.drawable: bgimage functions are not drawn`.

## Set it

```lua
local gsurface = require("gears.surface")
local texture = gsurface.load(os.getenv("HOME") .. "/.config/somewm/theme/bar-texture.png")

s.mywibox = awful.wibar {
    position = "top", screen = s,
    bg = "#222222",        -- shows wherever the image does not
    bgimage = texture,
}
```

Or for every bar, `theme.wibar_bgimage = "/absolute/path.png"`; it is read when each bar is constructed, so a later change needs `s.mywibox.bgimage = ...`. `gears.surface.load` caches by path and does not error on a missing file: it logs and returns an empty surface, which draws nothing.

## Cover the bar

Make the image the bar's size, `s.geometry.width` by the bar's height, with any image tool:

```bash
magick -size 1280x32 tile:bar-texture.png bar-background.png     # tile
magick bar-texture.png -resize 1280x32! bar-background.png       # or stretch
```

```lua
bgimage = gsurface.load(os.getenv("HOME") .. "/.config/somewm/theme/bar-background.png"),
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
