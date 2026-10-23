---
sidebar_position: 23
title: Control where focus goes
description: Jump to recent windows, choose the fallback when something closes, and keep utility windows from stealing focus
---

# Control where focus goes

Use `awful.client.focus.history` to return to a recent visible window. The examples assume `local awful = require("awful")` in `rc.lua`.

## Jump between your two most recent windows

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod1" }, "Tab", function()
        awful.client.focus.history.previous()
    end, { description = "focus previous client", group = "client" }),
})
```

This searches the current screen. To cycle visible clients in client-list order instead, call `awful.client.focus.byidx(1)` for next or `byidx(-1)` for previous.

## Choose who gets focus when a window closes

The default `request::focus_restore` handler chooses a recent visible, focusable client on the affected screen. To prefer its first tiled client, replace the handler:

```lua
screen.disconnect_signal("request::focus_restore", awful.permissions.focus_restore)
screen.connect_signal("request::focus_restore", function(s)
    local master = s.tiled_clients[1]
    if master and awful.client.focus.filter(master) then
        master:emit_signal("request::activate", "focus_restore", { raise = false })
    else
        awful.permissions.focus_restore(s)
    end
end)
```

This handles screen focus-restoration requests, including those after a window or launcher closes. It does not replace every focus path. The C restore path also tries a topmost-client fallback if Lua leaves no client focused, but cannot focus a client when none is eligible.

## Prefer a specific kind of window

Search for a visible terminal on the focused screen:

```lua
local s = awful.screen.focused()
local term = awful.client.focus.history.get(s, 0, function(c)
    return c.class == "Alacritty" and awful.client.focus.filter(c)
end)
if term then
    term:emit_signal("request::activate", "focus_switch", { raise = true })
end
```

Replace the class with the value from `somewm-client client list`. The second argument is the number of matching history entries to skip. If history has no match, `get` can fall back to a visible client outside the history.

## Keep utility windows from taking fallback focus

Extend the default eligibility filter:

```lua
local default_filter = awful.client.focus.filter
awful.client.focus.filter = function(c)
    if c.class == "scratchpad" then return nil end
    return default_filter(c)
end
```

Return the client to allow it or `nil` to reject it. This affects focus helpers that consult the filter. It does not prevent direct focus assignments or stop focused utility clients entering history.

## Pause history tracking

`disable_tracking()` pauses history updates until a matching `enable_tracking()`. Calls nest, and `is_enabled()` reports whether tracking is active.

Focus events can be queued in 2.0. Tracking must remain disabled when those events are delivered. Disabling, changing focus and immediately enabling in one callback does not reliably exclude that change. See [Focus History](../concepts/focus-history.md) before using this for a window-preview mode.

## Debug where focus went

Inspect history from a terminal:

```bash
somewm-client eval 'local out = {} for i, c in ipairs(require("awful").client.focus.history.list) do out[#out + 1] = i .. "  " .. (c.name or c.class or "?") end return table.concat(out, "\n")'
```

The list is most-recent-first. A fallback search also checks screen, visibility and eligibility, so the first entry is not necessarily the next focus target. A launcher or wibar can hold keyboard focus without appearing in client history.

## See also

- [Focus History](../concepts/focus-history.md)
- [Replace a Default Handler](replace-default-handler.md)
- [Signals Reference](../reference/signals.md)
