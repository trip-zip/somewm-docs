---
title: Widgets
description: "Self-updating bar regions with ui.widget: timers, watched signals, external data via spawn.watch, keyed lists, and a meter."
sidebar_position: 4
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Widgets

<YouWillLearn>

- What a widget is in kiln: a declare function plus a reason to redraw
- Periodic redraws with `ui.widget{ every = seconds }`
- Feeding a widget from a shell command with `some.spawn.watch`
- Reacting to object signals with `watch = { "Class::signal" }`
- Keyed dynamic lists with `ui.each`
- A percent meter built from two nested boxes

</YouWillLearn>

A kiln widget is just a function that declares nodes, called from your bar
function every dirty frame. There is no widget object and no update method:
the only question a widget ever raises is "what makes the screen dirty when
my data changes?" `ui.widget{}` answers it, wiring timers and signals to
dirty marks and handing you back the plain function.

## Prerequisites

A bar of your own (see [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)).
Snippets assume:

```lua
local some = require("somewm")
local ui = some.ui
local th = some.theme
```

:::warning
Build widgets once, at config load (top level of your rc), never inside a bar
function. `ui.widget{ every = n }` arms a recurring timer when it is called;
calling it inside a declare function would arm a new timer every frame.
:::

## 1. A seconds clock with `every`

The built-in `ui.clock()` redraws on the minute. For seconds you need a
faster cadence:

```lua
local seconds_clock = ui.widget {
	every = 1,
	function()
		ui.text(os.date("%H:%M:%S"), { size = 12 })
	end,
}
```

The spec's first positional entry (or a `fn` field) is the declare function;
`every = 1` marks every screen dirty each second. Then, in your bar:

```lua
	ui.bar(s, {}, function()
		ui.spacer()
		seconds_clock()
	end)
```

The widget is the function itself: you call it where you want its cells.

## 2. External data: a battery reader with spawn.watch

For data that lives outside the compositor, poll a command and park the
result in a table the widget reads. `some.spawn.watch(cmd, interval, cb)`
runs the command, feeds each output line to `cb`, and re-runs it `interval`
seconds after it exits:

```lua
local stats = { battery = nil }

some.spawn.watch("cat /sys/class/power_supply/BAT0/capacity", 30,
	function(line)
		stats.battery = tonumber(line)
		some.dirty()
	end)

local battery = ui.widget {
	function()
		ui.text(stats.battery and (stats.battery .. "%") or "n/a", { size = 12 })
	end,
}
```

The callback stores the fact and calls `some.dirty()`, so the redraw happens
when the data changes, not on a render timer; the widget itself needs no
`every`. The same pattern reads CPU load, volume, or anything else a command
can print: one `spawn.watch` per source, one shared `stats` table.

`spawn.watch` returns a handle with `:stop()`, and `some.reload()` stops all
watches automatically, so an edited config never doubles its pollers. See
[Spawn lifecycle](/kiln/guides/spawn-lifecycle).

## 3. Reacting to signals with `watch`

`watch` wires object signals to redraws. Entries are `"Class::signal"` where
the class is one of the globals (`client`, `screen`, `tag`, `layer`,
`notification`):

```lua
local focus_indicator = ui.widget {
	watch = { "client::focus", "client::property::title" },
	function()
		local c = client.focus
		ui.text(c and (c.title or c.app_id or "") or "nothing focused",
			{ size = 12, color = th.muted })
	end,
}
```

Whenever any client emits `focus` or `property::title`, the screens are
marked dirty and the next frame re-declares the widget with the new fact.
Listeners are registered once per signal name no matter how many widgets
watch it. The full signal list is in the
[signals reference](/kiln/reference/signals).

(For this particular example `watch` is belt and braces: focus and title
changes already dirty the screen. `watch` earns its keep for properties you
invent yourself, which redraw nothing on their own.)

## 4. Keyed lists with ui.each

When a widget shows one cell per item of a changing collection, declare it
with `ui.each(items, key, declare)`. The `key` function gives each item a
stable id, so a cell's identity (its press handler, its per-item state)
follows the item rather than its list position:

```lua
local function note_key(n)
	return "note:" .. n.seq
end

local notification_chips = ui.widget {
	watch = { "notification::added", "notification::dismissed" },
	function()
		ui.each(notification.all(), note_key, function(n, id, st)
			ui.box({
				id = id, color = th.accent, radius = 3, pad = { x = 6 },
				on_press = function() n:dismiss() end,
			}, function()
				ui.text(n.title or "", { size = 12 })
			end)
		end)
	end,
}
```

`declare(item, id, st)` receives a per-key state table `st` that survives
across frames as long as the key is still declared, then vanishes with it.
Define the key function at module level, not inline: the state store is
scoped by the key function's identity.

## 5. A meter from two boxes

A percent meter is a track with a fill whose width is a percentage of its
parent. Two nested boxes, no drawing code:

```lua
local function meter(pct)
	ui.row({ w = { "grow", max = 100 }, h = 8, color = th.muted, radius = 4 },
		function()
			ui.box({ w = pct .. "%", h = "grow", color = th.accent, radius = 4 })
		end)
end
```

The outer row grows up to 100 px; the inner box's `"N%"` width resolves
against the parent, so `meter(42)` fills 42 percent of the track.

## Complete example

A battery meter, wired end to end:

```lua
local some = require("somewm")
local ui = some.ui
local th = some.theme

local stats = { battery = nil }

some.spawn.watch("cat /sys/class/power_supply/BAT0/capacity", 30,
	function(line)
		stats.battery = tonumber(line)
		some.dirty()
	end)

local battery = ui.widget {
	function()
		local pct = stats.battery
		if pct == nil then
			ui.text("no battery", { size = 12, color = th.muted })
			return
		end
		ui.row({ gap = 6, align = { y = "center" } }, function()
			ui.text(pct .. "%", { size = 12 })
			ui.row({ w = { "grow", max = 100 }, h = 8, color = th.muted,
				radius = 4 }, function()
				ui.box({ w = pct .. "%", h = "grow",
					color = pct < 20 and th.urgent or th.accent, radius = 4 })
			end)
		end)
	end,
}

screen.on("added", function(s)
	tag.new { name = "1", screen = s, layout = some.layout.tile }
	ui.bar(s, {}, function()
		ui.taglist(s)
		ui.spacer()
		battery()
		ui.clock()
	end)
end)
```

The fill even recolors below 20 percent, because state read at declare time
is the entire styling model.

## See also

- [Data widgets guide](/kiln/guides/data-widgets)
- [Spawn lifecycle](/kiln/guides/spawn-lifecycle)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
