---
sidebar_position: 8
title: Widget Timers and Updates
description: Update a widget on a gears.timer, from a signal, or from an async command. Intervals that fit each kind of data, why io.popen is never acceptable, caching and debouncing, and a complete battery widget.
---

# Widget Timers and Updates

Setting a widget property (`text`, `value`, `image`) marks it for the next frame; there is nothing to redraw by hand. The question is only when to set it: on a timer, when a signal says something changed, or when an asynchronous command returns.

## Timers

```lua
local clock = wibox.widget.textbox()

gears.timer {
    timeout = 60,
    autostart = true,     -- without it the timer never runs
    call_now = true,      -- run the callback once immediately
    callback = function() clock.text = os.date("%H:%M") end,
}

gears.timer.start_new(3, function()        -- once, after 3 seconds
    naughty.notification { title = "Delayed" }
    return false
end)
```

`timer:start()`, `:stop()` and `:again()` control it later, and `single_shot = true` is the one-off form ([gears.timer upstream](https://awesomewm.org/apidoc/core_components/gears.timer.html)). A timer created repeatedly must stop the previous one or they accumulate.

| Data | Interval |
| --- | --- |
| clock to the minute | 60 s |
| clock to the second | 1 s |
| CPU, memory | 2 to 5 s |
| battery | 30 to 60 s |
| network status | 5 to 10 s |
| weather, an external API | 5 to 10 min |

## Signals

A signal fires only on change, so prefer it to polling where a change has a known source:

```lua
awesome.connect_signal("volume::changed", function(value) volume_widget.text = value .. "%" end)

awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", function()
        awful.spawn.easy_async("wpctl get-volume @DEFAULT_AUDIO_SINK@", function(out)
            awesome.emit_signal("volume::changed", math.floor(out:match("Volume: (%d+%.?%d*)") * 100))
        end)
    end)
end)
```

`client` `focus`, `tag` `property::selected` and `screen` `property::workarea` are the built-in ones widgets most often react to.

## Commands

Never `io.popen` in the compositor: it blocks every frame until the command exits. `awful.spawn.easy_async` and `easy_async_with_shell` call back with the output:

```lua
awful.spawn.easy_async_with_shell("cat /sys/class/power_supply/BAT1/capacity",
    function(stdout, stderr, reason, exit_code)
        battery_widget.text = stdout:gsub("%s+", "") .. "%"
    end)
```

Skip the update when the value did not change, and debounce a burst of triggers:

```lua
local last
local function set(value)
    if value ~= last then last = value; widget.text = value end
end

local pending
local function debounced_update()
    if pending then pending:stop() end
    pending = gears.timer.start_new(0.1, function() do_actual_update(); return false end)
end
```

## A battery widget

```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local battery_icon = wibox.widget.imagebox()
local battery_text = wibox.widget.textbox()
local battery_widget = wibox.widget {
    battery_icon, battery_text, spacing = 4,
    layout = wibox.layout.fixed.horizontal,
}
local last_warning

local function update_battery()
    awful.spawn.easy_async_with_shell([[
        cat /sys/class/power_supply/BAT1/capacity
        cat /sys/class/power_supply/BAT1/status
    ]], function(stdout)
        local lines = {}
        for line in stdout:gmatch("[^\n]+") do lines[#lines + 1] = line end
        local capacity, status = tonumber(lines[1]) or 0, lines[2] or "Unknown"

        battery_text.text = capacity .. "%"
        local icon = status == "Charging" and "battery-charging"
            or capacity > 80 and "battery-full"
            or capacity > 50 and "battery-good"
            or capacity > 20 and "battery-low"
            or "battery-empty"
        battery_icon.image = require("menubar").utils.lookup_icon_uncached(icon .. "-symbolic") or require("beautiful").awesome_icon

        if status == "Charging" then
            last_warning = nil
        elseif capacity <= 10 and last_warning ~= 10 then
            naughty.notification { title = "Battery Critical", message = capacity .. "%", urgency = "critical" }
            last_warning = 10
        elseif capacity <= 20 and last_warning ~= 20 then
            naughty.notification { title = "Battery Low", message = capacity .. "%" }
            last_warning = 20
        end
    end)
end

gears.timer { timeout = 30, autostart = true, call_now = true, callback = update_battery }

return battery_widget
```

A CPU widget is the same shape with `head -1 /proc/stat` and the difference between two readings; a network widget pairs a 10-second timer with a `network::connected` signal you emit from the script that connects.

A timer can update built-in widget properties or assign a newly drawn Cairo surface to an imagebox. The unsupported part is a widget with its own `draw`, `fit` or `layout` callback. See [Create or port a custom widget](./custom-widgets.md) for examples, or [Widgets](../tutorials/widgets.md) for an introduction to composition.
