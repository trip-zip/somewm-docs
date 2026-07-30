---
title: Menus
description: Build popup menus with some.menu, nest submenus, attach them to bar elements, and open a root menu on right-click.
sidebar_position: 4
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Menus

<YouWillLearn>

- Opening a menu with `some.menu.show`
- The item shape: actions, submenus, icons
- Dropping a menu under a bar element with `under`
- The ready-made window list, `some.menu.client_list`
- A root menu on desktop right-click

</YouWillLearn>

A kiln menu is a floating column of pressable rows drawn by the compositor itself: no popup window, no external process. It comes with its own dismissal behavior: a press anywhere outside the menu closes it.

## 1. Show a menu

```lua
local some = require("somewm")

some.menu.show {
	items = {
		{ "terminal", function() some.spawn("foot") end },
		{ "browser", function() some.spawn("firefox") end },
		{ "quit", some.quit },
	},
}
```

`some.menu.show(cfg)` takes:

| Key | Meaning |
|---|---|
| `items` | the item list (required) |
| `screen` | which screen to open on (default: the focused screen) |
| `x`, `y` | open at a point, in screen coordinates (default 0, 0) |
| `under` | an element id; the menu drops below that element instead of using `x`/`y` |

It returns the open-menu state; `some.menu.open` is non-nil while a menu is up, and `some.menu.close()` closes it (submenus included). `some.ui.menu` is the same function under another name.

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

`icon` is an image path (the same values `ui.image` accepts); `some.icon.client(c)` resolves a client's icon into one, which is how the window-list menu gets its icons.

## 3. Submenus

A nested table opens as a second column attached to the right edge of its row. It opens on hover and on press, and it nests as deep as you like:

```lua
some.menu.show {
	items = {
		{ "session", {
			{ "lock", some.lock },
			{ "reload config", some.reload },
			{ "quit", some.quit },
		} },
		{ "terminal", function() some.spawn("foot") end },
	},
}
```

Moving the pointer to a different row closes the submenu chain below it; walking into the submenu keeps its parent row highlighted.

## 4. Attach to a bar element with under

Passing `under = "<element id>"` anchors the menu to a declared element instead of a point. A root menu opened under a bar button drops from the button's bottom edge, clearing the bar:

```lua
screen.on("added", function(s)
	some.ui.bar(s, { edge = "top" }, function()
		some.ui.box({
			id = "menu-btn",
			color = some.theme.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_press = function()
				if some.menu.open ~= nil then
					some.menu.close()
				else
					some.menu.show {
						under = "menu-btn", screen = s,
						items = {
							{ "terminal", function() some.spawn("foot") end },
							{ "quit", some.quit },
						},
					}
				end
			end,
		}, function()
			some.ui.text("menu", { size = 12, color = some.theme.bg })
		end)
	end)
end)
```

The open-or-close check makes the button a toggle: pressing it while its menu is up dismisses instead of reopening.

## 5. The window list

`some.menu.client_list(cfg)` is a prebuilt menu over every mapped client: one row per window with its icon and title, and pressing a row unminimizes, views its tag, focuses, and raises it. `cfg` passes through to `menu.show`, so `screen`, `under`, `x`, and `y` all work:

```lua
some.key {
	mods = { "mod" }, key = "e",
	desc = "window list", group = "client",
	press = function() some.menu.client_list {} end,
}
```

## 6. A root menu on right-click

A button bind with `on = "root"` fires when the press lands on empty desktop, which is the classic place for a main menu:

```lua
some.button { mods = {}, button = 3, on = "root",
	press = function()
		if some.menu.open ~= nil then
			some.menu.close()
		else
			some.menu.show {
				screen = screen.focused,
				items = {
					{ "terminal", function() some.spawn("foot") end },
					{ "lock", some.lock },
					{ "quit", some.quit },
				},
			}
		end
	end }
```

## Keyboard navigation

An open menu holds the keyboard. The defaults: Down and Up move the
selection, Right, Return, or KP_Enter enter a submenu or run the row, Left
and Escape close one level (and the whole chain at the root). The map is
`some.menu.keys`, keysym to verb, replaceable one key at a time or wholesale:

```lua
some.menu.keys.j = "down"
some.menu.keys.k = "up"
```

`some.menu.nav(verb)` drives the same machinery from code, with verbs
`"down"`, `"up"`, `"enter"`, `"back"`, and `"close"`; it returns whether the
verb was handled.

Menu colors and sizing come from the theme: `menu_width` (default 200) and `menu_height` (row height, default 24), with `bg`, `bg2`, and `accent` for the chrome.

## See also

- [App Launcher](/kiln/guides/app-launcher)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [UI reference](/kiln/reference/ui)
- [Theme variables](/kiln/reference/theme-variables)
