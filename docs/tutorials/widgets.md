---
sidebar_position: 2
title: Build a clock widget
description: Create a clock module, preview it on screen, add hover and click behaviour, then put it in the default bar.
---

# Build a clock widget

Build a clock that updates itself, shows the date on hover, and opens a notification when clicked. You will first display it in a small box on screen, then put it in the bar.

Start with a running SomeWM 2.1 session and a copy of the bundled configuration at `~/.config/somewm/rc.lua`. [Launch](../getting-started/first-launch.md#configuration) explains how to create that copy. The examples use its theme and reload keybinding, **Super + Ctrl + r**.

Widgets combine in Lua tables: a textbox displays content, a margin adds space around one child, and a layout arranges several children. You choose their properties and behaviour. SomeWM calculates their sizes and draws them.

## 1. A clock module

Create the module directory:

```bash
mkdir -p ~/.config/somewm/widgets
```

Save this as `~/.config/somewm/widgets/clock.lua`:

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

## 2. Preview it on screen {#2-put-it-in-the-bar}

Add this at the end of `rc.lua`, after the existing theme initialisation. Leave the existing configuration in place:

```lua
local wibox = require("wibox")
local my_clock = require("widgets.clock")

local clock_preview = wibox {
    screen = screen.primary,
    x = screen.primary.geometry.x + 100,
    y = screen.primary.geometry.y + 100,
    width = 200,
    height = 40,
    bg = "#282828",
    fg = "#ebdbb2",
    visible = true,
    widget = my_clock,
}
```

Reload with **Super + Ctrl + r**. A box near the top-left of the primary screen should show the time, with seconds changing once a second. Here `wibox { ... }` creates the preview window, while `wibox.widget { ... }` in the module creates its content. The same clock can go inside your existing bar, which already supplies a window.

The timer changes `clock.text`. The textbox requests the display update. There is no separate drawing function to call.

## 3. An icon, containers, a tooltip, clicks

Replace the contents of `widgets/clock.lua` with this version, then reload. It uses the theme already loaded by the bundled configuration.

```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local clock_icon = wibox.widget {
    image = beautiful.awesome_icon,
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

## 4. Put it in the default bar

Remove the preview block you added to `rc.lua`. In the bundled configuration, find the `local mytextclock = wibox.widget` declaration under `-- Wibar`. Replace that entire widget declaration with:

```lua
local mytextclock = require("widgets.clock")
```

Leave the `mytextclock` entry inside `s.mywibox` in place. Reload: your clock now occupies the existing clock position in the bar, and the preview box is gone. Hover over it to see the date, then left-click for the notification.

If you use a different bar configuration, insert the returned clock widget into one of that bar's layouts. [Wibar](wibar.md) shows a complete bar and where custom widgets fit.

## If a widget is missing

- The module must return the widget, and a visible wibox or bar must contain it.
- A `module 'widgets.clock' not found` error means the file is not at `~/.config/somewm/widgets/clock.lua` or you are using a different configuration directory.
- Load the module after `beautiful.init()` so it can read the theme values.
- `somewm-client clay tree` shows the displayed widgets and their sizes. [Reading the tree](../concepts/reading-the-tree.md) explains the output.
- For errors while reloading, read standard error or, under `somewm-session`, `journalctl --user -u somewm.service -f`.

## Next steps {#patterns}

[Create a custom widget](../guides/custom-widgets.md) shows how to give a reusable component its own methods and state, and how to write a Clay description when you need new content or sizing rules. [Widget timers and updates](../guides/widget-timers.md) covers external commands and signals. The [wibox reference](../reference/wibox/index.md) lists the available components.
