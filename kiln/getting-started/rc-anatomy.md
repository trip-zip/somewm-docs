---
title: Anatomy of rc.lua
description: "A guided tour of the default config, top to bottom: globals, theme, assets, menus, tags, the bar, bindings, rules, and policy hooks."
sidebar_position: 3
---

# Anatomy of rc.lua

The default `rc.lua` (called `kilnrc.lua` in the source tree) is a complete
desktop written against the public API only: one `require`, no compositor
internals. This page walks it top to bottom. Open your copy alongside (see
[First Launch](/kiln/getting-started/first-launch) for where it lives).

The file's header lists four numbered SUBSTITUTIONS: behaviors expressed
through a different mechanism than the obvious one, because the obvious one
would need a capability kiln does not have. The wallpaper is the biggest: kiln
has no drawing API, so the gradient and logo are an SVG string rendered once
to a cached PNG by `rsvg-convert`.

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

## Errors first

The very first wiring is the error bus, so everything after it fails loudly:

```lua
some.on("error", function(_, err)
	some.notify {
		urgency = "critical",
		title = "Oops, an error happened!",
		message = tostring(err),
	}
end)
```

Every pcall-caught config error surfaces as a critical notification instead
of vanishing into the log.

## Theme and modkey

```lua
some.modkey = "super"
```

`some.modkey` is what the string `"mod"` resolves to in every key and button
spec. The stdlib default is `alt`; the shipped config picks `super`.

The theme section defines three inline palettes (gruvbox, catppuccin, nord),
each mapping the same nine keys (`bg`, `bg2`, `fg`, `accent`, `muted`,
`titlebar`, `titlebar_focus`, `close`, `urgent`). The chosen name persists in
`$XDG_CONFIG_HOME/kiln/theme`; `switch_theme(name)` writes the file and calls
`some.reload()`, and the reload re-runs this file, which re-reads the name.
Catppuccin is the fallback when the file is missing. See
[Theming](/kiln/tutorials/theming) and the
[theme variable reference](/kiln/reference/theme-variables).

## Glyphs and the wallpaper

The config draws no icons from disk. Every glyph (close button, layout icons,
menu icons) is a small inline SVG rendered to a cached PNG through
`some.asset`, and the wallpaper is the same trick at screen size: a gradient
in the theme colors plus the kiln mark, memoized per resolution and scale
(SUBSTITUTION 1). `KILN_WALLPAPER` still wins when it is set. The rendered
glyphs also feed two theme keys the stdlib reads when present:

```lua
th.menu_submenu_icon = glyph("chevron", th.muted)
th.layout_icons = { tile = glyph("tile", th.fg), ... }
```

See the [wallpaper guide](/kiln/guides/wallpaper) for the pattern in
isolation.

## The menu

```lua
local function menu_items(s)
	return {
		{ "hotkeys", icon = glyph("keys", th.fg), function()
			some.hotkeys.show(s)
		end },
		{ "terminal", icon = glyph("terminal", th.fg),
			function() some.spawn(terminal) end },
		{ "theme", icon = glyph("palette", th.fg), {
			{ "gruvbox", function() switch_theme("gruvbox") end },
			{ "catppuccin", function() switch_theme("catppuccin") end },
			{ "nord", function() switch_theme("nord") end },
		} },
		{ "edit config", ... },
		{ "restart", icon = glyph("restart", th.fg), some.reload },
		{ "lock", icon = glyph("lock", th.fg), some.lock },
		{ "quit", icon = glyph("power", th.fg), some.quit },
	}
end
```

Menu items are `{ label, action }` pairs; a table as the second element nests
a submenu (the theme switcher), and `icon = <path>` adds a leading image
cell. The launcher button in the bar and the root right-click both open the
main menu through `some.menu.show`. See [Menus](/kiln/guides/menus).

## The app launcher

`mod+p` opens the menubar: every installed `.desktop` application behind a
type-to-filter prompt. It is built from `some.prompt.run` plus a config-owned
float listing the matches; the `.desktop` scan is config space, zero stdlib
lines. The [app launcher guide](/kiln/guides/app-launcher) rebuilds the idea.

## Screens: tags and the bar

Everything per-screen happens in one handler:

