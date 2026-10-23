---
sidebar_position: 21
title: Replace a default handler
description: Disconnect and replace the default behavior on request::* signals
---

# Replace a default handler

Disconnect the existing function before connecting its replacement. Passing a new function with the same body does not disconnect the old one. Keep the function reference if you will need to remove it later.

The examples below belong in `rc.lua` after `local awful = require("awful")`.

## Example 1: custom border colors

<span id="borders" />

To give focused floating clients red borders, replace the default border handler:

```lua
local beautiful = require("beautiful")
local function my_border_handler(c)
    if c.fullscreen or c.maximized then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width or 1
    end
    if c.floating and c.active then
        c.border_color = "#ff5555"
    elseif c.active then
        c.border_color = beautiful.border_color_active or "#ffffff"
    else
        c.border_color = beautiful.border_color_normal or "#333333"
    end
end
client.disconnect_signal("request::border", awful.permissions.update_border)
client.connect_signal("request::border", my_border_handler)
```

This replaces the whole border policy, including theme handling for urgency. If only the normal focus colours need changing, set the theme's `border_focus` and `border_normal` instead.

## Example 2: pin everything to tag 1

<span id="tags" />

For clients that need a tag but have no explicit request, choose the primary screen's first tag:

```lua
local default_tag = awful.permissions.tag
local function my_tag_handler(c, t, hints)
    if t or #c:tags() > 0 then
        default_tag(c, t, hints)
        return
    end
    local first = screen.primary and screen.primary.tags[1]
    default_tag(c, first, hints)
end
client.disconnect_signal("request::tag", default_tag)
client.connect_signal("request::tag", my_tag_handler)
```

The default handles explicit tag objects and `t = true`, which requests a sticky client. Existing tag membership is preserved. Rules or later handlers can still move the window. This example also replaces the default transient-parent placement when an untagged client has no explicit request.

## Example 3: keep the default and add your own

When extra work must run after a default handler, call it from one wrapper:

```lua
local default_border = awful.permissions.update_border
client.disconnect_signal("request::border", default_border)
client.connect_signal("request::border", function(c, context, hints)
    default_border(c, context, hints)
    if c.floating and c.active then
        c.border_color = "#ff5555"
    end
end)
```

Use this as an alternative to the first example. It preserves the default border width and other theme rules. Two independent class signal handlers do not guarantee this execution order.

For client setup after rules, use a [rule callback](client-rules.md#using-callbacks).

## Finding the default handler

| Signal | Default handler |
| --- | --- |
| `client` `request::activate` | `awful.permissions.activate` |
| `client` `request::tag` | `awful.permissions.tag` |
| `client` `request::border` | `awful.permissions.update_border` |
| `client` `request::geometry` | `awful.permissions.geometry` |
| `screen` `request::focus_restore` | `awful.permissions.focus_restore` |
| `tag` `request::screen` | `awful.permissions.tag_screen` |

Other defaults may belong to another module or to your config. Check the [signal reference](../reference/signals.md) before replacing one.

## Pitfalls

- Disconnect the exact function that was connected, including a wrapper if you installed one.
- If two modules each disconnect the same original and add a replacement, both replacements remain connected. Choose one owner for that policy.
- Do not run all three examples together. The first and third are alternative border policies.

## See also

- [Signals](../concepts/signals.md)
- [Control Where Focus Goes](focus.md)
- [React to Client Lifecycle](react-to-client-lifecycle.md)
