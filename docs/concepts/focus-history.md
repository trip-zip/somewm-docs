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

## One Restoration Path

The reason the history exists: something that had focus is always eventually going away. A client closes, a launcher like rofi dismisses (layer-shell surfaces are not clients, but they can hold keyboard focus), the session unlocks, a monitor disconnects. Rather than four focus-restoration mechanisms, the C core funnels every one of these through a single signal: `request::focus_restore`, emitted on the affected screen.

The default handler, `awful.permissions.focus_restore`, consults the focus history and activates the most recently focused client still visible on that screen. This is why closing a window "goes back" to where you were, and why dismissing a launcher does too: it is the same decision, made in the same place. And because the C core falls back to the topmost client when no handler focuses anything, a broken handler degrades to sensible behavior instead of stranding focus.

This unified signal is a **somewm-specific design**. AwesomeWM restores focus from several separate code paths, and has no layer shell at all (it is a Wayland protocol).

## See Also

- [Control where focus goes](../guides/focus.md) - Recipes: alt-tab bindings, custom fallback policy, filtering, debugging
- [Client Stacking](/docs/concepts/client-stack) - Z-order and visual overlap (independent from focus history)
- [Object Model](/docs/concepts/object-model) - Understanding clients, tags, screens
- [Wayland vs X11](/docs/concepts/wayland-vs-x11) - Why some things work differently
