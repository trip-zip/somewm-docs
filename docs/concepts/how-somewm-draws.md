---
sidebar_position: 2
title: How SomeWM draws
description: How widget properties become sizes, positions and pixels on the screen.
---

# How SomeWM draws

When you change a textbox's text, SomeWM needs to work out how much room the new text takes, where neighbouring widgets belong, and which pixels to update. In 2.1, it uses the Clay layout library to calculate sizes and positions, then draws the result with its renderer.

This also applies to wibars, popups, notifications and window frames. Applications still draw their own contents. SomeWM decides where to put those contents and their borders on the screen.

## How sizes and positions are calculated {#what-computing-layout-means}

The objects in a configuration form a tree: a bar contains layouts, layouts contain widgets, and containers wrap other widgets. Each parent supplies rules for placing its children. A horizontal layout puts them side by side. A margin container reserves padding around its child.

The built-in widgets convert their properties into *declarations*, tables describing content and sizing rules. The function doing this is called a *describer*. Clay takes the combined declarations and calculates a rectangle for each element. The docs and the tree dump call those calculated rectangles *solved boxes*.

For example, if a textbox changes from `"9%"` to `"100%"`:

1. The textbox setter requests an update.
2. Its describer supplies the new text and font.
3. Clay measures the text and calculates its size within the parent's constraints. A content-sized parent may grow. A constrained textbox may wrap or ellipsize.
4. SomeWM updates the text and any affected positions on screen.

Client layouts use the same calculation. A wibar reserves space on its edge of the output. The remaining workarea contains the tiled windows. In the tile layout, `tag.master_width_factor` sets the master's share of the available width. Changing that value changes the client rectangles at the next layout pass. See the [client layout example](./clients-in-the-tree.md#see-it).

Custom client layouts using `arrange` can still supply rectangles computed in Lua. The dump labels these sizes `legacy`. Custom widgets need compositions or descriptions instead of the old widget `fit`, `layout` and `draw` callbacks. [Widgets in SomeWM 2.1](./widgets-in-the-tree.md) explains the distinction.

## When an update reaches the screen {#a-defined-stage-in-the-main-loop}

Property changes mark an output as needing an update. SomeWM first delivers queued notifications to Lua, then prepares the updated widget and client descriptions. Clay calculates the output's layout, and SomeWM applies the result before presenting the frame. A clean output skips declaration and layout calculation.

![Queued notifications and Lua declarations feed Clay layout. The resulting drawing commands update the scene before presentation.](/img/architecture/clay-frame-pipeline.svg)

Descriptions can be cached for widgets whose inputs have not changed. When layout is needed, Clay still calculates the complete output tree, not just the changed widget. This lets a change in one widget affect its neighbours.

