---
sidebar_position: 23
title: Control where focus goes
description: "Toggle between the two most recent windows, replace the request::focus_restore handler to choose the fallback, prefer a kind of window, filter what can be chosen, pause history tracking, and print the history."
---

# Control where focus goes

Every recipe here reads or shapes the focus history, the most-recent-first list of focused clients ([Focus History](../concepts/focus-history.md)).

## The two most recent windows

```lua
awful.key {
    modifiers = { "Mod1" }, key = "Tab",
    on_press = function() awful.client.focus.history.previous() end,
    description = "focus previous client (history)", group = "client",
},
```

`awful.client.focus.byidx(1)` cycles visible clients in index order instead.

## The fallback when something closes

A client closing, a layer-shell launcher dismissing, an unlock and a monitor disconnect all emit `request::focus_restore` on the screen. The default handler, `awful.permissions.focus_restore`, activates the most recently focused client still visible there. Replace it to change the policy:

```lua
screen.disconnect_signal("request::focus_restore", awful.permissions.focus_restore)
screen.connect_signal("request::focus_restore", function(s)
    local master = s.tiled_clients[1]
    if master then master:emit_signal("request::activate", "focus_restore", { raise = false }) end
end)
```

If the handler focuses nobody, C focuses the topmost client on that screen, so a broken handler never strands focus ([the pattern's pitfalls](./replace-default-handler.md)).

## Prefer a kind of window

`awful.client.focus.history.get(s, idx, filter)` returns the `idx`-th most recent client visible on `s` that passes `filter`, 0 being the most recent:

```lua
local term = awful.client.focus.history.get(s, 0, function(c) return c.class == "Alacritty" end)
if term then term:emit_signal("request::activate", "focus_switch", { raise = true }) end
```

In the handler above, that is "when the editor closes, go back to the last terminal".

## Keep utility windows out

`awful.client.focus.filter` decides which clients fallback and directional focus may choose; the default rejects desktop, dock, splash and unfocusable windows. Extend it, returning the client to allow and nil to reject:

```lua
local default_filter = awful.client.focus.filter
awful.client.focus.filter = function(c)
    if c.class == "scratchpad" then return nil end
    return default_filter(c)
end
```

Every focused client still enters the history; the filter only limits who can be chosen.

## Pause tracking

```lua
awful.client.focus.history.disable_tracking()
-- walk through clients without rewriting the order
awful.client.focus.history.enable_tracking()
```

Calls nest, one `enable` per `disable`; `is_enabled()` reports the state.

## Print the history

```bash
somewm-client eval 'local awful = require("awful"); local out = {}; for i, c in ipairs(awful.client.focus.history.list) do out[#out + 1] = i .. "  " .. (c.name or c.class or "?") end; return table.concat(out, "\n")'
```

The top entry is who fallback picks first. If the order is right and the wrong client wins, the filter rejected the expected one, or it is not visible on the screen that emitted the signal.
