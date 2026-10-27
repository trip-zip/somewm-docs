---
sidebar_position: 23
title: "Defer startup with request::rules"
description: Register startup rules from modules and control their order
---

# Defer startup with request::rules

Connect to `request::rules` when a module adds startup rules. Require the module from `rc.lua` so its handler is registered before startup reaches that stage.

## The pattern

Save this as `~/.config/somewm/rules/browser.lua`:

```lua
local ruled = require("ruled")
ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        rule = { class = "^firefox$" },
        properties = { tag = "web" },
    }
end)
```

Then load it from `rc.lua`:

```lua
require("rules.browser")
```

The `web` tag must exist when a client matches. Check the application's actual class with `somewm-client client list`.

## For notifications

Register notification rules the same way:

```lua
local ruled = require("ruled")
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
        rule = { app_name = "^Spotify$" },
        properties = { ignore = true },
    }
end)
```

These are separate startup events. `ruled.client` requests rules during `client.scanning`, before existing clients are managed. `ruled.notification` requests them on `awesome`'s `startup` signal. Connecting after the relevant event does not replay it.

## Multiple handlers compose

Each module can register a handler. Rules are appended when those handlers run, so separate handlers do not make overlapping rules independent of order. Later matching rules replace earlier values for the same property.

Keep defaults before exceptions. When order must be explicit, append those rules together in one handler. Deferring registration does not make conflicting rules independent of order.

## Add rules at runtime

For a module loaded after startup, append directly instead of waiting for `request::rules`:

```lua
local ruled = require("ruled")
ruled.client.append_rule {
    id = "chat-placement",
    rule = { class = "^Slack$" },
    properties = { tag = "chat" },
}
```

This affects clients managed afterward. It does not move existing windows. If a setting can change repeatedly, remove its previous rule with `ruled.client.remove_rule("chat-placement")` before appending a replacement.

## See also

- [Client Rules](client-rules.md)
- [Notifications](notifications.md)
- [Startup Ordering](../concepts/signals.md#startup-order)
