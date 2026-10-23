---
sidebar_position: 9
title: Screenshots
description: How desktop, screen and client captures use the rendered scene and logical coordinates.
---

# Screenshots

`root.content()` captures the desktop by walking the rendered scene in drawing order. It copies rectangles, text and image rasters, and reads application buffers from GPU or shared memory. Widgets do not supply screenshot surfaces of their own.

The result is a Cairo image surface at logical resolution, the size of `root.size()`. `root.content(true)` omits the wallpaper and starts with a transparent background. Other opaque content still covers that background.

`screen.content` captures a single screen. `client.content` captures an application's content without compositor titlebars or borders. `awful.screenshot` selects among these sources according to its options.

## HiDPI

At scale 2, an application's logical 800-by-600 surface can have a 1600-by-1200 buffer. Capture scales that buffer into its logical box. The resulting image and the crop coordinates both use logical pixels.

## Interactive selection

For an interactive `awful.screenshot`, `:refresh()` captures the image before showing the selection overlay. The overlay displays that saved capture and a selection rectangle. Dragging changes the rectangle. Accepting crops the saved image, so the screenshot does not include its own selection overlay.

The [screenshot guide](../guides/screenshots.md) shows commands and bindings. See [awful.screenshot](../reference/awful/screenshot.md) for options and methods.
