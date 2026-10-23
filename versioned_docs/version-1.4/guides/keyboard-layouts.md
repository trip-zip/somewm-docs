---
sidebar_position: 9
title: Keyboard Layout Switching
description: Configure multiple keyboard layouts and switch between them
---

# Keyboard Layout Switching

Configure a comma-separated list of layouts in `rc.lua`, then register a keybinding to cycle through them.

## Setting Your Layout

```lua
local awful = require("awful")
awful.input.xkb_layout = "us,de,ru"
awful.input.xkb_variant = ",nodeadkeys,"
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"
```

Variant positions correspond to layout positions. Here, only German uses a variant. For one layout, set `xkb_layout = "us"` and leave `xkb_variant` empty.

## Switching Layouts

<span id="why-toggle-options-dont-work" />
<span id="the-solution-keybindings" />

In SomeWM 1.4, use an explicit binding instead of relying on `grp:*` toggle options. This is a SomeWM implementation limitation, not a general restriction of Wayland.

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod1", "Shift" }, "space", function()
        local layouts = awful.widget.keyboardlayout.get_groups_from_group_names(
            awesome.xkb_get_group_names())
        if not layouts or #layouts == 0 then return end
        local current = awesome.xkb_get_layout_group()
        awesome.xkb_set_layout_group((current + 1) % #layouts)
    end, { description = "switch keyboard layout", group = "awesome" }),
})
```

Press **Alt+Shift+Space** to advance through the configured layouts. Group indices start at zero.

## Displaying Current Layout

Create an indicator inside your screen decoration handler and add it to the existing wibar's widget layout:

```lua
local keyboard_layout = awful.widget.keyboardlayout()
```

The widget updates when the active group changes. Clicking it also cycles layouts.

## XKB Options That Work

<span id="complete-example" />

Static mappings can be combined in `xkb_options`, as in the first example:

| Option | Mapping |
| --- | --- |
| `ctrl:nocaps` | Caps Lock becomes Control |
| `ctrl:swapcaps` | Swap Caps Lock and Control |
| `compose:ralt` | Right Alt becomes Compose |
| `caps:escape` | Caps Lock becomes Escape |

Choose one Caps Lock mapping. Each assignment replaces the whole option string.

## See Also

- [Input Device Configuration](input-devices.md)
- [Input Reference](../reference/awful/input.md)
