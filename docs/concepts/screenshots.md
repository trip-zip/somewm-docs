---
sidebar_position: 9
title: Screenshots
description: How the screenshot capture pipeline works
---

# Screenshots

This page explains how SomeWM captures screenshots through `root.content()` and how the interactive selection mode works.

## The Capture Pipeline

All screenshots flow through the same C function: `root.content()`. This is the Wayland equivalent of reading the X11 root window pixmap.

### X11 (AwesomeWM)

On X11, the root window is a composited pixmap managed by the X Server:

```
root.content() → cairo_xcb_surface_create() → Done
```

One function call. The X Server already has a composited framebuffer.

### Wayland (SomeWM)

On Wayland, the compositor owns all buffers. There is no pre-composited root pixmap to read from. SomeWM must manually composite every visible element onto a new Cairo surface:

```
root.content()
  ├─ Create Cairo surface at layout dimensions
  ├─ Paint wallpaper
  ├─ For each scene buffer (client windows):
  │   ├─ Read pixels from GPU texture (or SHM buffer)
  │   └─ Composite at logical position with scaling
  ├─ Composite widgets (drawins, titlebars)
  └─ Return surface as lightuserdata
```

The result is a Cairo image surface at **logical resolution** (matching `root.size()`). This is the coordinate system Lua operates in.

## HiDPI and Buffer Scaling

On HiDPI displays, client windows render at physical resolution but occupy logical space. A client at logical size 800x600 might have a 1600x1200 pixel buffer (at 2x scale).

The scene buffer compositor handles this by:

1. Reading the full `buffer->width x buffer->height` texture (physical pixels)
2. Scaling down to `dst_width x dst_height` (logical pixels) when painting

This produces a screenshot where every pixel corresponds 1:1 to a logical coordinate, which is what `awful.screenshot` expects for cropping.

### Widget Surfaces

Widget drawable surfaces (drawins, titlebars) use a different mechanism. Their Cairo surfaces have `cairo_surface_set_device_scale()` applied, so Cairo handles the physical-to-logical scaling automatically during compositing. No explicit scaling is needed.

## Interactive Selection Mode

`awful.screenshot({ interactive = true })` uses a three-phase pipeline:

### Phase 1: Capture

When `refresh()` is called, `root.content()` captures the entire desktop into a Cairo surface. This happens **before** the overlay is shown, so the overlay itself is not captured.

### Phase 2: Overlay

`start_snipping()` creates a fullscreen wibox (the "frame") containing:

- An **imagebox** showing the captured surface as a background
- A **selection widget** (red rectangle) that follows the mouse

The user sees the captured image and draws a selection rectangle on top of it. Mouse coordinates from the mousegrabber are in logical space, matching the captured surface.

### Phase 3: Crop

When the user releases the mouse button, `accept()` crops the pre-captured surface using the selection coordinates:

```lua
-- Inside accept()
crop_shot(selected_geometry.surface, selected_geometry)
-- selected_geometry = {x, y, width, height} from mouse coordinates
```

The crop operates on the original high-quality capture. The overlay was only for visual feedback.

## Coordinate Spaces

Everything in the screenshot pipeline uses **logical coordinates**:

| Component | Coordinate Space |
|-----------|-----------------|
| `root.size()` | Logical (layout bounding box) |
| `root.content()` surface | Logical pixels |
| Mouse position (mousegrabber) | Logical (Wayland compositor coords) |
| Frame wibox dimensions | Logical |
| Selection rectangle | Logical |
| `crop_shot()` source and target | Logical |

This consistency is what makes the crop coordinates match the captured content.

## See Also

- [Interactive Screenshots Guide](/guides/screenshots) - Practical setup
- [Display Scaling](/concepts/display-scaling) - How logical vs physical pixels work
- [awful.screenshot Reference](/reference/awful/screenshot) - Full API documentation
