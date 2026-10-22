---
sidebar_position: 3
title: Reading the tree
description: The sizing words Clay solves, which AwesomeWM property declares each, where every number comes from, and how to read a dump or the inspector line by line.
---

# Reading the tree

`somewm-client clay tree` prints each output's [solved element tree](./how-somewm-draws.md) and render commands from the last frame. `screen.inspector = true` shows the tree over that screen.

## Sizing

Each axis uses one of four sizing modes:

| Dump | Meaning |
| --- | --- |
| `fit` | the content: measured text, the image, or the children plus padding and gaps (`CLAY_SIZING_FIT`) |
| `grow` | what is left in the parent after its other children, shared among growing siblings (`CLAY_SIZING_GROW`) |
| `fixed(N)` | an explicit size (`CLAY_SIZING_FIXED`) |
| `percent(N)` | a share of the parent (`CLAY_SIZING_PERCENT`) |

`fit` and `grow` support minimum and maximum sizes: `fit>=32` is at least 32, and `grow<=200` is at most 200. Direction (`row` or `column`), `gap`, `pad l,r,t,b`, and alignment place the children.

What you write in `rc.lua` declares them:

| You write | It declares |
| --- | --- |
| `wibox.layout.fixed` | children fit along the row or column and grow across it; with `fill_space`, the last child also grows along it |
| `wibox.layout.flex` | children grow on both axes and share the length equally; a child wider than its share keeps its width; `max_widget_size` caps each |
| `wibox.layout.align` | three slots. `expand = "inside"` (default): outer two fit, middle grows. `"outside"`: middle fits, outer two grow. `"none"`: all three fit, each outer one at its edge of a growing box, so the middle centres in the whole length |
| `spacing` | the gap, unless a `spacing_widget` is set, which then sits between the children |
| `wibox.container.margin` | padding from `left`, `right`, `top`, `bottom`; the child fills what is inside |
| `wibox.container.constraint` | from `width` and `height`: a cap with `strategy = "max"` (default), a floor with `"min"`, an explicit size with `"exact"` |
| `wibox.container.place` | alignment of its child (`halign`, `valign`, centred by default); the child fits unless `content_fill_*` makes it grow; the place grows where `fill_*` says |
| `wibox.container.background` | no size of its own: a fill, a corner radius and a border around a child that fills it; `border_strategy = "inner"` adds the border width as padding |
| `forced_width`, `forced_height` | an explicit size; where the parent makes that axis grow, it becomes a floor instead |
| a wibar's `height` | an explicit size, from `beautiful.wibar_height` in the bundled config |

## Where a number comes from

Each `fixed` or `percent` size is labelled with its source:

