---
sidebar_position: 8
title: Widget Timers and Updates
description: Keep widgets updated with timers and signals
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Widget Timers and Updates

<YouWillLearn>

- Using gears.timer for periodic updates
- Efficient update patterns
- Signal-based updates vs polling
- Handling async operations in widgets

</YouWillLearn>

Widgets often need to update their content - clocks tick, battery levels change, network status updates. This guide covers the patterns for keeping widgets current.

## Basic Timer

Use `gears.timer` for periodic updates:

```lua
local gears = require("gears")
local wibox = require("wibox")

local clock = wibox.widget.textbox()

local function update_clock()
    clock.text = os.date("%H:%M")
end

gears.timer {
    timeout = 60,        -- Update every 60 seconds
    autostart = true,    -- Start immediately
    call_now = true,     -- Call once right away
    callback = update_clock,
}
```

### Timer Properties

| Property | Type | Description |
|----------|------|-------------|
| `timeout` | number | Seconds between callbacks |
| `autostart` | boolean | Start timer when created |
| `call_now` | boolean | Call callback immediately |
| `single_shot` | boolean | Only fire once, then stop |
| `callback` | function | Function to call |

### Timer Methods

```lua
local timer = gears.timer {
    timeout = 5,
    callback = update_function,
}

timer:start()   -- Start the timer
timer:stop()    -- Stop the timer
timer:again()   -- Restart the timer (resets countdown)

-- Check if running
if timer.started then
    print("Timer is running")
end
```

## One-Shot Timer

For delayed one-time actions:

```lua
-- Run once after 3 seconds
gears.timer.start_new(3, function()
    naughty.notify { title = "Delayed notification" }
    return false  -- Don't repeat
end)
```

Or using `single_shot`:

```lua
gears.timer {
    timeout = 3,
    single_shot = true,
    autostart = true,
    callback = function()
        -- This runs once after 3 seconds
    end,
}
```

## Choosing Update Intervals

Choose intervals based on what you're displaying:

| Widget Type | Recommended Interval | Reason |
|-------------|---------------------|--------|
| Clock (HH:MM) | 60s | Only need minute precision |
| Clock (HH:MM:SS) | 1s | Need second precision |
| CPU/Memory | 2-5s | Frequent enough to be useful |
| Battery | 30-60s | Changes slowly |
| Weather | 300-600s | External API, changes slowly |
| Network status | 5-10s | Balance responsiveness and overhead |

**Don't update more frequently than needed** - it wastes CPU cycles.

## Signal-Based Updates

When possible, use signals instead of polling. Signals only fire when something changes:

```lua
-- React to volume changes (custom signal)
awesome.connect_signal("volume::changed", function(value)
    volume_widget.text = value .. "%"
end)

-- In your keybinding when volume changes:
awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", function()
        awful.spawn.easy_async("wpctl get-volume @DEFAULT_AUDIO_SINK@", function(out)
            local volume = out:match("Volume: (%d+%.?%d*)")
            awesome.emit_signal("volume::changed", math.floor(volume * 100))
        end)
    end)
end)
```

### Built-in Signals

SomeWM provides many signals you can react to:

```lua
-- Client focus changed
client.connect_signal("focus", function(c)
    update_focused_client_widget(c)
end)

-- Tag selection changed
tag.connect_signal("property::selected", function(t)
    update_taglist()
end)

-- Screen workarea changed
screen.connect_signal("property::workarea", function(s)
    reposition_widgets(s)
end)
```

## Async Updates

For commands that take time (shell commands, network requests), use async spawning:

```lua
local battery_widget = wibox.widget.textbox()

local function update_battery()
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT1/capacity",
        function(stdout, stderr, reason, exit_code)
            local capacity = stdout:gsub("%s+", "")  -- Trim whitespace
            battery_widget.text = capacity .. "%"
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

### Non-Blocking Pattern

Never use blocking calls in the main loop:

```lua
-- WRONG: Blocks the compositor
local handle = io.popen("some-slow-command")
local result = handle:read("*a")
handle:close()

-- RIGHT: Non-blocking
awful.spawn.easy_async("some-slow-command", function(result)
    -- Use result here
end)
```

## Complete Widget Example

A battery widget with percentage, icon, and warning:

```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

-- Create widget components
local battery_icon = wibox.widget.imagebox()
local battery_text = wibox.widget.textbox()

-- Combine into one widget
local battery_widget = wibox.widget {
    battery_icon,
    battery_text,
    spacing = 4,
    layout = wibox.layout.fixed.horizontal,
}

-- Track last warning level
local last_warning = nil

