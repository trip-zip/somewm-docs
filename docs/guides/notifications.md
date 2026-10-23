---
sidebar_position: 5
title: Notifications
description: Configure desktop notifications with naughty
---

# Notifications

Configure `naughty` through notification rules, theme values and the existing `request::display` handler in `rc.lua`. The examples use `local naughty = require("naughty")` and the default config's `awful` and `modkey` locals.

## Filter Notifications by App

<span id="rules-per-app" />

Add these rules to the existing `ruled.notification` handler:

```lua
local ruled = require("ruled")
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule = { app_name = "^Spotify$" },
        properties = { timeout = 3 },
    }
    ruled.notification.append_rule {
        rule = { app_name = "^discord$" },
        properties = { position = "bottom_right" },
    }
    ruled.notification.append_rule {
        rule = { app_name = "^NoisyApp$" },
        properties = { ignore = true },
    }
end)
```

Use the app name sent with the notification, which can differ from the window's class. Strings support Lua patterns. See the [naughty reference](../reference/naughty/index.md) for matching fields and properties.

## Set Up Urgency Styles

<span id="urgency-presets" />

Inside the notification rules handler:

```lua
ruled.notification.append_rule {
    rule = { urgency = "low" },
    properties = { bg = "#222222", fg = "#888888", timeout = 3 },
}
ruled.notification.append_rule {
    rule = { urgency = "normal" },
    properties = { timeout = 5 },
}
ruled.notification.append_rule {
    rule = { urgency = "critical" },
    properties = { bg = "#ff0000", fg = "#ffffff", timeout = 0 },
}
```

A timeout of `0` disables automatic dismissal. With `ruled.notification` enabled, use rules for urgency styling. Its preset handler replaces the legacy urgency presets.

## Set Up Do Not Disturb

<span id="do-not-disturb" />

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "F9", function()
        naughty.suspended = not naughty.suspended
        naughty.notification {
            title = "Notifications",
            message = naughty.suspended and "Paused" or "Resumed",
            timeout = 2,
            ignore_suspend = true,
        }
    end, { description = "toggle notifications", group = "notifications" }),
})
```

Suspension queues notifications. Notifications marked `ignore_suspend = true` still appear.

### Let Critical Notifications Through

Inside the rules handler:

```lua
ruled.notification.append_rule {
    rule = { urgency = "critical" },
    properties = { ignore_suspend = true },
}
```

### Filter by Message Content

To require both the application and a message pattern, put them together in `rule`:

```lua
ruled.notification.append_rule {
    rule = { app_name = "^Signal$", message = "[Ee]mergency" },
    properties = { ignore_suspend = true, bg = "#ff6600" },
}
```

Combining `rule = { app_name = ... }` with `rule_any = { message = ... }` would match either condition, including other applications. For several message patterns, append one rule per pattern.

## Theme Notifications

<span id="theme" />

In your theme file, before it is loaded by `beautiful.init()`:

```lua
local gears = require("gears")
theme.notification_bg = "#282828"
theme.notification_fg = "#ebdbb2"
theme.notification_border_color = "#504945"
theme.notification_border_width = 2
theme.notification_width = 300
theme.notification_icon_size = 48
theme.notification_font = "monospace 10"
theme.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 8)
end
```

See [notification theme variables](../reference/beautiful/theme-variables.md#notifications) for the full list.

## Create a Custom Notification Widget

<span id="a-custom-layout" />

Replace the default `request::display` handler with this one. Keeping both creates two boxes for each notification.

```lua
local naughty = require("naughty")
local wibox = require("wibox")
naughty.connect_signal("request::display", function(n)
    naughty.layout.box {
        notification = n,
        widget_template = {
            {
                {
                    naughty.widget.icon,
                    {
                        naughty.widget.title,
                        naughty.widget.message,
                        spacing = 4,
                        layout = wibox.layout.fixed.vertical,
                    },
                    spacing = 10,
                    layout = wibox.layout.fixed.horizontal,
                },
                naughty.list.actions,
                spacing = 8,
                layout = wibox.layout.fixed.vertical,
            },
            margins = 10,
            widget = wibox.container.margin,
        },
    }
end)
```

The icon, title, message and action list receive the notification through the template. Compose them with [wibox layouts and containers](../reference/wibox/index.md).

## Send Notifications from Lua

<span id="from-lua" />

```lua
naughty.notification {
    title = "Volume",
    message = "Volume: 50%",
    timeout = 2,
    urgency = "low",
}
```

## Troubleshooting

If application notifications do not appear, check which program owns the notification service:

```bash
dbus-send --session --print-reply \
  --dest=org.freedesktop.Notifications \
  /org/freedesktop/Notifications \
  org.freedesktop.Notifications.GetServerInformation
```

Run one notification provider per D-Bus session. If another daemon owns the service, stop that daemon and remove its autostart entry before restarting your notification setup. Also check `naughty.suspended` and rules that set `ignore = true`.

## See Also

- [Naughty Reference](../reference/naughty/index.md)
- [Theme Variables](../reference/beautiful/theme-variables.md)
- [Widgets Tutorial](../tutorials/widgets.md)
- [AwesomeWM Naughty API](https://awesomewm.org/apidoc/libraries/naughty.html)
