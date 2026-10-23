---
sidebar_position: 22
title: React to client lifecycle
description: Run code when clients appear, gain focus, change state, or close
---

# React to client lifecycle

Use `client.connect_signal` for lifecycle and property changes. Use a rule callback when your operation needs properties assigned by client rules.

## Run code when a client appears

<span id="a-new-client" />

Add this rule inside your existing `ruled.client` `request::rules` handler to centre floating windows after rule properties have been applied:

```lua
ruled.client.append_rule {
    rule = {},
    callback = function(c)
        if c.floating then awful.placement.centered(c) end
    end,
}
```

`request::manage` is also available, but connecting a handler after requiring `ruled.client` does not guarantee that it runs after the rules. Class signal handlers do not promise connection order.

`request::manage` passes `(c, context, hints)`. The context is `"new"` for a new window or `"startup"` when managing an existing one. The hints table is currently empty.

SomeWM 2.1 uses `request::manage` and `request::unmanage`. The old `manage` and `unmanage` signals do not fire.

## Pin a scratchpad

Put window properties in a rule. Replace the class with the value reported by `somewm-client client list`, and create the `scratch` tag first:

```lua
ruled.client.append_rule {
    rule = { class = "^scratchpad$" },
    properties = {
        floating = true,
        skip_taskbar = true,
        sticky = false,
        tag = "scratch",
        placement = awful.placement.centered,
    },
}
```

This assigns the window to a tag. A show/hide toggle needs a separate binding.

## React to focus changes

<span id="focus" />

For focused and unfocused border colours, set `beautiful.border_color_active` and `beautiful.border_color_normal` in your theme. The default border handler already responds to focus changes.

For another action, connect to `focus` or `unfocus`:

```lua
client.connect_signal("focus", function(c)
    if c.valid and c == client.focus then
        print("Focused: " .. (c.name or c.class or "?"))
    end
end)
```

Focus signals can be queued. By delivery time, a client may have lost focus or closed. Check its current state when the action depends on it still being focused.

## React to property changes

<span id="properties" />

Read the current value inside the callback. A property signal reports changes in both directions:

```lua
local naughty = require("naughty")
client.connect_signal("property::urgent", function(c)
    if c.valid and c.urgent then
        naughty.notification {
            title = "Urgent: " .. (c.class or "?"),
            message = c.name or "",
        }
    end
end)
```

Use `property::name` for title updates or `property::floating` to react when a window becomes floating. These handlers also need validity checks if they access clients after queued delivery.

## Run code when a client closes

<span id="closing" />

`request::unmanage` runs before the client is invalidated. Its geometry and screen are still readable, but its tags have already been detached. Copy values you need before passing work to a timer or asynchronous callback.

To track time spent managed, keep state keyed by client and remove it on unmanage:

```lua
local opened = {}
client.connect_signal("request::manage", function(c)
    opened[c] = os.time()
end)
client.connect_signal("request::unmanage", function(c)
    local started = opened[c]
    opened[c] = nil
    if started then
        print(string.format("%s managed for %d seconds",
            c.class or "?", os.time() - started))
    end
end)
```

Reload re-manages existing clients, so this measures time in the current Lua state, not the application's total lifetime.

## See also

- [Client Signals](../reference/signals.md#client-signals)
- [Signals](../concepts/signals.md)
- [Replace a Default Handler](replace-default-handler.md)
- [Client Rules](client-rules.md)
