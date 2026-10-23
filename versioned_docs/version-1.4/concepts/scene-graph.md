---
sidebar_position: 3
title: Scene Graph
description: How SomeWM 1.4 orders application, widget and lock surfaces.
---

# Scene Graph

SomeWM 1.4 places application buffers, widget surfaces and wallpaper in a wlroots scene tree. Sibling order controls overlap, and disabling a parent hides its descendants.

## What is a Scene Graph?

The tree groups visible content so the compositor can position, hide and reorder it. wlroots tracks which regions need repainting. Configuration normally controls this through client and wibox properties, rather than editing scene nodes directly.

## Scene Layers {#the-six-layers}

The current 1.4 source defines nine layers, from bottom to top:

| Layer | Use |
| --- | --- |
| Background | Wallpaper, desktop clients, desktop and splash wiboxes |
| Bottom | Clients with `below`, bottom layer-shell surfaces |
| Tile | Ordinary clients, including floating clients without another layer property |
| Float | Defined in the scene, but not selected by the current client classifier |
| Wibox | Ordinary wiboxes |
| Top | Clients with `above`, dock wiboxes, top layer-shell surfaces |
| Fullscreen | Fullscreen clients eligible for elevation |
| Overlay | Clients and wiboxes with `ontop`, overlay layer-shell surfaces |
| Block | Session-lock background and lock surfaces |

The names are internal scene layers. `floating` controls layout participation and does not by itself select the Float layer.

## Where Things Go by Default

### Windows (Clients)

The client classifier checks, in order: `ontop`, eligible fullscreen, `above`, `below`, transient parent and desktop type. An ordinary client uses Tile. An unmodified transient is placed above its parent in the same scene layer.

Fullscreen is elevated when the client has focus, no client has focus, or focus is on another screen. A fullscreen client can therefore move below ordinary UI when another client on its screen gains focus.

### Wibars and Wiboxes

| Wibox state | Layer |
| --- | --- |
| `type = "desktop"` or `"splash"` | Background |
| `ontop = true`, except desktop/splash | Overlay |
| `type = "dock"`, without `ontop` | Top |
| Other types, without `ontop` | Wibox |

Wibars use dock type. A plain wibox does not reserve screen space merely because its type is `"dock"`. Struts are separate.

### Notifications

`naughty.layout.box` defaults to `ontop = true`, placing its wibox in Overlay, above fullscreen clients. Custom notification layouts follow their own wibox type and `ontop` settings. There is no separate notification layer.

## Client Stacking Within Layers

`c:raise()` and `c:lower()` change client order within layer constraints. Transients remain associated with their parents. See [Client Stacking](client-stack.md).

## Practical Implications

<span id="why-your-wibar-stays-above-windows" />
<span id="why-fullscreen-hides-your-wibar" />
<span id="making-a-window-stay-on-top" />

A normal dock wibar sits above ordinary clients but below elevated fullscreen clients. An `ontop` wibox uses Overlay, above fullscreen. Session-lock surfaces use Block above both.

### Creating a desktop widget

<span id="creating-a-dropdown-terminal" />

```lua
local wibox = require("wibox")
local desktop_widget = wibox {
    type = "desktop",
    x = 100, y = 100,
    width = 200, height = 100,
    bg = "#00000080",
    visible = true,
    widget = wibox.widget.textbox("Desktop widget"),
}
```

Desktop type keeps this wibox behind clients even if other wiboxes are raised.

## Struts and Workarea

<span id="layer-diagram-by-use-case" />

Struts reserve space along screen edges. `awful.wibar` manages them unless configured to overlap clients. Tiling uses `screen.workarea`, which excludes that reserved space. `screen.geometry` remains the full logical screen rectangle.

For a 1080-pixel-high screen with only a 24-pixel top strut, the workarea height is 1056. Layer placement controls overlap, while struts control the space offered to layouts.

## See Also

- [Client Stacking](client-stack.md)
- [Object Model](object-model.md)
- [Wibar](../tutorials/wibar.md)
