---
title: kiln.ui
description: The declarative UI module, every constructor, the cfg contract, floats and bands, and menus.
sidebar_position: 8
---

# kiln.ui

`kiln.ui` is how anything gets on screen in kiln: bars, titlebars, widgets, menus, even the clients themselves are declared as a tree of elements that the Clay solver lays out each frame. There are no widget objects and no update paths. You write a function that declares what the screen looks like right now, and kiln reruns it whenever something changes. Every constructor here maps its cfg onto Clay and adds no policy; the stock taglist, tasklist, clock and their kin are policy, and live one tier up on [`kiln.widgets`](/kiln/reference/widgets).

```lua
local kiln = require("kiln")
local ui = kiln.ui

screen.on("added", function(s)
  ui.bar(s, { edge = "top" }, function()
    kiln.widgets.taglist(s)
    ui.spacer()
    kiln.widgets.clock()
  end)
end)
```

## The declare-time contract

Constructors only work inside a declare function: a bar function, a widget function, or a policy the runtime calls during a frame. Outside a frame they error (`declare primitives are only callable inside the frame handler`). This is deliberate: an element is not an object you build and keep, it is a statement about the current frame. To change what is on screen, change the state your declare function reads; the next frame redeclares from the new facts.

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
| `ui.box(cfg, children?)` | Plain container or leaf. Children run left to right unless cfg says `dir = "column"`; `ui.row` and `ui.column` are this with the direction in the name. |
| `ui.row(cfg, children?)` | Left-to-right container. |
| `ui.column(cfg, children?)` | Top-to-bottom container. |
| `ui.text(str, cfg?)` | Text leaf. cfg: `color` (default `theme.fg`), `size` (default `theme.font_size`), `font` (a Pango font description such as `"Sans Bold"`, see [Fonts](#fonts)), `wrap` (`"words"` default, `"newlines"`, `"none"`), `align` (`"left"` default, `"center"`, `"right"`; places wrapped lines within the text box, use the parent's `align` for a single line), `line_height` (px per line; 0, the default, uses the font height), `ellipsize` (see [Truncation](#truncation)). |
| `ui.spacer()` | Exactly `ui.box({ w = "grow" })`: an empty element the solver hands the leftover room. Takes no argument. |
| `ui.image(path, cfg?)` | Image leaf. cfg: `id, w, h, aspect, radius, on_press, recolor`. Images have no intrinsic size: give both axes, or one axis plus `aspect`. Decoded once and cached by path. `recolor` takes a color spec and uses the file as a stencil: the color replaces the decoded pixels and only their alpha survives, so one glyph file draws in any ink. |
| `ui.surface(c, cfg?)` | The client leaf: places the client's own buffer tree at the solved box. |
| `ui.scroll(cfg, children)` | Clipped scroll viewport. cfg: `id` (required, keys the offset), `w, h, color, pad, step` (default 40). |
| `ui.each(items, key, declare)` | Keyed list: `key(item)` returns each element id, `declare(item, id, st)` gets a per-key state table that survives reorder. |
| `ui.widget(spec)` | Self-updating region: `{ fn or [1], watch = { "Class::signal", ... }, every = seconds }`. Returns the declare function; `watch` and `every` mark the screen dirty. |
| `ui.bar(s, cfg, fn)` | Register a bar on screen `s`. cfg is ordinary element cfg plus `edge`; see [Bars](#bars). |
| `ui.popup(spec)` | Build a popup: open state, a keyboard claim, a scrim that closes on an outside press, and a per-frame declare, in one session-lived object with `show`, `close`, `toggle`. Built once at load, never inside a handler (construction registers a declare hook). |
| `ui.menu(cfg)` | Alias for `kiln.menu.show` (see [Menus](#menus)). |
| `ui.tooltip(text)` | Alias for `kiln.tooltip.attach`: returns an `on_hover` handler that shows a tooltip. `text` is a string or a function read at declare. |

:::note
The stock widgets that used to sit beside these constructors (taglist, tasklist, systray, layoutbox, layoutlist, clock, titlebar, resize handles, the client composite, and the form widgets) live on [`kiln.widgets`](/kiln/reference/widgets). They are compositions of the constructors above, not primitives.
:::

Helpers that are not constructors:

| Helper | Description |
|---|---|
| `ui.color(spec)` | Parses `"#rrggbb"`, `"#rrggbbaa"`, or passes a `{ r, g, b, a }` table through. Every `color` cfg field accepts the same forms. |
| `ui.bands` | The band name to z base table (see [Bands](#bands-z-order)). |

## Bars

`ui.bar(s, cfg, fn)` registers `fn` as a bar on screen `s`, and the bar reserves workarea on whichever edge it names. The bar's body is a container built from the bar's own cfg: ordinary element cfg plus `edge`, one of `"top"`, `"bottom"`, `"left"`, or `"right"` (default top), and `band` (default `"above"`). A left or right bar is a real bar, laid out as a column, reserving workarea on its side.

Everything else is a documented default, overridden by the ordinary element key:

| Field | Default | Meaning |
|---|---|---|
| `dir` | from the edge | `"row"` for top and bottom, `"column"` for left and right. |
| `h` (top/bottom), `w` (left/right) | `theme.bar_height` | The across-edge axis. The along-edge axis is always `"grow"`; only it and the bar's id are forced. |
| `pad` | `{ x = 8 }` horizontal, `{ y = 8 }` vertical | Padding on the along axis. |
| `gap` | 6 | Space between cells. |
| `align` | cross-axis center | `{ y = "center" }` on a row, `{ x = "center" }` on a column. |
| `color` | `theme.bg` | Background. |

**The defaults are filled per frame, not when the bar registers.** Assign `kiln.theme.bg` live and every bar that left `color` unset draws the new value on the next frame; the same goes for `bar_height` and the rest.

**There is no `height` key.** The across-edge axis is plain element sizing, `h` on a horizontal bar and `w` on a vertical one. A config carrying `height` from an older kiln gets the default silently, because unknown cfg keys pass through to the element layer, which also ignores them.

## The cfg contract

Every `box`, `row`, `column`, and `surface` cfg accepts exactly these fields (`image` and `text` take the narrower cfgs listed in the constructor table above):

| Field | Values | Meaning |
|---|---|---|
| `id` | string, or `{ name, index }` | Element id. Needed for handlers, `core.box` readback, and float anchoring, and it is what labels the element in the [inspector](/kiln/guides/inspector). Auto-assigned when absent and a handler is present; an element with neither is anonymous, which is supported but shows as a blank row. Two elements sharing an id in one frame is fatal, so repeated elements need `{ name, index }` with a numeric index. |
| `w`, `h` | number (px), `"fit"`, `"grow"`, `"N%"`, `{ "grow", min =, max = }` | Sizing per axis. Omitted means `"fit"`: the element hugs its children. |
| `dir` | `"row"`/`"ltr"`, `"column"`/`"ttb"` | Layout direction of the children, on any container. `ui.row` and `ui.column` set it by name; on `ui.box` it defaults to left to right. |
| `pad` | number, `{ x =, y = }`, or `{ left =, right =, top =, bottom = }` | Padding. |
| `gap` | number | Space between children. |
| `align` | `"center"`, or `{ x =, y = }` with x in `"left"/"center"/"right"` and y in `"top"/"center"/"bottom"` | Child alignment. |
| `color` | color spec | Background. |
| `radius` | number | Corner radius, all four corners. |
| `border` | `{ width = n or { left =, right =, top =, bottom =, between = }, color = }` | Border; `width` defaults to 1. The table form also takes `between` (Clay's `betweenChildren`), a divider drawn between adjacent children along the layout axis. |
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
| `clip` | boolean | The float inherits the clip rectangle of what it attaches to: the part outside is neither drawn nor hittable. For a menu or tooltip anchored inside a `ui.scroll`. Default off: a float extends past its parent freely. |
| `expand` | number, or `{ w =, h = }` | Grow the float's own box outward without moving or resizing its children. One number means both axes. This is how a popup gets a margin that paints and hits, where a `pad` would have inset every child instead. |
| `fit` | boolean | Keep the float inside the screen's workarea. An `to = "element"` float flips to the opposite side of its target when it would overflow, which is how a submenu near the right edge opens leftward; a `to = "root"` float clamps instead, since mirroring a root attach would throw it across the screen rather than beside anything. Requires an `id`, because the fit is computed from the element's solved box. |

## Fonts

`font` takes a Pango font description and interns it to an id the declaration
carries, so a leaf can name any installed face:

```lua
ui.text("Handgloves", { font = "Sans Bold", size = 14 })
ui.text("Handgloves", { font = "Serif Italic" })
```

Two rules follow from how the id is used.

**Size lives in `size`, not in the description.** `"Sans Bold 14"` is refused
rather than silently ignored, because the size is set absolutely at the
output's device scale on its own channel and a size in the description would be
overridden without warning.

**A family nothing on the system provides is not an error.** Pango substitutes,
so a typo is a visual bug rather than a dead session.

Omitting `font` uses `theme.font`, which is interned like any other
description. The face reaches both the raster and the measure callback, so a
bold run wraps at the width it actually draws at.

## Truncation

`ellipsize = true` truncates an overflowing run and marks the cut, instead of
letting it run past its container.

```lua
ui.box({ id = "row", w = 180, clip = { horizontal = true } }, function()
    ui.text(title, { ellipsize = true })
end)
```

**It needs a clipping ancestor, and this is the part that surprises people.** A
text element is sized to its own glyphs, and its render command reports that
same width, so there is no "available width" anywhere in the declaration for a
run to be measured against. What bounds a run is the clip its parent declared.
Truncation is therefore a property of the pair, not of the text leaf.

Without a horizontally clipping ancestor whose width is fixed independently of
the text, `ellipsize` does nothing at all, with no error. That is the same
precondition CSS imposes with `overflow: hidden` plus a bounded box.

The wrap mode does not matter. A clipping parent leaves its children at full
width rather than compressing them, so a `wrap = "words"` run inside a
horizontal clip stays on one line and overflows exactly like `wrap = "none"`.

**Known cosmetic cost.** The scissor is the clip element's outer box, so an
ellipsis inside a padded box sits against the box edge rather than inside the
padding. Put the clip on an inner box if the padding must be respected.

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
kiln.menu.show({
  under = "launcher",
  items = {
    { "terminal", function() kiln.spawn("foot") end },
    { "layouts", {
      { "tile", function() screen.focused.selected_tag.layout = kiln.layout.tile end },
      { "max",  function() screen.focused.selected_tag.layout = kiln.layout.max end },
    } },
  },
})
```

| Function | Description |
|---|---|
| `kiln.menu.show(cfg)` | Open a menu. cfg: `screen` (default the focused screen), `items` (required), `x`, `y` (root offset, default 0), `under` (element id to drop below, the usual case for a bar button). |
| `kiln.menu.close()` | Close the open menu and its submenu chain. |
| `kiln.menu.client_list(cfg)` | A ready menu over all mapped clients, labelled and iconed like tasklist rows; pressing a row unminimizes, views, focuses, and raises the client. Same cfg as `show` but for `items`, which it fills in. |
| `kiln.menu.nav(verb)` | Drive the open menu from the keyboard: `"down"`, `"up"`, `"enter"` (descend into a submenu or run the row), `"back"` (close one level, or the chain at the root), `"close"`. Returns whether the verb was handled. |
| `kiln.menu.keys` | The keysym-to-verb map behind the built-in keyboard handling: Down/Up move, Right/Return/KP_Enter enter, Left/Escape go back. Replaceable per key (`kiln.menu.keys.j = "down"`) or wholesale. |

Each item is `{ "label", action }` with an optional `icon = path`. When the second element is a function, pressing the row closes the menu and calls it. When it is a table, the row is a submenu that opens beside it on hover. That one rule is the entire item schema.

An open menu declares its own near-invisible screen-sized scrim underneath itself: a press anywhere outside the menu closes it, while presses on rows never reach the scrim.

An open menu also holds the keyboard: arrow keys move the selection, Right or
Return enters a submenu or runs the row, Left or Escape backs out. The map is
`kiln.menu.keys`; a keyboard descent into a submenu lights its first row,
while a pointer descent does not (the pointer already says where it is).

## See also

- [kiln.widgets](/kiln/reference/widgets)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [Widgets](/kiln/tutorials/widgets)
- [Menus](/kiln/guides/menus)
- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [Theme variables](/kiln/reference/theme-variables)
