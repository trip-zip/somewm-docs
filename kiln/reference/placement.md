---
title: some.placement
description: The 14 float placement helpers, arithmetic over the screen workarea that writes c.float.
sidebar_position: 12
---

# some.placement

`some.placement` places floating clients: each helper is a function `f(c, s?)` that computes a position against the screen's workarea and writes `c.float` in one assignment (one `property::float`, one re-declare). `s` defaults to the client's screen.

```lua
some.placement.centered(c)
```

There are no placement objects and no apply pass: helpers compose by being called in order, so "centered, then nudged on screen" is two calls, not an operator.

The box being placed is `c.float` if set, otherwise the client's committed size, falling back to 400x300 for a client that has not committed one yet. The area placed against is `screen.workarea` (what is left after bars and exclusive zones), falling back to the whole output before the first solve.

## The helpers

The 11 position combinators put the box at a fixed fraction of the workarea per axis; an axis a helper does not name is left where it is.

| Helper | Horizontal | Vertical |
|---|---|---|
| `centered` | center | center |
| `center_horizontal` | center | unchanged |
| `center_vertical` | unchanged | center |
| `left` | left edge | center |
| `right` | right edge | center |
| `top` | center | top edge |
| `bottom` | center | bottom edge |
| `top_left` | left edge | top edge |
| `top_right` | right edge | top edge |
| `bottom_left` | left edge | bottom edge |
| `bottom_right` | right edge | bottom edge |

The three constraint helpers:

| Helper | Behavior |
|---|---|
| `no_offscreen` | Clamp the box into the workarea. A box larger than the area pins to the near edge rather than pushing its top-left off screen. |
| `no_overlap` | Place the box clear of every other visible float on the screen: try the workarea origin, then the right and bottom edge of each occupied float, and take the first spot that fits inside the workarea and overlaps nothing (touching edges do not count as overlap). With no free slot it degrades to `no_offscreen`. |
| `under_mouse` | Center the box on the pointer's last known position, then apply `no_offscreen`. Before any pointer motion exists (a launcher summoned by key, say) it falls back to `centered`. |

All three return the client, like the combinators, and compose the same way:

```lua
some.placement.under_mouse(c)      -- already includes no_offscreen
some.placement.top_right(c)
some.placement.no_overlap(c)       -- find a clear slot instead
```

## In a rule

A rule's `on(c)` callback takes a placement helper directly, since a helper is already a `function(c)`:

```lua
some.rule { match_any = { app = { "pinentry" } },
            props = { floating = true },
            on = some.placement.centered }

some.rule { match = { app = "mpv" },
            props = { floating = true },
            on = function(c)
                some.placement.bottom_right(c)
                some.placement.no_offscreen(c)
            end }
```

:::note
Rules fire at map, before the client has committed a size, so a placement at rule time places the box the client asked for (or the fallback), not the size it may end up drawing at. And `screen.workarea` reflects the last layout solve: inside a screen's own declare it is authoritative, but calling a helper from a keybinding on a multi-monitor setup can read a screen that did not solve last, which falls back to the whole output and loses the bar inset.
:::

## See also

- [Floating and placement guide](/kiln/guides/floating-and-placement)
- [Client rules guide](/kiln/guides/client-rules)
- [Keys, Buttons, and Rules](/kiln/reference/keybindings-and-rules)
- [client reference](/kiln/reference/client)
- [screen reference](/kiln/reference/screen)
