---
sidebar_position: 2
title: Widgets
description: Build a simple clock widget from scratch
---

# Widgets

Widgets are the building blocks of your SomeWM interface. In this tutorial, you'll build a custom clock widget from scratch to understand how the widget system works.

## Widget Basics

Wibars, titlebars, notifications, and tooltips are all built from widgets. There are three main types:

| Type | Purpose | Examples |
|------|---------|----------|
| **Primitives** | Display content | `textbox`, `imagebox`, `progressbar` |
| **Containers** | Modify a single widget | `background`, `margin`, `constraint` |
| **Layouts** | Arrange multiple widgets | `fixed`, `flex`, `align` |

Widgets compose together like nesting boxes:

```lua
-- A textbox inside a margin inside a background
wibox.widget {
    {
        {
            text = "Hello",
            widget = wibox.widget.textbox,
        },
        margins = 4,
        widget = wibox.container.margin,
    },
    bg = "#ff0000",
    widget = wibox.container.background,
}
```

## Your First Textbox

Let's start simple - a text widget:

```lua
local wibox = require("wibox")

local my_text = wibox.widget {
    text = "Hello, SomeWM!",
    widget = wibox.widget.textbox,
}
```

That's it! `my_text` is now a widget you can add to your wibar.

## Building a Clock Widget

Now let's build something useful - a clock that updates every second.

### Step 1: Create the Widget

Create a file `~/.config/somewm/widgets/clock.lua`:

```lua
-- widgets/clock.lua
local wibox = require("wibox")
local gears = require("gears")

local clock = wibox.widget {
    text = "",
    widget = wibox.widget.textbox,
}

return clock
```

### Step 2: Add Time Updates

We need to update the clock regularly. Use `gears.timer`:

```lua
-- widgets/clock.lua
local wibox = require("wibox")
local gears = require("gears")

local clock = wibox.widget {
    text = "",
    widget = wibox.widget.textbox,
}

-- Update function
local function update_clock()
    clock.text = os.date("%H:%M:%S")
end

-- Timer that runs every second
gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,  -- Run immediately on startup
    callback = update_clock,
}

return clock
```

### Step 3: Use it in Your Config

In your `rc.lua`, require and add the widget:

```lua
-- Near the top, after other requires
local my_clock = require("widgets.clock")

-- In your wibar setup (screen.connect_signal "request::desktop_decoration")
s.mywibox = awful.wibar {
    position = "top",
    screen = s,
    widget = {
        layout = wibox.layout.align.horizontal,
        { -- Left
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
        },
        s.mytasklist, -- Middle
        { -- Right
            layout = wibox.layout.fixed.horizontal,
            my_clock,  -- Add your widget here!
            s.mylayoutbox,
        },
    },
}
```

Reload with **Mod4 + Ctrl + r** and you should see your clock!

## Adding an Icon

Let's enhance the clock with an icon using `imagebox`:

```lua
-- widgets/clock.lua
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Icon widget
local clock_icon = wibox.widget {
    image = "/usr/share/icons/Adwaita/16x16/status/clock-symbolic.png",
    resize = true,
    widget = wibox.widget.imagebox,
}

-- Text widget
local clock_text = wibox.widget {
    text = "",
    widget = wibox.widget.textbox,
}

-- Combine them with a layout
local clock = wibox.widget {
    clock_icon,
    clock_text,
    spacing = 4,
    layout = wibox.layout.fixed.horizontal,
}

-- Update function
local function update_clock()
    clock_text.text = os.date("%H:%M")
end

gears.timer {
    timeout = 60,  -- Every minute is enough now
    autostart = true,
    call_now = true,
    callback = update_clock,
}

return clock
```

## Styling with Containers

Add some visual polish with containers:

```lua
local clock = wibox.widget {
    {
        {
            clock_icon,
            clock_text,
            spacing = 4,
            layout = wibox.layout.fixed.horizontal,
        },
        margins = 4,
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_focus,
    fg = beautiful.fg_focus,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
}
```

This adds:
- **Margin container** - 4px padding around the content
- **Background container** - colored background and rounded corners

## Adding a Tooltip

Tooltips show extra info on hover:

```lua
local awful = require("awful")

-- After creating your widget
local clock_tooltip = awful.tooltip {
    objects = { clock },
    timer_function = function()
        return os.date("%A, %B %d, %Y")
    end,
}
```

Now hovering shows the full date!

## Adding Click Handlers

Make widgets interactive with `add_button`:

