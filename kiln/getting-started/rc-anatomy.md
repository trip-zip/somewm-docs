---
title: Anatomy of rc.lua
description: "A guided tour of the default config, top to bottom: globals, theme, tags, the bar, bindings, rules, and policy hooks."
sidebar_position: 3
---

# Anatomy of rc.lua

The default `rc.lua` is a complete desktop written against the public API
only: one `require`, no compositor internals. This page walks it top to
bottom. Open your copy alongside (see
[First Launch](/kiln/getting-started/first-launch) for where it lives).

## The require line and the globals

```lua
local some = require("somewm")
local ui, key, rule, button = some.ui, some.key, some.rule, some.button
local th = some.theme
```

`require("somewm")` is the whole import. It returns the `some` module:
functions (`some.spawn`, `some.quit`, `some.dirty`), submodules (`some.ui`,
`some.layout`, `some.placement`), the theme table, and the binding
constructors `key`, `button`, `rule`. The locals are just shorthand.

Beyond the module, a config sees seven globals: `client`, `screen`, `tag`,
`layer`, `drag`, `notification` (the object classes and buses), and `core`
(the raw C boundary, which a normal config never needs). See
[The object model](/kiln/concepts/object-model).

## Theme and modkey

```lua
some.modkey = "alt"
th.bg = "#1c1c28"
th.accent = "#7aa2f7"
```

`some.modkey` is what the string `"mod"` resolves to in every key and button
spec. The theme is a plain table of colors and metrics; the default rc
overrides two keys and inherits the rest. See
[Theming](/kiln/tutorials/theming) and the
[theme variable reference](/kiln/reference/theme-variables).

## The hotkeys popup

Next comes about seventy lines building the `alt+s` cheat sheet. It is a
recipe, not a built-in: `some.key.all()` returns every binding's chord, `desc`
and `group`, and the config groups that registry into a centered overlay float
plus a click-away scrim, declared only while a boolean is set:

```lua
local hotkeys_open = false

local function declare_hotkeys(s)
	if not hotkeys_open then
		return
	end
	-- ... a scrim ui.box and a ui.column of groups built from some.key.all()
end
```

You can leave it untouched; the [hotkeys popup guide](/kiln/guides/hotkeys-popup)
rebuilds it step by step.

## The menu

```lua
local function menu_items(s)
	return {
		{ "terminal", function() some.spawn(os.getenv("TERMINAL") or "ghostty") end },
		{ "browser", function() some.spawn("firefox") end },
		{ "layout", layouts },
		{ "lock", some.lock },
		{ "quit", some.quit },
	}
end
```

Menu items are `{ label, action }` pairs; a table as the second element nests
a submenu (here `layouts`, built from `some.layout.list`). The bar's menu
button passes this to `some.menu.show`. See [Menus](/kiln/guides/menus).

## Screens: tags and the bar

Everything per-screen happens in one handler:

```lua
screen.on("added", function(s)
	tag.new { name = "term", screen = s, layout = some.layout.tile }
	tag.new { name = "web", screen = s, layout = some.layout.spiral }
	tag.new { name = "chat", screen = s, layout = some.layout.fair }
	tag.new { name = "media", screen = s, layout = some.layout.carousel }
	s.tags[1]:view()

	ui.bar(s, { edge = "top", height = 28, color = th.bg }, function()
		ui.taglist(s)
		ui.layoutbox(s)
		-- menu button, tasklist, spacer, clock ...
		declare_hotkeys(s)
	end)
end)
```

`screen.on("added")` fires once per output, at boot and whenever a monitor is
plugged in, so tags and bars exist on every screen without special-casing
multi-monitor. `tag.new` creates a tag with a layout; `t:view()` selects it.

`ui.bar(s, cfg, fn)` registers a bar. The `fn` is a declare function: it runs
again on every dirty frame and simply states what the bar contains right now.
`ui.taglist`, `ui.layoutbox`, `ui.tasklist` and friends are stock cells;
anything else is built from `ui.box`, `ui.row`, and `ui.text`. The default rc
also declares the wallpaper here (one image node floated to the background
band, read from `KILN_WALLPAPER`) and the clock with a tooltip:

```lua
		ui.box({
			id = "clock", color = th.accent, radius = 4, pad = { x = 8 },
			align = "center",
			on_hover = ui.tooltip(function() return os.date("%A %d %B %Y") end),
		}, ui.clock)
```

The full build-up is the [bar tutorial](/kiln/tutorials/a-bar-from-scratch);
the wallpaper trick is the [wallpaper guide](/kiln/guides/wallpaper).

## Bindings

```lua
key { mods = { "mod" }, key = "Return", desc = "open terminal", group = "launch",
	press = function() some.spawn(os.getenv("TERMINAL") or "ghostty") end }

key { mods = { "mod" }, key = "q", desc = "close client", group = "client",
	press = some.focused(function(c) c:close() end) }

key { mods = { "mod" }, key = "1-9", desc = "view tag", group = "tag",
	press = function(i)
		local t = screen.focused.tags[i]
		if t then t:view() end
	end }
```

Every binding is one `key{}` call: mods, key, a press handler, plus `desc` and
`group` for the hotkeys popup. `some.focused(fn)` wraps a client verb to run
on the focused client when there is one. `"1-9"` is a range: it expands to
nine bindings and passes the index to the handler.

Mouse bindings are the same shape:

```lua
button { mods = { "mod" }, button = 1, press = function(c) c:grab_move() end }
button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }
```

The [keybindings tutorial](/kiln/tutorials/keybindings) covers all of this
from scratch.

## Rules

```lua
rule { match_any = { app = { "pinentry" } },
	props = { floating = true }, on = some.placement.centered }
rule { match = { dialog = true }, props = { floating = true },
	on = some.placement.centered }
```

Rules run when a client maps: selectors (`match`, `match_any`, `except`)
against `app`, `class`, `title`, `role`, `dialog`, or an arbitrary predicate;
`props` are property writes; `on` is a callback, here a placement helper that
centers the window. See [Client rules](/kiln/guides/client-rules).

## Where policies hook in

The last section is the most kiln-flavored part of the file. Default
behaviors live as replaceable functions and signal listeners, and the config
swaps one wholesale:

```lua
client.off("request::activate", some.defaults.activate)
client.on("request::activate", function(c, ctx)
	c.activated_by = ctx.valid and "user" or "steal"
	if ctx.valid then c:focus() else c.urgent = true end
end)

client.on("mouse::enter", function(c) c:focus() end)
```

The stock focus-stealing arbitration is disconnected and replaced with a
custom one (which also records who asked, on a made-up property: objects
accept any key you store). The final line is focus-follows-mouse, which is
nothing more than a one-line listener. The ten `some.defaults.*` policies
work the same way; see
[Replace default policies](/kiln/guides/replace-default-policies) and the
[defaults reference](/kiln/reference/defaults).

## Where to go next

Work through the tutorials in order:

- [Basics](/kiln/tutorials/basics): drive the stock desktop, then reload a change
- [Keybindings](/kiln/tutorials/keybindings)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [Widgets](/kiln/tutorials/widgets)
- [Theming](/kiln/tutorials/theming)
