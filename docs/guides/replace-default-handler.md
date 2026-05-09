---
sidebar_position: 21
title: Replace a default handler
description: Disconnect and replace the default behavior on request::* signals
---

# Replace a default handler

Most `request::*` signals come with a sensible default handler from `awful.permissions`. When the default doesn't fit (you want different border colors, custom tag selection, alternate placement), the pattern is:

1. `disconnect_signal` to remove the default
2. `connect_signal` your replacement

This guide walks through the pattern with three concrete examples. For background on what `request::*` signals are, see [Signals (concepts)](../concepts/signals.md).

## The general shape

```lua
-- What's currently connected:
client.connect_signal("request::tag", awful.permissions.tag)

-- Replace it:
client.disconnect_signal("request::tag", awful.permissions.tag)
client.connect_signal("request::tag", my_tag_handler)
```

The function reference passed to `disconnect_signal` must be the same value that was connected. `awful.permissions` exposes its handlers as named module functions exactly so user code can disconnect them.

## Example 1: custom border colors

The default `request::border` handler sets borders to the active/inactive colors from your theme. If you want different colors for floating clients (say, red borders so they stand out), replace it:

```lua
local function my_border_handler(c, context, hints)
    -- Width: don't show borders on maximized/fullscreen clients
    if c.fullscreen or c.maximized then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
    end

    -- Color: red if floating and active, otherwise theme defaults
    if c.floating and c.active then
        c.border_color = "#ff5555"
    elseif c.active then
        c.border_color = beautiful.border_focus
    else
        c.border_color = beautiful.border_normal
    end
end

client.disconnect_signal("request::border", awful.permissions.update_border)
client.connect_signal("request::border", my_border_handler)
```

The `context` argument tells you why the signal fired (`"added"`, `"active"`, `"inactive"`, `"floating"`, `"urgent"`, `"maximized"`, `"fullscreen"`). You can branch on it if you only want to override specific cases.

## Example 2: pin everything to tag 1

The default `request::tag` handler picks a tag based on the client's hints and the current selection. If you want every new client on tag 1 of the primary screen instead, replace it:

```lua
client.disconnect_signal("request::tag", awful.permissions.tag)

client.connect_signal("request::tag", function(c, t, hints)
    if t then
        -- Caller already specified a tag; honor it
        c:move_to_tag(t)
        return
    end

    c:move_to_tag(screen.primary.tags[1])
end)
```

The `hints.reason` field tells you why the tag is being requested:
- `"screen"`: client appeared with no tag
- `"screen-removed"`: client's screen was disconnected
- `"rules"`: `ruled.client` set `tag = somefunction` and the function returned nothing

Branch on `hints.reason` if you want different behavior in different cases.

## Example 3: keep the default *and* add your own

Sometimes you don't want to replace the default; you want to run additionally. Just connect without disconnecting:

```lua
-- The default handler still runs. Your handler runs after it.
client.connect_signal("manage", function(c)
    if c.class == "Firefox" then
        c.maximized = true
    end
end)
```

Handler order is the order they were connected. The default handler is connected at `require "awful.permissions"` time, so any handler you connect after that will run after the default.

For `request::*` signals where the default is doing something specific (placing, tagging, drawing borders), additive isn't always what you want; your handler might fight the default. For pure observation (`manage`, `focus`, `property::*`), additive is almost always right.

## Finding the default handler

The defaults live in `awful.permissions`. The standard ones:

| Signal | Default handler |
|--------|-----------------|
| `client` `request::activate` | `awful.permissions.activate` |
| `client` `request::tag` | `awful.permissions.tag` |
| `client` `request::border` | `awful.permissions.update_border` |
| `client` `request::geometry` | `awful.permissions.geometry` |
| `tag` `request::screen` | `awful.permissions.tag_screen` |

If a signal has a default handler that isn't in `awful.permissions`, the [Signals Reference](../reference/signals.md) names it.

## Pitfalls

- **Disconnecting an anonymous function won't work.** You need the same reference back: store the function in a local first, or use a named module function.
- **Disconnecting the wrong reference silently no-ops.** If you copy a handler from a guide, make sure you're disconnecting the actual function name, not a similarly-named one.
- **Order matters across modules.** If two modules both replace the same default and one is `require`-d after the other, only the second replacement wins. For rule-style signals, prefer connecting from inside `request::rules` (see [Defer startup with `request::rules`](./defer-startup-with-request-rules.md)).

## See also

- [Signals (concepts)](../concepts/signals.md)
- [Signals Reference](../reference/signals.md)
- [React to client lifecycle](./react-to-client-lifecycle.md)
