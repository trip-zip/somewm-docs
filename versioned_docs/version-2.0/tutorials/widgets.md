---
sidebar_position: 2
title: Widgets
description: Build a simple clock widget from scratch
---

# Widgets

<span id="widget-basics" />
<span id="your-first-textbox" />
<span id="building-a-clock-widget" />
<span id="step-1-create-the-widget" />
<span id="step-2-add-time-updates" />

Build a clock for the default 2.0 wibar, then add styling, a tooltip, and a click action. The clock uses a textbox and a timer so you can reuse the same pattern for other widgets. SomeWM also provides `wibox.widget.textclock` for a ready-made clock.

## Create a clock module

Create a directory beside your `rc.lua`:

```bash
mkdir -p ~/.config/somewm/widgets
```

If your config is elsewhere, use that directory. Save this as `widgets/clock.lua`:

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
    callback = function()
        clock.text = os.date("%H:%M:%S")
    end,
}

return clock
```

`call_now` fills the textbox immediately. The timer then updates it every second.

## Put it in the bar {#step-3-use-it-in-your-config}

<span id="adding-an-icon" />
<span id="styling-with-containers" />
<span id="adding-a-tooltip" />
<span id="adding-click-handlers" />
<span id="complete-example" />
<span id="common-widget-patterns" />
<span id="running-shell-commands" />
<span id="reacting-to-signals" />
<span id="getting-children-by-id" />
<span id="widget-reference" />
<span id="troubleshooting" />
<span id="widget-not-showing" />
<span id="widget-ignores-the-theme-wrong-font-no-colors" />
<span id="timer-not-running" />
<span id="images-not-loading" />
<span id="next-steps" />

After the existing `beautiful.init(...)` call in `rc.lua`, add:

```lua
local config_dir = gears.filesystem.get_configuration_dir()
package.path = config_dir .. "?.lua;" .. config_dir .. "?/init.lua;" .. package.path
local my_clock = require("widgets.clock")
```

Inside `s.mywibox`, find the `wibox.container.place` containing `mytextclock`. Replace just that entry with `my_clock`. Keep the surrounding layout so the clock stays centred.

Reload with **Mod4+Ctrl+r**. The bar should show hours, minutes, and seconds. If it does not, check the error notification and confirm that you replaced the clock entry inside `s.mywibox`.

## Add a background

Replace `widgets/clock.lua` with this version:

```lua
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local text = wibox.widget {
    font = beautiful.font,
    widget = wibox.widget.textbox,
}

local clock = wibox.widget {
    {
        text,
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_focus,
    fg = beautiful.fg_focus,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
}

gears.timer {
    timeout = 1,
    autostart = true,
    call_now = true,
    callback = function()
        text.text = os.date("%H:%M:%S")
    end,
}

return clock
```

Reload. The same clock now has padding and a rounded background. The textbox displays content, the margin container adds space, and the background container draws behind it. Each container has one child. Layouts such as `wibox.layout.fixed.horizontal` arrange several children.

## Add a tooltip and click action

Add this before `return clock`:

```lua
local awful = require("awful")
local naughty = require("naughty")

awful.tooltip {
    objects = { clock },
    timer_function = function()
        return os.date("%A, %B %d, %Y")
    end,
}

clock:add_button(awful.button({}, 1, function()
    naughty.notification {
        title = "Current time",
        message = os.date("%A, %B %d, %Y\n%H:%M:%S"),
        timeout = 5,
    }
end))
```

Reload, hover over the clock to see the date, then left-click it to show a notification. Button 1 is left-click, 2 is middle-click, and 3 is right-click.

The module returns one shared clock, so displaying it on several bars uses one timer. Removing it from a bar does not stop that timer. See [widget timers](../guides/widget-timers.md) for cleanup and asynchronous command output.

Continue with [Wibar](wibar.md) to build a bar around your widgets. The [widget reference](../reference/wibox/index.md) lists the available widgets, containers, and layouts.