```lua
screen.on("added", function(s)
	tag.new { name = "dev", screen = s, layout = some.layout.tile }
	tag.new { name = "web", screen = s, layout = some.layout.tile }
	tag.new { name = "chat", screen = s, layout = some.layout.tile }
	tag.new { name = "files", screen = s, layout = some.layout.tile }
	tag.new { name = "media", screen = s, layout = some.layout.tile }
	s.tags[1]:view()

	ui.bar(s, { edge = "top", color = th.bg }, function()
		backdrop(s)          -- wallpaper, floated to the background band
		launcher_glyph(s)    -- the menu button (SUBSTITUTION 2)
		taglist(s)
		tasklist(s)
		ui.spacer()
		ui.systray()
		layoutbox(s)
		ui.box({
			id = "clock",
			float = { to = "parent", anchor = "center" },
			color = th.bg2, radius = 4, pad = { x = 8 }, align = "center",
			on_hover = ui.tooltip(function() return os.date("%A %d %B %Y") end),
		}, ui.clock)
		declare_launcher(s)
	end)
end)
```

`screen.on("added")` fires once per output, at boot and whenever a monitor is
plugged in, so tags and bars exist on every screen without special-casing
multi-monitor. `tag.new` creates a tag with a layout; `t:view()` selects it.

`ui.bar(s, cfg, fn)` registers a bar. The `fn` is a declare function: it runs
again on every dirty frame and simply states what the bar contains right now.
The local `taglist`, `tasklist`, and `layoutbox` are thin wrappers over the
stock cells that pass an `on = { press = ..., scroll = ... }` table, adding
gestures the stdlib does not wire by default (mod+click to move a client to
a tag, wheel to walk tags). A handler that returns a truthy value preempts
the stock behavior; returning nil declines to it. The clock is a plain box
floated to the bar's center with a tooltip. The full build-up is the
[bar tutorial](/kiln/tutorials/a-bar-from-scratch).

## Bindings

```lua
key { mods = { "mod" }, key = "s", desc = "show help", group = "kiln",
	press = some.hotkeys.toggle }

key { mods = { "mod", "shift" }, key = "c", desc = "close", group = "client",
	press = some.focused(function(c) c:close() end) }

key { mods = { "mod" }, key = "1-9", desc = "only view tag", group = "tag",
	press = function(i)
		local t = screen.focused.tags[i]
		if t then t:view() end
	end }
```

Every binding is one `key{}` call: mods, key, a press handler, plus `desc` and
`group` for the hotkeys sheet. The sheet itself is stdlib: `mod+s` calls
`some.hotkeys.toggle`, which renders every registered binding grouped by
`group`. `some.focused(fn)` wraps a client verb to run on the focused client
when there is one. `"1-9"` is a range: it expands to nine bindings and passes
the index to the handler. Note that `c:kill()` is deliberately unbound; the
polite `c:close()` is the only close verb in the default config.

Mouse bindings are the same shape:

```lua
button { mods = { "mod" }, button = 1, press = function(c) c:grab_move() end }
button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }
```

A third `button{}` with `on = "root"` binds right-click on the desktop to the
main menu. The [keybindings tutorial](/kiln/tutorials/keybindings) covers all
of this from scratch.

## Rules

```lua
rule { match = { fn = function() return true end },
	on = function(c)
		some.placement.no_overlap(c)
		some.placement.no_offscreen(c)
	end }

rule { match_any = {
		app = { "pinentry", "Blueman%-manager", "Gpick" },
		instance = { "pinentry" },
		class = { "Blueman%-manager", "Gpick" },
		role = { "pop%-up" },
	},
	props = { floating = true } }

rule { match_any = { app = { "wlroots" }, class = { "wlroots" } },
	props = { tag = "media", focus = false } }
```

Rules run when a client maps: selectors (`match`, `match_any`, `except`)
against `app`, `class`, `instance`, `title`, `role`, `dialog`, or an
arbitrary predicate; `props` are property writes; `on` is a callback. Two
idioms worth noting: an empty match clause matches nothing, so "all clients"
is spelled `match = { fn = function() return true end }`; and apps are named
in both their Wayland (`app`) and X11 (`class`/`instance`) forms so the rule
fires whichever way the client arrives. See
[Client rules](/kiln/guides/client-rules).

## Where policies hook in

The default behaviors live as ten replaceable `some.defaults.*` functions,
and the shipped config leaves all of them stock. What it does add is one
listener:

```lua
client.on("mouse::enter", function(c) c:focus() end)
```

That single line is focus-follows-mouse. Swapping a default wholesale is the
same shape in reverse: `client.off("request::activate",
some.defaults.activate)` then `client.on` with your own. See
[Replace default policies](/kiln/guides/replace-default-policies) and the
[defaults reference](/kiln/reference/defaults).

## Where to go next

Work through the tutorials in order:

- [Basics](/kiln/tutorials/basics): drive the stock desktop, then reload a change
- [Keybindings](/kiln/tutorials/keybindings)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [Widgets](/kiln/tutorials/widgets)
- [Theming](/kiln/tutorials/theming)
