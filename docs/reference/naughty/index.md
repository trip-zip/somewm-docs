---
sidebar_position: 1
title: naughty
description: Notification system
---

# naughty

The `naughty` library handles desktop notifications in AwesomeWM/SomeWM. It provides notification display, rules, and customization.

**Upstream documentation:** [awesomewm.org/apidoc/libraries/naughty.html](https://awesomewm.org/apidoc/libraries/naughty.html)

## Key Modules

| Module | Purpose |
|--------|---------|
| `naughty.notify` | Display notifications |
| `naughty.notification` | Notification object |
| `naughty.layout` | Notification positioning |
| `naughty.action` | Notification actions (buttons) |
| `ruled.notification` | Notification rules |

## Basic Usage

```lua
local naughty = require("naughty")

-- Simple notification
naughty.notify({
    title = "Hello",
    text = "This is a notification",
    timeout = 5
})
```

## Notification Rules

Rules let you customize notifications based on their properties:

```lua
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule({
        rule = { app_name = "Spotify" },
        properties = {
            timeout = 3,
            urgency = "low"
        }
    })
end)
```

See the [Notifications Guide](/guides/notifications) for detailed configuration.

## Behavioral Notes

SomeWM's `naughty` implementation is fully compatible with AwesomeWM.
