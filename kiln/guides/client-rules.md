---
title: Client Rules
description: Match new windows with kiln.rule and give them tags, screens, floating state, and placement automatically.
sidebar_position: 1
---

# Client Rules

A rule sets a new client's properties before it takes focus.

```lua
local kiln = require("kiln")

kiln.rule {
	match_any = { app = { "firefox" }, class = { "firefox" } },
	props = { tag = "web" },
}
```

A rule has up to three parts: selectors (which clients it matches), `props` (state to apply), and `on` (a callback for anything a property write cannot express).

The full spec (selector keys, clause fields, props semantics) is in the [rules reference](/kiln/reference/keybindings-and-rules#kilnrule). What matters for writing rules that work:

- **String values are Lua patterns**, and a list means any-of. Escape magic characters: to match the literal class `Blueman-manager`, write `"Blueman%-manager"`.
- **Wayland clients identify by `app_id`; X11 clients by `class`, `instance`, and `role`.** An app that can run either way needs both named:

```lua
kiln.rule {
	match_any = { app = { "Gpick" }, class = { "Gpick" } },
	props = { floating = true },
}
```

- **`props` writes properties; `on(c)` runs code.** Placement goes in `on`: helpers are functions that take the client and write `c.float`. Sending a client to a tag never switches the view to that tag; if you want to follow it, do so in `on(c)`.

:::warning
A rule with no selector at all matches nothing, not everything. To match every client, use an explicit always-true predicate: `match = { fn = function() return true end }`.
:::

## Ordering: every match applies

Rules are not first-match. Every rule that matches a client applies, in the order the rules were declared, and a later rule overrides an earlier one's props. Declare catch-all rules first and app-specific overrides after them.

```lua
-- Every client: place new floats in free space, and never off screen.
kiln.rule {
	match = { fn = function() return true end },
	on = function(c)
		kiln.placement.no_overlap(c)
		kiln.placement.no_offscreen(c)
	end,
}

-- App-specific rules declared later win on conflicts.
```

Rules only apply to normal windows; X11 override-redirect surfaces (menus, tooltips) bypass them entirely. `kiln.rule.clear()` drops every registered rule, which is what a config reload uses.

## Map order and focus

For a new normal client, Kiln runs these steps:

1. Read protocol properties and assign the focused screen's selected tag.
2. Apply matching rules in registration order.
3. Emit `map` to client instance and class listeners.
4. Emit requests for any initial fullscreen, maximized or minimized state.
5. Focus the client if it is eligible and `c.no_focus` is false or nil.

`c:focus()` does nothing while rules run. A rule can select the destination tag
with `c.tag:view()`; the final step then focuses the client. Rules run again
after config reload, but not on metadata changes or remaps of an existing
client object.

`props = { focus = false }` suppresses only the last step. To also refuse later
activation requests from those clients, replace the activation policy:

```lua
kiln.defaults.activate = function(c, ctx)
  if c.no_focus then return end
  if ctx.valid then c:focus() else c.urgent = true end
end
```

Explicit `c:focus()` calls, including click-to-focus, still work. A hidden or
minimized client must first be made visible and unminimized.

## Worked example: browser to its own tag

The opening rule assumes a tag named `"web"` exists (created in your `screen.on("added")` handler). To jump to the browser when it opens, add the follow in `on`:

```lua
kiln.rule {
	match_any = { app = { "firefox" }, class = { "firefox" } },
	props = { tag = "web" },
	on = function(c)
		if c.tag ~= nil then c.tag:view() end
	end,
}
```

## Worked example: dialogs float, centered

`dialog = true` matches any client with a parent window (file pickers, confirmation prompts):

```lua
kiln.rule {
	match = { dialog = true },
	props = { floating = true },
	on = kiln.placement.centered,
}
```

Placement helpers compose by being called in sequence, so "centered, but never off screen" is two calls in a custom `on`:

```lua
on = function(c)
	kiln.placement.centered(c)
	kiln.placement.no_offscreen(c)
end
```

## Worked example: a scratchpad-style terminal

Launch a terminal under a dedicated app id, and give that id a rule that always floats it, keeps it on top, and centers it:

```lua
kiln.key {
	mods = { "mod" }, key = "grave",
	desc = "scratchpad terminal", group = "launch",
	press = function() kiln.spawn("foot --app-id=scratchpad") end,
}

kiln.rule {
	match = { app = "^scratchpad$" },
	props = { floating = true, ontop = true, sticky = true },
	on = kiln.placement.centered,
}
```

`sticky = true` keeps it visible on every tag of its screen. The `^...$` anchors keep the pattern from also matching a longer app id.

## See also

- [Floating and Placement](/kiln/guides/floating-and-placement)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [Placement reference](/kiln/reference/placement)
- [Client reference](/kiln/reference/client)
