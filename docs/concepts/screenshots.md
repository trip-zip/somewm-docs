---
sidebar_position: 9
title: Screenshots
description: root.content() composes a capture by walking the scene in draw order, at logical resolution. The interactive selection is a wibox over that capture, and the crop lands on the capture, not the overlay.
---

# Screenshots

Every screenshot goes through `root.content()`. On Wayland the compositor owns every buffer, so SomeWM composes the capture itself: it walks [the scene](./scene-graph.md) once in draw order, paints each rectangle, copies each text and image raster, and reads each client buffer back from the GPU or shared memory. Nothing is read from a widget or a wibox, because no widget holds a surface; what the renderer holds for it is what the capture copies.

The result is a cairo image surface at logical resolution, the size of `root.size()`. `root.content(true)` leaves the wallpaper out and the ground transparent, so a transparent window keeps its alpha.

## HiDPI

On a scaled output a client at logical 800 by 600 has a 1600 by 1200 buffer at scale 2. The capture reads each buffer at its physical size and scales it to its logical box while painting, so one pixel of the result is one logical pixel, which is what `awful.screenshot` crops in. Text and image rasters are already at the output's scale and are copied the same way.

## Interactive selection

`awful.screenshot { interactive = true }`:

1. **Capture.** `root.content()` runs before anything is shown, so the overlay is never in the picture.
2. **Overlay.** A fullscreen wibox holds an imagebox with the capture, one image element the size of the screen, and a second widget for the selection, placed and sized by a manual layout at the drag's coordinates. The capture's content never changes, so it is rastered once; a pointer move resizes the selection's box and rasters nothing else.
3. **Crop.** On release, the capture is cropped at the selection, not the overlay.

`root.size()`, the capture, mousegrabber coordinates, the overlay and the crop are all in logical pixels, which is why the crop lands on the right ones.

[Screenshots guide](/docs/guides/screenshots) has the setup; [awful.screenshot](/docs/reference/awful/screenshot) is the API.
