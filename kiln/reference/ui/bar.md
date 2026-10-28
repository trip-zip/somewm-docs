---
title: kiln.ui.bar
description: Register an edge bar and reserve workarea.
---

# kiln.ui.bar

Registers `fn` as a bar on screen `s`. The bar reserves workarea on its edge.
Call once during config setup, outside declarations.

```lua
ui.bar(s, { edge = "top" }, function()
  kiln.widgets.taglist(s)
  ui.spacer()
  kiln.widgets.clock()
end)
```

## Options

Accepts the [element options](./common.md#element-options) with these defaults
and additions:

| Field | Default | Meaning |
|---|---|---|
| `edge` | `"top"` | `"top"`, `"bottom"`, `"left"` or `"right"`. An invalid edge raises. |
| `band` | `"above"` | Stacking band. |
| `dir` | from the edge | `"row"` for top and bottom, `"column"` for left and right. |
| `h` (top/bottom), `w` (left/right) | `theme.bar_height` | The across-edge axis. The along-edge axis is always `"grow"`; only it and the bar's id are forced. |
| `pad` | `{ x = 8 }` horizontal, `{ y = 8 }` vertical | Padding on the along axis. |
| `gap` | 6 | Space between cells. |
| `align` | cross-axis center | `{ y = "center" }` on a row, `{ x = "center" }` on a column. |
| `color` | `theme.bg` | Background. |

Defaults are read each frame. Changes to `theme.bg` or `theme.bar_height` apply
on the next frame to bars that left those fields unset.

Use `h` for horizontal bar thickness and `w` for vertical bar thickness.
There is no `height` field. Unknown fields are ignored.
