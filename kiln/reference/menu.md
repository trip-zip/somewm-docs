---
title: kiln.menu
description: "Popup menus drawn by the compositor: the show cfg, the item schema, submenus, keyboard navigation, and the client-list menu."
sidebar_position: 12
---

# kiln.menu

A menu is a floating column of pressable rows drawn by the compositor itself: no popup window, no external process. While one is open it owns the keyboard (an open menu outranks every keybinding, and a key the navigation map does not know is consumed rather than leaking to a binding underneath), and a press anywhere outside it dismisses the whole chain.

```lua
kiln.menu.show {
	items = {
		{ "terminal", function() kiln.spawn("foot") end },
		{ "session", {
			{ "lock", kiln.lock },
			{ "quit", kiln.quit },
		} },
	},
}
```

## kiln.menu.show(cfg)

Opens a menu and returns the open-menu state. With no `items`, or no screen to open on, it returns nil and opens nothing.

| Key | Meaning |
|---|---|
| `items` | The item list (required). |
| `screen` | Which screen to open on. Default: the focused screen. |
| `x`, `y` | Open at a point, in screen coordinates. Default 0, 0. |
| `under` | An element id; the menu drops below that element's bottom edge instead of using `x`/`y`. |

`kiln.ui.menu` is the same function under another name.

## The item schema

Each item is a table: label first, payload second. The payload's type is the whole schema:

| Item | Meaning |
|---|---|
| `{ "label", fn }` | A row that runs `fn`. Actions run after the menu closes, so an action can itself open another menu. |
| `{ "label", { subitems } }` | A row that opens a submenu, on hover and on press. Submenus nest without limit. |
| `icon = "/path"` | Optional key on any item: an image drawn before the label. Takes the same values `ui.image` accepts; `kiln.icon.client(c)` resolves a client's icon into one. |

## Module functions and state

| Name | Description |
|---|---|
| `kiln.menu.show(cfg)` | Open a menu. Replaces any menu already open. |
| `kiln.menu.close()` | Close the open menu, submenus included. No-op when none is open. |
| `kiln.menu.client_list(cfg)` | A prebuilt menu over every mapped client: one row per window with its icon and title (falling back to app id, then class). Pressing a row unminimizes, views its tag, focuses, and raises. `cfg` passes through to `show`. |
| `kiln.menu.nav(verb)` | Drive navigation from code: `"down"`, `"up"`, `"enter"`, `"back"`, `"close"`. Returns whether the verb was handled; false when no menu is open. |
| `kiln.menu.open` | The open-menu state. Non-nil exactly while a menu is up, which makes a press handler a toggle: close if open, show otherwise. |

`kiln.menu.declare(s)` is the runtime hook that draws the open chain inside each screen's frame; a config never calls it.

## Keyboard navigation

`kiln.menu.keys` maps keysyms to nav verbs. A config adds a key with one assignment (`kiln.menu.keys.j = "down"`) or replaces the whole map by assigning a table. The defaults:

| Keysym | Verb |
|---|---|
| `Down` | `down` |
| `Up` | `up` |
| `Right`, `Return`, `KP_Enter` | `enter` (enter a submenu, or run the row) |
| `Left`, `Escape` | `back` (close one level; closing the last level closes the menu) |

## Theme keys

The menu reads `menu_width` (default 200), `menu_height` (row height, 24), and `menu_submenu_icon` (optional image path drawn on submenu rows; unset renders a `>`), plus the shared palette: `bg` for the panel, `accent` for its border, `bg2` for the highlighted row. See [Theme Variables](theme-variables.md).

## See also

- [Menus guide](/kiln/guides/menus) - Recipes: bar-button menus, the right-click root menu, the window list
- [App Launcher guide](/kiln/guides/app-launcher) - A menu over every installed .desktop entry
- [kiln.ui](ui.md) - The element layer menus are drawn with
