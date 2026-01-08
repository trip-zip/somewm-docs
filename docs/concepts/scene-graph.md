---
sidebar_position: 3
title: Scene Graph
description: Understanding layers and stacking order
---

# Scene Graph

The scene graph determines what appears above or below everything else on your screen. Understanding it helps you control layer ordering for panels, notifications, and windows.

## What is a Scene Graph?

A scene graph is a tree structure containing all visual elements. The tree hierarchy determines:

- **Stacking order** - children are drawn after (on top of) earlier siblings
- **Visibility** - hiding a parent hides all children
- **Damage tracking** - only redraw what changed

You don't interact with the scene graph directly. Instead, you control which **layer** your windows and wibars belong to.

## The Six Layers

SomeWM organizes everything into six layers, rendered bottom-to-top:

```
┌─────────────────────────────────┐ ← Overlay (fullscreen)
│ ┌─────────────────────────────┐ │
│ │ ┌─────────────────────────┐ │ │ ← Top (wibars, notifications)
│ │ │ ┌─────────────────────┐ │ │ │
│ │ │ │ Floating windows    │ │ │ │ ← Floating
│ │ │ │ ┌─────────────────┐ │ │ │ │
│ │ │ │ │ Tiled windows   │ │ │ │ │ ← Tiled
│ │ │ │ │ ┌─────────────┐ │ │ │ │ │
│ │ │ │ │ │ Bottom      │ │ │ │ │ │ ← Bottom (background panels)
│ │ │ │ │ │ Background  │ │ │ │ │ │ ← Background (wallpaper)
└─┴─┴─┴─┴─┴─────────────┴─┴─┴─┴─┴─┘
```

| Layer | Z-Order | Contents | Examples |
|-------|---------|----------|----------|
| **Background** | 1 (bottom) | Wallpaper, desktop icons | `feh --bg-fill`, desktop widgets |
| **Bottom** | 2 | Panels that sit behind windows | Conky, background docks |
| **Tiled** | 3 | Normal tiled windows | Firefox, terminal, editor |
| **Floating** | 4 | Floating windows, dialogs | File dialogs, pop-ups |
| **Top** | 5 | Panels, notifications | Wibars, naughty notifications |
| **Overlay** | 6 (top) | Fullscreen content | Fullscreen video, lock screen |

## Where Things Go by Default

### Windows (Clients)

Normal clients go to the **Tiled** or **Floating** layer based on their state:

```lua
-- Tiled windows go to the Tiled layer
c.floating = false

-- Floating windows go to the Floating layer
c.floating = true

-- ontop puts floating windows above other floating windows
c.ontop = true

-- Fullscreen goes to Overlay
c.fullscreen = true
```

### Wibars and Wiboxes

Wibars (panels) default to the **Top** layer. You can change this with the `type` property:

```lua
-- Default: Top layer (above windows)
s.mywibar = awful.wibar {
    position = "top",
    screen = s,
}

-- Desktop layer: Background (behind windows)
local desktop_widget = wibox {
    type = "desktop",
    visible = true,
    -- Goes to Background layer
}

-- Dock layer: Top (like a dock/taskbar)
local dock = wibox {
    type = "dock",
    visible = true,
    -- Goes to Top layer, reserves strut space
}
```

Wibox types and their layers:

| `type` value | Layer | Reserves strut? |
|-------------|-------|-----------------|
| `"desktop"` | Background | No |
| `"dock"` | Top | Yes |
| `"toolbar"` | Top | No |
| `"notification"` | Top | No |
| `"normal"` (default) | Top | No |

### Notifications

Naughty notifications appear in the **Top** layer, above wibars and windows but below fullscreen content.

## Client Stacking Within Layers

The Scene Graph determines which *type* of element appears above others (wibars above windows, notifications above wibars). But what about multiple windows in the same layer?

Within the Tiled, Floating, and other client layers, windows have a **stacking order** controlled by `c:raise()` and `c:lower()`. This is separate from the layer system.

See [Client Stacking](/concepts/client-stack) for details on:
- The global client stack
- How raise/lower works
- Why focus and stack are independent

## Practical Implications

### Why your wibar stays above windows

Wibars are in the Top layer (5), while tiled windows are in layer 3. This is why your panel is always visible, even when windows are maximized.

### Why fullscreen hides your wibar

Fullscreen clients go to the Overlay layer (6), which is above the Top layer. This is intentional - fullscreen should be truly full-screen.

### Making a window stay on top

Use the `ontop` property to keep a floating window above other floating windows:

```lua
-- Keep a window on top of other floating windows
c.ontop = true

-- Toggle with a keybinding
awful.key({ modkey }, "t", function(c)
    c.ontop = not c.ontop
end)
```

### Creating a desktop widget

Use `type = "desktop"` for widgets that should sit behind windows:

```lua
local conky_like = wibox {
    type = "desktop",
    x = 100,
    y = 100,
    width = 200,
    height = 400,
    visible = true,
    bg = "#00000080",  -- Transparent background
}
```

### Creating a dropdown terminal

A dropdown terminal should be in the Top layer and marked `ontop`:

```lua
local dropdown = awful.popup {
    widget = { ... },
    ontop = true,
    visible = false,
    placement = awful.placement.top,
}
```

## Struts and Workarea

Panels in the **Top** layer can reserve space (struts) that windows avoid:

```lua
-- This wibar reserves space at the top
s.mywibar = awful.wibar {
    position = "top",
    screen = s,
    height = 24,
    -- Windows tile below this bar
}
```

The reserved space is subtracted from `screen.workarea`:

```lua
local s = screen.primary
print(s.geometry.height)   -- Full screen height: 1080
print(s.workarea.height)   -- Minus wibar: 1056
```

## Layer Diagram by Use Case

```
Layer     | What Goes Here
----------+--------------------------------------------------
Overlay   | Fullscreen videos, games, lock screens
Top       | Wibars, taskbars, notifications, dropdown menus
Floating  | Dialog boxes, floating terminals, pop-up windows
Tiled     | Normal application windows (browser, editor, etc.)
Bottom    | Background panels (Conky-style system monitors)
Background| Wallpaper, desktop icons
```

## See Also

- [Client Stacking](/concepts/client-stack) - How windows order within layers
- [The Object Model](/concepts/object-model) - Understanding clients and wibars
- [Architecture](/concepts/architecture) - How the compositor is structured
- [Wibar](/tutorials/wibar) - Create your own panel
