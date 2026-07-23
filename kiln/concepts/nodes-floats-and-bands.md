---
title: Nodes, Floats, and Bands
description: How stacking order works in kiln's one tree, and how floats, layer-shell surfaces, and hidden clients fit in.
sidebar_position: 4
---

# Nodes, Floats, and Bands

Everything on a kiln screen lives in one tree (see [The Clay Thesis](/kiln/concepts/the-clay-thesis)), so "what draws over what" has one answer with two ingredients: declaration order, and float bands.

## Declaration order is the base

In-flow nodes draw in the order they are declared, later over earlier where they overlap. Tiled clients are in-flow, so they sit under everything floated. Within any group at equal depth, the tiebreak is always declaration order, which is how "focused last" puts the focused client on top of its band: it is simply declared last.

## Bands are named z ranges

A float leaves the flow and names a band. A band is nothing more than a base z value, spaced 1000 apart:

| band | z |
|---|---|
| `background` | -1000 |
| `below` | 1000 |
| `normal` | 2000 |
| `above` | 3000 |
| `fullscreen` | 4000 |
| `overlay` | 5000 |

A float's final z is its band base plus an optional small within-band `z`; equal z falls back to declaration order. The in-flow tree sits at z 0, which is why `background` is negative: a wallpaper float must draw under the tiles, not over them. The stdlib uses the bands you would expect: floating clients in `normal`, bars in `above`, fullscreen clients in `fullscreen`, menus and notifications in `overlay`. C knows nothing about bands; the whole scheme is a Lua convention over Clay's float z-index.

## Where a float attaches

A float declares what it attaches to: the root (the whole screen, how wallpaper and notifications position), its parent in the tree (how a submenu opens beside its row), or a named element anywhere in the tree (how a popup drops under a specific bar widget). Position within the target is a nine-point anchor grid: the corners, the edge midpoints, and the center, with friendly names (`center`, `top`, `bottom`, `left`, `right`) for the common ones and an offset for fine placement. Anchoring to named elements is what lets a calendar hang off the clock without either knowing the other's coordinates. See the [ui reference](/kiln/reference/ui) for the exact `float` fields, and [Floating and placement](/kiln/guides/floating-and-placement) for client-window placement.

## Layer-shell surfaces join the same order

External panels, launchers, and lockers speak the layer-shell protocol, which defines four layers. kiln maps them straight onto its bands: protocol `background` to `background`, `bottom` to `below`, `top` to `above`, `overlay` to `overlay`. A third-party panel and a kiln bar therefore stack in one coherent order, because they are both just floats with band z values in the same tree. See the [layer reference](/kiln/reference/layer).

## Clip is for scrolling, not containment

Clay can clip a subtree to a box, and kiln exposes that through `ui.scroll`: a viewport whose content moves under it. That is the only intended use. Containment (keeping things on screen, keeping a menu under the bar) is never done by clipping a parent; it is done by the output edge and by band order. A float is not clipped by the element it attaches to, and that is a feature: a popup anchored to a bar widget extends past the bar freely.

## Hidden means not in the tree

kiln has no hidden flag, no unmapped-but-tracked visibility state. A minimized client is simply not declared: not drawn, not hit-testable, occupying no space, with nothing to keep in sync. The same holds for clients on unselected tags. The object still exists with all its properties and signals; it just contributes no node this frame. Un-minimizing or selecting the tag means the next declaration includes it again. Absence from the tree is the one and only hiding mechanism.

## See also

- [The Clay Thesis](/kiln/concepts/the-clay-thesis)
- [ui reference](/kiln/reference/ui)
- [Floating and placement](/kiln/guides/floating-and-placement)
- [Wallpaper](/kiln/guides/wallpaper)
- [layer reference](/kiln/reference/layer)
