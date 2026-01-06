---
sidebar_position: 5
title: Wibar
description: Build a custom status bar from scratch
---

# Wibar

The wibar is the status bar at the top (or bottom) of your screen. In this tutorial, you'll build a custom wibar from scratch.

## How Wibars Work

A wibar is created with `awful.wibar` and attached to a screen. The default setup creates one wibar per screen inside the `request::desktop_decoration` signal:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
        widget = { ... },
    }
end)
```

The `widget` property contains your entire bar layout - typically organized into left, center, and right sections.

## The Three-Section Pattern

Most wibars use `wibox.layout.align.horizontal` to create three sections:

```lua
widget = {
    { -- Left section
        layout = wibox.layout.fixed.horizontal,
        -- widgets go here
    },
    { -- Center section
        layout = wibox.layout.flex.horizontal,
        -- widgets go here
    },
    { -- Right section
        layout = wibox.layout.fixed.horizontal,
        -- widgets go here
    },
    layout = wibox.layout.align.horizontal,
}
```

- **Left** - Fixed width, grows from left edge
- **Center** - Takes remaining space, centers content
- **Right** - Fixed width, grows from right edge

## Creating a Wibar Factory

For cleaner code, create a factory function that builds your wibar:

Create `~/.config/somewm/wibar.lua`:

```lua
-- wibar.lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Factory function that creates a wibar for each screen
return function(s)
    local wibar = awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 24,
        widget = {
            { -- Left section
                layout = wibox.layout.fixed.horizontal,
                -- We'll add widgets here
            },
            { -- Center section
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right section
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        },
    }
    return wibar
end
```

Use it in your `rc.lua`:

```lua
local wibar = require("wibar")

screen.connect_signal("request::desktop_decoration", function(s)
    -- Create tags for this screen
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

    -- Create wibar for this screen
    s.mywibox = wibar(s)
end)
```

## Adding Standard Widgets

Let's populate the wibar with useful widgets:

```lua
-- wibar.lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

