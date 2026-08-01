---
title: kiln.widgets
description: The widget shelf, 13 widgets and the filter table, every one a composition of ui.* primitives that a config could have written itself.
sidebar_position: 9
---

# kiln.widgets

`kiln.widgets` is the widget shelf: compositions of the [`ui.*`](/kiln/reference/ui) primitives that read compositor state (screens, tags, clients, the theme) and encode an opinion. This is the API's one distinction: `ui.*` maps a cfg table onto Clay and adds no policy, `kiln.widgets.*` is policy a config could have written in the public element API, written once. None of them computes a position, because Clay solves everything. See [the two tiers](/kiln/concepts/the-clay-bet#the-two-tiers) for why the split exists.

```lua
local kiln = require("kiln")
local ui = kiln.ui
local widgets = kiln.widgets

screen.on("added", function(s)
  ui.bar(s, { edge = "top" }, function()
    widgets.taglist(s)
    widgets.tasklist(s)
    ui.spacer()
    widgets.systray()
    widgets.layoutbox(s)
    widgets.clock()
  end)
end)
```

## The module table is the extension point

**Widget-to-widget calls go through the module table, never a private upvalue.** `widgets.client` reaches the titlebar as `kiln.widgets.titlebar`, so a config that assigns `kiln.widgets.titlebar = fn` governs every caller, stdlib included: the tiled layouts, the floating composite, all of it. Any shelf symbol can be replaced the same way, and the replacement needs no registration step beyond the assignment.

## Writable by a config

Every widget on the shelf uses only API a config can reach with the same spelling, and a standing check in the kiln repo (`scripts/widget-lint.sh`) fails the build of any widget that reaches for a private door. The vocabulary, beyond `ui.*` and the shelf itself:

| Name | What a widget uses it for |
|---|---|
| [`core.box`](/kiln/reference/core) | Read back an element's solved box. The sanctioned answer to "where did Clay put it"; the slider depends on it. |
| [`core.dirty`](/kiln/reference/core) | Mark a screen dirty so the next frame redeclares. |
| [`core.timer`](/kiln/reference/core) | One-shot timer; the clock arms one per minute rollover. |
| [`core.tray_activate`](/kiln/reference/core) | Forward a press or scroll to a status-notifier item. |
| [`core.input.set_cursor`](/kiln/reference/core) | Set the pointer image; the resize handles set the edge cursors. |
| `kiln.theme` | Colors and metrics. The same table `state.theme` names inside the stdlib. |
| `client` | The client global: `client.focus`, the properties a row draws. |
| `kiln.icon`, `kiln.grab`, `kiln.layout`, `kiln.systray` | Icon resolution, pointer grabs, the layout registry, the tray registry. |

:::note
`core.box` returns nil before the first solve and for anything not in the current frame. A widget that reads its own box therefore needs a stable `id`, which is why `widgets.slider` errors without one.
:::

## Form widgets

