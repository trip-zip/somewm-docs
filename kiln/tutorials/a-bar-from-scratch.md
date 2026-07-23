---
title: A Bar from Scratch
description: Build a status bar step by step with ui.bar and the stock cells, then style it with theme keys and custom boxes.
sidebar_position: 3
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# A Bar from Scratch

<YouWillLearn>

- Registering a bar with `ui.bar(s, cfg, fn)` inside `screen.on("added")`
- Why the bar function re-runs on every dirty frame, and what that buys you
- The stock cells: taglist, tasklist, systray, layoutbox, clock, spacer
- Styling with `cfg` (color, height, gap, edge, band) and theme keys
- The `row`, `box`, and `text` primitives underneath every cell

</YouWillLearn>

A kiln bar is not a window or a surface. It is a row of nodes in the screen's
one layout tree, and it reserves workarea by construction: the frame stacks
bars and workarea in one column, so clients never sit under your bar.

## Prerequisites

A config you can edit and reload (see [Basics](/kiln/tutorials/basics)).
Snippets assume:

```lua
local some = require("somewm")
local ui = some.ui
local th = some.theme
```

## 1. The smallest possible bar

Bars are registered per screen, inside the `added` handler, right where the
default config does it:

```lua
screen.on("added", function(s)
	tag.new { name = "1", screen = s, layout = some.layout.tile }

	ui.bar(s, {}, function()
		ui.clock()
	end)
end)
```

Reload. You get a 32 px bar across the top with a clock: `ui.bar(s, cfg, fn)`
appends the bar to the screen and marks it dirty, and everything about its
content is the `fn`.

:::warning
`ui.bar` appends. Registering it anywhere that runs repeatedly (or pasting it
twice over IPC) stacks a second bar. Keep it inside `screen.on("added")` and
apply changes with `some.reload()`, which rebuilds the bar list cleanly.
:::

## 2. The declare function

The `fn` you passed is a declare function. It runs again on every dirty frame
of that screen, and each run states the bar's entire content from scratch.
There is no update path, no widget objects to mutate, no cache to invalidate:
when a tag is selected, a client maps, or a title changes, the screen is
marked dirty and your function simply runs again against the current facts.

That is why `ui.clock()` can be one line: it declares today's text, and a
timer aligned to the minute rollover marks the screen dirty when the text
would change. See [Frames and dirty](/kiln/concepts/frames-and-dirty).

Inside, your cells are laid out left to right, vertically centered, with a
6 px gap between cells and 8 px of horizontal padding (the bar wraps your fn
in a `ui.row`).

## 3. Add a taglist and push the clock right

```lua
	ui.bar(s, {}, function()
		ui.taglist(s)
		ui.spacer()
		ui.clock()
	end)
```

`ui.taglist(s)` declares one pressable cell per tag, highlighted with
`theme.accent` when the tag is selected; pressing one views it. `ui.spacer()`
is just `ui.box({ w = "grow" })`: an empty node that grows to eat the free
space, pushing everything after it to the right edge.

## 4. Tasklist, layoutbox, systray

```lua
	ui.bar(s, {}, function()
		ui.taglist(s)
		ui.layoutbox(s)
		ui.tasklist(s)
		ui.spacer()
		ui.systray()
		ui.clock()
	end)
```

- `ui.layoutbox(s)` shows the selected tag's layout name; pressing it cycles
  to the next layout.
- `ui.tasklist(s, cfg?)` declares one row per visible client: icon, title,
  accent when focused, press to focus (and restore, if minimized). Options:
  `filter` (default `ui.filter.currenttags`; also `ui.filter.alltags`,
  `ui.filter.minimized`, or any `function(c, s)` predicate) and `width`
  (default `{ "grow", max = 180 }` per entry).
- `ui.systray(cfg?)` shows status-notifier tray items; `size` (default 18)
  sets the icon size. Press activates an item, scrolling forwards the wheel.

## 5. Style it

The bar `cfg` takes:

| field | default | meaning |
|---|---|---|
| `color` | `theme.bg` | bar background |
| `height` | `theme.bar_height` (32) | bar height in px |
| `gap` | 6 | space between cells |
| `edge` | `"top"` | `"top"` or `"bottom"` |
| `band` | `"above"` | stacking band for the bar's chrome |

```lua
	ui.bar(s, { edge = "bottom", height = 24, color = "#101014", gap = 10 },
		function()
			ui.taglist(s)
			ui.spacer()
			ui.clock()
		end)
```

Colors and sizes the stock cells use come from `some.theme` (`bg`, `bg2`,
`fg`, `accent`, `muted`, `font_size`, `bar_height`), so restyling globally is
usually a theme edit rather than a bar edit. See
[Theming](/kiln/tutorials/theming).

## 6. Your own cells: row, box, text

Every stock cell is built from three primitives you can use directly:
`ui.box(cfg, children?)`, `ui.row(cfg, children?)`, `ui.column(cfg,
children?)`, and the `ui.text(str, cfg?)` leaf. A launcher button:

```lua
		ui.box({
			id = "launch-btn", color = th.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_press = function() some.spawn("fuzzel") end,
		}, function()
			ui.text("run", { color = th.bg, size = 12 })
		end)
```

Give interactive cells a stable `id`; it keys the press handler frame to
frame. The `cfg` fields (`w`, `h`, `pad`, `gap`, `align`, `color`, `radius`,
`border`, `on_press`, `on_hover`, `on_scroll`, and more) are the same on
every container: see the [ui reference](/kiln/reference/ui).

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
local some = require("somewm")
local ui = some.ui
local th = some.theme

screen.on("added", function(s)
	tag.new { name = "one", screen = s, layout = some.layout.tile }
	tag.new { name = "two", screen = s, layout = some.layout.fair }
	s.tags[1]:view()

	ui.bar(s, { edge = "top", height = 28, color = th.bg }, function()
		ui.taglist(s)
		ui.layoutbox(s)
		ui.box({
			id = "launch-btn", color = th.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_press = function() some.spawn("fuzzel") end,
		}, function()
			ui.text("run", { color = th.bg, size = 12 })
		end)
		ui.tasklist(s)
		ui.spacer()
		ui.systray()
		ui.box({
			id = "clock", color = th.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_hover = ui.tooltip(function() return os.date("%A %d %B %Y") end),
		}, ui.clock)
	end)
end)
```

This is essentially the default config's bar: the clock cell shows the
tooltip trick (`ui.tooltip` returns an `on_hover` handler; the text function
is read live at declare).

## See also

- [Widgets](/kiln/tutorials/widgets)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [Theming](/kiln/tutorials/theming)
