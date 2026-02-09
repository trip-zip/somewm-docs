---
sidebar_position: 5
title: Notifications
description: Configure desktop notifications with naughty
---

# Notifications

This guide covers common notification configuration tasks. For API details and property tables, see the [naughty reference](/reference/naughty/).

## Filter Notifications by App

To change timeout, position, or appearance for specific applications, use `ruled.notification`:

```lua
local ruled = require("ruled")

ruled.notification.connect_signal("request::rules", function()
    -- Spotify: shorter timeout
    ruled.notification.append_rule {
        rule = { app_name = "Spotify" },
        properties = {
            timeout = 3,
        },
    }

    -- Discord: show in bottom-right
    ruled.notification.append_rule {
        rule = { app_name = "discord" },
        properties = {
            position = "bottom_right",
        },
    }

    -- Silence a noisy app entirely
    ruled.notification.append_rule {
        rule = { app_name = "NoisyApp" },
        properties = {
            ignore = true,
        },
    }
end)
```

See [Rule Matching Fields](/reference/naughty/#rule-matching-fields) and [Rule Settable Properties](/reference/naughty/#rule-settable-properties) for all available fields.

## Set Up Urgency Styles

Configure how each urgency level looks:

```lua
local naughty = require("naughty")

-- Low urgency: subtle
naughty.config.presets.low.bg = "#222222"
naughty.config.presets.low.fg = "#888888"
naughty.config.presets.low.timeout = 3

-- Normal urgency
naughty.config.presets.normal.bg = "#333333"
naughty.config.presets.normal.fg = "#ffffff"
naughty.config.presets.normal.timeout = 5

-- Critical: attention-grabbing, no auto-dismiss
naughty.config.presets.critical.bg = "#ff0000"
naughty.config.presets.critical.fg = "#ffffff"
naughty.config.presets.critical.timeout = 0
```

## Set Up Do Not Disturb

Toggle notification suspension with a keybinding:

```lua
local awful = require("awful")
local naughty = require("naughty")

awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "n", function()
        naughty.suspended = not naughty.suspended

        naughty.notify {
            title = naughty.suspended and "Presentation Mode" or "Notifications",
            text = naughty.suspended and "Only critical alerts will show" or "All notifications enabled",
            timeout = 2,
            ignore_suspend = true,
        }
    end, {description = "toggle presentation mode", group = "notifications"}),
})
```

### Let Critical Notifications Through

Use a rule to let critical notifications bypass suspension:

```lua
local ruled = require("ruled")

ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule = { urgency = "critical" },
        properties = { ignore_suspend = true },
    }

    -- Also let through system errors
    ruled.notification.append_rule {
        rule_any = {
            category = { "device.error", "network.error" },
        },
        properties = { ignore_suspend = true },
    }
end)
```

### Filter by Message Content

Rules support Lua patterns in the `message` field. This is useful for letting specific messages through during DND:

```lua
ruled.notification.connect_signal("request::rules", function()
    -- Signal messages about school emergencies bypass DND
    ruled.notification.append_rule {
        rule = { app_name = "Signal" },
        rule_any = {
            message = {
                "[Pp]rincipal",
                "[Ee]mergency",
                "Bit another student"
            },
        },
        properties = {
            ignore_suspend = true,
            bg = "#ff6600",
        },
    }

    -- Boss messages always get through
    ruled.notification.append_rule {
        rule = {
            app_name = "Slack",
            title = "Direct message from: CEO.*",
        },
        properties = { ignore_suspend = true },
    }
end)
```

## Theme Notifications

Style notifications globally in your `theme.lua`:

```lua
-- In theme.lua
theme.notification_bg = "#282828"
theme.notification_fg = "#ebdbb2"
theme.notification_border_color = "#504945"
theme.notification_border_width = 2
theme.notification_width = 300
theme.notification_max_width = 400
theme.notification_max_height = 200
theme.notification_icon_size = 48
theme.notification_font = "monospace 10"

theme.notification_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 8)
end
```

See [Theme Variables: Notifications](/reference/beautiful/theme-variables#notifications) for all available variables.

## Create a Custom Notification Widget

For full control over notification layout, provide a `widget_template` in your `request::display` handler:

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
                        {
                            naughty.widget.title,
                            naughty.widget.message,
                            spacing = 4,
                            layout = wibox.layout.fixed.vertical,
                        },
                        fill_space = true,
                        spacing = 10,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    naughty.list.actions,
                    spacing = 10,
                    layout = wibox.layout.fixed.vertical,
                },
                margins = 10,
                widget = wibox.container.margin,
            },
            bg = beautiful.notification_bg,
            fg = beautiful.notification_fg,
            border_width = beautiful.notification_border_width,
            border_color = beautiful.notification_border_color,
            shape = beautiful.notification_shape,
            widget = wibox.container.background,
        },
    }
end)
```

The available widget building blocks are `naughty.widget.icon`, `naughty.widget.title`, `naughty.widget.message`, and `naughty.list.actions`. Combine them with standard [wibox layouts and containers](/reference/wibox/).

## Send Notifications from Lua

Trigger notifications from keybindings, widgets, or scripts:

```lua
local naughty = require("naughty")

naughty.notify {
    title = "Volume Changed",
    text = "Volume: 50%",
    icon = "/usr/share/icons/Adwaita/48x48/status/audio-volume-medium.png",
    timeout = 2,
    urgency = "low",
}
```

## Troubleshooting

### Notifications Not Showing

Make sure no other notification daemon is running:

```bash
# Kill other daemons
pkill dunst
pkill mako
pkill swaync

# Check if D-Bus is working
dbus-send --session --print-reply \
  --dest=org.freedesktop.Notifications \
  /org/freedesktop/Notifications \
  org.freedesktop.Notifications.GetServerInformation
```

### App-Specific Issues

Some apps need specific configuration to send notifications:

```bash
# For Electron apps
export ELECTRON_OZONE_PLATFORM_HINT=auto
```

## See Also

- **[naughty Reference](/reference/naughty/)** - API details, all properties, signals, and positions
- **[Theme Variables](/reference/beautiful/theme-variables)** - Notification theme variables
- **[Widgets Tutorial](/tutorials/widgets)** - Build widgets that send notifications
- **[naughty (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/naughty.html)** - Upstream API reference
