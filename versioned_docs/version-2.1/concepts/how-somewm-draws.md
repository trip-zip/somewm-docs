---
sidebar_position: 2
title: How SomeWM draws
description: How pending state changes become one output layout, computed by Clay in C and passed as render commands to the scene renderer.
---

# How SomeWM draws

SomeWM computes client and widget layout in the same C layout pass. Lua supplies the state and layout declarations. [Clay](https://github.com/nicbarker/clay) resolves those declarations into boxes and render commands, and SomeWM's renderer applies the result to `wlr_scene` before wlroots presents it.

## What computing layout means

Layouts declare sizing rules. The output is a column containing bars and a workarea that fills the remaining space. In the tile layout, the master column takes `tag.master_width_factor` of the available width; stack columns divide the rest.

Widget containers declare direction, padding, gaps and child sizes. Textboxes provide text and fonts. Clay computes their geometry, calling the renderer to measure text when needed.

Changing `tag.master_width_factor` changes the declared share. Clay computes the new client rectangles at the next layout pass; see the [client layout example](./clients-in-the-tree.md#see-it).

Supported `awful` and `wibox` objects translate their properties into declarations through *describer* functions. Custom client layouts using `arrange` supply explicit geometry, marked `legacy`. Custom widget `fit`, `layout` and `draw` methods are [unsupported](./widgets-in-the-tree.md).

## A defined stage in the main loop

Property changes mark the affected output dirty. At `clay::declare`, pending widget descriptions are compiled. A dirty output solves its complete tree; a clean output skips declaration and solving.

![Lua declarations become one output tree, Clay computes layout in C, and SomeWM reconciles the resulting commands into the wlroots scene.](/img/architecture/clay-frame-pipeline.svg)

The normal path runs in this order:

| Stage | Work | Code |
| --- | --- | --- |
| Deliver queued notifications | Drain a snapshot of C-generated notifications into Lua, then emit `refresh` and apply pending object updates. Synchronous callbacks retain their own dispatch rules. | `some_refresh()` in `loop.c`, `some_event_queue_drain()` in `event_queue.c` |
| Compile changed descriptions | Emit `clay::declare`; pending widgets and client layouts provide updated declarations. | `lua/wibox/drawable.lua`, `lua/wibox/clay.lua`, `lua/awful/layout/init.lua` |
| Declare and solve the output | Assemble the bar, workarea, clients and other elements between `Clay_BeginLayout` and `Clay_EndLayout`. Clay computes the boxes and produces render commands. | `declare_output_frame()` in `declare.c` |
| Publish the result | Publish solved boxes to layout and widget objects through `clay::solved`, and settle output, popup and client geometry. | `declare.c`, `lua/wibox/clay.lua` |
| Reconcile the scene | Apply the completed command array to retained scene nodes, matching them by element id. | `render_reconcile()` in `render.c` |
| Present | Commit the scene to the output. | `rendermon()` in `monitor.c`, `wlr_scene_output_commit()` |

`loop.c` runs `some_refresh()` before polling and dispatches pending Wayland idle work. Output frame callbacks call `declare_output_frame()` before presenting. A deadline fallback calls the same function if no frame callback arrives.

Changes raised during a pass mark work for a subsequent pass. The declaration function guards against recursive entry. Active transitions request further frames until they settle. [Signals](./signals.md#dispatch) explains which callbacks run before this work and which remain synchronous.

## The renderer consumes the solved result

Clay outputs a flat array of render commands with solved boxes, clipping and drawing order. `render_reconcile()` consumes that array. It creates, changes or removes scene nodes as required; unchanged commands cause no scene mutations.

The renderer draws solid rectangles, borders and rounded corners with scene rects. Text, images, paths and shadows use cached raster content. Changes to content, size, output scale or path clipping can require rebuilding a raster. Cairo and Pango serve that rendering work; a stock widget does not receive a Cairo context and paint its own surface.

Application surfaces are placed at their solved positions. Applications render their own pixels; wlroots performs the final GPU or pixman composition.

## State, layout and scene

| Structure | Responsibility | How to inspect it |
| --- | --- | --- |
| State and declarations | Object properties, content, ordering and sizing rules supplied by C and Lua. | Lua properties or `somewm-client eval` |
| Solved element tree | The boxes and relationships computed for an output. Clay retains state needed for element identity, scrolling, text measurement and transitions between passes. | `somewm-client clay tree`, `screen.inspector`, `clay::solved` |
| Retained scene | Rectangles, raster buffers and client surfaces that wlroots can draw. | The dump's `realized:` section |

Solved geometry is available for inspection, input handling and protocol updates. The [scene graph](./scene-graph.md) explains stacking order.

## What Clay is

Clay is a single-header layout library, vendored unmodified in `third_party/clay.h`; `third_party/README.clay.md` records its version and checksum. SomeWM re-declares the tree each layout pass. Clay retains identities, scroll positions and transitions between passes.

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

- **Size sources.** Each `fixed` or `percent` size is labelled `user`, `theme`, `output`, `protocol`, `legacy`, `transition` or `scroll` ([list](./reading-the-tree.md#where-a-number-comes-from)). The header's `derived` counts numbers SomeWM computed from a previous solve. It must read 0, and the test suite checks it.
- **Bands.** Everything outside the output's flow floats at a z-index assigned from state: wallpaper -4, normal client 20, pointer 32767 ([table](./scene-graph.md#bands)).
- **Describers.** Every stock `wibox` class has a function that turns its properties into declarations ([what each declares](./widgets-in-the-tree.md)).

## See it

```bash
somewm-client clay tree
```

On a headless SomeWM with the bundled config, the dump starts:

```
OK
output HEADLESS-1 scale 1.00 inspector off frames 3 elements 41/65536 map 41 free 0 inspector_input 0 bounds 0/0
  commands 23 mutations 6 created 2 swept 0 nodes 23 raster_bytes 3793424 buffers 2 declare 37us solve 36us reconcile 101us
  roots flow 1 floating 2 derived 0 legacy 0
  WALLPAPER screen 1 1280x720+0+0 converted: 5 nodes, 1 images clip w=grow h=grow row attach OUTPUT offset 0,0 band -4 box 0,0 1280x720
  ...
  Clay__RootContainer w=fixed(1280) output h=fixed(720) output row box 0,0 1280x720
    OUTPUT HEADLESS-1 w=fixed(1280) output h=fixed(720) output column box 0,0 1280x720
      WIBAR screen 1 1280x32+0+0 converted: 32 nodes, 4 images, radius 8 clip w=grow h=fixed(32) theme row box 0,0 1280x32
    6a6e2fe9     - spacer w=grow h=grow row box 0,0 582x32
    58414e45       wibox.layout.fixed w=fit h=grow row box 0,0 211x32
```

[Reading the tree](./reading-the-tree.md) explains the dump’s fields and sizing labels.
