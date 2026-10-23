---
sidebar_position: 1
title: naughty
description: Notification system
---

import FromAwesomeWM from '@site/src/components/FromAwesomeWM';

# naughty

<FromAwesomeWM upstream="libraries/naughty" lastSynced="2026-05-11" />

The `naughty` library handles desktop notifications. It receives notifications from applications via the D-Bus `org.freedesktop.Notifications` interface and displays them on screen.

## Deviations from AwesomeWM

Notifications use the standard D-Bus service on Wayland. The widget and rule APIs follow AwesomeWM.

## Modules

| Module | Purpose |
|--------|---------|
| `naughty.notify` | Deprecated constructor, use `naughty.notification` |
| `naughty.notification` | Notification object |
| `naughty.layout.box` | Default notification display widget |
| `naughty.widget.icon` | Notification icon widget |
| `naughty.widget.title` | Notification title widget |
| `naughty.widget.message` | Notification message widget |
| `naughty.list.actions` | Notification action buttons widget |
| `naughty.action` | Notification action (clickable button) |
| `ruled.notification` | Rule-based notification configuration |

## Display Handler

The default config registers a `request::display` handler. A custom config can use:

```lua
local naughty = require("naughty")

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)
```

## naughty.notification {#naughtynotify}

`naughty.notification` creates a notification object. `naughty.notify` is the deprecated equivalent, with `text` as the legacy name for `message`:

```lua
naughty.notification {
    title   = "Title",
    message = "Body text",
    timeout = 5,
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | string | `""` | Notification title |
| `message` | string | `""` | Notification body |
| `timeout` | number | `5` | Auto-dismiss time in seconds (0 = never) |
| `urgency` | string | `"normal"` | `"low"`, `"normal"`, or `"critical"` |
| `position` | string | `"top_right"` | Screen position (see [Positions](#positions)) |
| `icon` | string | `nil` | Path to icon image |
| `icon_size` | number | `nil` | Icon size in pixels |
| `bg` | string | theme default | Background colour |
| `fg` | string | theme default | Foreground colour |
| `actions` | table | `{}` | List of `naughty.action` objects |
| `ignore_suspend` | boolean | `false` | Show even when notifications are suspended |
| `category` | string | `nil` | Notification category (e.g., `"email.arrived"`) |
| `app_name` | string | `nil` | Application name |

### Actions

`invoked` belongs to each action, not the notification. The default action widget passes the action and its notification to the handler:

```lua
local naughty = require("naughty")
local open = naughty.action { name = "Open" }
open:connect_signal("invoked", function(action, notification)
    print(action.name, notification.title)
end)

local n = naughty.notification {
    title = "Download complete",
    message = "document.pdf",
    actions = { open },
}
```

Calling `open:invoke(n)` emits the same signal. Calling it without an argument passes nil as the notification.

## naughty.config.defaults

Fallback values used unless properties, rules, presets, or theme settings override them:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `timeout` | number | `5` | Auto-dismiss time in seconds |
| `position` | string | `"top_right"` | Screen position |
| `margin` | number | DPI-scaled `5` | Margin inside the notification |
| `icon_size` | number | `nil` | Icon size override |

### Spacing

`naughty.config.padding` defaults to DPI-scaled 4 pixels from the workarea edge. `spacing` defaults to DPI-scaled 1 pixel between notifications. For example:

```lua
naughty.config.spacing = 4  -- Gap between stacked notifications
```

## Positions {#positions}

| Value | Location |
|-------|----------|
| `"top_left"` | Top-left corner |
| `"top_middle"` | Top centre |
| `"top_right"` | Top-right corner (default) |
| `"bottom_left"` | Bottom-left corner |
| `"bottom_middle"` | Bottom centre |
| `"bottom_right"` | Bottom-right corner |

## Urgency Presets

Legacy D-Bus notifications use `naughty.config.presets` by urgency. Connecting `ruled.notification`’s `request::rules` handler replaces this preset matching with rules. Use the [notification rules](#notification-rules) below in a modern config.

| Preset | Default Timeout | Description |
|--------|----------------|-------------|
| `naughty.config.presets.low` | `5` | Subtle, low-priority |
| `naughty.config.presets.normal` | Inherits defaults | No preset override |
| `naughty.config.presets.critical` | `0` (never) | Requires manual dismissal |

Presets accept notification properties. Lua-created notifications use a preset only when it is passed explicitly as `preset = naughty.config.presets.critical`:

```lua
naughty.config.presets.critical.bg = "#ff0000"
naughty.config.presets.critical.fg = "#ffffff"
naughty.config.presets.critical.timeout = 0
```

## Notification Rules

`ruled.notification` applies properties to notifications matching specified criteria.

```lua
local ruled = require("ruled")

ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule       = { app_name = "Spotify" },
        properties = { timeout = 3 }
    }
