---
title: Menus
description: Build popup menus with kiln.menu, nest submenus, attach them to bar elements, and open a root menu on right-click.
sidebar_position: 5
---

# Menus

A kiln menu is a floating column of pressable rows drawn by the compositor itself: no popup window, no external process. It comes with its own dismissal behavior: a press anywhere outside the menu closes it. The smallest one is a list of labeled actions:

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

Each item is label first, payload second, and the payload's type is the whole schema: a function is an action, a nested table is a submenu, and an optional `icon = "/path"` draws an image before the label. The full cfg and item schema are in the [kiln.menu reference](/kiln/reference/menu); this guide is the recipes.

## Attach a menu to a bar button

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

The open-or-close check makes the button a toggle: pressing it while its menu is up dismisses instead of reopening. `kiln.menu.open` is non-nil exactly while a menu is up, which is what makes the check work.

## A root menu on right-click

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

## The window list on a key

`kiln.menu.client_list(cfg)` is a prebuilt menu over every mapped client: one row per window with its icon and title, and pressing a row unminimizes, views its tag, focuses, and raises it. `cfg` passes through to `menu.show`, so `screen`, `under`, `x`, and `y` all work:

```lua
kiln.key {
	mods = { "mod" }, key = "e",
	desc = "window list", group = "client",
	press = function() kiln.menu.client_list {} end,
}
```

## Group actions into submenus

A nested table opens as a second column attached to the right edge of its row, on hover and on press, nesting as deep as you like:

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

## Drive it from the keyboard

An open menu holds the keyboard: arrows move, Return enters or runs, Escape backs out ([the full default map](/kiln/reference/menu#keyboard-navigation)). If you want vim keys, each is one assignment:

```lua
kiln.menu.keys.j = "down"
kiln.menu.keys.k = "up"
```

Menu colors and sizing come from `menu_*` [theme variables](/kiln/reference/theme-variables).

## See also

- [kiln.menu reference](/kiln/reference/menu)
- [App Launcher](/kiln/guides/app-launcher)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
