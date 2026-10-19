---
sidebar_position: 2
title: How SomeWM draws
description: How pending state changes become one output layout, computed by Clay in C and passed as render commands to the scene renderer.
---

# How SomeWM draws

SomeWM computes client and widget layout in the same C layout pass. Lua supplies the state and layout declarations. [Clay](https://github.com/nicbarker/clay) resolves those declarations into boxes and render commands, and SomeWM's renderer applies the result to `wlr_scene` before wlroots presents it.

Bars, widgets, popups, notifications and client frames participate in that pass. An application still renders the pixels inside its own surface; Clay computes where that surface and its decorations belong.

## What computing layout means

A native layout supplies relationships and constraints, rather than a finished rectangle for every child. The output is a column containing its bar and workarea. The bar has a declared height; the workarea grows into the remaining space. Inside the workarea, a tiled master column takes `tag.master_width_factor` of the available width and the stack takes the rest.

A widget container uses the same computation. It supplies a direction, padding, gaps and child sizing rules. A textbox supplies text and a font. Clay resolves the container's dimensions and the children's positions, using the renderer's text-measurement callback when it needs text dimensions.

For example, changing `tag.master_width_factor` from `0.5` to `0.65` changes the share declared by the stock tile layout. Lua does not calculate each client's new x coordinate and width. At the next layout pass, Clay computes the client boxes from that share, the workarea and its gaps. The [client layout example](./clients-in-the-tree.md#see-it) shows the property and its solved boxes in the dump.

Your configuration still composes supported `awful` and `wibox` objects. Their describers translate properties into declarations. Custom client layouts using `arrange` retain a compatibility path: their calculated rectangles enter the tree as explicit geometry, marked `legacy`. Custom widget `fit`, `layout` and `draw` methods are [not part of this path](./widgets-in-the-tree.md).

## A defined stage in the main loop

A property change records state and marks the affected output dirty. Dirty widget descriptions are compiled at the frame's `clay::declare` boundary. A clean output skips declaration and solving; a dirty output declares and solves its complete tree. Dirty tracking avoids unnecessary compilation, but does not mean Clay solves isolated dirty nodes independently.

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

The GLib prepare source in `loop.c` runs `some_refresh()` before polling and dispatches pending Wayland idle work. Output frame callbacks enter `declare_output_frame()` before presenting; a deadline fallback can enter the same pass if the backend has not supplied a frame callback. Both use the same declaration, solve and reconciliation function. There is no separate widget painting loop alongside it.

Changes raised during a pass mark work for a subsequent pass. The declaration function guards against recursive entry. Active transitions request further frames until they settle. [Signals](./signals.md#dispatch) explains which callbacks run before this work and which remain synchronous.

## The renderer consumes the solved result

Clay outputs a flat array of render commands with solved boxes, clipping and drawing order. `render_reconcile()` consumes that array. It creates, changes or removes scene nodes as required; unchanged commands cause no scene mutations.

The renderer draws solid rectangles, borders and rounded corners with scene rects. Text, images, paths and shadows use cached raster content. Changes to content, size, output scale or path clipping can require rebuilding a raster. Cairo and Pango serve that rendering work; a stock widget does not receive a Cairo context and paint its own surface.

Client surface commands attach application content at the solved positions. The compositor controls the frame and placement; the application controls its pixels. The final GPU or pixman composition remains wlroots' responsibility. Clay computes layout, SomeWM reconciles the scene, and wlroots presents it.

## State, layout and scene

| Structure | Responsibility | How to inspect it |
| --- | --- | --- |
| State and declarations | Object properties, content, ordering and sizing rules supplied by C and Lua. | Lua properties or `somewm-client eval` |
| Solved element tree | The boxes and relationships computed for an output. Clay retains state needed for element identity, scrolling, text measurement and transitions between passes. | `somewm-client clay tree`, `screen.inspector`, `clay::solved` |
| Retained scene | Rectangles, raster buffers and client surfaces that wlroots can draw. | The dump's `realized:` section |

Solved geometry is published back to objects for inspection, input handling and protocol updates. That readback exposes the result of the layout pass; it does not run an independent layout algorithm. The [scene graph](./scene-graph.md) explains how declared stacking order becomes scene order.

## What Clay is

Clay is a single-header immediate-mode layout library, vendored unmodified in `third_party/clay.h`. The exact pin and checksum are recorded in `third_party/README.clay.md`. Immediate mode means SomeWM re-declares the output tree for each layout pass. Clay retains the state needed to connect successive passes, including element identities, scroll positions and transitions.

The dump and these pages use Clay's model with short words:

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

Clay's limits are SomeWM's limits:

| Budget | Value | Where |
| --- | --- | --- |
| elements per output | 65536 | `CLAY_ELEMENTS_MAX`, printed as `elements N/65536` |
| nodes per wibox | 4096 | `WIDGET_NODES_MAX`; a larger wibox shows nothing and warns |
| scroll containers per output | 100 | `WIDGET_SCROLLS_OUTPUT_MAX` |

## What SomeWM adds

- **A source word on every number.** Each `fixed` or `percent` size says who chose it: `user`, `theme`, `output`, `protocol`, `legacy`, `transition` or `scroll` ([list](./reading-the-tree.md#where-a-number-comes-from)). The header's `derived` counts numbers SomeWM computed from a previous solve. It must read 0, and the test suite checks it.
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

One root is in the flow: `OUTPUT`, a column of the bar and the workarea. Every other root floats at a band. An element line is id, name, sizing per axis with its source word, direction, padding and gap, then the solved box. [Reading the tree](./reading-the-tree.md) walks a whole dump.
