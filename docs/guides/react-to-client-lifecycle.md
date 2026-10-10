---
sidebar_position: 22
title: React to client lifecycle
description: "request::manage for new clients, focus and unfocus, property::* for state changes, request::unmanage for closing, and what state is safe to read in each."
---

# React to client lifecycle

`client.connect_signal(name, handler)` runs the handler with the client as its first argument. [client signals](../reference/signals.md#client-signals) is the full list; [Signals](../concepts/signals.md) the dispatch model.

| Want | Signal | Note |
| --- | --- | --- |
| act on a new window | `request::manage` | use a `ruled.client` rule where a table of properties will do |
| see the pre-rule state | `request::manage`, connected before `ruled.client` is required | |
| highlight the focused window | `focus`, `unfocus` | or replace `request::border` |
| react to a title change | `property::name` | |
| notify on urgent | `property::urgent` | fires for true and false; read `c.urgent` |
| save and restore per-window state | `request::manage` plus `request::unmanage` | stash in a table keyed by client |

## A new client

```lua
client.connect_signal("request::manage", function(c, context, hints)
    if c.floating then awful.placement.centered(c) end
end)
```

`context` is `"new"`, or `"startup"` for a window that existed before SomeWM started. A handler connected after `ruled.client` was required, the normal case in `rc.lua`, sees the client with rules applied. The bare `manage` and `unmanage` signals of AwesomeWM are gone since 2.0; a handler on them never runs, and SomeWM warns at startup.

A scratchpad, always floating, on one tag, out of the tasklist:

```lua
client.connect_signal("request::manage", function(c)
    if c.instance == "scratchpad" then
        c.floating, c.skip_taskbar, c.sticky = true, true, false
        c:move_to_tag(screen.primary.tags[5])
        awful.placement.centered(c)
    end
end)
```

A rule expresses the same thing; the signal is for logic a table cannot hold, such as reading other clients.

## Focus

```lua
client.connect_signal("focus", function(c) c.border_color = "#88c0d0" end)
client.connect_signal("unfocus", function(c) c.border_color = "#3b4252" end)
```

`unfocus` on the old client fires before `focus` on the new. `awful.permissions` already colours borders from `request::border`, so either leave borders to it or [replace that handler](./replace-default-handler.md).

## Properties

```lua
client.connect_signal("property::floating", function(c)
    if c.floating then awful.placement.centered(c) end
end)
client.connect_signal("property::urgent", function(c)
    if c.urgent then naughty.notification { title = "Urgent: " .. (c.class or "?"), message = c.name } end
end)
```

## Closing

In `request::unmanage` the client is gone: geometry, screen and tags may be invalid. Keep what you need from `request::manage`, and drop the entry afterwards so the table does not grow:

```lua
local client_data = {}

client.connect_signal("request::manage", function(c)
    client_data[c] = { class = c.class, opened_at = os.time() }
end)

client.connect_signal("request::unmanage", function(c)
    local d = client_data[c]
    if d then
        print(string.format("%s ran for %d seconds", d.class, os.time() - d.opened_at))
        client_data[c] = nil
    end
end)
```

[Client Rules](/docs/guides/client-rules) covers the declarative form.
