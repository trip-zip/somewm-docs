---
title: The Clay Thesis
description: Why kiln's entire screen is a single Clay layout tree, and what falls out of that one decision.
sidebar_position: 1
---

# The Clay Thesis

kiln is built on one idea: the entire visible surface of each screen is a single [Clay](https://github.com/nicbarker/clay) layout tree. Windows, bars, widgets, the contents of your tags, menus, notifications, the wallpaper: every one of them is a node in that tree. There is no window layer and a separate widget layer, no chrome pass and a separate client pass. One tree, solved as a whole, every frame that needs drawing.

## The loop

Each screen runs the same cycle:

1. Something marks the screen dirty (a client mapped, a tag switched, a property changed).
2. Lua declares a fresh node tree for that screen: your bars, the selected tag's layout with its clients, any floats, menus, and notifications.
3. Clay solves the tree: every node gets a box.
4. A thin retained renderer in C reconciles the solved boxes into `wlr_scene`, the scene graph wlroots actually presents.

The declaration is cheap and rebuilt from scratch; the reconcile is incremental. Nothing happens between dirty frames. When and why a frame is produced is its own topic: see [Frames and Dirty State](/kiln/concepts/frames-and-dirty).

## One fork, at the leaf

Every node in the tree is one of two things:

- **Clay owns the content.** A rectangle, a border, text, or an image. This covers all of kiln's chrome: bars, titlebars, taglists, menus, notifications, tooltips.
- **The node is someone else's Wayland surface.** A client's buffer tree, placed at exactly the box Clay solved for it. kiln never draws into a client; it only decides where the client's own pixels go.

That is the whole distinction. A titlebar and the window under it are siblings in the same tree, differing only in who supplies the pixels for the leaf. Because the fork sits at the leaf and nowhere else, everything above it (containers, sizing, alignment, floats, stacking) is uniform, and almost the entire framework (widgets, clients, tags, layouts, keys, rules) is Lua configuration over a small, general core.

## What this deletes

**Tiling layouts contain no rectangle arithmetic.** A traditional window manager's tile layout is a page of geometry math: divide the width, subtract the gaps, round, assign. In kiln, the tile layout declares a master container sized as a percentage beside a stack of `grow` cells, and Clay divides the space. Changing `master_width_factor` changes one declared percentage; the solver does the rest. Layouts are ordinary Lua functions that declare nodes, which is why writing your own is a short exercise: see [Custom layouts](/kiln/guides/custom-layouts) and the [layout reference](/kiln/reference/layout).

**Hit testing is Clay's order.** A click is answered by asking Clay what is under the point, innermost first, in the same tree that was drawn. There is no second bookkeeping structure that can disagree with the screen. If a menu draws over a button, the menu gets the click, because it is over the button in the one tree that defines both facts. Stacking itself is declaration order plus float bands: see [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands).

**There is no separate widget toolkit.** A widget is not an object with a draw method; it is a function that declares nodes, using the same constructors the layouts and the titlebar use. The bar is a row of declarations. The taglist is a row of boxes with press handlers. Composing a new widget means composing declarations: see the [widgets tutorial](/kiln/tutorials/widgets) and the [ui reference](/kiln/reference/ui).

## The experiment, honestly

wlroots already ships a retained scene graph, so kiln deliberately keeps two retained trees: Clay's and the scene's. The bet is that Clay earns its place by owning layout and hit testing so nothing else has to. kiln is the working test of that bet: a proof of concept with an unstable API, not a finished product. What the model deliberately excludes is documented in [Limitations](/kiln/concepts/limitations), and how the work splits between C and Lua is in [The C/Lua Boundary](/kiln/concepts/c-lua-boundary).

## See also

- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands)
- [The C/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [ui reference](/kiln/reference/ui)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
