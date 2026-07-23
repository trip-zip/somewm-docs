---
title: tag
description: The tag object, workspace selection, layout parameters, and tag history.
sidebar_position: 3
---

# tag

A tag is a named workspace on one screen: it holds a client list, a layout, and the layout's parameters. The `tag` global is the class; `tag.new{...}` creates instances, and a screen views one or more of them at a time.

```lua
screen.on("added", function(s)
  for i = 1, 5 do
    tag.new { name = tostring(i), screen = s }
  end
end)

some.key { mods = { "mod" }, key = "1-9", press = function(i)
  local t = screen.focused.tags[i]
  if t then t:view() end
end }
```

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `selected` | boolean | derived | Whether the tag is in its screen's `selected_tags`. Computed on read, never stored. Writing routes to the screen's selection, keeps the screen's tag order, and refuses a write that would empty the last selection. |
| `name` | string | nil | Display name. A rename redraws the screen even when the tag is not selected, since the taglist draws every tag. |
| `layout` | function | `some.layout.tile` | The layout function; see [layout](/kiln/reference/layout). |
| `clients` | list of clients | `{}` | The tag's client stack, in stacking order. Read only: mutate through `c.tags` writes, never directly. |
| `screen` | screen | set at `tag.new` | The tag's screen. Read only. |
| `master_width_factor` | number | 0.5 | Master area fraction, clamped to 0.05..0.95 by the layout. Writing it animates the split. |
| `master_count` | number | 1 | Clients in the master area. |
| `column_count` | number | 1 | Stack columns. |
| `gap` | number | `theme.gap` | Gap between cells, per tag. |
| `carousel_width` | number | 0.5 | Center cell fraction; read by the carousel layout only. |

Writing `layout`, `master_width_factor`, `master_count`, `column_count`, `gap`, or `carousel_width` redraws the screen when the tag is selected; the write is the whole verb, there is no separate arrange call.

## Methods

| Method | Description |
|---|---|
| `t:view()` | Exclusive select: `t.screen.selected_tags = { t }`. |
| `t:toggle()` | Multi-select: add or remove `t` from the screen's selection, keeping the screen's tag order. Refuses to empty the last selected tag. |
| `t:delete()` | Delete the tag. Clients on it are rehomed to the first surviving tag; requires at least two tags on the screen. |

## Class functions

| Method | Description |
|---|---|
| `tag.new{...}` | Create a tag. Defaults `layout` to tile, registers on `props.screen`, and auto-selects itself if it is the screen's first tag. |
| `tag.history.restore(s)` | Flip screen `s` (default: the focused screen) back to its previous selection. Selections that only name deleted tags are skipped. |
| `tag.on(name, fn)` / `tag.off(name, fn)` | Class-level signals. |

## Signals

| Signal | Payload | Emitted when |
|---|---|---|
| `property::<any>` | new value | Any tag property write that changed the value. |

Tags emit only `property::<name>` signals. Selection changes surface as `property::selected_tags` on the screen, not on the tag; listen there for tag switches. See [screen](/kiln/reference/screen).

## See also

- [screen](/kiln/reference/screen)
- [layout](/kiln/reference/layout)
- [Custom layouts](/kiln/guides/custom-layouts)
- [Tag persistence](/kiln/guides/tag-persistence)
- [Signal index](/kiln/reference/signals)