end)
```

### Rule Matching Fields

| Field | Type | Description |
|-------|------|-------------|
| `app_name` | string | Application name (e.g., `"Spotify"`, `"discord"`) |
| `title` | string | Notification title (supports Lua patterns) |
| `message` | string | Notification body text (supports Lua patterns) |
| `urgency` | string | `"low"`, `"normal"`, or `"critical"` |
| `category` | string | Notification category (e.g., `"email.arrived"`) |

String matching accepts equality or Lua patterns. All fields in `rule` must match. `rule_any` matches any listed alternative:

```lua
ruled.notification.append_rule {
    rule_any = {
        app_name = { "Spotify", "vlc" },
        category = { "device.error", "network.error" },
    },
    properties = { timeout = 3 },
}
```

### Rule Settable Properties

| Property | Type | Description |
|----------|------|-------------|
| `timeout` | number | Auto-dismiss time in seconds (0 = never) |
| `implicit_timeout` | number | Fallback timeout if notification doesn't specify one |
| `never_timeout` | boolean | Force timeout to 0 |
| `position` | string | Screen position |
| `screen` | screen | Target screen |
| `ignore_suspend` | boolean | Show even when suspended |
| `ignore` | boolean | Completely ignore this notification |
| `bg` | string | Background colour |
| `fg` | string | Foreground colour |
| `icon` | string | Icon path |
| `icon_size` | number | Icon size in pixels |

## Suspension

Suspend notifications to prevent them from displaying:

```lua
naughty.suspended = true   -- Suspend all notifications
naughty.suspended = false  -- Resume (queued notifications appear)
```

Notifications with `ignore_suspend = true` still display while suspended.

Access queued notifications during suspension:

```lua
for _, n in ipairs(naughty.notifications.suspended) do
    print(n.title)
end
```

### Legacy API

```lua
naughty.suspend()   -- Deprecated, use naughty.suspended = true
naughty.resume()    -- Deprecated, use naughty.suspended = false
naughty.toggle()    -- Deprecated, use naughty.suspended = not naughty.suspended
```

## Signals

### Notification Lifecycle

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `request::display` | `n` | Notification ready for the configured display handler |
| `request::rules` | (none) | Rules should be registered (via `ruled.notification`) |
| `added` | `n` | Notification created |
| `destroyed` | `n, reason` | Notification dismissed or expired |

### Notification Object Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `invoked` (on a `naughty.action`) | `action, notification` | Action invoked. Connect to the action object |
| `property::title` | `n` | Title changed |
| `property::message` | `n` | Message changed |
| `property::urgency` | `n` | Urgency changed |

## Theme Variables

Notifications are styled via `beautiful` variables. See [Theme Variables: Notifications](/docs/1.4/reference/beautiful/theme-variables#notifications) for the full list.

Key variables:

| Variable | Description |
|----------|-------------|
| `notification_bg` | Background colour |
| `notification_fg` | Foreground colour |
| `notification_border_color` | Border colour |
| `notification_border_width` | Border width in pixels |
| `notification_width` | Default width |
| `notification_max_width` | Maximum width |
| `notification_max_height` | Maximum height |
| `notification_icon_size` | Default icon size |
| `notification_font` | Font |
| `notification_shape` | Shape function |

## See Also

- **[Notifications Guide](/docs/1.4/guides/notifications)** - Practical configuration tasks
- **[Theme Variables](/docs/1.4/reference/beautiful/theme-variables)** - All theme variables including notifications
- **[naughty (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/naughty.html)** - Upstream API reference
