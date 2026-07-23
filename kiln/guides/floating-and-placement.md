---
title: Floating and Placement
description: Float windows, move and resize them with the mouse, and position them with placement helpers.
sidebar_position: 3
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Floating and Placement

<YouWillLearn>

- How `c.floating` and the `c.float` box relate
- Toggling floating from a key
- Positioning floats with `some.placement` helpers
- Interactive move and resize with mouse buttons and edge handles
- Keeping floats on screen with `no_offscreen`, `no_overlap`, and `under_mouse`

</YouWillLearn>

## 1. Two properties: the flag and the box

`c.floating` is a boolean: a floating client leaves the tiled order and is drawn above the tiles at its own position. `c.float` is that position, one table:

```lua
c.float = { x = 200, y = 120, width = 800, height = 600 }
```

The box is always replaced whole, never mutated field by field, so one write is one change. It covers the whole window including the titlebar, and it persists across floating and tiling: unfloat a client and float it again, and it comes back where it was. A client floated for the first time keeps its own size (plus titlebar height) at a cascading offset near the top-left, so successive new floats do not stack exactly.

Writing either property redraws the client's screens; no extra call is needed.

## 2. Toggle floating from a key

```lua
some.key {
	mods = { "mod" }, key = "space",
	desc = "toggle floating", group = "client",
	press = some.focused(function(c)
		c.floating = not c.floating
	end),
}
```

`some.focused(fn)` wraps the handler to receive the focused client, and no-ops when nothing is focused.

## 3. Place floats with helpers

Every helper in `some.placement` has the signature `helper(c, s)` (screen optional, defaulting to the client's own) and works by writing `c.float`. Eleven named positions place against the workarea, the space left after bars:

`centered`, `center_horizontal`, `center_vertical`, `left`, `right`, `top`, `bottom`, `top_left`, `top_right`, `bottom_left`, `bottom_right`

Plus three smarter ones:

| Helper | Does |
|---|---|
| `no_offscreen` | clamps the box back inside the workarea |
| `no_overlap` | finds a spot clear of every other visible float, falling back to `no_offscreen` when the screen is full |
| `under_mouse` | centers the box on the pointer, then clamps on screen; centers on the workarea if the pointer has not moved yet |

Helpers compose by being called in order:

```lua
some.placement.centered(c)
some.placement.no_offscreen(c)
```

Use them in a [rule](/kiln/guides/client-rules)'s `on` callback:

```lua
some.rule {
	match = { dialog = true },
	props = { floating = true },
	on = some.placement.centered,
}
```

or from a bind:

```lua
some.key {
	mods = { "mod" }, key = "c",
	desc = "center window", group = "client",
	press = some.focused(function(c)
		if c.floating then
			some.placement.centered(c)
		end
	end),
}
```

:::note
A rule fires at map, before the client has drawn anything, so a placement in a rule positions the size the client asked for, which may differ slightly from what it finally draws at.
:::

## 4. Interactive move and resize

Three client methods start a pointer drag. All of them must be called from a button handler while the button is still held: the press anchors the drag, and releasing the same button ends it. Called from a keybinding, they do nothing.

| Method | Does |
|---|---|
| `c:grab_move()` | floats the client and moves it with the pointer |
| `c:grab_resize(edges)` | resizes from a compass edge or corner: `"n"`, `"s"`, `"e"`, `"w"`, `"ne"`, `"nw"`, `"se"`, `"sw"` |
| `c:grab_resize_nearest()` | resizes from whichever corner is nearest the press |

The standard bindings (these exact two ship in the default config):

```lua
some.button { mods = { "mod" }, button = 1,
	press = function(c) c:grab_move() end }
some.button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }
```

So `mod` + left-drag moves any window (a tiled one floats as the drag starts), and `mod` + right-drag resizes from the nearest corner. Titlebars can wire the same methods to their own presses; the default titlebar drags on press.

Resizes are floored at `some.theme.min_size` (default 60 px) on both axes, so a drag cannot collapse a window to nothing.

## 5. Resize handles

Every floating client automatically carries eight invisible handles along its edges and corners, each `some.theme.resize_handle` (default 6) pixels thick. Hovering one sets the matching resize cursor; pressing one starts `c:grab_resize` for that edge. There is nothing to enable: they are part of the floating client's declaration, and only floating clients get them (a tiled client's geometry belongs to the layout).

## 6. Related state

Floating interacts with a few neighboring properties, all plain writes on the client:

- `c.ontop = true` keeps a float above other windows (a higher band, so it beats raising).
- `c.sticky = true` shows the client on every tag of its screen.
- Focusing a floating client raises it; focusing a tiled one does not reorder the tiles.

See [the client reference](/kiln/reference/client) for the full property list.

## Complete example

A float-centric setup: toggle and center from keys, drag with the mouse, and dialogs always float centered.

```lua
local some = require("somewm")

some.key {
	mods = { "mod" }, key = "space",
	desc = "toggle floating", group = "client",
	press = some.focused(function(c)
		c.floating = not c.floating
	end),
}

some.key {
	mods = { "mod", "shift" }, key = "c",
	desc = "center float", group = "client",
	press = some.focused(function(c)
		if c.floating then
			some.placement.centered(c)
		end
	end),
}

some.button { mods = { "mod" }, button = 1,
	press = function(c) c:grab_move() end }
some.button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }

some.rule {
	match = { dialog = true },
	props = { floating = true },
	on = function(c)
		some.placement.centered(c)
		some.placement.no_offscreen(c)
	end,
}
```

## See also

- [Client Rules](/kiln/guides/client-rules)
- [Placement reference](/kiln/reference/placement)
- [Client reference](/kiln/reference/client)
- [Theme variables](/kiln/reference/theme-variables)