`progress`, `separator`, `toggle`, and `slider` are controlled: the caller owns the value and the widget draws it. `value` and `on` come in, `changed` and `press` go out, and the widget holds no state to go stale. General element keys (`pad`, `align`, `float`, handlers) are not repeated below; each widget passes its cfg onto ordinary elements, and the full element contract lives in [the cfg contract](/kiln/reference/ui#the-cfg-contract).

### widgets.progress(cfg)

A fill across a track, both boxes named so a probe can read the ratio back.

| Field | Values | Meaning |
|---|---|---|
| `id`, `fill_id` | element ids | Track and fill. `fill_id` is its own key rather than derived, so a caller porting an existing widget keeps its ids. |
| `value` | 0 to 1 | Fill fraction, clamped. |
| `w`, `h` | sizing | Defaults `"grow"` and 4. |
| `color`, `track` | color spec | Fill (default `theme.accent`) and track (default `theme.muted`). |
| `radius` | number | Default 2, both boxes. |

### widgets.separator(cfg?)

A rule: thin on one axis, long on the other, and which is which is the whole of its configuration.

| Field | Values | Meaning |
|---|---|---|
| `vertical` | boolean | Swaps which axis is thin. Default false, a horizontal rule. |
| `thickness` | number | Default 1. |
| `length` | sizing | Default `"grow"`. |
| `color` | color spec | Default `theme.muted`. |

### widgets.toggle(cfg)

A switch. The knob is placed by child alignment, so the two states differ by one word and not by any arithmetic over the track.

| Field | Values | Meaning |
|---|---|---|
| `on` | boolean | The state, owned by the caller. |
| `press` | `fn(ev)` | The output; flip your own state here and the next frame draws it. |
| `id` | element id | Optional; the knob derives `id .. ":knob"`. |
| `w`, `h`, `pad` | numbers | Defaults 32, 16, 2. The knob is `h - 2 * pad` square. |
| `color`, `track`, `knob` | color spec | On fill (`theme.accent`), off fill (`theme.muted`), knob (`theme.fg`). |
| `radius` | number | Default half the height, a pill. |

### widgets.slider(cfg)

A value dragged along a track. **`id` is required**: the slider reads its own solved box to turn a pointer position into a value, and errors without one. The drag is a mousegrabber, the same claim interactive move and resize use; the value is read absolutely at every step, so a press lands where it was pressed and a long drag cannot drift. The drag ends on the release of the button that started it, not of any button.

| Field | Values | Meaning |
|---|---|---|
| `id` | element id | Required. The fill derives `id .. ":fill"`. |
| `value` | 0 to 1 | The position, owned by the caller. |
| `changed` | `fn(v)` | The output, called with the new 0 to 1 value on press and on every drag step. |
| `w`, `h` | numbers | Defaults 120, 16. |
| `color`, `track` | color spec | Fill (`theme.accent`) and track (`theme.bg2`). |
| `radius` | number | Default 3. |

## Bar cells

The stock bar cells. Each declares under a stable id the inspector and the docs figures read back: `taglist:<screen>`, `tasklist:<screen>`, `layoutbox:<screen>`, tasklist rows `task:<handle>`, tray cells `tray:<service>`.

| Widget | Description |
|---|---|
| `widgets.taglist(s, cfg?)` | One pressable cell per tag of screen `s`, accent fill when viewed, a corner mark when occupied (filled when the focused client is there). Pressing views the tag. cfg: `on` (below). |
| `widgets.tasklist(s, cfg?)` | One row per mapped client on the screen's viewed tags, deduped across tags, icon plus ellipsized title, accent fill on the focused row. Pressing unminimizes and focuses. cfg: `filter` (default `widgets.filter.currenttags`), `width` (default `{ "grow", max = 180 }`), `on`. |
| `widgets.systray(cfg?)` | The status-notifier items as pressable icon cells in registration order. Press activates the item, scroll forwards the delta. cfg: `size` (default 18). |
| `widgets.layoutbox(s, cfg?)` | The viewed tag's layout, as `theme.layout_icons[family]` when set, else the layout name as text. Pressing cycles to the next layout. cfg: `on`. |
| `widgets.layoutlist(s, cfg?)` | Layout picker: a [menu](/kiln/reference/ui#menus) over `kiln.layout.list`. cfg is menu cfg (`under` is the usual key). |
| `widgets.clock()` | Minute-aligned clock text. The redraw timer arms on the rollover the first time the clock is declared, so the displayed minute is never stale. |

### widgets.filter

A tasklist filter is a predicate `(client, screen)`, not a class and not a registry: the extension point is "write a function", and any rc.lua predicate is these three's equal.

| Filter | Keeps |
|---|---|
| `widgets.filter.currenttags` | Clients on any viewed tag of the screen. The default. |
| `widgets.filter.alltags` | Every client. |
| `widgets.filter.minimized` | Minimized clients on the screen's viewed tags. |

### The handler table

`widgets.taglist`, `widgets.tasklist`, and `widgets.layoutbox` take an `on` sub-table of named gestures: `press(item, ev)` (the tag, client, or tag under the pointer, plus the ordinary press event with `button` and `mods`) and `scroll(ev)`. A handler preempts: returning a truthy value means handled and the stdlib default (view the tag, focus the client, cycle the layout) does not run; returning nil declines to it. `on` is a sub-table because `on_press` on an element cfg already means the box's own edge.

## Client chrome

What the stock layouts declare per client. A custom layout composes these the same way; see [Custom Layouts](/kiln/guides/custom-layouts).

| Widget | Description |
|---|---|
| `widgets.titlebar(c, focused?)` | The titlebar row: icon slot, live title riding one growing cell that centers it, maximize and close buttons. Pressing the empty bar starts a move drag. The replaceability exemplar: assign `kiln.widgets.titlebar = fn` and every layout draws yours. |
| `widgets.resize_handles(c, z?)` | Eight invisible edge and corner handles floated over a floating client, one z above the client's own float. A press starts the edge's resize grab, a hover sets the edge cursor. |
| `widgets.client(c, cfg?)` | The composite: bordered, rounded column of titlebar over surface, colored by focus, resize handles added when the client floats. A client with `c.titlebar == false` is just the surface in the same bordered column. cfg: `w`, `h` (default `"grow"`), `z` (the layout's band slot, threaded to the handles). |

## See also

- [kiln.ui](/kiln/reference/ui)
- [core](/kiln/reference/core)
- [Widgets tutorial](/kiln/tutorials/widgets)
- [Data widgets](/kiln/guides/data-widgets)
- [Custom layouts](/kiln/guides/custom-layouts)
- [Replacing default policies](/kiln/guides/replace-default-policies)
