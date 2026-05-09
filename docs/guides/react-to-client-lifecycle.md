---
sidebar_position: 22
title: React to client lifecycle
description: Run code when clients appear, gain focus, change state, or close
---

# React to client lifecycle

A common task: do something when a client appears, when focus changes, when a window closes. The mechanism is `client.connect_signal`. This guide shows the most useful client signals, with worked examples and gotchas.

For the full list, see [`client` signals](../reference/signals.md#client-signals). For the conceptual model, see [Signals (concepts)](../concepts/signals.md).

## Run code when a client appears

`client.manage` fires when a client is fully managed: tagged, placed, with rules applied. It's the standard hook for "do X to new windows".

```lua
client.connect_signal("manage", function(c)
    -- Center floating windows on the focused screen
    if c.floating then
        awful.placement.centered(c)
    end
end)
```

If you need to do something *before* rules apply (e.g. set a property the rules will then act on), use `request::manage` instead. The default rule handlers run in `request::manage`, so connect-order matters: handlers connected before `awful.permissions` and `ruled.client` are loaded see the pre-rule state.

## Pin a scratchpad

A scratchpad is a window you toggle in and out, always on the same tag, always floating, ignored by tasklists. Set it up on `manage`:

```lua
client.connect_signal("manage", function(c)
    if c.instance == "scratchpad" then
        c.floating = true
        c.skip_taskbar = true
        c.sticky = false
        c:move_to_tag(screen.primary.tags[5])
        awful.placement.centered(c)
    end
end)
```

Better: do this with a `ruled.client` rule. `manage` works, but rules are the structured way to express "every Foo client gets these properties". Use `manage` when the logic doesn't fit a rule (depends on runtime state, needs to read other clients).

## React to focus changes

```lua
-- Highlight the focused client with a colored border
client.connect_signal("focus", function(c)
    c.border_color = "#88c0d0"
end)

client.connect_signal("unfocus", function(c)
    c.border_color = "#3b4252"
end)
```

`focus` fires *after* the new client has focus; `unfocus` fires *before* `focus` on the new client. So `unfocus(old) → focus(new)` is the order.

A note on the border-color example: if `awful.permissions` is handling borders for you, this fights with `request::border`. Either don't connect `focus`/`unfocus` for borders (let `request::border` do it), or replace the default `request::border` handler. See [Replace a default handler](./replace-default-handler.md).

## React to property changes

Each property has its own signal. Read the new value off the client inside the handler:

```lua
-- Log title changes
client.connect_signal("property::name", function(c)
    print(c.name)
end)

-- React to floating toggle
client.connect_signal("property::floating", function(c)
    if c.floating then
        awful.placement.centered(c)
    end
end)

-- Show a notification when a client becomes urgent
client.connect_signal("property::urgent", function(c)
    if c.urgent then
        naughty.notify {
            title = "Urgent: " .. (c.class or "?"),
            message = c.name,
        }
    end
end)
```

`property::urgent` fires for *both* `urgent = true` and `urgent = false`. Always check `c.urgent` inside the handler.

## Run code when a client closes

`unmanage` fires when a client is gone. Don't access geometry, screen, or tags inside the handler. They may already be invalid.

```lua
client.connect_signal("unmanage", function(c)
    print("Closed: " .. (c.class or "?"))
end)
```

If you need state from the client at close time, save it on `manage`:

```lua
local client_data = {}

client.connect_signal("manage", function(c)
    client_data[c] = { class = c.class, opened_at = os.time() }
end)

client.connect_signal("unmanage", function(c)
    local data = client_data[c]
    if data then
        print(string.format("%s ran for %d seconds", data.class, os.time() - data.opened_at))
        client_data[c] = nil
    end
end)
```

Tables keyed by client object are safe. Once the client is unmanaged, drop your entry to avoid leaking.

## Common patterns

| Want | Signal | Notes |
|------|--------|-------|
| Do X to new windows | `manage` | Use `ruled.client` rules where they fit |
| Do X *before* rules apply | `request::manage` | Connect order matters |
| Highlight focused window | `focus` / `unfocus` | Or replace `request::border` |
| React to title changes | `property::name` | Useful for tasklists |
| Save / restore window state | `manage` + `unmanage` | Stash data keyed by client |
| Notify on urgent | `property::urgent` | Check `c.urgent` inside |
| Flash on first paint | `property::geometry` | Filter on first emit per client |

## See also

- [`client` signals](../reference/signals.md#client-signals)
- [Signals (concepts)](../concepts/signals.md)
- [Replace a default handler](./replace-default-handler.md)
- [Client Rules](/docs/guides/client-rules)
