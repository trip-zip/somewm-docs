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
  some.ui.bar(s, {}, function()
    some.ui.taglist(s)
    some.ui.spacer()
    some.ui.clock()
  end)
end)
```

## Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `workarea` | table | derived | `{x, y, width, height}` left after bars and exclusive layer surfaces, read back from the last solve. Read only. |
| `scale` | number | 1 | Fractional output scale. Read comes from the output list; writing drives the output's scale. Logical geometry is unchanged by scale. |
| `selected_tag` | tag or nil | derived | Sugar for `selected_tags[1]`. Writing a tag means `{t}`; writing nil writes `{}`, which the tag layer refuses to leave empty. |
| `selected_tags` | list of tags | `{}` | The selection fact. Writing it redraws, runs the tag-switch reveal animation, and pushes tag history. |
| `name` | string | seeded | The output name (for example `"eDP-1"`). Read only. |
| `width`, `height` | number | seeded | Output size in logical pixels, re-seeded every frame. Do not write. |
| `tags` | list of tags | `{}` | The screen's tags, in creation order. `tag.new` appends. Read only. |
| `bars` | list | `{}` | The registered bars, as `{cfg, fn}` pairs. `some.ui.bar` appends. Read only. |

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
