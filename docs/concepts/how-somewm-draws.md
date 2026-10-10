---
sidebar_position: 2
title: How SomeWM draws
description: One Clay element tree per output, rebuilt and solved every frame from Lua state, reconciled into wlr_scene. What the three structures are and how to read each.
---

# How SomeWM draws

Each frame, SomeWM rebuilds one [Clay](https://github.com/nicbarker/clay) element tree per output from Lua state, solves it, and reconciles the solved boxes into wlr_scene. Bars, widgets, popups, notifications, client frames, titlebars, borders, shadows, the wallpaper and the pointer are all elements of that one tree. A client application supplies only the pixels inside its surface.

## The three structures

| Structure | What it is | Read it | Write it |
| --- | --- | --- | --- |
| **State** | The Lua objects: `client`, `tag`, `screen`, `wibox`, every widget. Lasts between frames. | Lua, or `somewm-client eval` | `rc.lua`, rules, properties |
| **Element tree** | Clay elements, one per box on the output. Rebuilt every frame; keeps nothing between frames except element ids and scroll offsets. | `somewm-client clay tree`, the inspector (`screen.inspector = true`), or the `clay::solved` signal | Stock widgets and layouts emit it. A widget with its own `draw` method is left out. |
| **Scene** | wlr_scene nodes: rects, buffers, client surfaces. | The `realized:` section of the same dump | Never. The renderer owns it. |

A fact lives in exactly one of them. A client's box is on the client object until the frame runs, is a solved element during the frame, and is a scene node position after. Nothing copies it back.

## A frame

1. A property write marks the output dirty and requests a frame. `c.floating = true`, a textbox's `text`, a tag selection: all the same path.
2. `awesome` emits `clay::declare`. Each dirty wibox compiles its widget tree to element declarations (`lua/wibox/clay.lua`), and `awful.layout` describes the selected tag's layout as a node table. C declares the output between `Clay_BeginLayout` and `Clay_EndLayout`: the bar and workarea column, every client's frame, titlebar and surface, every wibox, the wallpaper and the pointer.
3. Clay solves the tree, one context per output. Text is measured by the one `Clay_SetMeasureTextFunction` callback; nothing else measures anything.
4. The renderer reconciles Clay's render commands into the scene by element id. An unchanged node is not touched, and a frame identical to the last makes zero mutations. Each `screen` and `drawable` then receives `clay::solved` with a table of its solved boxes (`id`, `x`, `y`, `width`, `height`).

Only text, images, shape paths and shadows are rasterised, and only when their content, size or output scale changes. Rectangles, borders and rounded corners are scene rects with no buffer. An output with nothing dirty declares nothing.

## What Clay is

Clay is a single-header immediate-mode layout library, vendored unmodified at v0.14 in `third_party/clay.h`. Immediate mode means the caller re-declares the whole tree every frame; Clay retains only a hash map from element id to last frame's box, plus scroll container records. Its output is a flat array of render commands: rectangle, border, text, image, scissor start and end, and custom, which SomeWM uses for client surfaces and shape paths.

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
output HEADLESS-1 scale 1.00 inspector off frames 3 elements 39/65536 map 39 free 0 inspector_input 0 bounds 0/0
  commands 21 mutations 1 created 0 swept 0 nodes 21 raster_bytes 3789136 buffers 1 declare 185us solve 42us reconcile 142us
  roots flow 1 floating 2 derived 0 legacy 0
  WALLPAPER screen 1 1280x720+0+0 converted: 5 nodes, 1 images clip w=grow h=grow row attach OUTPUT offset 0,0 band -4 box 0,0 1280x720
  ...
  Clay__RootContainer w=fixed(1280) output h=fixed(720) output row box 0,0 1280x720
    OUTPUT HEADLESS-1 w=fixed(1280) output h=fixed(720) output column box 0,0 1280x720
      WIBAR screen 1 1280x32+0+0 converted: 30 nodes, 2 images, radius 8 clip w=grow h=fixed(32) theme row box 0,0 1280x32
    6a6e2fe9     - spacer w=grow h=grow row box 0,0 580x32
    20c65f54       wibox.layout.fixed w=fit h=grow row box 0,0 211x32
```

One root is in the flow: `OUTPUT`, a column of the bar and the workarea. Every other root floats at a band. An element line is id, name, sizing per axis with its source word, direction, padding and gap, then the solved box. [Reading the tree](./reading-the-tree.md) walks a whole dump.
