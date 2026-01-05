---
sidebar_position: 5
title: Notifications
description: Configure desktop notifications with naughty
---

# Notifications

SomeWM includes `naughty`, a notification daemon that receives notifications from applications via D-Bus and displays them on screen.

## How Notifications Work

When an app sends a notification:

1. App calls the D-Bus `org.freedesktop.Notifications` interface
2. Naughty receives the notification
3. Rules are applied (if any)
4. Notification displays on screen
5. After timeout, it disappears (or user dismisses it)

## Basic Setup

The default config enables naughty automatically. If you're building from scratch:

```lua
local naughty = require("naughty")

-- Enable the notification daemon
naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)
```

That's it - apps can now send notifications.

## Customizing Defaults

Configure default behavior via `naughty.config.defaults`:

```lua
local naughty = require("naughty")

-- Default timeout (seconds, 0 = never auto-dismiss)
naughty.config.defaults.timeout = 5

-- Default position on screen
naughty.config.defaults.position = "top_right"

-- Margin from screen edge
naughty.config.defaults.margin = 10

-- Default icon size
naughty.config.defaults.icon_size = 48

-- Gap between notifications
naughty.config.spacing = 4
```

### Position Options

| Position | Location |
|----------|----------|
| `"top_left"` | Top-left corner |
| `"top_middle"` | Top center |
| `"top_right"` | Top-right corner (default) |
| `"bottom_left"` | Bottom-left corner |
| `"bottom_middle"` | Bottom center |
| `"bottom_right"` | Bottom-right corner |

## Preset Urgency Levels

Notifications have urgency levels: `low`, `normal`, `critical`. Configure each:

```lua
-- Low urgency (subtle)
naughty.config.presets.low.bg = "#222222"
naughty.config.presets.low.fg = "#888888"
naughty.config.presets.low.timeout = 3

-- Normal urgency (default)
naughty.config.presets.normal.bg = "#333333"
naughty.config.presets.normal.fg = "#ffffff"
naughty.config.presets.normal.timeout = 5

-- Critical urgency (attention-grabbing)
naughty.config.presets.critical.bg = "#ff0000"
naughty.config.presets.critical.fg = "#ffffff"
naughty.config.presets.critical.timeout = 0  -- Don't auto-dismiss
```

## Notification Rules

Use `ruled.notification` to customize notifications based on their properties:

```lua
local ruled = require("ruled")

ruled.notification.connect_signal("request::rules", function()
    -- Default rule for all notifications
    ruled.notification.append_rule {
        rule = {},
        properties = {
            screen = awful.screen.preferred,
            implicit_timeout = 5,
        },
    }

    -- Spotify notifications: shorter timeout
    ruled.notification.append_rule {
        rule = { app_name = "Spotify" },
        properties = {
            timeout = 3,
        },
    }

    -- Discord: different position
    ruled.notification.append_rule {
        rule = { app_name = "discord" },
        properties = {
            position = "bottom_right",
        },
    }

    -- Critical notifications: never timeout
    ruled.notification.append_rule {
        rule = { urgency = "critical" },
        properties = {
            timeout = 0,
            bg = "#ff0000",
            fg = "#ffffff",
        },
    }
end)
```

### Rule Matching Properties

| Property | Description |
|----------|-------------|
| `app_name` | Application name (e.g., "Spotify", "discord") |
| `title` | Notification title |
| `message` | Notification body text |
| `urgency` | Urgency level: "low", "normal", "critical" |
| `category` | Notification category |

## Sending Notifications from Lua

Send notifications from your rc.lua or widgets:

```lua
local naughty = require("naughty")

-- Simple notification
naughty.notify {
    title = "Hello",
    text = "This is a notification",
}

-- With more options
naughty.notify {
    title = "Volume Changed",
    text = "Volume: 50%",
    icon = "/usr/share/icons/Adwaita/48x48/status/audio-volume-medium.png",
    timeout = 2,
    urgency = "low",
}

-- Critical notification (won't auto-dismiss)
naughty.notify {
    title = "Battery Low!",
    text = "Battery at 10%",
    urgency = "critical",
}
```

### Notification with Actions

Add clickable buttons to notifications:

```lua
naughty.notify {
    title = "Meeting in 5 minutes",
    text = "Standup with team",
    actions = {
        naughty.action { name = "Join" },
        naughty.action { name = "Snooze" },
    },
}
```

Handle action clicks:

```lua
local n = naughty.notify {
    title = "File download complete",
    text = "document.pdf",
    actions = {
        naughty.action { name = "Open" },
        naughty.action { name = "Show in folder" },
    },
}

n:connect_signal("invoked", function(_, action_index)
    if action_index == 1 then
        awful.spawn("xdg-open ~/Downloads/document.pdf")
    elseif action_index == 2 then
        awful.spawn("nautilus ~/Downloads")
    end
end)
```

## Theming Notifications

Use `beautiful` variables to style notifications globally:

```lua
-- In theme.lua
local theme = {}

-- Notification colors
theme.notification_bg = "#282828"
theme.notification_fg = "#ebdbb2"
theme.notification_border_color = "#504945"
theme.notification_border_width = 2

-- Notification size
theme.notification_width = 300
theme.notification_max_width = 400
theme.notification_max_height = 200
theme.notification_icon_size = 48

-- Notification font
theme.notification_font = "monospace 10"

-- Notification shape
theme.notification_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 8)
end

return theme
```

## Custom Notification Widget

For complete control, create a custom notification display:

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

## Notification Signals

React to notification events:

```lua
-- When a notification is created
naughty.connect_signal("added", function(n)
    print("New notification: " .. n.title)
end)

-- When a notification is destroyed
naughty.connect_signal("destroyed", function(n, reason)
    print("Notification dismissed: " .. n.title)
end)
```

## Do Not Disturb

Implement a simple do-not-disturb mode:

```lua
local dnd = false

-- Toggle DND with keybinding
awful.key({ modkey }, "n", function()
    dnd = not dnd
    if dnd then
        naughty.suspend()
        naughty.notify { title = "Do Not Disturb", text = "Enabled" }
    else
        naughty.resume()
        naughty.notify { title = "Do Not Disturb", text = "Disabled" }
    end
end)
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

- **[Widgets](/tutorials/widgets)** - Build notification-triggering widgets
- **[AwesomeWM Naughty Docs](https://awesomewm.org/doc/api/libraries/naughty.html)** - Full naughty API
