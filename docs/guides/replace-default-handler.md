---
sidebar_position: 21
title: Replace a default handler
description: "Disconnect the awful.permissions handler of a request::* signal and connect your own. The same function reference is required, and the table of which handler serves which signal."
---

# Replace a default handler

Each `request::*` signal has a default handler in `awful.permissions`, exported as a named function so it can be disconnected. Replacing it is two calls with the same function reference:

```lua
client.disconnect_signal("request::tag", awful.permissions.tag)
client.connect_signal("request::tag", my_tag_handler)
```

Connecting without disconnecting adds to the default instead. For observation signals (`focus`, `property::*`) that is right; for a `request::*` that places, tags or draws borders, two handlers fight.

| Signal | Default handler |
| --- | --- |
| `client` `request::activate` | `awful.permissions.activate` |
| `client` `request::tag` | `awful.permissions.tag` |
| `client` `request::border` | `awful.permissions.update_border` |
| `client` `request::geometry` | `awful.permissions.geometry` |
| `tag` `request::screen` | `awful.permissions.tag_screen` |
| `screen` `request::focus_restore` | `awful.permissions.focus_restore` |

`request::manage`'s default is connected when `ruled.client` is required. [Signals Reference](../reference/signals.md) names the rest.

## Borders

`context` says why the signal fired: `"added"`, `"active"`, `"inactive"`, `"floating"`, `"urgent"`.

```lua
local function my_border_handler(c, context, hints)
    c.border_width = (c.fullscreen or c.maximized) and 0 or beautiful.border_width
    if c.floating and c.active then
        c.border_color = "#ff5555"
    else
        c.border_color = c.active and beautiful.border_focus or beautiful.border_normal
    end
end

client.disconnect_signal("request::border", awful.permissions.update_border)
client.connect_signal("request::border", my_border_handler)
```

## Tags

`hints.reason` is `"screen"` (the client has no tag), `"screen-removed"`, or `"rules"` (a rule's `tag` function returned nothing).

```lua
client.disconnect_signal("request::tag", awful.permissions.tag)
client.connect_signal("request::tag", function(c, t, hints)
    c:move_to_tag(t or screen.primary.tags[1])
end)
```

## Pitfalls

- An anonymous function cannot be disconnected; keep it in a local.
- Disconnecting the wrong reference is a silent no-op.
- Two modules replacing the same default: the later `require` wins. For rules, connect from `request::rules` instead ([Defer startup with request::rules](./defer-startup-with-request-rules.md)).
