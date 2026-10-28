---
title: Widgets
description: "Self-updating bar regions with ui.widget: timers, watched signals, external data via spawn.watch, keyed lists, and wiring the stock kiln.widgets."
sidebar_position: 4
---

# Widgets

`ui.widget{fn, every=, watch=}` arms a timer and signal listeners that mark
screens dirty, and returns `fn` for your bar function to call.

[`kiln.widgets`](/kiln/reference/widgets) provides stock widgets such as the taglist and clock.

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
`every = 1` marks every screen dirty each second. Call `seconds_clock()`
inside your existing bar function:

```lua
		seconds_clock()
```

Reload. The clock appears in the bar and updates every second.

## 2. External data: a battery reader with spawn.watch

`kiln.spawn.watch(cmd, interval, cb)` runs a command, passes each output line to `cb`, and runs it again `interval` seconds after it exits:

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

Add `battery()` to your bar and reload. It shows the charge percentage, or `n/a` if no `BAT0` is found. Adjust the path if your battery has a different name, such as `BAT1`.

The callback saves the reading and calls `kiln.dirty()` to redraw. The widget needs no `every` timer.

`spawn.watch` returns a handle with `:stop()`. Reload stops watches and drops
their callbacks, but running children continue until they exit. See
[pipe and watch lifetime](../guides/spawn-lifecycle.md#pipes-and-watches-across-stop-and-reload).

## 3. Reacting to signals with `watch`

`watch` wires object signals to redraws. Entries are `"Class::signal"` where
the class is one of the globals (`client`, `screen`, `tag`, `layer`,
`notification`). Focus and title changes already redraw the screen; a
property of your own does not. Writing any unknown key on a client stores it
and emits `property::<key>`, so a `mark` flag set from a key becomes a
watchable signal:

```lua
kiln.key { mods = { "mod" }, key = "b", desc = "toggle mark", group = "client",
	press = kiln.focused(function(c) c.mark = not c.mark end) }

local marked = ui.widget {
	watch = { "client::property::mark" },
	function()
		local n = 0
		for _, c in ipairs(client.all()) do
			if c.mark then n = n + 1 end
		end
		ui.text(n .. " marked", { size = 12, color = th.muted })
	end,
}
```

Add `marked()` to your bar, reload, and press `mod+b` on a few windows. The
count follows each press. Listeners are registered once per signal name; see
the [signals reference](/kiln/reference/signals).

## 4. Keyed lists with ui.each

`ui.each(items, key, declare)` declares a cell per item. Give each item a stable key to preserve its handler and state when the list is reordered:

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

Wire the chips into your bar, reload, and send yourself a notification:

```bash
kiln-client eval 'require("kiln").notify { title = "hello" }'
```

A chip labelled "hello" appears in the bar. Click it to dismiss the notification and remove the chip.

`declare(item, id, st)` receives a per-key state table `st` that survives
across frames as long as the key is still declared, then vanishes with it.
Define the key function at module level, not inline: the state store is
scoped by the key function's identity.

## 5. A stock meter

Add a progress bar with `widgets.progress`:

```lua
	widgets.progress({ id = "meter", value = 0.42,
		w = { "grow", max = 100 }, h = 8 })
```

Drop that line into your bar function and reload: a thin 100 px track
appears with the left 42 percent filled in the accent color.

Pass the current value on each frame. See the [form widgets reference](/kiln/reference/widgets#form-widgets) for configuration options.

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

Reload. The meter shows the charge and changes color below 20%. Without a battery, it displays "no battery".

## See also

- [Data widgets guide](/kiln/guides/data-widgets)
- [Spawn lifecycle](/kiln/guides/spawn-lifecycle)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
