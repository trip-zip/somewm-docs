---
title: A Bar from Scratch
description: Build a status bar step by step with ui.bar and the stock kiln.widgets, center the clock honestly, then turn it sideways.
sidebar_position: 3
---

# A Bar from Scratch

A kiln bar is not a window or a surface. It is a container of nodes in the
screen's one layout tree, and it reserves workarea by construction: the frame
stacks bars and workarea in one flow, so clients never sit under your bar.

## Prerequisites

A config you can edit and reload (see [Basics](/kiln/tutorials/basics)).
Snippets assume:

```lua
local kiln = require("kiln")
local ui = kiln.ui
local widgets = kiln.widgets
local th = kiln.theme
```

## 1. The smallest possible bar

Bars are registered per screen, inside the `added` handler, right where the
default config does it:

```lua
screen.on("added", function(s)
	tag.new { name = "1", screen = s, layout = kiln.layout.tile }

	ui.bar(s, { edge = "top" }, function()
		widgets.clock()
	end)
end)
```

Reload. You get a 32 px bar across the top with a clock. `ui.bar(s, cfg, fn)`
appends the bar to the screen and marks it dirty; everything about its content
is the `fn`, and everything about its container is the `cfg`, which is
ordinary element cfg plus `edge`. What you did not write, the frame fills in
as defaults: a `row` direction because the edge is horizontal, `theme.bar_height`
for the height, 8 px of padding along the bar, a 6 px gap between cells,
vertical centering, `theme.bg` behind it all.

:::warning
`ui.bar` appends. Registering it anywhere that runs repeatedly (or pasting it
twice over IPC) stacks a second bar. Keep it inside `screen.on("added")` and
apply changes with `kiln.reload()`, which rebuilds the bar list cleanly.
:::

## 2. The declare function

The `fn` you passed is a declare function. It runs again on every dirty frame
of that screen, and each run states the bar's entire content from scratch.
There is no update path, no widget objects to mutate, no cache to invalidate:
when a tag is selected, a client maps, or a title changes, the screen is
marked dirty and your function simply runs again against the current facts.

That is why `widgets.clock()` can be one line: it declares today's text, and a
timer aligned to the minute rollover marks the screen dirty when the text
would change. See [Frames and dirty](/kiln/concepts/frames-and-dirty).

Inside a top or bottom bar, your cells are laid out left to right; a left or
right bar lays them out top to bottom. The bar's body is a `ui.row` or
`ui.column` built from the bar's own cfg, so there is nothing about its layout
you cannot reach.

## 3. Add a taglist and push the clock right

```lua
	ui.bar(s, { edge = "top" }, function()
		widgets.taglist(s)
		ui.spacer()
		widgets.clock()
	end)
```

`widgets.taglist(s)` declares one pressable cell per tag, highlighted with
`theme.accent` when the tag is selected; pressing one views it. `ui.spacer()`
is exactly `ui.box({ w = "grow" })`: an empty node the solver hands the
leftover room, pushing everything after it to the right edge.

## 4. Tasklist, layoutbox, systray

```lua
	ui.bar(s, { edge = "top" }, function()
		widgets.taglist(s)
		widgets.layoutbox(s)
		widgets.tasklist(s)
		ui.spacer()
		widgets.systray()
		widgets.clock()
	end)
```

- `widgets.layoutbox(s)` shows the selected tag's layout name; pressing it
  cycles to the next layout.
- `widgets.tasklist(s, cfg?)` declares one row per visible client: icon,
  title, accent when focused, press to focus (and restore, if minimized).
  Options: `filter` (default `widgets.filter.currenttags`; also
  `widgets.filter.alltags`, `widgets.filter.minimized`, or any
  `function(c, s)` predicate) and `width` (default `{ "grow", max = 180 }`
  per entry).
- `widgets.systray(cfg?)` shows status-notifier tray items; `size` (default
  18) sets the icon size. Press activates an item, scrolling forwards the
  wheel.

:::tip Look at what you just built
Press `mod+shift+i` to open Clay's debug inspector over the running desktop.
Your bar is in there as a row of nodes, and clicking one shows the box the
solver gave it: width, height, sizing mode, padding, alignment. This is the
fastest way to understand `ui.spacer()`, because you can watch it report
whatever width was left over. See [Inspect the Live Element
Tree](/kiln/guides/inspector).
:::

## 5. Style it

The bar `cfg` is element cfg, so styling a bar is the same vocabulary as
styling any box. What you leave unset falls to a documented default, filled
per frame:

| field | default | meaning |
|---|---|---|
| `edge` | `"top"` | `"top"`, `"bottom"`, `"left"`, or `"right"` |
| `dir` | from the edge | `"row"` on top/bottom, `"column"` on left/right |
| `h` / `w` | `theme.bar_height` (32) | the across-edge axis: `h` on a horizontal bar, `w` on a vertical one |
| `pad` | `{ x = 8 }` or `{ y = 8 }` | padding along the bar |
| `gap` | 6 | space between cells |
| `align` | cross-axis center | cell alignment |
| `color` | `theme.bg` | bar background |
| `band` | `"above"` | stacking band for the bar's widgets |

```lua
	ui.bar(s, { edge = "bottom", h = 24, color = "#101014", gap = 10 },
		function()
			widgets.taglist(s)
			ui.spacer()
			widgets.clock()
		end)
```

:::note
Older kiln configs sized a bar with a `height` key. That key no longer
exists: the across-edge axis is plain element sizing, `h` here, and an
unknown key is silently ignored, so a leftover `height = 24` gets you a
32 px bar with no error. Rename it to `h`.
:::

