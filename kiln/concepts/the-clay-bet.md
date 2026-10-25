---
title: The Clay Bet
description: Why kiln's entire screen is a single Clay layout tree, and what falls out of that one decision.
sidebar_position: 1
---

# The Clay Bet

kiln is built on one idea: the entire visible surface of each screen is a single [Clay](https://github.com/nicbarker/clay) layout tree. Windows, bars, widgets, the contents of your tags, menus, notifications, the wallpaper: every one of them is a node in that tree.

## What Clay does

Clay is a layout solver in a single C header. You declare a tree of nested elements, each with sizing rules; Clay computes a rectangle for every one and hands back a flat array of drawing commands. It allocates nothing per frame, draws nothing itself, and knows nothing about windows.

The whole sizing vocabulary is four rules, set per axis:

| Rule | Means | In kiln |
|---|---|---|
| fixed | exactly this many pixels | `w = 180` |
| grow | share whatever is left over | `w = "grow"` |
| percent | a fraction of the parent | `w = "25%"` |
| fit | just big enough for the children | `w = "fit"` |

A container lays its children out in one of two directions, left to right or top to bottom.

![Three cells in one row, labelled w = 180, w = "grow" and w = "25%", each drawn at the width Clay solved for it](/img/kiln/clay/01-sizing.png)

*Figures captured from an earlier build; the layout is unchanged.*

```lua
ui.row({ w = "grow", h = 108, gap = 10 }, function()
  ui.box({ w = 180,    h = "grow" })
  ui.box({ w = "grow", h = "grow" })
  ui.box({ w = "25%",  h = "grow" })
end)
```

Nesting is how everything else gets built. A container holding a fixed square and a growing column is already a usable row:

![The same card twice, plain and with badges naming ui.row, ui.box, ui.column and ui.text](/img/kiln/clay/02-nesting.png)

```lua
ui.row({ pad = 14, gap = 12 }, function()
  ui.box({ w = 44, h = 44 })
  ui.column({ w = "grow", gap = 3 }, function()
    ui.text("Declarative syntax")
    ui.text("one function, called every frame")
  end)
end)
```

The labels are floats, so they take no space; the two cards are solved identically.

### Going further into Clay

- [How Clay's UI Layout Algorithm Works](https://www.youtube.com/watch?v=by9lQvpvMIc). Nic Barker, Clay's author, walking through the solver itself. Start here if you want the algorithm rather than the API.
- [The Clay README](https://github.com/nicbarker/clay#readme) is the documentation: the concepts, the full API, and every element macro.
- [nicbarker.com/clay](https://www.nicbarker.com/clay) is Clay laying out its own website, compiled to WebAssembly. The debug panel there is Clay's built-in inspector, the same one kiln embeds (see [Inspect the Live Element Tree](/kiln/guides/inspector)).

kiln vendors unmodified upstream Clay (revision `e6cc369`, v0.14) and its
official Odin binding in `clay/`. Cite `clay/clay.h` for exact behaviour.

## One tree, the whole screen

Every screen runs the same cycle:

1. Something marks the screen dirty (a client mapped, a tag switched, a property changed).
2. Lua declares a fresh node tree for that screen: your bars, the selected tag's layout with its clients, any floats, menus, and notifications.
3. Clay solves the tree: every node gets a box.
4. A thin retained renderer in Odin reconciles the solved boxes into the scene, the part list kiln's GLES renderer draws and presents.

The declaration is cheap and rebuilt from scratch; the reconcile is incremental. Nothing happens between dirty frames. See [Frames and Dirty State](/kiln/concepts/frames-and-dirty) for when a frame is produced.

The bar is the easiest place to see it. This is the bar from [the landing page](/kiln), reduced to the constructors each cell reaches for: three percent-third regions in a row, each region a container, the clock an ordinary in-flow box in the middle one.

![The kiln bar with each cell outlined and labelled with the constructor that declared it](/img/kiln/clay/03-bar.png)

```lua
ui.bar(s, { edge = "top" }, function()
  ui.row({ w = "33.33%", h = "grow", gap = 6,
      clip = { horizontal = true }, align = { y = "center" } }, function()
    ui.box({ id = "launcher", w = 28, h = 28 }, launcher_glyph)
    kiln.widgets.taglist(s)
    kiln.widgets.tasklist(s)
  end)
  ui.row({ w = "33.33%", h = "grow", align = "center" }, function()
    ui.box({ id = "clock", pad = { x = 8 } }, kiln.widgets.clock)
  end)
  ui.row({ w = "33.33%", h = "grow", gap = 6,
      clip = { horizontal = true }, align = { x = "right", y = "center" } }, function()
    kiln.widgets.systray()
    kiln.widgets.layoutbox(s)
  end)
end)
```

The percent thirds are the centering mechanism: Clay sizes a percent child unconditionally, so the middle third's center is the bar's center at any tasklist width, and the side regions clip so an overfull tasklist truncates at its third instead of pushing the clock aside.

## One fork, at the leaf

Every node in the tree is one of two things:

- **Clay owns the content.** A rectangle, a border, text, or an image, arriving as `RECTANGLE`, `BORDER`, `TEXT`, or `IMAGE`. This is everything kiln draws itself: bars, titlebars, taglists, menus, notifications, tooltips.
- **The node is someone else's Wayland surface.** A client's buffer tree, placed at the box Clay solved. It arrives as `CUSTOM`, which the renderer reads as "put this client's buffers here". kiln never draws into a client.

![One window with its titlebar outlined and labelled widgets.titlebar, and its content area labelled ui.surface](/img/kiln/clay/04-leaf.png)

A titlebar and the window under it are siblings, differing only in who supplies the pixels. Because the fork sits at the leaf and nowhere else, everything above it (containers, sizing, alignment, floats, stacking) is uniform.

## The two tiers

The API splits along one line, and the bar above shows both sides of it. [`ui.*`](/kiln/reference/ui) is the primitives: each constructor maps a cfg table onto one Clay concept and adds no policy. [`kiln.widgets.*`](/kiln/reference/widgets) is the stock widgets: compositions of those primitives that read compositor state (screens, tags, clients, the theme) and encode an opinion about what a taglist or a titlebar should be.

`scripts/widget-lint.sh` (run by `make check`) rejects any stock widget that reads a name outside the public API. Replacing a widget is one assignment, because every caller goes through the `kiln.widgets` table.

## Consequences {#what-this-deletes}

**Tiling layouts contain no rectangle arithmetic.** A traditional tile layout is a page of geometry math: divide the width, subtract the gaps, round, assign. kiln's tile layout declares a master container sized as a percentage beside a stack of `grow` cells. `master_width_factor` is that percentage:

![The same layout function at master_width_factor 0.4 and 0.75, with the master column visibly wider in the second](/img/kiln/clay/05-mwfact.png)

Layouts are ordinary Lua functions that declare nodes, so writing your own is short: see [Custom layouts](/kiln/guides/custom-layouts) and the [layout reference](/kiln/reference/layout).

**Hit testing is Clay's.** Widget hit testing asks Clay what is under the point, innermost first, in the tree that was drawn. Inside a client's box, the scene decides (so popups that overhang the box get clicks). See [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands).

**There is no separate widget toolkit.** A widget is not an object with a draw method. It is a function that declares nodes, using the constructors the layouts and the titlebar already use. The stock ones live on [`kiln.widgets`](/kiln/reference/widgets); building your own is the [widgets tutorial](/kiln/tutorials/widgets).

## Two retained trees

kiln keeps two retained trees: Clay's tree and its own scene, the part list the renderer draws from and diffs for damage. Keeping both costs memory and a reconcile pass; in return, layout and widget hit testing live only in Clay. What the model deliberately excludes is documented in [Limitations](/kiln/concepts/limitations), and how the work splits between Odin and Lua is in [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary).

## See also

- [Binding Clay](/kiln/concepts/binding-clay)
- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands)
- [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [ui reference](/kiln/reference/ui)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