return function(s)
    -- Create widgets that need the screen
    s.mypromptbox = awful.widget.prompt()

    s.mylayoutbox = awful.widget.layoutbox {
        screen = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
        },
    }

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        },
    }

    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({}, 3, function()
                awful.menu.client_list { theme = { width = 250 } }
            end),
        },
    }

    local wibar = awful.wibar {
        position = "top",
        screen = s,
        widget = {
            { -- Left section
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Center section
            { -- Right section
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                wibox.widget.textclock(),
                s.mylayoutbox,
            },
            layout = wibox.layout.align.horizontal,
        },
    }

    return wibar
end
```

## Adding Custom Widgets

Add your own widgets from modules:

```lua
-- At the top of wibar.lua
local my_clock = require("widgets.clock")
local my_battery = require("widgets.battery")

-- In the right section:
{ -- Right section
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.systray(),
    my_battery,
    my_clock,
    s.mylayoutbox,
},
```

## Adding Separators

Create visual separation between widget groups:

```lua
local function separator()
    return wibox.widget {
        {
            widget = wibox.widget.separator,
            orientation = "vertical",
            forced_width = 1,
            color = beautiful.fg_normal .. "40",  -- 25% opacity
        },
        margins = { left = 8, right = 8 },
        widget = wibox.container.margin,
    }
end

-- Use in your layout:
{ -- Right section
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.systray(),
    separator(),
    my_battery,
    separator(),
    my_clock,
    separator(),
    s.mylayoutbox,
},
```

## Wibar Properties

For a complete reference of all wibar properties, see the [Wibar Properties Reference](/reference/wibox/wibar).

Key properties include:
- `position` - `"top"`, `"bottom"`, `"left"`, `"right"`
- `height`/`width` - Size in pixels
- `margins` - Create floating effect with gaps
- `shape` - Custom shape function (e.g., rounded corners)
- `bg`/`fg` - Colors (can include alpha for transparency)

## Styling the Wibar

### Through Theme Variables

In your `theme.lua`:

```lua
theme.wibar_bg = "#282828"
theme.wibar_fg = "#ebdbb2"
theme.wibar_height = 28
theme.wibar_border_color = "#3c3836"
theme.wibar_border_width = 1
```

### Inline Styling

```lua
awful.wibar {
    position = "top",
    screen = s,
    bg = beautiful.wibar_bg .. "e0",  -- Slightly transparent
    fg = beautiful.wibar_fg,
    border_width = 1,
    border_color = beautiful.wibar_border_color,
}
```

## Complete Example

Here's a complete wibar module with all features:

```lua
-- wibar.lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Optional: import custom widgets
-- local widgets = require("widgets")

-- Separator widget
local function separator()
    return wibox.widget {
        {
            orientation = "vertical",
            forced_width = 1,
            color = beautiful.fg_normal .. "30",
            widget = wibox.widget.separator,
        },
        top = 6,
        bottom = 6,
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    }
end

-- Wibar factory function
return function(s)
    -- Per-screen widgets
    s.mypromptbox = awful.widget.prompt()

    s.mylayoutbox = awful.widget.layoutbox {
        screen = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(-1) end),
            awful.button({}, 5, function() awful.layout.inc(1) end),
        },
    }

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        },
    }

    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({}, 3, function()
                awful.menu.client_list { theme = { width = 250 } }
            end),
            awful.button({}, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({}, 5, function() awful.client.focus.byidx(1) end),
        },
    }

    -- Create the wibar
    local wibar = awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 28,
        bg = beautiful.wibar_bg,
        fg = beautiful.wibar_fg,
        widget = {
            { -- Left section
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                separator(),
                s.mypromptbox,
            },
            { -- Center section
                s.mytasklist,
                layout = wibox.layout.flex.horizontal,
            },
            { -- Right section
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                separator(),
                awful.widget.keyboardlayout(),
                separator(),
                wibox.widget.textclock(" %a %b %d, %H:%M "),
                separator(),
                s.mylayoutbox,
            },
            layout = wibox.layout.align.horizontal,
        },
    }

    return wibar
end
```

{/* TODO: Screenshot needed
   - Custom wibar with all sections visible
   - Show taglist, tasklist, systray, clock, layoutbox
*/}

## Multiple Wibars

You can have multiple wibars on a screen:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    -- Top bar with tags and systray
    s.top_wibar = awful.wibar {
        position = "top",
        screen = s,
        widget = { ... },
    }

    -- Bottom bar with tasklist only
    s.bottom_wibar = awful.wibar {
        position = "bottom",
        screen = s,
        widget = s.mytasklist,
    }
end)
```

## Toggling Visibility

Hide/show the wibar with a keybinding:

```lua
awful.key({ modkey }, "b", function()
    local s = awful.screen.focused()
    s.mywibox.visible = not s.mywibox.visible
end, { description = "toggle wibar", group = "awesome" }),
```

## Troubleshooting

### Wibar not showing

1. Check that you're returning the wibar from your factory function
2. Verify it's being called in `request::desktop_decoration`
3. Try adding explicit `height` to ensure it has size

### Widgets cut off

The wibar may be too short. Increase the height:

```lua
awful.wibar {
    height = 32,  -- Increase from default
    ...
}
```

### Systray icons not showing

The systray can only be on one screen. Make sure it's only added once:

```lua
-- Only add systray to primary screen
if s == screen.primary then
    -- add wibox.widget.systray()
end
```

## Next Steps

- **[Wibar Properties Reference](/reference/wibox/wibar)** - Complete wibar configuration reference
- **[Widgets](/tutorials/widgets)** - Create custom widgets for your wibar
- **[Theme](/tutorials/theme)** - Style your wibar
- **[awful.wibar (AwesomeWM docs)](https://awesomewm.org/apidoc/classes/awful.wibar.html)** - Upstream API reference
