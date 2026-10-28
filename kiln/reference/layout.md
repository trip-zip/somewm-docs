---
title: kiln.layout
description: The layout contract, the nine built-in layout families and their variants, and the tag properties they read.
sidebar_position: 10
---

# kiln.layout

A layout is a function `(clients, area, tag)` called during a frame. The first
selected tag supplies the layout and its parameters for all selected tags on
that screen. Assigning `t.layout` changes the next frame when `t` is first in
the selection.

```lua
local kiln = require("kiln")

-- at creation
tag.new { name = "www", screen = screen.focused, layout = kiln.layout.fair }

-- or switch a tag later, variants included
screen.focused.selected_tag.layout = kiln.layout.corner.se
```

## The layout contract

| Argument | Meaning |
|---|---|
| `clients` | The eligible tiled clients from all selected tags, deduplicated in selection order, then each tag's client order. Eligible sticky clients are appended in screen tag order. See [visibility](./client.md#membership-and-visibility). |
| `area` | The workarea box from the last solve, inset by the gap: `{ x, y, width, height }`. Most layouts ignore it; carousel and magnifier use it for their arithmetic. |
| `tag` | The first selected tag, which supplies the layout parameters for the whole list. |

The function declares elements (usually `kiln.widgets.client` cells inside `ui.row`/`ui.column` containers) and returns nothing. Most layouts compute no positions: a layout describes structure, and the solver produces the pixels.

## How layouts tile

Built-in layouts express tiling as sizing declarations, not arithmetic. A cell is `"grow"` when it should take an equal share, or `"N%"` when a factor applies (the master's `master_width_factor` becomes a percent width), and the Clay solver divides the workarea among the declared cells. Splitting a region in half is just declaring two grow children; a master beside a stack is a percent cell beside a grow cell. See [Custom layouts](/kiln/guides/custom-layouts) and [One tree per screen](/kiln/concepts/one-tree).

## The families

| Layout | Variants | Description |
|---|---|---|
| `layout.tile` | `.left`, `.top`, `.bottom` | Master area at `master_width_factor` beside a stack of the rest. The suffix names where the stack goes: bare `tile` stacks on the right, `tile.left` on the left, `tile.top` above, `tile.bottom` below. `master_count` clients share the master; `column_count` splits the stack into columns. |
| `layout.fair` | `.horizontal` | Balanced grid: `ceil(sqrt(n))` columns, earlier columns fill first, every cell an equal grow share. `.horizontal` builds rows instead. |
| `layout.spiral` | | Each client takes half of what remains, the split axis alternating with depth, winding inward. |
| `layout.dwindle` | | Same halving, always splitting toward the bottom-right. |
| `layout.corner` | `.nw`, `.ne`, `.sw`, `.se` | Master fills one corner at the factor on both axes, with one stack down the far vertical edge and one across the far horizontal edge; remaining clients alternate between the two. Bare `corner` is `.nw`. |
| `layout.magnifier` | | Unfocused clients tile behind as a column; the focused client floats centered over them at `master_width_factor` of the area's size. |
| `layout.carousel` | | A clipped strip of fixed-width columns, scrolled so the focused client is centered. Column width is `carousel_width` of the workarea. |
| `layout.max` | | One client fills the workarea: the focused one if present, else the first. The others stay alive, just not declared. |
| `layout.floating` | | Every client floats at its remembered position and size; nothing tiles. |

Missing pieces degrade cleanly: a tile with no stack grows the master over the whole area, a corner with one client is max.

## Tag properties layouts read

Layout parameters are plain tag properties. Set them per tag; each has a default so an unconfigured tag tiles sensibly.

| Property | Default | Read by |
|---|---|---|
| `t.master_width_factor` | 0.5 | tile, corner, magnifier (clamped to 0.05..0.95) |
| `t.master_count` | 1 | tile |
| `t.column_count` | 1 | tile |
| `t.gap` | `theme.gap` (8) | all tiling layouts, as the space between cells |
| `t.carousel_width` | 0.5 | carousel |

## Module helpers

| Function | Description |
|---|---|
| `layout.name(fn)` | The display name of a layout function, variants included: a tag on `tile.left` names as `"tile.left"`. Only the stock families have names: for a custom layout it returns nil (the stock `kiln.widgets.layoutbox` then shows `?`). |
| `layout.next(fn)` | The layout after `fn` in the cycle order; from a variant (or anything not in the list) it restarts the list. |
| `layout.list` | The cycle order, one entry per family. A config can replace it: `kiln.layout.list = { kiln.layout.tile, kiln.layout.max }`. |

`kiln.widgets.layoutbox` and `kiln.widgets.layoutlist` are built on these three.

## See also

- [Custom layouts](/kiln/guides/custom-layouts)
- [One tree per screen](/kiln/concepts/one-tree)
- [tag](/kiln/reference/tag)
- [kiln.ui](/kiln/reference/ui)
