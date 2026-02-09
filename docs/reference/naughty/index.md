---
sidebar_position: 1
title: naughty
description: Notification system
---

# naughty

The `naughty` library handles desktop notifications. It receives notifications from applications via the D-Bus `org.freedesktop.Notifications` interface and displays them on screen.

**Upstream documentation:** [awesomewm.org/apidoc/libraries/naughty.html](https://awesomewm.org/apidoc/libraries/naughty.html)

SomeWM's `naughty` implementation is fully compatible with AwesomeWM.

## Modules

| Module | Purpose |
|--------|---------|
| `naughty.notify` | Create and display notifications |
| `naughty.notification` | Notification object |
| `naughty.layout.box` | Default notification display widget |
| `naughty.widget.icon` | Notification icon widget |
| `naughty.widget.title` | Notification title widget |
| `naughty.widget.message` | Notification message widget |
| `naughty.list.actions` | Notification action buttons widget |
| `naughty.action` | Notification action (clickable button) |
| `ruled.notification` | Rule-based notification configuration |

## Display Handler

Naughty requires a `request::display` handler to show notifications. The default config provides one. If building from scratch:

```lua
local naughty = require("naughty")

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)
```

## naughty.notify

Create a notification:

```lua
naughty.notify {
    title   = "Title",
    text    = "Body text",
    timeout = 5,
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | string | `""` | Notification title |
| `text` | string | `""` | Notification body |
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

```lua
naughty.notify {
    title = "Download complete",
    text = "document.pdf",
    actions = {
        naughty.action { name = "Open" },
        naughty.action { name = "Show in folder" },
    },
}
```

Handle action clicks with the `invoked` signal:

```lua
local n = naughty.notify {
    title = "Download complete",
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

## naughty.config.defaults

Global defaults applied to all notifications:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `timeout` | number | `5` | Auto-dismiss time in seconds |
| `position` | string | `"top_right"` | Screen position |
| `margin` | number | `10` | Margin from screen edge |
| `icon_size` | number | `48` | Default icon size |

```lua
naughty.config.defaults.timeout = 5
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 10
naughty.config.defaults.icon_size = 48
```

### Spacing

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

Configure appearance per urgency level via `naughty.config.presets`:

| Preset | Default Timeout | Description |
|--------|----------------|-------------|
| `naughty.config.presets.low` | `5` | Subtle, low-priority |
| `naughty.config.presets.normal` | `5` | Standard notifications |
| `naughty.config.presets.critical` | `0` (never) | Requires manual dismissal |

Each preset accepts `bg`, `fg`, `timeout`, and other notification properties:

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
        rule       = { ... },       -- match criteria
        rule_any   = { ... },       -- match any of these criteria
        properties = { ... },       -- properties to apply
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

Use `rule` for exact matches. Use `rule_any` with table values to match any of multiple values:

```lua
rule_any = {
    app_name = { "Spotify", "vlc" },
    category = { "device.error", "network.error" },
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
| `request::display` | `n` | Notification ready to display (must connect a handler) |
| `request::rules` | (none) | Rules should be registered (via `ruled.notification`) |
| `added` | `n` | Notification created |
| `destroyed` | `n, reason` | Notification dismissed or expired |

### Notification Object Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `invoked` | `n, action_index` | User clicked a notification action |
| `property::title` | `n` | Title changed |
| `property::message` | `n` | Message changed |
| `property::urgency` | `n` | Urgency changed |

## Theme Variables

Notifications are styled via `beautiful` variables. See [Theme Variables: Notifications](/reference/beautiful/theme-variables#notifications) for the full list.

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

- **[Notifications Guide](/guides/notifications)** - Practical configuration tasks
- **[Theme Variables](/reference/beautiful/theme-variables)** - All theme variables including notifications
- **[naughty (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/naughty.html)** - Upstream API reference
