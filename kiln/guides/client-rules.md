---
title: Client Rules
description: Match new windows with some.rule and give them tags, screens, floating state, and placement automatically.
sidebar_position: 1
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Client Rules

<YouWillLearn>

- How `some.rule{}` selectors match a new window
- What the `props` table can set, and which keys are special
- When the `on(c)` callback runs and what it is for
- How multiple matching rules combine
- Three working rules: a browser pinned to a tag, floating centered dialogs, and a scratchpad terminal

</YouWillLearn>

A rule runs when a client maps, before it takes focus. It is the place to say "this app lives on that tag", "dialogs float", or "this window never steals focus", without touching a keybinding.

```lua
local some = require("somewm")

some.rule {
	match = { dialog = true },
	props = { floating = true },
	on = some.placement.centered,
}
```

A rule has up to three parts: selectors (which clients it matches), `props` (state to apply), and `on` (a callback for anything a property write cannot express).

## 1. Selectors

Four selector keys, each holding a clause table:

| Selector | Matches when |
|---|---|
| `match` | every field in the clause hits |
| `match_any` | any one field in the clause hits |
| `except` | vetoes the rule when every field in its clause hits |
| `except_any` | vetoes the rule when any field in its clause hits |

A clause can use these fields:

| Field | Tested against |
|---|---|
| `app` | `c.app_id` (Wayland app id) |
| `class` | `c.class` (X11 WM_CLASS class) |
| `instance` | `c.instance` (X11 WM_CLASS instance) |
| `title` | `c.title` |
| `role` | `c.role` (X11 WM_WINDOW_ROLE) |
| `dialog` | boolean: does the client have a parent window |
| `fn` | `fn(c)`, an arbitrary predicate over the client object |

String values are Lua patterns, and a list means any-of, so `app = "firefox"` and `app = { "firefox" }` behave the same. Because they are patterns, escape magic characters: to match the literal class `Blueman-manager`, write `"Blueman%-manager"`.

:::warning
A rule with no selector at all matches nothing, not everything. To match every client, use an explicit always-true predicate: `match = { fn = function() return true end }`.
:::

Wayland clients identify by `app_id`; X11 clients by `class`, `instance`, and `role`. An app that can run either way needs both named:

```lua
some.rule {
	match_any = { app = { "Gpick" }, class = { "Gpick" } },
	props = { floating = true },
}
```

## 2. Props

`props` is applied when the rule matches. Three keys are special; everything else is a plain property write on the client.

| Key | Effect |
|---|---|
| `tag` | a tag name (string) or tag object; the client's tags become `{ t }` |
| `screen` | a screen name (like `"eDP-1"`) or screen object; scopes the `tag` name lookup, or, with no `tag`, sends the client to that screen's selected tag |
| `focus` | `focus = false` stops the client taking focus when it opens |

Any other key is written directly onto the client: `floating`, `titlebar = false`, `sticky`, `ontop`, `fullscreen`, `urgent`, or a field of your own. Each write emits `property::<name>` like any other property write. See [the client reference](/kiln/reference/client) for the properties the library reads.

:::note
Sending a client to a tag never switches the view to that tag. If you want to follow it, do so in `on(c)`.
:::

## 3. The on(c) callback

`on` runs after `props`, with the client as its argument. It is where placement lives, because a placement helper is just a function of the client:

```lua
some.rule {
	match_any = { app = { "pinentry" } },
	props = { floating = true },
	on = some.placement.centered,
}
```

Anything else that needs code goes here too: multi-line setup, conditional tagging, following the client to its tag.

## 4. Ordering: every match applies

Rules are not first-match. Every rule that matches a client applies, in the order the rules were declared, and a later rule overrides an earlier one's props. That makes broad-then-specific stacking natural: a catch-all placement rule first, app-specific overrides after it.

```lua
-- Every client: place new floats in free space, and never off screen.
some.rule {
	match = { fn = function() return true end },
	on = function(c)
		some.placement.no_overlap(c)
		some.placement.no_offscreen(c)
	end,
}

-- App-specific rules declared later win on conflicts.
```

Rules only apply to normal windows; X11 override-redirect surfaces (menus, tooltips) bypass them entirely. `some.rule.clear()` drops every registered rule, which is what a config reload uses.

## 5. Worked example: browser to its own tag

Assuming a tag named `"web"` exists (created in your `screen.on("added")` handler):

```lua
some.rule {
	match_any = { app = { "firefox" }, class = { "firefox" } },
	props = { tag = "web" },
}
```

To jump to the browser when it opens, add the follow in `on`:

```lua
some.rule {
	match_any = { app = { "firefox" }, class = { "firefox" } },
	props = { tag = "web" },
	on = function(c)
		if c.tag ~= nil then c.tag:view() end
	end,
}
```

## 6. Worked example: dialogs float, centered

`dialog = true` matches any client with a parent window (file pickers, confirmation prompts):

```lua
some.rule {
	match = { dialog = true },
	props = { floating = true },
	on = some.placement.centered,
}
```

Placement helpers compose by being called in sequence, so "centered, but never off screen" is two calls in a custom `on`:

```lua
on = function(c)
	some.placement.centered(c)
	some.placement.no_offscreen(c)
end
```

## 7. Worked example: a scratchpad-style terminal

Launch a terminal under a dedicated app id, and give that id a rule that always floats it, keeps it on top, and centers it:

```lua
some.key {
	mods = { "mod" }, key = "grave",
	desc = "scratchpad terminal", group = "launch",
	press = function() some.spawn("foot --app-id=scratchpad") end,
}

some.rule {
	match = { app = "^scratchpad$" },
	props = { floating = true, ontop = true, sticky = true },
	on = some.placement.centered,
}
```

`sticky = true` keeps it visible on every tag of its screen, so it follows you around like a drop-down terminal. The `^...$` anchors keep the pattern from also matching a longer app id.

## See also

- [Floating and Placement](/kiln/guides/floating-and-placement)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [Placement reference](/kiln/reference/placement)
- [Client reference](/kiln/reference/client)
