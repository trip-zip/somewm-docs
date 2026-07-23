---
title: some.ui
description: The declarative UI module, every constructor, the cfg contract, floats and bands, and menus.
sidebar_position: 8
---

# some.ui

`some.ui` is how anything gets on screen in kiln: bars, titlebars, widgets, menus, even the clients themselves are declared as a tree of elements that the Clay solver lays out each frame. There are no widget objects and no update paths. You write a function that declares what the screen looks like right now, and kiln reruns it whenever something changes.

```lua
local some = require("somewm")
local ui = some.ui

screen.on("added", function(s)
  ui.bar(s, {}, function()
    ui.taglist(s)
    ui.spacer()
    ui.clock()
  end)
end)
```

## The declare-time contract

Constructors only work inside a declare function: a bar function, a widget function, or a policy the runtime calls during a frame. Outside a frame they error (`declare primitives are only callable inside` a declare pass). This is deliberate: an element is not an object you build and keep, it is a statement about the current frame. To change what is on screen, change the state your declare function reads; the next frame redeclares from the new facts.

Container constructors take their children as a closure, so nesting is plain Lua:

```lua
ui.row({ gap = 4 }, function()
  ui.box({ w = 14, h = 14, color = "#5078be", radius = 2 })
  ui.text("hello")
end)
```

## Constructors

