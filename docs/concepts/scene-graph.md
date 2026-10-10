---
sidebar_position: 3
title: Scene Graph
description: The scene is what wlroots draws, in the order the tree declares. Every floating root carries a band, Clay's zIndex, from the wallpaper at -4 to the pointer at 32767.
---

# Scene Graph

The scene is what wlroots draws. It holds nothing of its own: each frame, SomeWM [declares the output as one Clay tree, solves it, and reconciles the result into the scene](./how-somewm-draws.md). What is above what is a number on each floating root, its band, which is the Clay floating element's `zIndex`. Clay sorts floating roots by it, and the renderer keeps that order in the scene.

## Bands

The scene draws roots from the lowest band to the highest, and roots in the same band in declaration order, so a later popup is above an earlier one. The numbers are the `Z_*` enum in `declare.c`:

| Band | What is there |
| --- | --- |
| -8 | a layer-shell surface in the background layer |
| -6 | a client of type desktop |
| -4 | the wallpaper wibox, and a wibox of type `desktop` or `splash` |
| -2 | a layer-shell surface in the bottom layer |
| 10 | a client marked below |
| 20 | a normal client |
| 25 | a wibox placed by its geometry, and a wibar that is not ontop and reserves no space |
| 30 | a client marked above |
| 38 | the backdrop behind a fullscreen client |
| 40 | a fullscreen client |
| 50 | a client marked ontop |
| 60 | an ontop wibar |
| 70 | a layer-shell surface in the top layer |
| 80 | an ontop wibox: popups, menus, tooltips, and an xdg popup over its owner |
| 90 | a notification |
| 100 | a layer-shell surface in the overlay layer |
| 110 | an override-redirect X11 window: a menu, a tooltip, a drag icon |
| 120 | a drag icon |
| 200, 210, 220 | the lock screen: backdrop, cover, surfaces |
| 32765, 32766 | Clay's inspector panel |
| 32767 | the pointer |

A wibar in the flow has no band: it is part of the output's column with the workarea. A tiled client has none either; its frame is a cell of the workarea and only its surface floats, at the client's band, attached to its slot. The dump prints the band after `band` on a root line, and the inspector shows it as the floating element's z-index.

## Where things go

A client's band follows its state:

```lua
c.floating = true    -- still 20, as a root at its own box
c.below = true       -- 10
c.above = true       -- 30
c.fullscreen = true  -- 40, over a backdrop at 38
c.ontop = true       -- 50
```

A wibox's band follows its `type` and `ontop`:

| You write | Band |
| --- | --- |
| `wibox { ... }` placed by its geometry | 25 |
| `awful.wibar { position = "top" }` | in the flow; the workarea moves down |
| `awful.wibar { ontop = true }` | 60, over the clients; reserves no space |
| `wibox { type = "desktop" }` | -4, with the wallpaper |
| `awful.menu`, a tooltip, an `awful.popup` with `ontop = true` | 80 |
| a `naughty` notification | 90 |

So a wibar stays above a maximized client because the client's cell is inside the workarea the bar leaves; a fullscreen client at 40 covers a bar in the flow and a wibox at 25; an ontop bar at 60 stays above it; a notification at 90 is above both.

## Struts and the workarea

Nobody subtracts a wibar from the screen. The output is a column: top bar, workarea, bottom bar, and Clay gives the workarea what is left. `screen.workarea` is that element's solved box.

```lua
local s = screen.primary
print(s.geometry.height)   -- 720
print(s.workarea.height)   -- 688 under a 32 pixel bar
```

## Stacking within a band

Two clients in the same band are ordered by the client stack, which `c:raise()` and `c:lower()` change ([Client Stacking](./client-stack.md)). Under `max` and `magnifier`, a floating client is above the layout's clients whatever the raise order, and a transient of such a client is above every client of that layout.