Changes made during a layout pass request another pass. They do not recursively restart the one in progress. Animations request further frames until they finish. [Signals](./signals.md#dispatch) explains which handlers run immediately and which wait for the main loop.

## Drawing the calculated layout {#the-renderer-consumes-the-solved-result}

Clay produces drawing commands containing positions, sizes, clipping and drawing order. SomeWM's renderer uses them to update the *scene*: the rectangles, image buffers and application surfaces that wlroots combines into a frame. It reuses scene nodes when possible and removes those no longer needed.

Solid rectangles, borders and rounded corners use scene rectangles. Text, images, paths and shadows use cached raster content. Cairo and Pango still help render that content, but SomeWM does not call a `draw` method on each widget. Changing the content, size, output scale or clipping path can require a new raster image.

Finally, wlroots combines the scene contents using the GPU or pixman and presents them on the output. Clay calculates layout. It does not draw application pixels or present frames.

## Inspecting the result {#state-layout-and-scene}

An object's properties express what your configuration requested. The tree dump shows the resulting sizes and positions. Its `realized:` section shows the scene nodes used to draw them. These are different views of the same update, useful when a widget has an unexpected size or position.

```bash
somewm-client clay tree
```

<span id="see-it" />

[Reading the tree](./reading-the-tree.md) explains the dump and the interactive inspector. [Scene graph](./scene-graph.md) explains drawing order. SomeWM also uses the calculated rectangles for pointer hit testing and client geometry updates.

## Implementation entry points

The normal update follows these stages:

| Stage | Code |
| --- | --- |
| Deliver queued notifications, emit `refresh`, apply pending object updates | `some_refresh()` in `loop.c` and `some_event_queue_drain()` in `event_queue.c` |
| Emit `clay::declare` and compile pending widget and client descriptions | `lua/wibox/drawable.lua`, `lua/wibox/clay.lua`, `lua/awful/layout/init.lua` |
| Build the output tree and calculate layout | `declare_output_frame()` in `declare.c`, between `Clay_BeginLayout` and `Clay_EndLayout` |
| Publish calculated boxes through `clay::solved` and settle popup and client geometry | `declare.c`, `lua/wibox/drawable.lua` |
| Update scene nodes from drawing commands | `render_reconcile()` in `render.c` |
| Present the frame | `rendermon()` in `monitor.c`, `wlr_scene_output_commit()` |

`loop.c` runs `some_refresh()` before polling and dispatches pending Wayland idle work. Output frame callbacks call `declare_output_frame()` before presenting. A deadline fallback calls the same function if no frame callback arrives.

## What Clay is

Clay calculates sizes and positions from a tree of elements. It is a single-header library, vendored unmodified in `third_party/clay.h`. `third_party/README.clay.md` records its version and checksum. SomeWM re-declares the tree each layout pass. Clay retains identities, scroll positions and transitions between passes.

Dump labels map to these Clay definitions:

| In the dump | In clay.h |
| --- | --- |
| `fit`, `grow`, `fixed(N)`, `percent(N)` | `CLAY_SIZING_FIT`, `GROW`, `FIXED`, `PERCENT` |
| `fit>=32`, `grow<=200` | `min` and `max` on `Clay_SizingMinMax` |
| `row`, `column` | `CLAY_LEFT_TO_RIGHT`, `CLAY_TOP_TO_BOTTOM` |
| `pad l,r,t,b`, `gap N` | `Clay_Padding`, `childGap` |
| `clip` | `Clay_ClipElementConfig` |
| `attach ROOT`, `PARENT`, `OUTPUT` or `ELEMENT` | `CLAY_ATTACH_TO_ROOT`, `CLAY_ATTACH_TO_PARENT`, `CLAY_ATTACH_TO_ELEMENT_WITH_ID` (the last two names say which element) |
| `offset x,y`, `band N` | the floating element's `offset` and `zIndex` |
| the eight-hex id | `Clay_ElementId.id`, stable while the widget exists |
| `transition` | `Clay_TransitionData`; Clay animates the box, SomeWM declares only the target |
| the inspector | Clay's own debug view, `Clay_SetDebugModeEnabled`, styled from `beautiful.inspector_*` |

Configured limits:

| Budget | Value | Where |
| --- | --- | --- |
| elements per output | 65536 | `CLAY_ELEMENTS_MAX`, printed as `elements N/65536` |
| nodes per wibox | 4096 | `WIDGET_NODES_MAX`; a larger wibox shows nothing and warns |
| scroll containers per output | 100 | `WIDGET_SCROLLS_OUTPUT_MAX` |

## What SomeWM adds

- **Size sources.** Each `fixed` or `percent` size is labelled `user`, `theme`, `output`, `protocol`, `legacy`, `transition` or `scroll` ([list](./reading-the-tree.md#where-a-number-comes-from)). The header's `derived` counter is checked by the tests and should be 0. The [dump reference](./reading-the-tree.md#header) explains the counters.
- **Bands.** Everything outside the output's flow floats at a z-index assigned from state: wallpaper -4, normal client 20, pointer 32767 ([table](./scene-graph.md#bands)).
- **Describers.** Every stock `wibox` class has a function that turns its properties into declarations ([what each declares](./widgets-in-the-tree.md)).
