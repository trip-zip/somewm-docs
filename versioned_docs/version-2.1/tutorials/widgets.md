---
sidebar_position: 2
title: Widgets
description: Build a clock widget in its own module, update it on a timer, add an icon, containers, a tooltip and click handlers, and put it in the bar.
---

# Widgets

Compose widgets from primitives (`textbox`, `imagebox`), single-child containers (`margin`, `background`), and layouts (`fixed`, `flex`, `align`). They nest in declarative tables:

```lua
wibox.widget {
    { { text = "Hello", widget = wibox.widget.textbox },
      margins = 4, widget = wibox.container.margin },
    bg = "#ff0000",
    widget = wibox.container.background,
}
```

## 1. A clock module

`~/.config/somewm/widgets/clock.lua`:

```lua
local wibox = require("wibox")
local gears = require("gears")

local clock = wibox.widget {
    text = "",
    widget = wibox.widget.textbox,
}

gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function() clock.text = os.date("%H:%M:%S") end,
}

return clock
```

## 2. Put it in the bar

In `rc.lua`, require it after `beautiful.init()`:

```lua
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
local my_clock = require("widgets.clock")
```

:::warning
A module required before `beautiful.init()` may copy nil theme values without an error. Loading the theme later does not update those copies.
:::

Then in the right section of the bar:

```lua
{ layout = wibox.layout.fixed.horizontal, my_clock, s.mylayoutbox },
```

Mod4 + Ctrl + r shows the clock.

## 3. An icon, containers, a tooltip, clicks

```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local clock_icon = wibox.widget {
    image = gears.color.recolor_image(
        require("menubar").utils.lookup_icon_uncached("clock-symbolic") or beautiful.awesome_icon,
        beautiful.fg_normal
    ),
    forced_width = 16,
    forced_height = 16,
    widget = wibox.widget.imagebox,
}

local clock_text = wibox.widget {
    text = "",
    font = beautiful.font,
    widget = wibox.widget.textbox,
}

local clock = wibox.widget {
    {
        { clock_icon, clock_text, spacing = 6, layout = wibox.layout.fixed.horizontal },
        left = 8, right = 8,
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_normal,
    widget = wibox.container.background,
}

clock:connect_signal("mouse::enter", function(w) w.bg = beautiful.bg_focus end)
clock:connect_signal("mouse::leave", function(w) w.bg = beautiful.bg_normal end)

awful.tooltip {
    objects = { clock },
    timer_function = function() return os.date("%A, %B %d, %Y") end,
}

clock:add_button(awful.button({}, 1, function()      -- 1 left, 2 middle, 3 right
    naughty.notification {
        title = "Current Time",
        message = os.date("%A, %B %d, %Y\n%H:%M:%S"),
        timeout = 5,
    }
end))

gears.timer {
    timeout = 60,
    autostart = true,
    call_now = true,
    callback = function() clock_text.text = os.date(" %H:%M") end,
}

return clock
```

The margin pads the row, the background colours it and changes on hover, the tooltip shows the date, and a left click posts a notification. `shape = gears.shape.rounded_rect` on the background rounds its corners.

## Patterns

**Shell output.** Run the command asynchronously and set the text in the callback:

```lua
gears.timer {
    timeout = 30, autostart = true, call_now = true,
    callback = function()
        awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT1/capacity",
            function(stdout) battery_text.text = stdout:gsub("\n", "") .. "%" end)
    end,
}
```

**Signals.** Emit a custom signal where the change happens and update where the widget is:

```lua
awesome.connect_signal("volume::update", update_volume_widget)
-- in the keybinding:
awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+",
    function() awesome.emit_signal("volume::update") end)
```

**Children by id.** Name a nested widget and fetch it later:

```lua
local w = wibox.widget {
    { id = "text_role", text = "", widget = wibox.widget.textbox },
    { id = "icon_role", widget = wibox.widget.imagebox },
    layout = wibox.layout.fixed.horizontal,
}
w:get_children_by_id("text_role")[1].text = "Updated!"
```

## If a widget is missing

- The module must `return` the widget, and the bar must include it.
- A line in the log ending `is left out of the tree` names a widget with its own `draw` or `fit`, left out with everything inside it. Compose it from stock widgets ([Upgrading from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md#what-you-will-see)).
- `somewm-client clay tree` shows the widget's line with its size and where the size came from ([Reading the tree](../concepts/reading-the-tree.md)).
- A timer needs `autostart = true`. An image path must be absolute: `os.getenv("HOME") .. "/.config/somewm/icons/clock.svg"`.

[wibox reference](../reference/wibox/index.md) lists every primitive, container and layout; [Wibar](wibar.md) builds the bar around this widget.
