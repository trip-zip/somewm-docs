---
title: layer
description: Layer-shell surfaces (bars, launchers, wallpapers) as objects with facts and signals.
sidebar_position: 5
---

# layer

A layer object is one layer-shell surface: an external bar, launcher, wallpaper, or lock helper that placed itself with the wlr-layer-shell protocol. The `layer` global is the class. The surface's facts live on the object; how it is sized, answered, and granted the keyboard is Lua policy in `some.defaults`, replaceable wholesale.

```lua
layer.on("map", function(l)
  print("layer surface mapped:", l.namespace, "on", l.screen.name)
end)
```

## Properties

All seeded from the protocol on map and refreshed on every commit. Treat them as facts.

| Property | Type | Default | Description |
|---|---|---|---|
| `handle` | number | seeded | The C-side identity; the key for `core.layer_configure`. |
| `namespace` | string | seeded | The surface's self-declared namespace (`"waybar"`, `"wallpaper"`, ...). |
| `output` | string or nil | seeded | The output the client asked for; nil means it left the choice to the compositor. |
| `screen` | screen | derived | The resolved screen: the named output, else the focused screen. |
| `layer` | string | seeded | Protocol layer: background, bottom, top, or overlay. |
| `interactivity` | string | seeded | Keyboard interactivity: `"none"`, `"on_demand"`, or `"exclusive"`. |
| `anchors` | table | seeded | `{top, bottom, left, right}` booleans. |
| `margin` | table | seeded | `{top, right, bottom, left}` in pixels. |
| `exclusive` | number | seeded | The exclusive zone the surface reserves. |
| `desired_w`, `desired_h` | number | seeded | The size the surface asked for; 0 on an axis means stretch when anchored to both opposite edges. |
| `mapped` | boolean | true on map | Liveness. |
| `w`, `h` | number | set by policy | The answered size, written by whichever handler calls `core.layer_configure`. |
| `kb_granted` | boolean | false | Whether the keyboard policy currently grants the surface the seat. |

As with every kiln object, unknown keys store and emit `property::<key>`.

## Signals

| Signal | Payload | Emitted when |
|---|---|---|
| `map` | none | The surface's initial commit. It blocks until a handler answers with `core.layer_configure`. |
| `commit` | none | The surface committed new facts (anchors, margins, size, interactivity). |
| `unmap` | none | The surface unmapped. |
| `destroy` | none | The surface is gone. |
| `property::<any>` | new value | Any property write that changed the value. |

## Policy

Layer surfaces carry no built-in behavior; three replaceable policies on `some.defaults` decide everything (see [defaults](/kiln/reference/defaults)):

| Policy | Runs on | Decides |
|---|---|---|
| `some.defaults.layer(l)` | `map`, `commit` | How the surface is sized and answered. The stock one implements standard protocol sizing: a zero desired axis anchored to both opposite edges stretches between them minus margins; everything else is honored as asked. |
| `some.defaults.layer_keyboard(l)` | `map`, `commit` | Whether the surface gets the keyboard. Stock: `exclusive` takes the seat, `on_demand` stays inert. |
| `some.defaults.layer_release(l)` | `unmap`, `destroy` | Cleanup; the stock one returns the seat to the focused client if the surface held it. |

Replace any of them with a plain assignment before the surface maps. A broken `layer` policy means the surface is visibly absent, never a compositor-synthesized answer.

## See also

- [defaults](/kiln/reference/defaults)
- [Replacing default policies](/kiln/guides/replace-default-policies)
- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [Signal index](/kiln/reference/signals)
