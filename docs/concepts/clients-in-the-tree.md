---
sidebar_position: 5
title: Clients and layouts in the same tree
description: How Clay lays out window frames, titlebars and application surfaces.
---

# Clients and layouts in the same tree

A tag’s layout is a subtree under `WORKAREA`, using [the same sizing modes as widgets](./reading-the-tree.md#sizing). Each client has a frame, titlebars, a slot, and an application surface attached to that slot.

## A layout is a tree

`awful.layout` describes the selected tag's layout as a node table at each frame's `clay::declare`, and the screen receives the solved boxes at `clay::solved`. Each stock suite declares:

| Suite | Declares |
| --- | --- |
| `tile` | the workarea as a row. The master column is `master_width_factor` as a `percent`, marked `user`. The stack columns `grow` |
| `fair`, `corner` | cells sized by `percent` |
| `max` | every tiled client in the same box, the whole workarea, in stacking order |
| `carousel` | a scroll container of columns, each a percent of the viewport. Clay keeps the scroll offset ([Scrollable tiling](./scrollable-tiling.md)) |
| `floating` | nothing. Every client stays at its own box |

The tag’s useless gap sets the workarea’s padding and gaps.

Custom layouts using `arrange` still work. SomeWM converts their client geometry, minus border and gap, into floating elements labelled `legacy`. The dump header counts them.

## A client is a few elements

| Element | Declares |
| --- | --- |
| `CLIENT` | the frame: a column with the layout's sizing. Border padding belongs to `CHROME` and `PROBE` when present, otherwise to `CLIENT`. A floating client's frame has explicit geometry, marked `user`. A fullscreen one `grow`s to the output. |
| `TITLEBAR`, `TITLEBAR_LEFT`, `_RIGHT`, `_BOTTOM` | widget trees like a wibar's. A top or bottom bar spans the frame's width and a side bar its height. Its thickness is `fixed`, marked `theme`. |
| `SLOT` | `grow`s into what is left inside the frame |
| `SURFACE` | the client's pixels: a floating element attached to the slot at the client's band, with the client's size hints as `min` and `max`, marked `protocol` |

When a client draws at a different size from the one requested, the frame adds two elements:

- `CHROME` fits the drawn size and clips the titlebars and surface at the frame’s top-left corner. Drawing is clipped at the layout cell. It does not enlarge the cell or workarea.
- `PROBE` is invisible at band 0. It represents the requested size minus borders and titlebars, with size hints on a `CONFIGURE` leaf.

Terminals commonly differ from the requested size because they snap to a character grid.

## Floating, fullscreen, ontop, and order

Floating clients use their own geometry plus border, marked `user`. Fullscreen clients grow to `OUTPUT`. Tiled clients remain in their layout slots when marked ontop, above or below. Only their surface band changes. See [stacking exceptions for max and magnifier](./scene-graph.md#stacking-within-a-band).

Bands determine drawing order. [the client stack](./client-stack.md) orders clients within a band. See the [band table](./scene-graph.md#bands).

## Corners, borders, shadows and motion

See [Rounded Corners](../guides/rounded-corners.md) to set a client radius with a rule.

- `client.shape` is nil, a corner radius in pixels, or a `gears.shape` function. `gears.shape.rounded_rect`, or a function that draws its path, is read as that radius. Any other function warns once and the client stays square.
- A titlebar on an edge takes that edge's corners and the surface takes the rest, each less the border width. The border stays square.
- A shadow is drawn by the renderer around the frame's solved box. It declares no box and takes no room from the slot.
- With `theme.animation_layout_duration` above 0, each frame declares a Clay transition on the client's box, and Clay moves it over that duration. At 0, a client snaps to its new box in one frame. [Animation](../guides/animation.md) has the client, wibox and widget triggers.

## See it

With the bundled config, two `foot` terminals and `awful.layout.suit.tile`, run `somewm-client clay tree`. This excerpt shows the first client, with titlebar widgets omitted:

```text
WORKAREA - w=grow h=grow row pad 8,8,8,8 gap 8 box 0,32 1280x688
  CLIENT foot w=percent(0.5) user h=grow column box 8,40 628x672
    CHROME_CUT foot w=percent(1) theme h=percent(1) theme column box 8,40 628x672
      CHROME foot w=fit h=fit column pad 2,2,2,2 box 8,40 628x662
        ...
        SLOT foot w=fixed(624) protocol h=fixed(637) protocol row box 10,63 624x637
...
PROBE foot w=grow h=grow column pad 2,2,2,2 attach PARENT offset 0,0 band 0 box 8,40 628x672
  PROBE_TOP foot w=grow h=fixed(21) theme row box 10,42 624x21
  PROBE_SLOT foot w=grow h=grow row box 10,63 624x647
...
SURFACE foot w=fixed(624) protocol h=fixed(637) protocol attach PARENT offset 0,0 band 20 custom box 10,63 624x637
CONFIGURE foot w=grow>=6 protocol h=grow>=13 protocol attach PARENT offset 0,0 band 20 custom box 10,63 624x647
```

The layout cell is 628 by 672. Subtracting borders and the 21-pixel titlebar leaves the requested content area, `PROBE_SLOT`, at 624 by 647. Foot commits 624 by 637 to fit its character grid. `SLOT`, `SURFACE` and `CHROME` reflect that smaller result, while `CHROME_CUT` clips it to the layout cell. Font and theme settings change the exact measurements.

Change the split:

```bash
somewm-client eval 'screen.primary.selected_tag.master_width_factor = 0.6'
```

The client cells become:

```text
CLIENT foot w=percent(0.6) user h=grow column box 8,40 754x672
CLIENT foot w=grow h=grow column box 770,40 502x672
```

754 is 0.6 of the 1256 pixels available after padding and gaps, rounded to pixels.
