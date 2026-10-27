---
sidebar_position: 8
title: Update widgets from timers and commands
description: Keep widgets updated with timers and signals
---

# Update widgets from timers and commands

Use a timer for periodic data and a signal when the producer can report changes. Built-in property setters request layout and rendering updates. Keep command execution asynchronous so a slow command does not block the compositor.

## Basic Timer

<span id="timers" />

```lua
local gears = require("gears")
local wibox = require("wibox")
local clock = wibox.widget.textbox()
local timer = gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
        clock.text = os.date("%H:%M:%S")
    end,
}
```

Add `clock` to your wibar. `timeout` is in seconds, `autostart` starts periodic updates and `call_now` runs the callback immediately. Use `wibox.widget.textclock()` if you only need a standard clock.

Call `timer:stop()` when removing a dynamically created widget. `timer:start()` starts a stopped timer, and `timer:again()` restarts its countdown.

## One-Shot Timer

```lua
gears.timer.start_new(3, function()
    require("naughty").notification { title = "Delayed notification" }
    return false
end)
```

Returning `false` stops a timer created by `start_new`. Alternatively, construct a `gears.timer` with `single_shot = true` and `autostart = true`.

## Choosing Update Intervals

Match the interval to the data. Battery readings may only need a check every 30 seconds. CPU usage needs two samples over a shorter interval. Network services may impose rate limits. Avoid starting another command while the previous read is still running.

## Async Updates

<span id="commands" />
<span id="a-battery-widget" />

Save this battery widget as `~/.config/somewm/widgets/battery.lua`. Replace `BAT0` with the battery directory on your machine:

```lua
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local widget = wibox.widget.textbox()
local base = "/sys/class/power_supply/BAT0/"
local busy = false
local last_warning

local function update()
    if busy then return end
    busy = true
    awful.spawn.easy_async({ "cat", base .. "capacity", base .. "status" },
        function(stdout, _, _, code)
            busy = false
            local percent, status = stdout:match("^(%d+)%s*\n([^\n]+)")
            percent = tonumber(percent)
            if code ~= 0 or not percent then
                widget.text = "Battery unavailable"
                return
            end
            widget.text = percent .. "% " .. status
            local level = status == "Discharging"
                and (percent <= 10 and 10 or percent <= 20 and 20) or nil
            if level and level ~= last_warning then
                naughty.notification {
                    title = level == 10 and "Battery critical" or "Battery low",
                    message = "Battery at " .. percent .. "%",
                    urgency = level == 10 and "critical" or "normal",
                }
            end
            last_warning = level
        end)
end

local timer = gears.timer {
    timeout = 30,
    autostart = true,
    call_now = true,
    callback = update,
}
widget.stop_updates = function() timer:stop() end
return widget
```

Require `widgets.battery` and add the returned widget to your bar. The example displays a read failure instead of treating it as a zero-percent battery. It warns when entering each low-battery band, then resets when charging or recovering above the threshold.

Do not use `io.popen`, `os.execute` or sleeps for slow work in a widget callback. For commands that require pipes or redirection, use `awful.spawn.easy_async_with_shell`.

## Signal-Based Updates

<span id="signals" />

For data your config controls, emit a custom signal after a successful change:

```lua
local volume_widget = wibox.widget.textbox()
awesome.connect_signal("volume::changed", function(percent)
    volume_widget.text = percent .. "%"
end)
```

A producer would call `awesome.emit_signal("volume::changed", percent)` after reading the new value. This is a custom signal, so changes made by other programs will not emit it automatically. Use a subscription to the audio service or polling if those changes must be reflected too.

Built-in signals such as client `focus`, tag `property::selected` and screen `property::workarea` can update widgets without polling.

## Caching and Debouncing

For several rapid events, restart one timer and update after the events settle:

```lua
local focused_title = wibox.widget.textbox()
local update_timer = gears.timer {
    timeout = 0.1,
    single_shot = true,
    callback = function()
        focused_title.text = client.focus and client.focus.name or ""
    end,
}
local function queue_update()
    update_timer:again()
end
client.connect_signal("focus", queue_update)
client.connect_signal("unfocus", queue_update)
client.connect_signal("property::name", queue_update)
queue_update()
```

When removing this widget, stop the timer and disconnect these handlers. For expensive updates, keep the last successful value and skip rebuilding content when it has not changed.

## Troubleshooting

- **No updates:** start the timer, or set `autostart = true`. Inspect the compositor log for callback errors.
- **Blank initial value:** use `call_now = true`, or set placeholder text while waiting for the first sample.
- **Custom content does not refresh:** emit `widget::redraw_needed` after changing custom state. If its requested size changes, emit `widget::layout_changed` too.
- **Updates continue after removing a widget:** stop its timer and disconnect its signal handlers. Removing it from the layout does not stop those producers.

For custom content, use a [widget composition, Clay description or image surface](custom-widgets.md). Widget `draw`, `fit` and `layout` callbacks are not supported in 2.1.

## See Also

- [Widgets Tutorial](../tutorials/widgets.md)
- [Signals](../concepts/signals.md)
- [AwesomeWM Timer API](https://awesomewm.org/doc/api/libraries/gears.timer.html)
