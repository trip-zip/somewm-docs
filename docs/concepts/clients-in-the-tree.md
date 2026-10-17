---
sidebar_position: 5
title: Clients and layouts in the same tree
description: A tag's layout is a Clay subtree under WORKAREA. Each client is a frame, titlebars, a slot and a floating surface, sized by the same words a widget uses and stacked by band.
---

# Clients and layouts in the same tree

A tag's layout is a subtree under the output's `WORKAREA` element, declared with [the same sizing words a widget uses](./reading-the-tree.md#sizing). Each client in it is a few elements: a frame, its titlebars, a slot, and a surface that floats over the slot. Even the size a client asks for is declared in the tree; the only thing that comes from outside it is the surface's pixels.

## A layout is a tree

`awful.layout` describes the selected tag's layout as a node table at each frame's `clay::declare`, and the screen receives the solved boxes at `clay::solved`. Each stock suite declares:

| Suite | Declares |
| --- | --- |
| `tile` | the workarea as a row; the master column is `master_width_factor` as a `percent`, marked `user`; the stack columns `grow` |
| `fair`, `corner`, `carousel` | cells sized by `percent` |
| `max` | every tiled client in the same box, the whole workarea, in stacking order |
| `carousel` | a scroll container of columns, each a percent of the viewport; Clay keeps the scroll offset ([Scrollable tiling](./scrollable-tiling.md)) |
| `floating` | nothing; every client stays at its own box |

The workarea's padding and gap are the tag's useless gap. Its box starts under the bar because the output is a column of bar and workarea, not a subtraction.

A layout of your own written the AwesomeWM way, with an `arrange` function that writes a geometry onto each client, still works. SomeWM calls it, reads each box it wrote, less border and gap, and declares each client floating at that box with its numbers marked `legacy`. The dump header counts them under `legacy`.

## A client is a few elements

| Element | Declares |
| --- | --- |
| `CLIENT` | the frame: a column with the layout's sizing. Border padding belongs to `CHROME` and `PROBE` when present, otherwise to `CLIENT`. A floating client's frame carries its own box, marked `user`; a fullscreen one `grow`s to the output. |
| `TITLEBAR`, `TITLEBAR_LEFT`, `_RIGHT`, `_BOTTOM` | widget trees like a wibar's. A top or bottom bar spans the frame's width and a side bar its height; its thickness is `fixed`, marked `theme`. |
| `SLOT` | `grow`s into what is left inside the frame |
| `SURFACE` | the client's pixels: a floating element attached to the slot at the client's band, carrying the client's size hints as `min` and `max`, marked `protocol` |

When a client commits a size other than the one it was configured, the frame holds two more things. A `CHROME` element, a clip that fits the drawn size, wraps the titlebars and the surface at that size from the frame's top left. A `PROBE`, floating at band 0 and invisible, is the frame less border and bars: the size the client is being configured to, with the hints on a `CONFIGURE` leaf. The drawn size is cut at the cell and never grows the cell, the row or the workarea. Terminals do this on every resize, since they snap to their cell grid.

## Floating, fullscreen, ontop, and order

A layout does not take a floating client. It floats as a root of its own at its geometry plus border, marked `user`. A fullscreen client has `w=grow h=grow`, attached to `OUTPUT`. An ontop, above or below client under a stock layout tiles into its slot like any other; only its surface's band changes. Under `max` and `magnifier`, a floating client is above the layout's clients whatever the raise order, and a transient of such a client is above every client of that layout.

The scene draws roots in band order, lowest first: a below client at 10, a normal client at 20, above at 30, fullscreen at 40, ontop at 50 ([all bands](./scene-graph.md#bands)). Two clients in the same band are ordered by [the client stack](./client-stack.md).

## Corners, borders, shadows and motion

See [Rounded Corners](../guides/rounded-corners.md) to set a client radius with a rule.

- `client.shape` is nil, a corner radius in pixels, or a `gears.shape` function. `gears.shape.rounded_rect`, or a function that draws its path, is read as that radius. Any other function warns once and the client stays square.
- A titlebar on an edge takes that edge's corners and the surface takes the rest, each less the border width. The border stays square.
- A shadow is drawn by the renderer around the frame's solved box. It declares no box and takes no room from the slot.
- With `theme.animation_layout_duration` above 0, each frame declares a Clay transition on the client's box, and Clay moves it over that duration. At 0, a client snaps to its new box in one frame. [Animation](../guides/animation.md) has the client, wibox and widget triggers.

## See it

On a headless SomeWM with the bundled config, the tag's layout set to `awful.layout.suit.tile` and two `foot` terminals open, `somewm-client clay tree` prints under the workarea (titlebar widgets cut):

```
      WORKAREA - w=grow h=grow row pad 8,8,8,8 gap 8 box 0,32 1280x688
        CLIENT foot w=percent(0.5) user h=grow column box 8,40 628x672
          CHROME foot w=fit h=fit column pad 2,2,2,2 box 8,40 624x663
            TITLEBAR foot converted: 13 nodes, 4 images clip w=grow h=fixed(30) theme row box 10,42 620x30
...
            SLOT foot w=fixed(620) protocol h=fixed(629) protocol row box 10,72 620x629
        CLIENT foot w=grow h=grow column box 644,40 628x672
          CHROME foot w=fit h=fit column pad 2,2,2,2 box 644,40 624x663
...
  PROBE foot w=grow h=grow column pad 2,2,2,2 attach PARENT offset 0,0 band 0 box 8,40 628x672
    PROBE_TOP foot w=grow h=fixed(30) theme row box 10,42 624x30
    PROBE_SLOT foot w=grow h=grow row box 10,72 624x638
...
  SURFACE foot w=fixed(620) protocol h=fixed(629) protocol attach PARENT offset 0,0 band 20 custom box 10,72 620x629
  CONFIGURE foot w=grow>=5 protocol h=grow>=17 protocol attach PARENT offset 0,0 band 20 custom box 10,72 624x638
```

- `w=percent(0.5) user` on the first `CLIENT` is the tag's `master_width_factor`; `w=grow` on the second is the stack taking what the master leaves. Both are 672 tall: the workarea's 688 less its padding.
- `PROBE_SLOT ... 624x638` is the cell the client is configured to: 628 by 672 less the 2-pixel border on each side and the 30-pixel titlebar. `CONFIGURE` carries foot's size hints, a minimum of 5 by 17.
- `SLOT ... w=fixed(620) protocol h=fixed(629) protocol` and the `SURFACE` are the size foot actually drew, snapped to its cell grid, so `CHROME` fits 624 by 663 around it and the last few pixels of the cell stay empty.

Then:

```
somewm-client eval 'screen.primary.selected_tag.master_width_factor = 0.6'
```

and dump again:

```
        CLIENT foot w=percent(0.6) user h=grow column box 8,40 754x672
        CLIENT foot w=grow h=grow column box 770,40 502x672
```

754 is 0.6 of the 1256 pixels left in the row after its padding and gap. The number in the tree is the number you set; nothing between the property and the solve computed a rectangle from it.
