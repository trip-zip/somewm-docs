---
sidebar_position: 3
title: Scene Graph
description: How bands and client stacking determine drawing order in the wlroots scene.
---

# Scene Graph

SomeWM updates the wlroots scene from [Clay’s layout result](./how-somewm-draws.md). Each floating root has a band, stored as Clay’s `zIndex`, which determines its drawing order.

## Bands

Lower bands draw first. Within a band, roots draw in declaration order, so a later popup appears above an earlier one. The values come from `Z_*` in `declare.c`:

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

A wibar in the flow has no band: it is part of the output's column with the workarea. A tiled client has none either. Its frame is a cell of the workarea and only its surface floats, at the client's band, attached to its slot. The dump prints the band after `band` on a root line, and the inspector shows it as the floating element's z-index.

## Where things go

Floating changes placement, not the normal client band of 20. `below`, `above` and `ontop` change stacking. A fullscreen client uses band 40, or 50 when also `ontop`.

A wibox's band follows its `type` and `ontop`:

| You write | Band |
| --- | --- |
| `wibox { ... }` placed by its geometry | 25 |
| `awful.wibar { position = "top" }` | in the flow. The workarea moves down |
| `awful.wibar { ontop = true }` | 60, over the clients. Reserves no space |
| `wibox { type = "desktop" }` | -4, with the wallpaper |
| `awful.menu`, a tooltip, an `awful.popup` with `ontop = true` | 80 |
| a `naughty` notification | 90 |

A fullscreen client covers a bar in the flow. An ontop bar remains above it. Notifications appear above both.

## Struts and the workarea

The output is a column of bars and workarea. Clay assigns the remaining space to the workarea. `screen.workarea` reports its solved rectangle.

For example, a 720-pixel-high screen with one 32-pixel top bar has a 688-pixel-high workarea.

## Stacking within a band

Two clients in the same band are ordered by the client stack, which `c:raise()` and `c:lower()` change ([Client Stacking](./client-stack.md)). Under `max` and `magnifier`, a floating client is above the layout's clients whatever the raise order, and a transient of such a client is above every client of that layout.
