---
sidebar_position: 23
title: Defer startup with request::rules
description: "ruled.client and ruled.notification emit request::rules once, at client.scanning, after every module has loaded. A module that appends its rules from that signal works in any require order."
---

# Defer startup with `request::rules`

A module that appends to `ruled.client.rules` at load time depends on the order it is required in, and breaks when another module does the same or when it is required after clients were scanned. `ruled.client` and `ruled.notification` each emit `request::rules` once, on `client.scanning`, after every module has loaded and before any client is matched. Append from there:

```lua
-- my_module.lua
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule { rule = { class = "Firefox" }, properties = { tag = "web" } }
end)

ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule { rule = { app_name = "spotify" }, properties = { ignore = true } }
end)
```

Every module's handler runs, in connect order, and the rules table is complete before the first client is managed. A `require` from inside a callback still works as long as it happens before scanning.

The signal fires once. A rule added at runtime, from a setting the user toggles, goes through `ruled.client.append_rule` directly and applies to clients managed from then on; existing clients are not re-evaluated.

The sequence: `rc.lua` runs and modules connect their handlers; `client.scanning` fires; `ruled.client` then `ruled.notification` emit `request::rules`; pre-existing clients are managed with the rules in place; `client.scanned` fires ([Signals](../concepts/signals.md#startup-order)).

[Client Rules](/docs/guides/client-rules), [Notifications](/docs/guides/notifications), [ruled.client signals](../reference/signals.md#ruledclient-signals).
