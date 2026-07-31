---
title: Menus
description: Build popup menus with kiln.menu, nest submenus, attach them to bar elements, and open a root menu on right-click.
sidebar_position: 4
---

# Menus

A kiln menu is a floating column of pressable rows drawn by the compositor itself: no popup window, no external process. It comes with its own dismissal behavior: a press anywhere outside the menu closes it.

## 1. Show a menu

```lua
local kiln = require("kiln")

kiln.menu.show {
	items = {
		{ "terminal", function() kiln.spawn("foot") end },
		{ "browser", function() kiln.spawn("firefox") end },
		{ "quit", kiln.quit },
	},
}
```

`kiln.menu.show(cfg)` takes:

| Key | Meaning |
|---|---|
| `items` | the item list (required) |
| `screen` | which screen to open on (default: the focused screen) |
| `x`, `y` | open at a point, in screen coordinates (default 0, 0) |
| `under` | an element id; the menu drops below that element instead of using `x`/`y` |

It returns the open-menu state; `kiln.menu.open` is non-nil while a menu is up, and `kiln.menu.close()` closes it (submenus included). `kiln.ui.menu` is the same function under another name.

## 2. Items

Each item is a table: label first, payload second.

```lua
local items = {
	{ "label", action_function },          -- a row that runs the function
	{ "label", { subitems } },             -- a row that opens a submenu
	{ "label", action, icon = "/path" },   -- optional icon before the label
}
```

The payload's type is the whole schema: a function is an action, a table is a submenu. Actions run after the menu closes, so an action can itself open another menu.

`icon` is an image path (the same values `ui.image` accepts); `kiln.icon.client(c)` resolves a client's icon into one, which is how the window-list menu gets its icons.

## 3. Submenus

A nested table opens as a second column attached to the right edge of its row. It opens on hover and on press, and it nests as deep as you like:

```lua
kiln.menu.show {
	items = {
		{ "session", {
			{ "lock", kiln.lock },
			{ "reload config", kiln.reload },
			{ "quit", kiln.quit },
		} },
		{ "terminal", function() kiln.spawn("foot") end },
	},
}
```

Moving the pointer to a different row closes the submenu chain below it; walking into the submenu keeps its parent row highlighted.

## 4. Attach to a bar element with under

Passing `under = "<element id>"` anchors the menu to a declared element instead of a point. A root menu opened under a bar button drops from the button's bottom edge, clearing the bar:

```lua
screen.on("added", function(s)
	kiln.ui.bar(s, { edge = "top" }, function()
		kiln.ui.box({
			id = "menu-btn",
			color = kiln.theme.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_press = function()
				if kiln.menu.open ~= nil then
					kiln.menu.close()
				else
					kiln.menu.show {
						under = "menu-btn", screen = s,
						items = {
							{ "terminal", function() kiln.spawn("foot") end },
							{ "quit", kiln.quit },
						},
					}
				end
			end,
		}, function()
			kiln.ui.text("menu", { size = 12, color = kiln.theme.bg })
		end)
	end)
end)
```

The open-or-close check makes the button a toggle: pressing it while its menu is up dismisses instead of reopening.

## 5. The window list

`kiln.menu.client_list(cfg)` is a prebuilt menu over every mapped client: one row per window with its icon and title, and pressing a row unminimizes, views its tag, focuses, and raises it. `cfg` passes through to `menu.show`, so `screen`, `under`, `x`, and `y` all work:

```lua
kiln.key {
	mods = { "mod" }, key = "e",
	desc = "window list", group = "client",
	press = function() kiln.menu.client_list {} end,
}
```

## 6. A root menu on right-click

A button bind with `on = "root"` fires when the press lands on empty desktop, which is the classic place for a main menu:

```lua
kiln.button { mods = {}, button = 3, on = "root",
	press = function()
		if kiln.menu.open ~= nil then
			kiln.menu.close()
		else
			kiln.menu.show {
				screen = screen.focused,
				items = {
					{ "terminal", function() kiln.spawn("foot") end },
					{ "lock", kiln.lock },
					{ "quit", kiln.quit },
				},
			}
		end
	end }
```

## Keyboard navigation

An open menu holds the keyboard. The defaults: Down and Up move the
selection, Right, Return, or KP_Enter enter a submenu or run the row, Left
and Escape close one level (and the whole chain at the root). The map is
`kiln.menu.keys`, keysym to verb, replaceable one key at a time or wholesale:

```lua
kiln.menu.keys.j = "down"
kiln.menu.keys.k = "up"
```

`kiln.menu.nav(verb)` drives the same machinery from code, with verbs
`"down"`, `"up"`, `"enter"`, `"back"`, and `"close"`; it returns whether the
verb was handled.

Menu colors and sizing come from the theme: `menu_width` (default 200) and `menu_height` (row height, default 24), with `bg`, `bg2`, and `accent` for the chrome.

## See also

- [App Launcher](/kiln/guides/app-launcher)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [UI reference](/kiln/reference/ui)
- [Theme variables](/kiln/reference/theme-variables)
