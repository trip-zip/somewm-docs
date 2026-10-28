---
title: screen
description: The screen object, tag selection, workarea, scale, and output lifecycle signals.
sidebar_position: 4
---

# screen

A screen is one output. The `screen` global is the class; instances appear when outputs are added and carry the tag selection, the workarea, and the bars a config registers. A config builds its per-monitor world in the `added` signal.

```lua
screen.on("added", function(s)
  tag.new { name = "1", screen = s }
  tag.new { name = "2", screen = s }
  kiln.ui.bar(s, { edge = "top" }, function()
    kiln.widgets.taglist(s)
    kiln.ui.spacer()
    kiln.widgets.clock()
  end)
end)
```

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `workarea` | table | derived | `{x, y, width, height}` left after bars and exclusive layer surfaces, read back from the last solve. Read only. |
| `canvas` | table | derived | `core.box('root')`: the root element's box, bars included, from the layout most recently read (the last screen solved or queried with `core.hits`), which is not necessarily this screen's. Read only; nil before the first solve. |
| `scale` | number | 1 | Fractional output scale. Writing it changes the output scale and logical size. A 1280×720 mode at scale 2 has a 640×360 logical size. |
| `selected_tag` | tag or nil | derived | Sugar for `selected_tags[1]`. Writing a tag means `{t}`; writing nil writes `{}`, which the tag layer refuses to leave empty. |
| `selected_tags` | list of tags | `{}` | The selection fact. Writing it redraws, runs the tag-switch reveal animation, and pushes tag history. |
| `name` | string | seeded | The output name (for example `"eDP-1"`). Read only. |
| `x`, `y` | number | seeded | Output origin in global logical coordinates. Read only; change with `core.output.set_position`. |
| `width`, `height` | number | seeded | Output size in logical pixels, re-seeded every frame. Do not write. |
| `tags` | list of tags | `{}` | The screen's tags, in creation order. `tag.new` appends. Read only. |
| `bars` | list | `{}` | The registered bars, as `{ cfg = ..., fn = ... }` entries. `kiln.ui.bar` appends; each reserves workarea on the edge its cfg names, any of the four. Read only. |

## Geometry and units

| Value | Units and origin |
|---|---|
| `core.output.list()` widths, heights and advertised modes | Physical pixels. |
| `core.output.list()` refresh values; `core.output.set_mode` refresh argument | Millihertz: 60000 means 60 Hz. |
| `s.width`, `s.height`, UI sizes and gaps | Logical pixels. |
| `s.x`, `s.y`; pointer event `x`, `y`; `core.hits` arguments | Global logical coordinates across all outputs. |
| `s.workarea`, `core.box(id)`, `c.float`, popup `at` | Logical coordinates relative to the output's origin. |

Convert a pointer event to output-local coordinates by subtracting the output
origin: `x = ev.x - s.x`, `y = ev.y - s.y`. Do not multiply by scale.

`core.box` reads the previous successful solve. Inside a declaration it reads
that output's tree. Outside a declaration it reads the last output solved or
selected by `core.hits`. To query a particular output over IPC:

```lua
local s = screen.all()[1]
core.hits(s.name, s.x, s.y)
local b = core.box("root")
return b and b.width, b and b.height
```

`s.canvas` calls `core.box("root")` without selecting an output. Use `s.width`
and `s.height` for that screen's logical size, or `s.workarea` for its cached
usable area. Box readback can be nil before the first solve. A box for an
element removed from the tree can retain its last value; use `core.hits` to
test what is currently under a point.

## Class functions and fields

| Method | Description |
|---|---|
| `screen.all()` | Every screen, in add order. |
| `screen.focused` | Plain field: the focused screen. Follows `c:focus()` and pointer motion. |
| `screen.on(name, fn)` / `screen.off(name, fn)` | Class-level signals. |

## Signals

| Signal | Payload | Emitted when |
|---|---|---|
| `added` | none | A new output appears (also restated for each screen on reload). This is where a config creates tags and bars for the screen. |
| `changed` | none | The output's mode, scale, position, or enabled state changed. Re-read `core.output.list()` for the new facts; layer surfaces re-answer automatically on the next frame. A config rarely needs to do anything here. |
| `removed` | none | The output is gone. The standard library has already rehomed its clients to a survivor's selected tag before this fires; use it for cleanup of your own per-screen state. |
| `property::<any>` | new value | Any property write that changed the value. Notably `property::selected_tags` fires on every tag switch. |

## See also

- [tag](/kiln/reference/tag)
- [Multi-monitor](/kiln/guides/multi-monitor)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [Signal index](/kiln/reference/signals)
