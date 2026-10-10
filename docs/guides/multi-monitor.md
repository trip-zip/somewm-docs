---
sidebar_position: 3
title: Multi-Monitor Setup
description: Each monitor is a screen with its own tags and bar, set up by connect_for_each_screen. Move windows between screens, react to hotplug, configure by output, and vary tags, layouts, bars and wallpaper per screen.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Multi-Monitor Setup

Every connected monitor is a `screen` with its own tags, wibar and workarea. `awful.screen.connect_for_each_screen` runs its function once per existing screen and again for each screen added later, which is why the default config sets up tags and bars inside it:

```lua
awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.suit.tile)
    s.mywibar = awful.wibar {
        position = "top", screen = s,
        widget = {
            { layout = wibox.layout.fixed.horizontal, s.mytaglist },
            s.mytasklist,
            { layout = wibox.layout.fixed.horizontal, wibox.widget.textclock() },
            layout = wibox.layout.align.horizontal,
        },
    }
end)
```

`screen.primary`, `awful.screen.focused()` and `for s in screen do` are the three ways to reach a screen ([screen reference](/docs/reference/screen)).

## Moving windows

```lua
c:move_to_screen()                                        -- next screen
c:move_to_screen(screen[2])
c:move_to_screen(c.screen:get_next_in_direction("right"))
awful.screen.focus_relative(1)                            -- focus the next screen
```

The default config binds Mod4 + o to focus the next screen and Mod4 + Shift + o to move the focused window there. A rule places an app on a screen: `properties = { screen = 2, tag = "web" }`.

## Hotplug

`screen` emits `added` and `removed`. On removal, `awful.permissions.tag_screen` saves each tag's state and moves its clients to another screen ([Tag Persistence](/docs/guides/tag-persistence)). To decide yourself:

```lua
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)
tag.connect_signal("request::screen", function(t)
    for s in screen do
        if s ~= t.screen then t.screen = s; return end
    end
end)
```

## Configure by output <SomewmOnly /> {#configure-by-output}

`s.output` is the physical connector, which outlives the screen across disable and enable, sleep and docking. Identify monitors by it rather than by index or geometry:

```lua
local output_config = {}

output.connect_signal("added", function(o)
    if o.name:match("^eDP") then
        output_config[o] = { tags = { "1", "2", "3", "4", "5" }, scale = 1.5 }
    elseif o.make == "Dell" and o.model == "U2723QE" then
        output_config[o] = { tags = { "web", "code", "docs" }, scale = 1.25 }
    else
        output_config[o] = { tags = { "web", "code", "docs" }, scale = 1.0 }
    end
    o.scale = output_config[o].scale
end)

screen.connect_signal("request::desktop_decoration", function(s)
    local config = output_config[s.output]
    if config then awful.tag(config.tags, s, awful.layout.suit.tile) end
end)
```

Mode, rotation and position are output properties too:

```lua
output.get_by_name("DP-1").mode = { width = 2560, height = 1440 }
output.get_by_name("DP-2").transform = "90"
output.get_by_name("DP-2").position = { x = 2560, y = 0 }
```

[output reference](/docs/reference/output) has every property.

## Per-screen differences

Branch on the screen inside `connect_for_each_screen`:

```lua
awful.screen.connect_for_each_screen(function(s)
    if s == screen.primary then
        awful.tag({ "code", "web", "mail", "chat", "music" }, s, awful.layout.suit.tile)
        s.mywibar = awful.wibar { position = "top", screen = s }
    else
        awful.tag({ "docs", "term", "logs" }, s, awful.layout.suit.fair)
    end
end)
```

`awful.tag(names, s, layouts)` takes a table of layouts, one per tag, so a secondary screen can default to `fair` while the primary tiles. A laptop panel is usually the one with `s.geometry.width < 1920`, or better, the output named `eDP-*`.

Per-screen wallpaper replaces the default `request::wallpaper` handler:

```lua
local wallpapers = { "/home/user/wallpapers/primary.jpg", "/home/user/wallpapers/secondary.jpg" }

screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            { image = wallpapers[s.index] or wallpapers[1], upscale = true, downscale = true,
              widget = wibox.widget.imagebox },
            valign = "center", halign = "center", tiled = false,
            widget = wibox.container.tile,
        },
    }
end)
```

To move focus to a screen when one of its tags is selected:

```lua
tag.connect_signal("property::selected", function(t)
    if t.selected then t.screen:emit_signal("request::activate", "tag_switch", { raise = false }) end
end)
```

## When a screen is missing or misordered

`somewm-client screen list` or `wlr-randr` shows what the compositor sees. Indices follow detection order, so pick a screen by output name or geometry, not by index, and use rules with `screen = screen.primary` for apps that must land on one screen.

[Fractional Scaling](/docs/guides/fractional-scaling) covers per-screen scale; [The Object Model](/docs/concepts/object-model) the output, screen and client relationship.
