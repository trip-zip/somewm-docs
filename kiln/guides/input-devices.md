---
title: Input Devices
description: Configure keyboard layouts, key repeat, and pointer behavior through the some.input properties.
sidebar_position: 8
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Input Devices

<YouWillLearn>

- The `some.input` property surface and its defaults
- Switching keyboard layouts from a bind, with a bar indicator
- Key repeat, numlock, and pointer settings
- The all-devices caveat

</YouWillLearn>

Input configuration is a set of plain read/write properties on `some.input`. Writing one applies it; reading one returns the last value you wrote (there is no readback from the hardware, so an unwritten property reads `nil` unless a default is listed below).

| Property | Default | Meaning |
|---|---|---|
| `keymap` | unset | `{ rules, model, layout, variant, options }`, XKB names |
| `repeat_rate` | `25` | key repeats per second |
| `repeat_delay` | `600` | ms before repeat starts |
| `numlock` | unset | boolean, numlock LED state |
| `tap_to_click` | unset | boolean, touchpad tap |
| `natural_scrolling` | unset | boolean |
| `left_handed` | unset | boolean, swaps pointer buttons |
| `accel_speed` | unset | number, -1.0 to 1.0 |
| `accel_profile` | unset | `"flat"`, anything else selects adaptive |
| `scroll_method` | unset | `"two_finger"`, `"edge"`, `"button"`, other values disable scrolling |
| `click_method` | unset | `"button_areas"`, `"clickfinger"` |

## 1. Keyboard layout

Set the keymap once at the top of your config:

```lua
local some = require("somewm")

some.input.keymap = { layout = "us", variant = "colemak" }
```

All five fields are optional; unset ones take XKB defaults. `options` takes the usual XKB option string, for example `options = "caps:escape"`.

## 2. Layout switching with a bar indicator

Because `some.input` reads back what you wrote, the store doubles as the state for an indicator. A toggle bind plus a bar cell:

```lua
local layouts = { "us", "de" }

some.input.keymap = { layout = layouts[1] }

some.key {
	mods = { "mod" }, key = "i",
	desc = "switch keyboard layout", group = "input",
	press = function()
		local cur = some.input.keymap and some.input.keymap.layout
		local next_i = 1
		for i, l in ipairs(layouts) do
			if l == cur then
				next_i = i % #layouts + 1
			end
		end
		some.input.keymap = { layout = layouts[next_i] }
		some.dirty()
	end,
}

-- In your bar function:
screen.on("added", function(s)
	some.ui.bar(s, { edge = "top" }, function()
		some.ui.taglist(s)
		some.ui.spacer()
		some.ui.text((some.input.keymap and some.input.keymap.layout or "us"),
			{ size = 12, color = some.theme.muted })
		some.ui.clock()
	end)
end)
```

The bar function re-runs on every redraw, so the `some.dirty()` after the keymap write is what refreshes the label.

## 3. Repeat and numlock

```lua
some.input.repeat_rate = 40
some.input.repeat_delay = 300
some.input.numlock = true
```

Rate and delay always travel together to the keyboard, which is why both have defaults: writing one keeps the other's current value.

## 4. Pointer settings

```lua
some.input.tap_to_click = true
some.input.natural_scrolling = true
some.input.accel_profile = "flat"
some.input.accel_speed = 0.3
some.input.scroll_method = "two_finger"
some.input.click_method = "clickfinger"
```

Each write sends only that field; everything else on the device is untouched. A device that does not support a given setting ignores it, so a config written for a touchpad is harmless on a desktop mouse.

## 5. The all-devices caveat

:::warning
Input settings apply to every device of their kind: there is no per-device targeting. A pointer write configures all pointer devices present at that moment, and a device plugged in later starts with its own defaults until the property is written again. If you hotplug mice or keyboards regularly, re-apply your settings from a bind, or simply reload the config, which re-runs the writes.
:::

## See also

- [Some module reference](/kiln/reference/some)
- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Reload and Debugging](/kiln/guides/reload-and-debugging)
