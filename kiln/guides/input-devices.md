---
title: Input Devices
description: Configure keyboard layouts, key repeat, and pointer behavior through the kiln.input properties.
sidebar_position: 9
---

# Input Devices

Input configuration is a set of plain read/write properties on `kiln.input`. Writing one applies it; reading one returns the last value you wrote (there is no readback from the hardware). The [kiln.input reference](/kiln/reference/kiln#kilninput) lists all 11 properties with their defaults.

## 1. Keyboard layout

Set the keymap once at the top of your config:

```lua
local kiln = require("kiln")

kiln.input.keymap = { layout = "us", variant = "colemak" }
```

All five fields are optional; unset ones take XKB defaults. `options` takes the usual XKB option string, for example `options = "caps:escape"`.

## 2. Layout switching with a bar indicator

Because `kiln.input` reads back what you wrote, the store doubles as the state for an indicator. A toggle bind plus a bar cell:

```lua
local layouts = { "us", "de" }

kiln.input.keymap = { layout = layouts[1] }

kiln.key {
	mods = { "mod" }, key = "i",
	desc = "switch keyboard layout", group = "input",
	press = function()
		local cur = kiln.input.keymap and kiln.input.keymap.layout
		local next_i = 1
		for i, l in ipairs(layouts) do
			if l == cur then
				next_i = i % #layouts + 1
			end
		end
		kiln.input.keymap = { layout = layouts[next_i] }
		kiln.dirty()
	end,
}

-- In your bar function:
screen.on("added", function(s)
	kiln.ui.bar(s, { edge = "top" }, function()
		kiln.widgets.taglist(s)
		kiln.ui.spacer()
		kiln.ui.text((kiln.input.keymap and kiln.input.keymap.layout or "us"),
			{ size = 12, color = kiln.theme.muted })
		kiln.widgets.clock()
	end)
end)
```

The bar function re-runs on every redraw, so the `kiln.dirty()` after the keymap write is what refreshes the label.

## 3. Repeat and numlock

```lua
kiln.input.repeat_rate = 40
kiln.input.repeat_delay = 300
kiln.input.numlock = true
```

Rate and delay always travel together to the keyboard, which is why both have defaults: writing one keeps the other's current value.

## 4. Set up the touchpad and mouse

```lua
kiln.input.tap_to_click = true
kiln.input.natural_scrolling = true
kiln.input.accel_profile = "flat"
kiln.input.accel_speed = 0.3
kiln.input.scroll_method = "two_finger"
kiln.input.click_method = "clickfinger"
```

Each write sends only that field; everything else on the device is untouched. A device that does not support a given setting ignores it, so a config written for a touchpad is harmless on a desktop mouse.

## 5. The all-devices caveat

:::warning
Input settings apply to every device of their kind: there is no per-device targeting. A pointer write configures all pointer devices present at that moment, and a device plugged in later starts with its own defaults until the property is written again. If you hotplug mice or keyboards regularly, re-apply your settings from a bind, or simply reload the config, which re-runs the writes.
:::

## See also

- [kiln module reference](/kiln/reference/kiln)
- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Reload and Debugging](/kiln/guides/reload-and-debugging)