```lua
clock:add_button(awful.button({}, 1, function()
    -- Left click: show notification
    local naughty = require("naughty")
    naughty.notify {
        title = "Current Time",
        text = os.date("%A, %B %d, %Y\n%H:%M:%S"),
    }
end))

clock:add_button(awful.button({}, 3, function()
    -- Right click: spawn calendar app
    awful.spawn("gnome-calendar")
end))
```

Button numbers: `1` = left, `2` = middle, `3` = right.

## Complete Example

Here's a polished clock widget with all features:

```lua
-- widgets/clock.lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Icon (use any clock icon you have)
local clock_icon = wibox.widget {
    image = gears.color.recolor_image(
        "/usr/share/icons/Adwaita/symbolic/status/clock-symbolic.svg",
        beautiful.fg_normal
    ),
    forced_width = 16,
    forced_height = 16,
    widget = wibox.widget.imagebox,
}

-- Time text
local clock_text = wibox.widget {
    text = "",
    font = beautiful.font,
    widget = wibox.widget.textbox,
}

-- Combine with styling
local clock = wibox.widget {
    {
        {
            clock_icon,
            clock_text,
            spacing = 6,
            layout = wibox.layout.fixed.horizontal,
        },
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_normal,
    widget = wibox.container.background,
}

-- Hover effect
clock:connect_signal("mouse::enter", function(w)
    w.bg = beautiful.bg_focus
end)

clock:connect_signal("mouse::leave", function(w)
    w.bg = beautiful.bg_normal
end)

-- Tooltip with full date
awful.tooltip {
    objects = { clock },
    timer_function = function()
        return os.date("%A, %B %d, %Y")
    end,
}

-- Click to show notification
clock:add_button(awful.button({}, 1, function()
    naughty.notify {
        title = "Current Time",
        text = os.date("%A, %B %d, %Y\n%H:%M:%S"),
        timeout = 5,
    }
end))

-- Update function
local function update_clock()
    clock_text.text = os.date(" %H:%M")
end

-- Timer
gears.timer {
    timeout = 60,
    autostart = true,
    call_now = true,
    callback = update_clock,
}

return clock
```

{/* TODO: Screenshot needed
   - Custom clock widget in wibar
   - Show both the widget and tooltip on hover
*/}

## Common Widget Patterns

### Running Shell Commands

For widgets that need system info (battery, volume, etc.):

```lua
local function update_battery()
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT1/capacity",
        function(stdout)
            battery_text.text = stdout:gsub("\n", "") .. "%"
        end
    )
end

gears.timer {
    timeout = 30,
    autostart = true,
    call_now = true,
    callback = update_battery,
}
```

### Reacting to Signals

For real-time updates based on events:

```lua
-- Listen for volume changes
awesome.connect_signal("volume::update", function()
    update_volume_widget()
end)

-- In your keybinding when volume changes:
awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", function()
    awesome.emit_signal("volume::update")
end)
```

### Getting Children by ID

For complex widgets, use IDs to access nested parts:

```lua
local my_widget = wibox.widget {
    {
        id = "text_role",
        text = "",
        widget = wibox.widget.textbox,
    },
    {
        id = "icon_role",
        widget = wibox.widget.imagebox,
    },
    layout = wibox.layout.fixed.horizontal,
}

-- Later, update specific children:
local text = my_widget:get_children_by_id("text_role")[1]
text.text = "Updated!"
```

## Widget Reference

For the full list of all primitives, containers, and layouts, see the [wibox reference](/reference/wibox/).

## Troubleshooting

### Widget not showing

1. Make sure you `return` the widget from your module
2. Check that it's added to the wibar layout
3. Try adding `forced_width` and `forced_height` to see if it has size

### Timer not running

Make sure `autostart = true` is set:

```lua
gears.timer {
    timeout = 1,
    autostart = true,  -- Don't forget this!
    callback = update_function,
}
```

### Images not loading

Check the path and use absolute paths:

```lua
-- Instead of relative path
image = "~/.config/somewm/icons/clock.svg"

-- Use absolute or expand it
image = os.getenv("HOME") .. "/.config/somewm/icons/clock.svg"
```

## Next Steps

- **[Wibar](/tutorials/wibar)** - Build a complete status bar
- **[Theme](/tutorials/theme)** - Style your widgets
- **[AwesomeWM Widget Docs](https://awesomewm.org/doc/api/classes/wibox.widget.html)** - Full widget reference
