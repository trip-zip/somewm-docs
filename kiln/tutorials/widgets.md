---
title: Widgets
description: "Self-updating bar regions with ui.widget: timers, watched signals, external data via spawn.watch, keyed lists, and wiring the stock kiln.widgets."
sidebar_position: 4
---

# Widgets

A kiln widget is just a function that declares nodes, called from your bar
function every dirty frame. There is no widget object and no update method:
the only question a widget ever raises is "what makes the screen dirty when
my data changes?" `ui.widget{}` answers it, wiring timers and signals to
dirty marks and handing you back the plain function.

Two names sound alike and do different jobs. `ui.widget` is the wiring
constructor this page is about. [`kiln.widgets`](/kiln/reference/widgets) is
the stock widgets (taglist, clock, the form widgets); your own
widgets compose stock pieces the same way your bar does.

## Prerequisites

A bar of your own (see [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)).
Snippets assume:

```lua
local kiln = require("kiln")
local ui = kiln.ui
local widgets = kiln.widgets
local th = kiln.theme
```

:::warning
Build widgets once, at config load (top level of your rc), never inside a bar
function. `ui.widget{ every = n }` arms a recurring timer when it is called;
calling it inside a declare function would arm a new timer every frame.
:::

## 1. A seconds clock with `every`

The built-in `widgets.clock()` redraws on the minute. For seconds you need a
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
	ui.bar(s, { edge = "top" }, function()
		ui.spacer()
		seconds_clock()
	end)
```

The widget is the function itself: you call it where you want its cells.

## 2. External data: a battery reader with spawn.watch

For data that lives outside the compositor, poll a command and park the
result in a table the widget reads. `kiln.spawn.watch(cmd, interval, cb)`
runs the command, feeds each output line to `cb`, and re-runs it `interval`
seconds after it exits:

```lua
local stats = { battery = nil }

kiln.spawn.watch("cat /sys/class/power_supply/BAT0/capacity", 30,
	function(line)
		stats.battery = tonumber(line)
		kiln.dirty()
	end)

local battery = ui.widget {
	function()
		ui.text(stats.battery and (stats.battery .. "%") or "n/a", { size = 12 })
	end,
}
```

The callback stores the fact and calls `kiln.dirty()`, so the redraw happens
when the data changes, not on a render timer; the widget itself needs no
`every`. The same pattern reads CPU load, volume, or anything else a command
can print: one `spawn.watch` per source, one shared `stats` table.

`spawn.watch` returns a handle with `:stop()`, and `kiln.reload()` stops all
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

## 5. A stock meter

A percent meter is a track with a fill whose width is a percentage of its
parent: two nested boxes, no drawing code. That composition ships stock
as `widgets.progress`, so a meter is one call:

```lua
	widgets.progress({ id = "meter", value = 0.42,
		w = { "grow", max = 100 }, h = 8 })
```

The form widgets (`progress`, `separator`, `toggle`, `slider`) are
controlled: you own the value and the widget draws it. Nothing inside
`widgets.progress` remembers 0.42; the next frame draws whatever your
declare function passes, which is exactly how every other fact on the bar
already behaves. Wiring one to `ui.widget` is therefore just reading your
own state in the declare function, as the complete example below does. The
cfg for each form widget is in the
[kiln.widgets reference](/kiln/reference/widgets#form-widgets).

## Complete example

A battery meter, wired end to end:

```lua
local kiln = require("kiln")
local ui = kiln.ui
local widgets = kiln.widgets
local th = kiln.theme

local stats = { battery = nil }

kiln.spawn.watch("cat /sys/class/power_supply/BAT0/capacity", 30,
	function(line)
		stats.battery = tonumber(line)
		kiln.dirty()
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
			widgets.progress({ id = "bat", value = pct / 100,
				w = { "grow", max = 100 }, h = 8,
				color = pct < 20 and th.urgent or th.accent })
		end)
	end,
}

screen.on("added", function(s)
	tag.new { name = "1", screen = s, layout = kiln.layout.tile }
	ui.bar(s, { edge = "top" }, function()
		widgets.taglist(s)
		ui.spacer()
		battery()
		widgets.clock()
	end)
end)
```

The fill even recolors below 20 percent, because state read at declare time
is the entire styling model: `spawn.watch` owns the number, `ui.widget` owns
the dirty mark, and `widgets.progress` just draws whatever it is handed.

## See also

- [Data widgets guide](/kiln/guides/data-widgets)
- [Spawn lifecycle](/kiln/guides/spawn-lifecycle)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
