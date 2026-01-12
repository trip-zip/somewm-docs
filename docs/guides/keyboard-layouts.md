---
sidebar_position: 9
title: Keyboard Layout Switching
description: Configure multiple keyboard layouts and switch between them
---

# Keyboard Layout Switching

This guide covers setting up multiple keyboard layouts and switching between them in SomeWM.

## Setting Your Layout

Configure your keyboard layout in `rc.lua` using `awful.input`:

```lua
local awful = require("awful")

-- Single layout
awful.input.xkb_layout = "us"

-- Multiple layouts (comma-separated)
awful.input.xkb_layout = "us,de,ru"

-- With variants
awful.input.xkb_variant = ",nodeadkeys,"  -- variant for each layout
```

## Switching Layouts

### Why Toggle Options Don't Work

In X11, XKB toggle options like `grp:alt_shift_toggle` work because the X server executes the layout switch when you press the key combination. On Wayland, there's no X server to do this - the toggle key is just a key press that never triggers a switch.

Sway, Hyprland, and other Wayland compositors have the same limitation.

### The Solution: Keybindings

Create an explicit keybinding to cycle through your layouts:

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local layouts = awful.widget.keyboardlayout.get_groups_from_group_names(
        awesome.xkb_get_group_names())
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % #layouts)
end, {description = "switch keyboard layout", group = "awesome"})
```

Or a simpler version if you know you have exactly 2 layouts:

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % 2)
end, {description = "switch keyboard layout", group = "awesome"})
```

## Displaying Current Layout

Add a keyboard layout indicator to your wibar:

```lua
local awful = require("awful")

-- Create the widget
local keyboard_layout = awful.widget.keyboardlayout()

-- Add to your wibar
s.mywibox = awful.wibar({
    position = "top",
    screen = s,
    widget = {
        -- ... other widgets ...
        keyboard_layout,
        -- ... other widgets ...
    }
})
```

The widget automatically updates when you switch layouts.

## XKB Options That Work

Static XKB options still work fine on Wayland. Only toggle options (`grp:*`) are affected:

```lua
-- These work
awful.input.xkb_options = "ctrl:nocaps"       -- Caps Lock as Ctrl
awful.input.xkb_options = "ctrl:swapcaps"     -- Swap Caps Lock and Ctrl
awful.input.xkb_options = "compose:ralt"      -- Right Alt as Compose
awful.input.xkb_options = "caps:escape"       -- Caps Lock as Escape

-- These do NOT trigger automatic switching
awful.input.xkb_options = "grp:alt_shift_toggle"
awful.input.xkb_options = "grp:win_space_toggle"
```

You can combine working options:

```lua
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"
```

## Complete Example

```lua
local awful = require("awful")

-- Set up layouts
awful.input.xkb_layout = "us,de"
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"

-- Keybinding to switch
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod1", "Shift" }, "space", function()
        local layouts = awful.widget.keyboardlayout.get_groups_from_group_names(
            awesome.xkb_get_group_names())
        local current = awesome.xkb_get_layout_group()
        awesome.xkb_set_layout_group((current + 1) % #layouts)
    end, {description = "switch keyboard layout", group = "awesome"})
})
```

## See Also

- [Input Device Configuration](/guides/input-devices) - Pointer and other keyboard settings
- [awful.input Reference](/reference/awful/input) - All input properties
- [Wayland vs X11](/concepts/wayland-vs-x11) - Why some features work differently
