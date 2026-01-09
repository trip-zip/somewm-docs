---
sidebar_position: 4
title: Focus History
description: How the compositor decides which window gets focus when one closes
---

# Focus History

When you close a window, which one gets focus next?

## The Focus History List

The focus history is maintained by `awful.client.focus.history`. Key facts:

- Most recently focused client is at the front
- When a client closes, the next one in history gets focus
- History has **unlimited depth**: every client you've ever focused is tracked until it closes

## How It Works

Every time a client receives focus:

1. It's removed from wherever it was in the history
2. It's inserted at the front (position 1)

```lua
-- Conceptually (simplified from awful/client/focus.lua)
function focus.history.add(c)
    focus.history.delete(c)                    -- Remove if present
    table.insert(focus.history.list, 1, c)     -- Insert at front
end
```

This means the history always reflects the *order you focused clients*, not their stack position or creation order.

## Example Walkthrough

You have 5 clients. You focus them in this order:

| Action | Focus History (front → back) |
|--------|------------------------------|
| Focus client 1 | [1] |
| Focus client 2 | [2, 1] |
| Focus client 5 | [5, 2, 1, ...] |
| Focus client 4 | [4, 5, 2, 1, ...] |
| **Close client 4** | Focus → 5, history becomes [5, 2, 1, ...] |
| **Close client 5** | Focus → 2, history becomes [2, 1, ...] |

Notice that closing client 4 gives focus to client 5 (the previous focus), and closing 5 jumps back to 2, skipping clients 3 and 1 because you never focused them recently.

## Focus History vs Client Stack

These are completely independent systems:

| Aspect | Focus History | Client Stack |
|--------|---------------|--------------|
| What it tracks | Focus order (timing) | Z-order (visual overlap) |
| What uses it | Focus fallback on close | Rendering order |
| How it's ordered | Most recent focus first | Back-to-front by raise/lower |
| Raising a window | No effect | Moves to top |
| Focusing a window | Moves to front | No effect |

You can have a window at the top of the z-order stack but deep in the focus history (if you raised it but haven't focused it recently). The two systems don't affect each other.

## Accessing the Focus History

```lua
-- Direct access to the history list
local history = awful.client.focus.history.list

-- Get the previously focused client
local prev = awful.client.focus.history.get(screen, 1, nil)

-- Get previous client on a specific screen
local prev_on_screen = awful.client.focus.history.get(s, 0, function(c)
    return c.screen == s
end)

-- Filter by arbitrary criteria
local prev_floating = awful.client.focus.history.get(nil, 0, function(c)
    return c.floating
end)
```

### Parameters for `focus.history.get()`

| Parameter | Description |
|-----------|-------------|
| `screen` | Filter to this screen (nil for any) |
| `idx` | How many positions back to look (0 = most recent, 1 = second most recent) |
| `filter` | Optional function `(client) -> boolean` for custom filtering |

## Common Use Cases

### Alt-Tab Style Switching

Switch between your two most recently focused windows:

```lua
awful.key({ "Mod1" }, "Tab", function()
    awful.client.focus.history.previous()
end)
```

Or cycle through the full history:

```lua
awful.key({ modkey }, "Tab", function()
    awful.client.focus.byidx(1)
end)
```

### Focus Follows Close

This is the default behavior. When a client closes, `awful.client.focus.history.previous()` is called automatically to focus the next client in history. No configuration needed.

### Screen-Aware Focus Fallback

Focus the previous client on the same screen:

```lua
client.connect_signal("unmanage", function(c)
    if c == client.focus then
        local fallback = awful.client.focus.history.get(c.screen, 0, function(cl)
            return cl ~= c and cl.screen == c.screen
        end)
        if fallback then
            fallback:emit_signal("request::activate", "history", {raise = true})
        end
    end
end)
```

### Custom Focus Fallback Logic

Override the default behavior entirely:

```lua
-- Replace default focus fallback with your own logic
client.connect_signal("request::unmanage", function(c)
    if c == client.focus then
        -- Your custom logic here
        local next_client = find_my_preferred_client()
        if next_client then
            next_client:emit_signal("request::activate", "custom", {raise = true})
        end
    end
end)
```

### Disable Focus History

If you want focus to follow a different pattern (e.g., always focus the master window):

```lua
awful.client.focus.history.disable_tracking()
```

Or selectively exclude clients:

```lua
awful.client.focus.filter = function(c)
    -- Return false to exclude from focus history
    if c.class == "some-app" then
        return false
    end
    return true
end
```

## Debugging Focus Issues

If focus isn't going where you expect when you close a window:

```lua
-- Print the current focus history
for i, c in ipairs(awful.client.focus.history.list) do
    print(i, c.name, c.class)
end
```

This shows the complete history in order, so you can see why a particular client got focus.

## Layer Shell Focus Restoration

Layer shell surfaces (rofi, wofi, fuzzel, and other launchers) are not clients - they're special Wayland surfaces that can grab keyboard focus for input.

When a layer shell surface closes after having keyboard focus, somewm automatically restores focus to the most recent client from focus history. This is handled by `awful.permissions.handle_layer_shell_closed`.

### How It Works

1. Layer shell surface opens (e.g., rofi launcher)
2. It grabs keyboard focus for input
3. User makes a selection or presses Escape
4. Layer shell surface closes
5. somewm emits `layer_shell::closed` signal
6. Default handler calls `awful.client.focus.history.get()` to find the previous client
7. That client receives focus via `request::autoactivate`

### Customizing the Behavior

Replace the default handler with your own:

```lua
-- Disconnect the default handler
awesome.disconnect_signal("layer_shell::closed", awful.permissions.handle_layer_shell_closed)

-- Connect your own
awesome.connect_signal("layer_shell::closed", function()
    -- Your custom logic here
    -- For example, always focus the master client:
    local s = awful.screen.focused()
    local master = awful.client.getmaster(s)
    if master then
        master:emit_signal("request::activate", "layer_shell_closed", {raise = true})
    end
end)
```

### Note for AwesomeWM Users

This is a **somewm-specific feature**. AwesomeWM doesn't have layer shell (it's a Wayland protocol), so `layer_shell::closed` signal and `handle_layer_shell_closed` don't exist there.

## See Also

- [Client Stacking](/concepts/client-stack) - Z-order and visual overlap (independent from focus history)
- [Object Model](/concepts/object-model) - Understanding clients, tags, screens
- [Wayland vs X11](/concepts/wayland-vs-x11) - Why some things work differently
