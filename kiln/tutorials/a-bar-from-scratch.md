---
title: A Bar from Scratch
description: Build a status bar step by step with ui.bar and the stock kiln.widgets, center the clock honestly, then turn it sideways.
sidebar_position: 3
---

# A Bar from Scratch

A kiln bar is not a window or a surface. It is a container of nodes in the
screen's one layout tree. The stock frame lays out bars and the workarea in
one Clay column, so clients are never placed under a bar.

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

Bars are registered per screen, inside the `added` handler. Replace the
default config's `screen.on("added")` block with this one (adding a second
handler would give you a second bar and a sixth tag):

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
When the screen is marked dirty (tag selected, client mapped, title changed),
`fn` runs again and declares the whole bar.

That is why `widgets.clock()` can be one line: it declares today's text, and a
timer aligned to the minute rollover marks the screen dirty when the text
would change. See [Frames and dirty](/kiln/concepts/frames-and-dirty).

Inside a top or bottom bar, your cells are laid out left to right; a left or
right bar lays them out top to bottom. The bar's body is a `ui.row` or
`ui.column` built from the bar's own cfg.

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
  Which clients it lists and how wide each row grows are configurable; see
  [the widgets reference](/kiln/reference/widgets#bar-cells).
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
styling any box: `h` for the bar's height, `color`, `gap`, `pad`, and the
rest. What you leave unset falls to a documented default, filled per frame;
the [ui reference](/kiln/reference/ui#bars) lists every bar field and its
default.

```lua
	ui.bar(s, { edge = "bottom", h = 24, color = "#101014", gap = 10 },
		function()
			widgets.taglist(s)
			ui.spacer()
			widgets.clock()
		end)
```

The defaults are read from `kiln.theme` each frame, so a theme edit restyles
every bar that left the field unset; see [Theming](/kiln/tutorials/theming).

## 6. Center the clock on the screen {#center-the-clock-honestly}

Two spacers center a cell in the leftover space, so a growing tasklist pushes
it right. Split the bar into three 33.33% regions instead:

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

`edge = "left"` reserves workarea on the left, uses a `ui.column`, and takes
its width from `theme.bar_height`.

```lua
	ui.bar(s, { edge = "left" }, function()
		widgets.layoutbox(s)
		ui.spacer()
		ui.box({ w = 16, h = 16, color = th.accent, radius = 8 })
	end)
```

`ui.spacer()` grows along the column, so it pushes later cells down. Cells
that assume a wide bar (the tasklist's ellipsized titles, the clock's text)
are a poor fit for a 32 px wide column; vertical bars usually carry glyphs.

## 8. Your own cells: row, box, text

Every stock cell is built from primitives you can use directly:
`ui.box(cfg, children?)`, `ui.row(cfg, children?)`, `ui.column(cfg,
children?)`, and the `ui.text(str, cfg?)` leaf. A launcher button; add this
inside your bar function:

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

The clock uses `ui.tooltip`, which returns an `on_hover` handler. The default
config's bar also adds the launcher glyph, the backdrop and a clipped right
region.

## See also

- [Widgets](/kiln/tutorials/widgets)
- [kiln.widgets reference](/kiln/reference/widgets)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [Theming](/kiln/tutorials/theming)