| Constructor | Description |
|---|---|
| `ui.box(cfg, children?)` | Plain container or leaf. No layout direction of its own. |
| `ui.row(cfg, children?)` | Left-to-right container. |
| `ui.column(cfg, children?)` | Top-to-bottom container. |
| `ui.text(str, cfg?)` | Text leaf. cfg: `color` (default `theme.fg`), `size` (default `theme.font_size`). |
| `ui.spacer(n?)` | Flexible gap: `ui.box{ w = n or "grow", h = n }`. With no argument it grows to fill the row. |
| `ui.image(path, cfg?)` | Image leaf. cfg: `id, w, h, aspect, radius, on_press`. Images have no intrinsic size: give both axes, or one axis plus `aspect`. Decoded once and cached by path. |
| `ui.surface(c, cfg?)` | The client leaf: places the client's own buffer tree at the solved box. |
| `ui.titlebar(c, focused?)` | Stock titlebar row: icon, title, maximize and close buttons. Replaceable: assign `some.ui.titlebar = fn`. |
| `ui.resize_handles(c, z?)` | Eight invisible edge and corner handles over a floating client. |
| `ui.client(c, cfg?)` | The composite: border plus titlebar plus surface, rounded, colored by focus; adds resize handles when the client floats. |
| `ui.scroll(cfg, children)` | Clipped scroll viewport. cfg: `id` (required, keys the offset), `w, h, color, pad, step` (default 40). |
| `ui.each(items, key, declare)` | Keyed list: `key(item)` returns each element id, `declare(item, id, st)` gets a per-key state table that survives reorder. |
| `ui.widget(spec)` | Self-updating region: `{ fn or [1], watch = { "Class::signal", ... }, every = seconds }`. Returns the declare function; `watch` and `every` mark the screen dirty. |
| `ui.bar(s, cfg, fn)` | Register a bar on screen `s`. cfg: `color` (`theme.bg`), `height` (`theme.bar_height`), `gap` (6), `edge` (`"top"` or `"bottom"`, default top), `band` (default `"above"`). |
| `ui.taglist(s)` | Stock taglist: one pressable cell per tag, accent when selected. |
| `ui.tasklist(s, cfg?)` | Stock tasklist. cfg: `filter` (default `ui.filter.currenttags`), `width` (default `{ "grow", max = 180 }`). |
| `ui.systray(cfg?)` | Status-notifier tray items as pressable icon cells. cfg: `size` (default 18). |
| `ui.layoutbox(s)` | Current layout indicator; pressing cycles to the next layout. |
| `ui.layoutlist(s, cfg?)` | Layout picker, as a menu over `some.layout.list`. |
| `ui.clock()` | Minute-aligned clock text. |
| `ui.menu(cfg)` | Alias for `some.menu.show` (see [Menus](#menus)). |
| `ui.tooltip(text)` | Alias for `some.tooltip.attach`: returns an `on_hover` handler that shows a tooltip. `text` is a string or a function read at declare. |

Helpers that are not constructors:

| Helper | Description |
|---|---|
| `ui.color(spec)` | Parses `"#rrggbb"`, `"#rrggbbaa"`, or passes a `{ r, g, b, a }` table through. Every `color` cfg field accepts the same forms. |
| `ui.filter.currenttags` | Tasklist filter: clients on any selected tag of the screen. |
| `ui.filter.alltags` | Tasklist filter: every client. |
| `ui.filter.minimized` | Tasklist filter: minimized clients on the screen's selected tags. |
| `ui.bands` | The band name to z base table (see [Bands](#bands-z-order)). |

## The cfg contract

Every `box`, `row`, `column`, `surface`, and `image` cfg accepts exactly these fields:

| Field | Values | Meaning |
|---|---|---|
| `id` | string, or `{ name, index }` | Element id. Needed for handlers, `core.box` readback, and float anchoring. Auto-assigned when absent and a handler is present. |
| `w`, `h` | number (px), `"fit"`, `"grow"`, `"N%"`, `{ "grow", min =, max = }` | Sizing per axis. |
| `pad` | number, `{ x =, y = }`, or `{ left =, right =, top =, bottom = }` | Padding. |
| `gap` | number | Space between children. |
| `align` | `"center"`, or `{ x =, y = }` with x in `"left"/"center"/"right"` and y in `"top"/"center"/"bottom"` | Child alignment. |
| `color` | color spec | Background. |
| `radius` | number | Corner radius, all four corners. |
| `border` | `{ width = n or { left =, right =, top =, bottom = }, color = }` | Border; `width` defaults to 1. |
| `float` | table, see below | Take the element out of flow. |
| `aspect` | number | Aspect ratio (width / height). |
| `clip` | `{ vertical =, horizontal =, childOffset = { x, y } }` | Scissor plus content offset (what `ui.scroll` wraps for you). |
| `image` | `{ path = }` | Image fill (what `ui.image` wraps for you). |
| `on_press` | `fn(ev)` | Pointer press on the element; `ev` carries `button`, `mods`, `x`, `y`. |
| `on_release` | `fn(ev)` | Pointer release. |
| `on_hover` | `fn(over, hit)` | Pointer enter (`over = true`) and leave (`over = false`); `hit` names the element. |
| `on_scroll` | `fn(ev)` | Wheel over the element; `ev.dx` and `ev.dy` carry the deltas. |

Handler dispatch is innermost-first with no bubbling: the deepest element with a handler for the edge wins.

### float

`float` takes the element out of flow and attaches it somewhere:

| Sub-field | Values | Meaning |
|---|---|---|
| `anchor` | `"center"`, `"top"`, `"bottom"`, `"left"`, `"right"`; any Clay attach point (`"left_top"`, `"center_center"`, `"right_bottom"`, ...); or `{ parent =, element = }` when the two points differ | Where the element attaches. The friendly names set both points; the pair form is how a submenu hangs its left edge off its parent's right edge. |
| `to` | `"parent"` (default), `"root"`, `"element"` | What the float attaches to. |
| `parent` | element id | The target element, when `to = "element"`. |
| `offset` | `{ x, y }` | Offset from the attach point. |
| `band` | band name | Stacking band, see below. |
| `z` | number | Fine z within the band. |
| `passthrough` | boolean | Pointer events pass through the float. |

## Bands (z order)

A band is a z range convention for floats. `ui.bands`:

| Band | Base z |
|---|---|
| `background` | -1000 |
| `below` | 1000 |
| `normal` | 2000 |
| `above` | 3000 |
| `fullscreen` | 4000 |
| `overlay` | 5000 |

A float's effective z is `ui.bands[band] + z`. Equal z resolves by declaration order (the sort is stable), which is how focused-last stacking works inside a band. The in-flow tree sits at z 0, which is why `background` is negative.

Layer-shell surfaces declare into the band their protocol layer names: `background` to `background`, `bottom` to `below`, `top` to `above`, `overlay` to `overlay`.

## Menus

A menu is chrome in the screen's Clay tree, declared while open, gone when closed. There is no menu widget object.

```lua
some.menu.show({
  under = "launcher",
  items = {
    { "terminal", function() some.spawn("foot") end },
    { "layouts", {
      { "tile", function() screen.focused.selected_tag.layout = some.layout.tile end },
      { "max",  function() screen.focused.selected_tag.layout = some.layout.max end },
    } },
  },
})
```

| Function | Description |
|---|---|
| `some.menu.show(cfg)` | Open a menu. cfg: `screen` (default the focused screen), `items` (required), `x`, `y` (root offset, default 0), `under` (element id to drop below, the usual case for a bar button). |
| `some.menu.close()` | Close the open menu and its submenu chain. |
| `some.menu.client_list(cfg)` | A ready menu over all mapped clients, labelled and iconed like tasklist rows; pressing a row unminimizes, views, focuses, and raises the client. Same cfg as `show` but for `items`, which it fills in. |

Each item is `{ "label", action }` with an optional `icon = path`. When the second element is a function, pressing the row closes the menu and calls it. When it is a table, the row is a submenu that opens beside it on hover. That one rule is the entire item schema.

An open menu declares its own near-invisible screen-sized scrim underneath itself: a press anywhere outside the menu closes it, while presses on rows never reach the scrim.

:::note
Menus are pointer-driven: rows navigate on hover and dispatch on press, and there is no keyboard navigation. See [Limitations](/kiln/concepts/limitations).
:::

## See also

- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [Widgets](/kiln/tutorials/widgets)
- [Menus](/kiln/guides/menus)
- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [Theme variables](/kiln/reference/theme-variables)
