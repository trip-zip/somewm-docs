---
title: Multi-Monitor
description: React to outputs coming and going, keep per-screen tags and bars, move clients across screens, and configure modes and scale.
sidebar_position: 7
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Multi-Monitor

<YouWillLearn>

- The three screen signals: `added`, `changed`, `removed`
- Per-screen tags and bars, including per-monitor differences
- Moving clients between screens with `c:move_to`
- What happens to windows when an output disappears
- Static output configuration: mode, position, scale, enable

</YouWillLearn>

## 1. The screen lifecycle

Screens are objects that arrive and leave with their outputs. Three class signals cover the lifecycle:

```lua
screen.on("added", function(s)
	-- a new output appeared (also fires once per output at startup)
end)

screen.on("changed", function(s)
	-- the output's mode, scale, position, or enabled state changed
end)

screen.on("removed", function(s)
	-- the output is gone; its clients have already been rehomed
end)
```

`screen.all()` returns every live screen in the order they appeared, and `screen.focused` is the active one, following both client focus and pointer movement. Each screen has a stable `s.name`, the output connector: `"eDP-1"`, `"DP-2"`, `"HDMI-A-1"`.

`added` is where a config builds its per-screen world, which is why even single-monitor configs put tags and bars inside it: the same code then handles a projector being plugged in.

## 2. Per-screen tags and bars

Every screen gets its own tags and its own bars; nothing is shared. Branch on `s.name` for per-monitor differences:

```lua
local some = require("somewm")
local ui = some.ui

screen.on("added", function(s)
	if s.name == "eDP-1" then
		-- the laptop panel: five workspaces
		for _, name in ipairs({ "dev", "web", "chat", "files", "media" }) do
			tag.new { name = name, screen = s, layout = some.layout.tile }
		end
	else
		-- anything external: two, on max
		tag.new { name = "ext", screen = s, layout = some.layout.max }
		tag.new { name = "ext2", screen = s, layout = some.layout.max }
	end
	s.tags[1]:view()

	ui.bar(s, { edge = "top" }, function()
		ui.taglist(s)
		ui.tasklist(s)
		ui.spacer()
		ui.clock()
	end)
end)
```

On `changed`, the screen's geometry (`s.width`, `s.height`) refreshes on the next frame and bars, layer surfaces, and layouts re-solve automatically; a config only needs a `changed` listener when it keeps derived state of its own, and `core.output.list()` has the fresh facts when it does.

## 3. Move clients across screens

`c:move_to(target)` sends a client to another screen's selected tag; focus follows the window. The standard next-screen binding:

```lua
some.key {
	mods = { "mod" }, key = "o",
	desc = "move to next screen", group = "client",
	press = some.focused(function(c)
		local all = screen.all()
		if #all < 2 or c.tag == nil then
			return
		end
		for i, sc in ipairs(all) do
			if sc == c.tag.screen then
				c:move_to(all[i % #all + 1])
				return
			end
		end
	end),
}
```

To move a client to a specific tag on another screen instead, write its membership directly: `c.tags = { other_screen.tags[2] }`.

Switching which screen is active without moving anything is a plain write: `screen.focused = screen.all()[2]`.

## 4. When an output disappears

Unplugging a monitor does not lose windows. Before `removed` fires, the runtime moves every client from the dead screen onto a surviving screen's selected tag, and moves `screen.focused` off the dead screen. Your `removed` listener runs after that, so it is for your own cleanup (state you keyed by screen name), not for rescuing clients.

The stock rehoming is deliberately simple: everything lands on one tag. If you want tag arrangements restored when the monitor comes back, see [Tag Persistence](/kiln/guides/tag-persistence).

## 5. Static output configuration

kiln has no output configuration GUI protocol: tools like wdisplays and kanshi rely on wlr-output-management, which kiln does not implement (see [limitations](/kiln/concepts/limitations)). The config is the output configuration, via the `core.output` verbs:

| Verb | Does |
|---|---|
| `core.output.list()` | every output's facts: `name, width, height, refresh, scale, x, y, enabled`, and its `modes` list |
| `core.output.set_mode(name, w, h, refresh?)` | pick a mode |
| `core.output.set_position(name, x, y)` | place the output in layout coordinates |
| `core.output.set_scale(name, f)` | set (fractional) scale |
| `core.output.set_enabled(name, on)` | switch the output on or off |
| `core.output.set_adaptive_sync(name, on)` | toggle adaptive sync |

A fixed desk arrangement, applied whenever the outputs appear:

```lua
screen.on("added", function(s)
	if s.name == "DP-1" then
		core.output.set_mode("DP-1", 2560, 1440, 144)
		core.output.set_position("DP-1", 0, 0)
	elseif s.name == "eDP-1" then
		core.output.set_position("eDP-1", 2560, 0)
	end
	-- ...tags and bars as above...
end)
```

For scale alone, prefer the screen property: `s.scale` reads the current fractional scale and writing it drives the same verb.

```lua
screen.on("added", function(s)
	if s.name == "eDP-1" then
		s.scale = 1.5
	end
end)
```

Scale is fractional and per-output; kiln solves all layout in logical pixels, so nothing else in your config changes when scale does.

## See also

- [Tag Persistence](/kiln/guides/tag-persistence)
- [Screen reference](/kiln/reference/screen)
- [Core reference](/kiln/reference/core)
- [Limitations](/kiln/concepts/limitations)
