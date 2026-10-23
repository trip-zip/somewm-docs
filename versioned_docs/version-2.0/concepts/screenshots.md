---
sidebar_position: 9
title: Screenshots
description: Logical-resolution capture and interactive cropping in SomeWM 2.0.
---

# Screenshots

SomeWM 2.0 implements `root.content()` by compositing the desktop into a Cairo image surface at logical resolution. `awful.screenshot` uses that surface for capture and cropping. External tools such as `grim` use a Wayland capture protocol instead.

## The Capture Pipeline

<span id="x11-awesomewm" />
<span id="wayland-somewm" />

`root.content()` performs these steps:

1. Allocate an ARGB32 Cairo surface using the output layout's logical bounding-box dimensions.
2. Paint the wallpaper, or clear to transparent when preserving alpha.
3. Read visible application scene buffers and composite them at their logical destinations.
4. Composite widget surfaces, processing ordinary widgets before `ontop` widgets.
5. Return a Cairo surface pointer for Lua to wrap with `gears.surface`.

This is a CPU composition path, rather than a readback of a single completed output framebuffer. It is not the capture path for every screenshot tool.

## HiDPI and Buffer Scaling

A client occupying 800×600 logical pixels may supply a 1600×1200 buffer at scale 2. Capture maps that buffer back into its logical rectangle. Increasing the output scale therefore does not double the dimensions returned by `root.content()`.

### Widget Surfaces

Drawable surfaces carry a Cairo device scale. The capture code accounts for that scale when painting them into the logical-resolution result.

## Interactive Selection Mode

### Phase 1: Capture

The screenshot object captures before showing its selection overlay, so the overlay is absent from the captured image.

### Phase 2: Overlay

A wibox displays the captured image and selection outline. A mousegrabber records the drag in logical coordinates. The default outline is red and can be themed.

### Phase 3: Crop

Accepting the selection crops the stored capture at the selected logical rectangle. It does not capture the desktop again. Changes made by applications during selection therefore do not appear in the result.

## Coordinate Spaces

`root.size()`, the capture dimensions and selection coordinates use logical units. The 2.0 capture code allocates the output-layout bounding-box size but does not translate scene positions by the bounding box's origin. Layouts with outputs at negative coordinates can therefore produce clipped or displaced captures.

For capture and saving examples, see the [screenshot guide](../guides/screenshots.md).

## See Also

- [Display Scaling](display-scaling.md)
- [Screenshot Reference](../reference/awful/screenshot.md)