Because the defaults are filled per frame, a live theme edit governs bars
that are already registered: set `kiln.theme.bg` and every bar that left
`color` unset repaints on the next frame. Colors and sizes the stock cells
use come from `kiln.theme` too (`bg`, `bg2`, `fg`, `accent`, `muted`,
`font_size`, `bar_height`), so restyling globally is usually a theme edit
rather than a bar edit. See [Theming](/kiln/tutorials/theming).

## 6. Center the clock honestly

The spacer layout from step 4 has a flaw you can watch happen: the clock
sits at the right edge, and anything you center with two spacers is centered
in the leftover space, not on the screen. Open a few clients and the growing
tasklist shoves your "centered" cell toward the right edge.

The honest fix is to say what you mean in the tree: three regions of a third
each, and the clock centered in the middle one.

```lua
	ui.bar(s, { edge = "top" }, function()
		ui.row({ w = "33.33%", h = "grow", gap = 6,
				clip = { horizontal = true },
				align = { y = "center" } }, function()
			widgets.taglist(s)
			widgets.tasklist(s)
		end)
		ui.row({ w = "33.33%", h = "grow", align = "center" }, function()
			widgets.clock()
		end)
		ui.row({ w = "33.33%", h = "grow", gap = 6,
				align = { x = "right", y = "center" } }, function()
			widgets.systray()
			widgets.layoutbox(s)
		end)
	end)
```

Two things make this hold at any tasklist width. A percent child is sized
unconditionally, so the middle third's center is the bar's center no matter
what the sides contain; `"grow"` regions would only stay equal until one
side's content outgrew its share. And the left region clips, so an overfull
tasklist truncates at its own third instead of pushing into the middle.
Check it in the inspector: the three regions report a third each, clients
open or not.

## 7. Turn it sideways

`edge = "left"` is a real bar, not a rotation trick: it reserves workarea on
the left, its body is a `ui.column`, and `theme.bar_height` now sets its
width.

```lua
	ui.bar(s, { edge = "left" }, function()
		widgets.layoutbox(s)
		ui.spacer()
		ui.box({ w = 16, h = 16, color = th.accent, radius = 8 })
	end)
```

The same spacer idiom works turned 90 degrees, because it was never
horizontal to begin with: `"grow"` on a column's main axis is height. Cells
that assume a wide bar (the tasklist's ellipsized titles, the clock's text)
are a poor fit for a 32 px wide column; vertical bars usually carry glyphs.

## 8. Your own cells: row, box, text

Every stock cell is built from primitives you can use directly:
`ui.box(cfg, children?)`, `ui.row(cfg, children?)`, `ui.column(cfg,
children?)`, and the `ui.text(str, cfg?)` leaf. A launcher button:

```lua
		ui.box({
			id = "launch-btn", color = th.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_press = function() kiln.spawn("fuzzel") end,
		}, function()
			ui.text("run", { color = th.bg, size = 12 })
		end)
```

Give interactive cells a stable `id`; it keys the press handler frame to
frame. The `cfg` fields (`w`, `h`, `dir`, `pad`, `gap`, `align`, `color`,
`radius`, `border`, `on_press`, `on_hover`, `on_scroll`, and more) are the
same on every container: see the [ui reference](/kiln/reference/ui).

Because the whole bar re-declares each frame, live state is just Lua read in
place:

```lua
		ui.text(client.focus and (client.focus.title or "") or "", { size = 12 })
```

No subscription needed for facts that already dirty the screen (focus, title,
tags all do). For your own data sources and timers, see
[Widgets](/kiln/tutorials/widgets).

## Complete example

```lua
local kiln = require("kiln")
local ui = kiln.ui
local widgets = kiln.widgets
local th = kiln.theme

screen.on("added", function(s)
	tag.new { name = "one", screen = s, layout = kiln.layout.tile }
	tag.new { name = "two", screen = s, layout = kiln.layout.fair }
	s.tags[1]:view()

	ui.bar(s, { edge = "top", h = 28, color = th.bg }, function()
		ui.row({ w = "33.33%", h = "grow", gap = 6,
				clip = { horizontal = true },
				align = { y = "center" } }, function()
			widgets.taglist(s)
			ui.box({
				id = "launch-btn", color = th.accent, radius = 4,
				pad = { x = 8 }, align = "center",
				on_press = function() kiln.spawn("fuzzel") end,
			}, function()
				ui.text("run", { color = th.bg, size = 12 })
			end)
			widgets.tasklist(s)
		end)
		ui.row({ w = "33.33%", h = "grow", align = "center" }, function()
			ui.box({
				id = "clock", color = th.bg2, radius = 4, pad = { x = 8 },
				align = "center",
				on_hover = ui.tooltip(function()
					return os.date("%A %d %B %Y")
				end),
			}, widgets.clock)
		end)
		ui.row({ w = "33.33%", h = "grow", gap = 6,
				align = { x = "right", y = "center" } }, function()
			widgets.systray()
			widgets.layoutbox(s)
		end)
	end)
end)
```

This is essentially the default config's bar: the same three regions, with
the clock cell showing the tooltip trick (`ui.tooltip` returns an `on_hover`
handler; the text function is read live at declare).

## See also

- [Widgets](/kiln/tutorials/widgets)
- [kiln.widgets reference](/kiln/reference/widgets)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [Theming](/kiln/tutorials/theming)
