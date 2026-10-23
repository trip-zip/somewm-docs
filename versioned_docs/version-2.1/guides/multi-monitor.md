---
sidebar_position: 3
title: Multi-Monitor Setup
description: Configure multiple screens and outputs
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Multi-Monitor Setup

Use a screen decoration handler to create tags and a wibar for each active screen. Configure physical displays through their `output` objects.

## Screen Detection

Inspect the active screens and their connectors:

```lua
for s in screen do
    print(s.index, s.output and s.output.name, s.geometry.width, s.geometry.height)
end
```

`screen[1]` is the first screen, `screen.primary` is the designated primary screen and `awful.screen.focused()` follows the screen focus policy. Screen indices can change when outputs are added or removed.

## Per-Screen Setup

The default config already handles `request::desktop_decoration`. Edit that handler rather than registering a second one that creates duplicate tags and bars.

For a minimal config without a decoration handler, this creates tags and a clock bar for every screen:

```lua
local awful = require("awful")
local wibox = require("wibox")

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "dev", "web", "chat", "files", "media" }, s, awful.layout.suit.tile)
    s.mywibar = awful.wibar {
        screen = s,
        position = "top",
        widget = wibox.widget.textclock(),
    }
end)
```

`connect_for_each_screen` calls the function for existing screens and for screens added later. It does not provide the default config's tag restoration logic. Keep that logic when editing the shipped config.

## Moving Windows Between Screens

<span id="moving-windows" />

Add bindings if your config does not already provide them:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "o", function()
        if client.focus then client.focus:move_to_screen() end
    end, { description = "move to next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus next screen", group = "screen" }),
})
```

To move the focused client to a screen on its right:

```lua
local c = client.focus
if c then
    local destination = c.screen:get_next_in_direction("right")
    if destination then c:move_to_screen(destination) end
end
```

Passing a specific screen to `c:move_to_screen(s)` selects that screen. With no argument, the method cycles to the next screen.

## Screen Geometry

`screen.geometry` describes the full logical rectangle. `screen.workarea` excludes panel struts. Both have `x`, `y`, `width` and `height` fields. Screen padding is a separate layout constraint.

## Handling Hotplug

<span id="hotplug" />

`screen` emits `added` and `removed` as displays become available or unavailable. The default `awful.permissions.tag_screen` handler saves tag state when a screen disappears, and the default decoration handler restores it when the connector returns.

To change that behaviour, use the paired save and restore examples in [Tag Persistence](tag-persistence.md). Client rules run when clients are managed, so an initial `screen` rule alone does not control every later hotplug migration.

## Using the Output Object <SomewmOnly />

An output survives being disabled and enabled. Unplugging the display invalidates it, so keep persistent preferences by connector name or hardware identity rather than by the object itself.

### Configure by Hardware {#configure-by-output}

The `added` handler also receives outputs already present when it is connected:

```lua
output.connect_signal("added", function(o)
    if o.name:match("^eDP") then
        o.scale = 1.5
    elseif o.make == "Dell" and o.model == "U2723QE" then
        o.scale = 1.25
    end
end)
```

### Set Resolution and Transform

Look up the connector and check that it exists before assigning settings:

```lua
local o = output.get_by_name("DP-1")
if o then
    o.mode = { width = 2560, height = 1440 }
end

local portrait = output.get_by_name("DP-2")
if portrait then
    portrait.transform = "90"
    portrait.position = { x = 2560, y = 0 }
end
```

Choose a mode supported by the output. Positions are logical coordinates, so account for the neighbouring output's scale. See the [output reference](../reference/output.md) for available modes and configuration properties.

## Different Configurations Per Screen

<span id="per-screen-differences" />

Inside the existing decoration handler, choose default tag names by connector:

```lua
local name = s.output and s.output.name or ""
local names = name:match("^eDP")
    and { "code", "web", "chat" }
    or { "docs", "term", "logs" }
awful.tag(names, s, awful.layout.suit.tile)
```

Use this in the branch that creates new tags, after checking for saved tags. To show a bar only on the primary screen, wrap the bar creation in `if s == screen.primary then ... end`.

## Different Wallpaper Per Screen

Edit the existing `request::wallpaper` handler. Use `awful.wallpaper` in 2.1:

```lua
local gears = require("gears")
screen.connect_signal("request::wallpaper", function(s)
    local name = s.output and s.output.name or ""
    local file = name:match("^eDP") and "laptop.png" or "desktop.png"
    awful.wallpaper {
        screen = s,
        widget = {
            image = gears.filesystem.get_configuration_dir() .. file,
            resize = true,
            widget = wibox.widget.imagebox,
        },
    }
end)
```

Place the images beside `rc.lua`. Each handler uses the screen's current connector, so it also works when outputs reconnect.

## Troubleshooting

<span id="when-a-screen-is-missing-or-misordered" />

Run `somewm-client screen list` to check active screens, or `wlr-randr` to inspect output configuration. Identify monitors by connector or hardware properties when screen order changes. If windows return to the wrong tags after reconnecting, check the save/restore logic described in [Tag Persistence](tag-persistence.md).

## See Also

- [Output Reference](../reference/output.md)
- [Object Model](../concepts/object-model.md)
- [Fractional Scaling](fractional-scaling.md)
- [AwesomeWM Screen API](https://awesomewm.org/doc/api/classes/screen.html)