| Word | Source |
| --- | --- |
| `user` | you, a rule or a property: a wibox's `width`, a `forced_width`, a constraint's `width`, a floating client's box |
| `theme` | a beautiful value, or a size a stock part takes from the theme: a bar's height, a titlebar's thickness |
| `output` | the output's mode or scale |
| `protocol` | the client's own request: size hints, or the size it committed |
| `legacy` | a layout written with `arrange` computed it from a box it read ([Clients in the tree](./clients-in-the-tree.md#a-layout-is-a-tree)) |
| `transition` | the current value of an animation Clay keeps for that box |
| `scroll` | Clay's scroll record: a scrollbar thumb's length, a clip's offset |

Bare `fit` and `grow` sizes have no source label. The header's `derived` count tracks sizes SomeWM computed from a previous solve; it is 0 in stock configs.

An explicit size, minus padding, bounds a child that grows across the parent's flow or is its only child. A `fit` ancestor makes this a maximum; a `percent` ancestor stops propagation. Children growing along the flow beside siblings receive no such bound; Clay computes their shares.

For example, a 32-pixel bar sets a square icon's height through its growing ancestors. The icon's aspect ratio then sets its width to 32, shown as `w=fit>=32 theme`.

Clay computes geometry for elements in the flow, including tiled clients, widgets, and bars. Floating elements use a band and explicit geometry: `user` for wiboxes and floating clients, `theme` or `protocol` for the pointer. A popup attached to a widget is sized by its content.

## The dump

### Header

```
output HEADLESS-1 scale 1.00 inspector off frames 3 elements 41/65536 map 41 free 0 inspector_input 0 bounds 0/0
  commands 23 mutations 6 created 2 swept 0 nodes 23 raster_bytes 3793424 buffers 2 declare 37us solve 36us reconcile 101us
  roots flow 1 floating 2 derived 0 legacy 0
```

- Line 1: the output, its scale, whether the inspector is open, how many frames it has declared, and `elements` used of the per-output budget. `map` and `free` are Clay's element-id table and its freed slots. `inspector_input` and `bounds` are zero until the inspector opens.
- Line 2: the last frame. `commands` from the solve, `mutations` the renderer made to the scene, nodes `created` and `swept`, current `nodes`, raster memory in `raster_bytes`, `buffers` rastered this frame, and the time of each step.
- Line 3: roots in the flow and floating, and the two counts that must be 0: `derived` and `legacy`.

Dump twice with nothing changed and `frames` does not move: an output with nothing dirty is not declared.

### Roots

```
  WALLPAPER screen 1 1280x720+0+0 converted: 5 nodes, 1 images clip w=grow h=grow row attach OUTPUT offset 0,0 band -4 box 0,0 1280x720
  Clay__RootContainer w=fixed(1280) output h=fixed(720) output row box 0,0 1280x720
    OUTPUT HEADLESS-1 w=fixed(1280) output h=fixed(720) output column box 0,0 1280x720
      WIBAR screen 1 1280x32+0+0 converted: 32 nodes, 4 images, radius 8 clip w=grow h=fixed(32) theme row box 0,0 1280x32
      WORKAREA - w=grow h=grow row pad 8,8,8,8 gap 8 box 0,32 1280x688
  SURFACE CLIENT_1 w=grow h=grow attach PARENT offset 0,0 band 20 custom box 10,72 624x638
  cursor left_ptr w=fixed(24) theme h=fixed(24) theme attach ROOT offset 97,99 band 32767 image box 97,99 24x24
```

A root line is its role in capitals and the object: `WIBAR screen 1`, `SURFACE CLIENT_1`, `cursor left_ptr`. One root is in the flow, `OUTPUT`: a column of the bars and the `WORKAREA` between them, with the workarea filling the remaining space. Every other root floats: `attach` is what it is placed against, `offset` its position from there, `band` its z-index ([table](./scene-graph.md#bands)). A wibox root reports `converted: N nodes, M images` from its widget tree, `radius` from its shape, and `clip` when it cuts its content. The geometry after the object is what `wibox:geometry()` reports.

### Elements

```
    b8e72127     wibox.container.margin w=fit h=grow row pad 0,0,6,6 box 580,0 120x32
    0835a631       wibox.container.background clip w=fit h=grow row pad 8,8,0,0 box 580,6 120x20
    a4ba44de         wibox.widget.textbox w=fit h=grow row box 588,6 104x20
    5a1614a8           text "Sun Oct 11  16:11" font=2 box 588,6 104x20
```

Each element line lists:

- The id: eight hex digits, stable while the widget exists.
- The widget class or role, such as `text_role`; `- spacer` means no associated widget.
- `w=` and `h=`, including minimum, maximum, and source labels.
- Direction, padding, gap, and clipping or image dimensions.
- `box x,y WxH`: the computed position and size.

Text lines show the content and font id.

The clock's margin is 120 × 32. Vertical padding of 6 leaves the background 20 pixels tall at y=6. Horizontal padding of 8 leaves 104 pixels for the text: 104 + 8 + 8 = 120.

### The realized list

```
  realized:
  b334a95b RECTANGLE     z=0    box 0,0 1280x720 rbox 0,0 1280x720 output HEADLESS-1
  63d73290 CUSTOM        z=-    box 0,0 1280x720 rbox 0,0 1280x720 drawin screen 1 1280x720+0+0 clip
  63d73290 SCISSOR_START z=-    box 0,0 1280x720 rbox 0,0 1280x720 drawin screen 1 1280x720+0+0
  f767848d CUSTOM        z=-    box 0,0 1280x720 rbox 0,0 1280x720 widget wibox.container.background raster=3686400
  c1b0daaa IMAGE         z=-    box 540,260 91x200 rbox 540,260 91x200 widget image image raster=72800
  08efd078 SCISSOR_END   z=-    box 0,0 0x0 rbox 0,0 0x0 -
  7c2c5897 SCISSOR_START z=-    box 0,0 1280x32 rbox 0,0 1280x32 drawin screen 1 1280x32+0+0
  7c2c5897 RECTANGLE     z=0    box 0,0 1280x32 rbox 0,0 1280x32 drawin screen 1 1280x32+0+0
```

The realized list contains one line per render command, in draw order, with the originating element id.

- `RECTANGLE` and `BORDER` use scene rectangles without raster buffers. Only rectangles report their band as `z=`.
- `TEXT` and `IMAGE` use rasters; `raster=` reports their bytes.
- `CUSTOM` represents a client surface, shadow, or clipped fill. Entries ending in `clip` or `configure` are markers without scene nodes.
- `SCISSOR_START` and `SCISSOR_END` delimit clipping. `rbox` is the box after clipping.

## A worked example

```lua
local wibox = require("wibox")
local sample = wibox {
    x = 100, y = 100, width = 400, height = 48, visible = true, bg = "#282828",
    widget = {
        layout = wibox.layout.fixed.horizontal,
        spacing = 8,
        { widget = wibox.container.margin, left = 6, right = 6,
            { widget = wibox.widget.textbox, text = "padded" } },
        { widget = wibox.widget.textbox, text = "told", forced_width = 80 },
        { widget = wibox.container.constraint, width = 60,
            { widget = wibox.widget.textbox, text = "capped at sixty" } },
    },
}
```

Its lines in the dump:

```
  drawin screen 1 400x48+100+100 converted: 9 nodes, 0 images clip w=fixed(400) user h=fixed(48) user row gap 8 attach ROOT offset 100,100 band 25 box 100,100 400x48
    8528b9a3 wibox.container.margin w=fit h=grow row pad 6,6,0,0 box 100,100 59x48
    e379425f   wibox.widget.textbox w=fit h=grow row box 106,100 47x48
    36061abd     text "padded" font=2 box 106,114 47x20
    d9d82f15 wibox.widget.textbox w=fixed(80) user h=grow row box 167,100 80x48
    11ae8672   text "told" font=2 box 167,114 25x20
    86891c6e wibox.container.constraint w=fit<=60 user h=grow row box 255,100 60x48
    ed32d5ca   wibox.widget.textbox w=fit h=grow row box 255,100 60x48
    0b2afadd     text "capped at sixty" font=2 box 255,104 60x40
```

- The `drawin` line is the wibox: `w=fixed(400) user h=fixed(48) user` from `width` and `height`, `row gap 8` from the fixed layout and `spacing`, floating at `band 25` with `offset 100,100` from `x` and `y`.
- The margin's `pad 6,6,0,0` is `left = 6, right = 6`. It fits along the row and grows across it, as every child of a fixed layout does, so the textbox inside fits: 47 wide for "padded".
- `w=fixed(80) user` is `forced_width = 80`. The word is 25 wide; the box is 80.
- `w=fit<=60 user` is the constraint's `width = 60`. The text fits but never past 60, so Clay wraps it at the word: `60x40`, two lines.

## The inspector

```lua
screen.primary.inspector = true
```

opens Clay's debug view on that screen: one row per element, the selected element's box, sizing, padding, alignment and colours, and a highlight on the desktop over the element under the pointer. [`somewm.inspector.toggle()`](../reference/screen.md#somewminspector) flips it from a keybinding. Its colours, width and font are the `beautiful.inspector_*` variables ([Theme Variables](../reference/beautiful/theme-variables.md)).

The panel is part of the tree, at band 32765, so the header grows while it is open:

```
output HEADLESS-1 scale 1.00 inspector on frames 9 elements 663/65536 map 663 free 0 inspector_input 48 bounds 2912/3008
```

`inspector_input` is how many elements the desktop declared before the panel. `bounds` is the budget the panel was admitted under: eighteen elements and twenty bytes of row text per input element, plus a reserve of 2048 each. A desktop too large for that budget gets no panel; the log says so and `screen.inspector` reads false.

## When something is wrong

- **A widget is missing.** It is not in the tree at all. The log has a line ending `is left out of the tree` naming the class and why ([the cases](./widgets-in-the-tree.md#a-widget-that-paints-itself)).
- **A widget is the wrong size.** Read its source label and parent's line. `fit>=32` has a minimum of 32; `grow` shares available space with siblings.
- **A property does nothing.** Look for a `wibox.clay:` warning naming it; the warning identifies the unsupported value and what happened instead.
- **A client is somewhere odd.** Find its `CLIENT` line under `WORKAREA`, or its `SURFACE` root if it floats, and read the band and the source word on its box.
