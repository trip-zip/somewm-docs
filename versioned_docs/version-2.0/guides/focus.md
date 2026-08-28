---
sidebar_position: 23
title: Control where focus goes
description: Jump to recent windows, choose the fallback when something closes, and keep utility windows from stealing focus
---

# Control where focus goes

A common task: get focus back to the right window, whether you are switching between two apps, closing a window, or dismissing a launcher. The mechanism behind all of it is the focus history, a most-recent-first list of every client you have focused. This guide shows the recipes; [Focus History (concepts)](../concepts/focus-history.md) explains the model.

## Jump between your two most recent windows

`awful.client.focus.history.previous()` focuses the client you were on before this one. Bound to a key, it is the classic two-app toggle:

```lua
awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { "Mod1" },
        key         = "Tab",
        on_press    = function() awful.client.focus.history.previous() end,
        description = "focus previous client (history)",
        group       = "client",
    },
})
```

If you want to cycle through all visible clients instead of bouncing between two, use index order rather than history order:

```lua
awful.client.focus.byidx(1)   -- next client; -1 for previous
```

## Choose who gets focus when a window closes

Whenever the focused thing goes away, the compositor emits `request::focus_restore` on the affected screen. One signal covers every case: a client closes, a layer-shell surface (rofi, wofi, fuzzel) dismisses, the session unlocks, a monitor disconnects.

The default handler is `awful.permissions.focus_restore`: it picks the most recently focused client still visible on that screen and activates it. To change the policy, replace the handler:

```lua
screen.disconnect_signal("request::focus_restore", awful.permissions.focus_restore)

screen.connect_signal("request::focus_restore", function(s)
    -- Always fall back to the master client
    local master = s.tiled_clients[1]
    if master then
        master:emit_signal("request::activate", "focus_restore", { raise = false })
    end
end)
```

This is the standard replace-a-default-handler pattern; [Replace a default handler](./replace-default-handler.md) covers its pitfalls.

**Gotcha turned guarantee:** if your handler focuses nobody, the C core falls back to the topmost client on the monitor. A buggy or do-nothing handler cannot strand you with no focus.

## Prefer a specific kind of window

`awful.client.focus.history.get(s, idx, filter)` walks the history: `s` is the screen to search, `idx` how many matches to skip (0 is the most recent), and `filter` an optional predicate. Only clients currently visible on `s` are considered.

```lua
-- The most recently focused terminal on screen s
local term = awful.client.focus.history.get(s, 0, function(c)
    return c.class == "Alacritty"
end)
if term then
    term:emit_signal("request::activate", "focus_switch", { raise = true })
end
```

Combine it with the handler above and "when my editor closes, go back to the last terminal" is a three-line policy.

## Keep utility windows from taking fallback focus

`awful.client.focus.filter` decides which clients are eligible for fallback and directional focus. The default rejects desktop, dock, and splash windows plus anything unfocusable. Extend it rather than replacing it; the contract is to return the client to allow it, `nil` to reject:

```lua
local default_filter = awful.client.focus.filter
awful.client.focus.filter = function(c)
    if c.class == "scratchpad" then return nil end
    return default_filter(c)
end
```

This controls who can be *chosen*, not what gets recorded: every focused client still enters the history.

## Pause history tracking

For scripted focus changes that should not rewrite the history (previewing windows during a cycling loop, for example), suspend tracking around them:

```lua
awful.client.focus.history.disable_tracking()
-- ... walk through clients without disturbing the order ...
awful.client.focus.history.enable_tracking()
```

Calls nest: each `disable_tracking()` needs a matching `enable_tracking()`, and `is_enabled()` reports the current state.

## Debug where focus went

When focus lands somewhere unexpected, print the history and read it top to bottom; the top entry is who fallback will pick first:

```bash
somewm-client eval 'local out = {}
for i, c in ipairs(awful.client.focus.history.list) do
    out[#out + 1] = i .. "  " .. (c.name or c.class or "?")
end
return table.concat(out, "\n")'
```

If the order looks right but the wrong client wins, the usual culprits are `awful.client.focus.filter` rejecting the expected client, or the client not being visible on the screen that emitted `request::focus_restore`.

## See Also

- [Focus History (concepts)](../concepts/focus-history.md) - The model: how the list is ordered, and why it is independent of the client stack
- [Replace a default handler](./replace-default-handler.md) - The general pattern used above
- [Signals Reference](../reference/signals.md) - `request::focus_restore` and the other screen signals
