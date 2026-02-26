---
sidebar_position: 3
title: Client Stacking
description: How windows are layered and what controls their visual order
---

# Client Stacking

When windows overlap, which one appears in front?

## The Global Stack

There is exactly **one stack** for the entire compositor. Not per-tag, not per-screen. One global stack.

This explains behavior that might otherwise seem odd:
- Switch to tag 2, raise window A to the top
- Switch to tag 1, then back to tag 2
- Window A is still on top because the stack didn't reset

Switching tags changes what's *visible*, not the stacking order.

## Stack, Focus, and Layout: Three Different Things

These three concepts control different aspects of window behavior:

| Concept | What it controls | How it's ordered |
|---------|------------------|------------------|
| **Stack** | Z-order (visual overlap) | Raise/lower operations |
| **Focus** | Keyboard input destination | Single focused client |
| **Layout** | Position and size | Creation order |

The key insight: **layout algorithms use creation order, NOT stack order**. Raising a window to the top doesn't make it the "master" in a tiling layout because layouts ignore the stack entirely.

## Client Layers

Client properties determine which compositor layer a window belongs to:

| Property | Effect |
|----------|--------|
| `c.below` | Renders behind normal windows |
| `c.above` | Renders above normal windows |
| `c.ontop` | Renders above most windows |
| `c.fullscreen` | Renders above everything when focused |

See [Scene Graph](/concepts/scene-graph) for the full layer hierarchy including wibars and notifications.

Within a layer, the **stack** controls which client appears in front. A `normal` client can never appear above an `ontop` client, regardless of stack position.

## Stack Operations

### Methods

| Method | Effect | Signal emitted |
|--------|--------|----------------|
| `c:raise()` | Move to top of layer | `raised` |
| `c:lower()` | Move to bottom of layer | `lowered` |

Both methods handle transients automatically. Dialogs move with their parent window to maintain proper stacking relationships.

### What Changes the Stack?

| Action | Stack changes? | Notes |
|--------|----------------|-------|
| Open new window | Yes | Added to top of its layer |
| Close window | Yes | Removed from stack |
| `c:raise()` | Yes | Emits `raised` signal |
| `c:lower()` | Yes | Emits `lowered` signal |
| Focus a window | **No** | Focus and stack are independent |
| `c:swap(other)` | **No** | Swaps in clients array, not stack |
| Change tags | **No** | Tags filter visibility, don't reorder |

## The Two Client Arrays

The compositor maintains two separate arrays for clients:

| Array | Purpose | Order |
|-------|---------|-------|
| `clients` | All managed clients | Creation order |
| `stack` | Visual stacking | Z-order (back to front) |

### Why This Matters

When you query clients in Lua, you can choose which ordering you want:

```lua
-- Creation order (default) - what layouts use
local by_creation = client.get(s, false)

-- Stacked order - visual z-order
local by_stack = client.get(s, true)

-- client.tiled() also uses creation order
local tiled = awful.client.tiled(s)
```

This is why raising a window doesn't move it to the master position. `client.tiled()` returns clients in creation order, which layouts use to decide who gets the master slot.

## When Stack Order Matters

1. **Floating windows** - Which window appears in front when they overlap
2. **Dialogs over fullscreen** - Transient windows above fullscreen apps
3. **Querying stacked order** - When you need to iterate windows front-to-back or back-to-front

## When Stack Order Doesn't Matter

- **Tiled layouts** - Windows don't overlap, so z-order is invisible
- **Layout algorithms** - Use creation order to determine window positions

## Practical Examples

### Basic raise/lower

```lua
-- Open 3 windows in order: firefox, slack, terminal
-- Stack: [firefox, slack, terminal]  (terminal on top)

-- Focus firefox (stack doesn't change!)
client.focus = firefox
-- Stack: [firefox, slack, terminal]  (terminal still on top)

-- Raise firefox
firefox:raise()
-- Stack: [slack, terminal, firefox]  (firefox now on top)
```

### Keep a window always on top

```lua
-- Use the ontop layer
c.ontop = true

-- To toggle
c.ontop = not c.ontop
```

### Reacting to stack changes

```lua
-- Do something when a client is raised
client.connect_signal("raised", function(c)
    -- c was just raised to the top of its layer
end)

client.connect_signal("lowered", function(c)
    -- c was just lowered to the bottom of its layer
end)

-- React to layer property changes
client.connect_signal("property::ontop", function(c)
    -- c.ontop changed
end)

client.connect_signal("property::above", function(c)
    -- c.above changed
end)

client.connect_signal("property::below", function(c)
    -- c.below changed
end)
```

### Auto-raise on focus (optional behavior)

By default, focusing a window doesn't raise it. If you want focus to also raise:

```lua
client.connect_signal("focus", function(c)
    c:raise()
end)
```

## See Also

- [Master and Stack](/concepts/master-and-stack) - How tiling layouts divide the screen into primary and secondary sections
- [Scene Graph](/concepts/scene-graph) - Full compositor layer hierarchy
- [Focus History](/concepts/focus-history) - What determines focus when a client closes
- [Object Model](/concepts/object-model) - Understanding clients, tags, screens
