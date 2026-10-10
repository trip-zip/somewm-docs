---
sidebar_position: 5
title: Notifications
description: "ruled.notification rules per app, urgency presets, a do-not-disturb toggle that lets critical and matched messages through, theme variables, a custom widget_template, and sending from Lua."
---

# Notifications

`naughty` is the notification daemon; nothing else needs to run. [naughty reference](/docs/reference/naughty/) has every property.

## Rules per app

```lua
local ruled = require("ruled")

ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule { rule = { app_name = "Spotify" }, properties = { timeout = 3 } }
    ruled.notification.append_rule { rule = { app_name = "discord" }, properties = { position = "bottom_right" } }
    ruled.notification.append_rule { rule = { app_name = "NoisyApp" }, properties = { ignore = true } }
end)
```

[Matching fields](/docs/reference/naughty/#rule-matching-fields) and [settable properties](/docs/reference/naughty/#rule-settable-properties) list the rest. `message` and `title` take Lua patterns.

## Urgency presets

```lua
naughty.config.presets.low.bg, naughty.config.presets.low.fg, naughty.config.presets.low.timeout = "#222222", "#888888", 3
naughty.config.presets.normal.bg, naughty.config.presets.normal.fg = "#333333", "#ffffff"
naughty.config.presets.critical.bg, naughty.config.presets.critical.fg, naughty.config.presets.critical.timeout = "#ff0000", "#ffffff", 0   -- 0 never dismisses
```

## Do not disturb

```lua
awful.key({ modkey }, "n", function()
    naughty.suspended = not naughty.suspended
    naughty.notification {
        title = naughty.suspended and "Presentation Mode" or "Notifications",
        message = naughty.suspended and "Only critical alerts will show" or "All notifications enabled",
        timeout = 2, ignore_suspend = true,
    }
end, { description = "toggle presentation mode", group = "notifications" })
```

Rules decide what gets through while suspended:

```lua
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule { rule = { urgency = "critical" }, properties = { ignore_suspend = true } }
    ruled.notification.append_rule {
        rule_any = { category = { "device.error", "network.error" } },
        properties = { ignore_suspend = true },
    }
    ruled.notification.append_rule {
        rule = { app_name = "Signal" },
        rule_any = { message = { "[Pp]rincipal", "[Ee]mergency" } },
        properties = { ignore_suspend = true, bg = "#ff6600" },
    }
    ruled.notification.append_rule {
        rule = { app_name = "Slack", title = "Direct message from: CEO.*" },
        properties = { ignore_suspend = true },
    }
end)
```

## Theme

```lua
theme.notification_bg = "#282828"
theme.notification_fg = "#ebdbb2"
theme.notification_border_color = "#504945"
theme.notification_border_width = 2
theme.notification_width = 300
theme.notification_max_width = 400
theme.notification_max_height = 200
theme.notification_icon_size = 48
theme.notification_font = "monospace 10"
theme.notification_shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end
```

[Theme Variables](/docs/reference/beautiful/theme-variables#notifications) lists them all.

## A custom layout

`request::display` receives each notification; build its box from `naughty.widget.icon`, `title`, `message` and `naughty.list.actions` with any [wibox layout](/docs/reference/wibox/):

```lua
naughty.connect_signal("request::display", function(n)
    naughty.layout.box {
        notification = n,
        type = "notification",
        screen = awful.screen.focused(),
        widget_template = {
            {
                {
                    {
                        naughty.widget.icon,
                        { naughty.widget.title, naughty.widget.message, spacing = 4, layout = wibox.layout.fixed.vertical },
                        fill_space = true, spacing = 10, layout = wibox.layout.fixed.horizontal,
                    },
                    naughty.list.actions,
                    spacing = 10, layout = wibox.layout.fixed.vertical,
                },
                margins = 10, widget = wibox.container.margin,
            },
            bg = beautiful.notification_bg, fg = beautiful.notification_fg,
            border_width = beautiful.notification_border_width, border_color = beautiful.notification_border_color,
            shape = beautiful.notification_shape,
            widget = wibox.container.background,
        },
    }
end)
```

## From Lua

```lua
naughty.notification {
    title = "Volume Changed", message = "Volume: 50%",
    icon = "/usr/share/icons/Adwaita/48x48/status/audio-volume-medium.png",
    timeout = 2, urgency = "low",
}
```

If nothing shows, another daemon holds the D-Bus name: `pkill dunst`, `pkill mako`, `pkill swaync`, then `dbus-send --session --print-reply --dest=org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications.GetServerInformation` should answer. Electron apps may need `ELECTRON_OZONE_PLATFORM_HINT=auto`.
