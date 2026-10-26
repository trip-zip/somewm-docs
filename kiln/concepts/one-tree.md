---
title: One tree per screen
description: Why every window, bar, widget and popup on a kiln screen is a node in one layout tree, solved from one snapshot of state per frame.
sidebar_position: 6
---

# One tree per screen

The entire visible surface of each screen is a single Clay layout tree.
Windows, bars, widgets, the contents of your tags, menus, notifications,
the wallpaper: every one of them is a node in that tree, and the tree is
rebuilt from one snapshot of state each time the screen is drawn.
[Layout with Clay](/kiln/concepts/layout-with-clay) covers the sizing
rules; this page is what the single tree replaces and what it costs.

## What it replaces

In AwesomeWM and SomeWM a rectangle on screen comes from one of three
systems, each with its own rules:

- A **window's** rectangle comes from the tag layout (`awful.layout`): the
  layout function receives the workarea and the client list and assigns each
  client a geometry by arithmetic.
- A **widget's** rectangle comes from the wibox layout (`wibox.layout`,
  `wibox.container`): each widget reports the size it wants through `fit`,
  then its parent places it through `layout`, inside a wibox, titlebar or
  popup.
- A **floating** window's or popup's rectangle comes from `awful.placement`,
  which positions one rectangle relative to another.

The C core then adjusts the results for borders, titlebars and struts. No
widget can hold a window and no tag layout can hold a widget, so a titlebar
is a window rectangle from the tag layout, inset by C, with a widget tree
solved inside it by the wibox layout: three computations of one rectangle.

Each system also runs at its own time. The tag layout runs on a deferred
call after any of some twenty signals; the widget tree relayouts when a
widget reports a change and repaints on another deferred call; placement
runs once when it is called. Results pass between them through signals, so
at any moment the screen is assembled from rectangles computed from
different states.

Kiln has one system and one order. Something marks the screen dirty. At the
next frame your config reads the current state and declares the tree. Clay
solves it. The renderer walks the solved commands into the scene and draws.
Nothing in that chain reads a rectangle from an earlier pass, and state
changes during the declare are refused, so a window and the clock beside it
are always from the same moment. [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
lists what marks a screen dirty.

## What it costs

Widgets do not draw. Kiln draws rectangles, borders, text and images, and
anything else arrives as an image: the default config renders SVG through
`rsvg-convert` for its glyphs and wallpaper. A widget that wants an arc
gauge or a graph in AwesomeWM writes a `:draw()` method with cairo; in kiln
it declares boxes, or declares an image it rendered elsewhere. That is the
trade: no custom rasterisation, in exchange for one owner of every rectangle
and every pixel. [Limitations](/kiln/concepts/limitations) lists the rest.

A widget also has no `:fit()`. Fitting is a sizing rule the solver applies
(`w = "fit"`), and text is measured by the renderer's font metrics, so a
widget that sizes to its content declares that rule and nothing else.

## The frame

Every screen runs the same cycle:

1. Something marks the screen dirty (a client mapped, a tag switched, a property changed).
2. Lua declares a fresh node tree for that screen: your bars, the selected tag's layout with its clients, any floats, menus, and notifications.
3. Clay solves the tree: every node gets a box.
4. A thin retained renderer in Odin reconciles the solved boxes into the scene, the part list kiln's GLES renderer draws and presents.

The declaration is cheap and rebuilt from scratch; the reconcile is incremental. Nothing happens between dirty frames.

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

kiln keeps two retained trees: Clay's tree and its own scene, the part list the renderer draws from and diffs for damage. Keeping both costs memory and a reconcile pass; in return, layout and widget hit testing live only in Clay. How the work splits between Odin and Lua is in [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary).

## See also

- [Layout with Clay](/kiln/concepts/layout-with-clay)
- [Frames and Dirty State](/kiln/concepts/frames-and-dirty)
- [Nodes, Floats, and Bands](/kiln/concepts/nodes-floats-and-bands)
- [The Native/Lua Boundary](/kiln/concepts/c-lua-boundary)
- [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm)
- [Binding Clay](/kiln/concepts/binding-clay), the retired C implementation
