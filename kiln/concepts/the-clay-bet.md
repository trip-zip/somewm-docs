---
title: The Clay Bet
description: Why kiln's entire screen is a single Clay layout tree, and what falls out of that one decision.
sidebar_position: 6
---

# The Clay Bet

kiln is built on one idea: the entire visible surface of each screen is a
single Clay layout tree. Windows, bars, widgets, the contents of your tags,
menus, notifications, the wallpaper: every one of them is a node in that
tree. [Layout with Clay](/kiln/concepts/layout-with-clay) covers the sizing
rules; this page is what the single tree buys and costs.

## What Clay does {#what-clay-does}

Clay is a layout solver in a single C header. Given a tree of nested
elements with sizing rules, it computes a rectangle for every one and hands
back a flat array of drawing commands. The sizing rules and worked examples
are in [Layout with Clay](/kiln/concepts/layout-with-clay).

## One tree, the whole screen

Every screen runs the same cycle:

1. Something marks the screen dirty (a client mapped, a tag switched, a property changed).
2. Lua declares a fresh node tree for that screen: your bars, the selected tag's layout with its clients, any floats, menus, and notifications.
3. Clay solves the tree: every node gets a box.
4. A thin retained renderer in Odin reconciles the solved boxes into the scene, the part list kiln's GLES renderer draws and presents.

The declaration is cheap and rebuilt from scratch; the reconcile is incremental. Nothing happens between dirty frames. See [Frames and Dirty State](/kiln/concepts/frames-and-dirty) for when a frame is produced.

## One fork, at the leaf

Every node in the tree is one of two things:

- **Clay owns the content.** A rectangle, a border, text, or an image, arriving as `RECTANGLE`, `BORDER`, `TEXT`, or `IMAGE`. This is everything kiln draws itself: bars, titlebars, taglists, menus, notifications, tooltips.
- **The node is someone else's Wayland surface.** A client's buffer tree, placed at the box Clay solved. It arrives as `CUSTOM`, which the renderer reads as "put this client's buffers here". kiln never draws into a client.

![One window with its titlebar outlined and labelled widgets.titlebar, and its content area labelled ui.surface](/img/kiln/clay/04-leaf.png)

*Figure captured from an earlier build; the layout is unchanged.*

A titlebar and the window under it are siblings, differing only in who supplies the pixels. Because the fork sits at the leaf and nowhere else, everything above it (containers, sizing, alignment, floats, stacking) is uniform.

## The two tiers

The API splits along one line. [`ui.*`](/kiln/reference/ui) is the primitives: each constructor maps a cfg table onto one Clay concept and adds no policy. [`kiln.widgets.*`](/kiln/reference/widgets) is the stock widgets: compositions of those primitives that read compositor state (screens, tags, clients, the theme) and encode an opinion about what a taglist or a titlebar should be.

`scripts/widget-lint.sh` (run by `make check`) rejects any stock widget that reads a name outside the public API. Replacing a widget is one assignment, because every caller goes through the `kiln.widgets` table.

## Consequences {#what-this-deletes}

**Tiling layouts contain no rectangle arithmetic.** A traditional tile layout is a page of geometry math: divide the width, subtract the gaps, round, assign. kiln's tile layout declares a master container sized as a percentage beside a stack of `grow` cells. Layouts are ordinary Lua functions that declare nodes, so writing your own is short: see [Custom layouts](/kiln/guides/custom-layouts) and the [layout reference](/kiln/reference/layout).

**Hit testing is Clay's.** Widget hit testing asks Clay what is under the point, innermost first, in the tree that was drawn. Inside a client's box, the scene decides (so popups that overhang the box get clicks). See [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands).

**There is no separate widget toolkit.** A widget is not an object with a draw method. It is a function that declares nodes, using the constructors the layouts and the titlebar already use. The stock ones live on [`kiln.widgets`](/kiln/reference/widgets); building your own is the [widgets tutorial](/kiln/tutorials/widgets).

## Two retained trees

kiln keeps two retained trees: Clay's tree and its own scene, the part list the renderer draws from and diffs for damage. Keeping both costs memory and a reconcile pass; in return, layout and widget hit testing live only in Clay. What the model deliberately excludes is documented in [Limitations](/kiln/concepts/limitations), and how the work splits between Odin and Lua is in [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary).

## See also

- [Layout with Clay](/kiln/concepts/layout-with-clay)
- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands)
- [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [Binding Clay](/kiln/concepts/binding-clay), the retired C implementation