local function update_battery()
    awful.spawn.easy_async_with_shell([[
        cat /sys/class/power_supply/BAT1/capacity
        cat /sys/class/power_supply/BAT1/status
    ]], function(stdout)
        local lines = {}
        for line in stdout:gmatch("[^\n]+") do
            table.insert(lines, line)
        end

        local capacity = tonumber(lines[1]) or 0
        local status = lines[2] or "Unknown"

        -- Update text
        battery_text.text = capacity .. "%"

        -- Update icon based on level
        local icon_name
        if status == "Charging" then
            icon_name = "battery-charging"
        elseif capacity > 80 then
            icon_name = "battery-full"
        elseif capacity > 50 then
            icon_name = "battery-good"
        elseif capacity > 20 then
            icon_name = "battery-low"
        else
            icon_name = "battery-empty"
        end

        battery_icon.image = "/usr/share/icons/Adwaita/symbolic/status/"
            .. icon_name .. "-symbolic.svg"

        -- Warning notifications
        if status ~= "Charging" then
            if capacity <= 10 and last_warning ~= 10 then
                naughty.notify {
                    title = "Battery Critical",
                    text = "Battery at " .. capacity .. "%",
                    urgency = "critical",
                }
                last_warning = 10
            elseif capacity <= 20 and last_warning ~= 20 then
                naughty.notify {
                    title = "Battery Low",
                    text = "Battery at " .. capacity .. "%",
                    urgency = "normal",
                }
                last_warning = 20
            end
        else
            last_warning = nil
        end
    end)
end

-- Update every 30 seconds
gears.timer {
    timeout = 30,
    autostart = true,
    call_now = true,
    callback = update_battery,
}

return battery_widget
```

## Caching and Debouncing

### Caching

Avoid redundant updates:

```lua
local last_value = nil

local function update_widget()
    awful.spawn.easy_async("command", function(stdout)
        local new_value = stdout:gsub("%s+", "")

        -- Only update if changed
        if new_value ~= last_value then
            last_value = new_value
            widget.text = new_value
        end
    end)
end
```

### Debouncing

Prevent rapid repeated updates:

```lua
local update_timer = nil

local function debounced_update()
    if update_timer then
        update_timer:stop()
    end

    update_timer = gears.timer.start_new(0.1, function()
        do_actual_update()
        return false  -- One-shot
    end)
end

-- Call debounced_update() from anywhere
-- It will wait 100ms before actually updating
```

## Common Patterns

### Network Widget (Signal-Based + Timer)

```lua
local network_widget = wibox.widget.textbox()

local function update_network()
    awful.spawn.easy_async_with_shell(
        "iwctl station wlan0 show | grep 'Connected network' | awk '{print $3}'",
        function(stdout)
            local ssid = stdout:gsub("%s+", "")
            network_widget.text = ssid ~= "" and ssid or "Disconnected"
        end
    )
end

-- Periodic check
gears.timer {
    timeout = 10,
    autostart = true,
    call_now = true,
    callback = update_network,
}

-- Also update on signal (if you emit one when connecting)
awesome.connect_signal("network::connected", update_network)
```

### CPU Widget (Polling)

```lua
local cpu_widget = wibox.widget.textbox()
local prev_idle, prev_total = 0, 0

local function update_cpu()
    awful.spawn.easy_async_with_shell(
        "head -1 /proc/stat | awk '{print $2+$3+$4+$5+$6+$7+$8, $5}'",
        function(stdout)
            local total, idle = stdout:match("(%d+) (%d+)")
            total, idle = tonumber(total), tonumber(idle)

            local diff_total = total - prev_total
            local diff_idle = idle - prev_idle

            local usage = 100 * (1 - diff_idle / diff_total)
            cpu_widget.text = string.format("CPU: %.0f%%", usage)

            prev_total, prev_idle = total, idle
        end
    )
end

gears.timer {
    timeout = 2,
    autostart = true,
    call_now = true,
    callback = update_cpu,
}
```

## Troubleshooting

### Timer Not Running

Make sure `autostart = true`:

```lua
gears.timer {
    timeout = 1,
    autostart = true,  -- Don't forget this!
    callback = my_function,
}
```

### Widget Not Updating Visually

Widgets update automatically when properties change. If using custom drawing:

```lua
widget:emit_signal("widget::redraw_needed")
```

### Memory Leaks

If creating timers dynamically, make sure to stop old ones:

```lua
local my_timer = nil

local function start_updates()
    if my_timer then
        my_timer:stop()
    end

    my_timer = gears.timer {
        timeout = 1,
        autostart = true,
        callback = update_function,
    }
end
```

## See Also

- **[First Widget](/tutorials/first-widget)** - Complete widget tutorial
- **[Architecture](/concepts/architecture)** - Understanding signals
- **[AwesomeWM Timer Docs](https://awesomewm.org/doc/api/libraries/gears.timer.html)** - Full timer API
