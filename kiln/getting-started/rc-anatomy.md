---
title: Anatomy of rc.lua
description: "The default config, walked top to bottom in file order: every section, its real code, and what each piece wires up."
sidebar_position: 4
---

# Anatomy of rc.lua

The default `rc.lua` (called `kilnrc.lua` in the source tree) is a complete
desktop in about 1000 lines of Lua, written against the public API only: one
`require`, no compositor internals. Open your copy alongside (see
[First Launch](/kiln/getting-started/first-launch) for where it lives). The
screenshots were captured from an earlier build.

## The require line and the globals

```lua
local kiln = require("kiln")
local ui, key, rule, button = kiln.ui, kiln.key, kiln.rule, kiln.button
local widgets = kiln.widgets
local th = kiln.theme

kiln.modkey = "super"
```

`require("kiln")` is the whole import. It returns the `kiln` module: functions
(`kiln.spawn`, `kiln.quit`, `kiln.dirty`), submodules (`kiln.ui`,
`kiln.layout`, `kiln.placement`, `kiln.widgets`), the theme table, and the
binding constructors `key`, `button`, `rule`. The locals are just shorthand.

`kiln.modkey` is what the string `"mod"` resolves to in every key and button
spec below; it is read at each `key{}` and `button{}` call. The stdlib default
is `alt`; the shipped config picks `super`.

Beyond the module, a config sees seven globals: `client`, `screen`, `tag`,
`layer`, `drag`, `notification` (the object classes and buses), and `core`
(the native compositor boundary, which a normal config never needs). See
[The object model](/kiln/concepts/object-model).

## Errors first

The config registers an error listener first:

```lua
kiln.on("error", function(_, err)
    kiln.notify { urgency="critical", title="Oops, an error happened!", message=tostring(err) }
end)
```

Binding, listener, rule and spawn callback errors produce a critical
notification through this handler. Bar, layout and direct timer errors are
log-only. See [error reporting](../guides/reload-and-debugging.md#3-catch-errors-with-the-error-signal).

![The critical notification the error handler produces, photographed by throwing a deliberate error](/img/kiln/rc/rc-error.png)

## Theme and its persistence

The theme section defines three inline palettes, each mapping the same nine
keys:

```lua
local palettes = {
	gruvbox = {
		bg = "#282828", bg2 = "#1d2021", fg = "#ebdbb2", accent = "#83a598",
		muted = "#665c54", titlebar = "#3c3836", titlebar_focus = "#504945",
		close = "#cc241d", urgent = "#d79921",
	},
	catppuccin = {
		bg = "#1e1e2e", bg2 = "#313244", fg = "#cdd6f4", accent = "#cba6f7",
		muted = "#6c7086", titlebar = "#1e1e2e", titlebar_focus = "#313244",
		close = "#f38ba8", urgent = "#f38ba8",
	},
	nord = {
		bg = "#2e3440", bg2 = "#272c36", fg = "#eceff4", accent = "#88c0d0",
		muted = "#4c566a", titlebar = "#3b4252", titlebar_focus = "#434c5e",
		close = "#bf616a", urgent = "#ebcb8b",
	},
}
```

The chosen name persists in one file, read back at the top of every run:

```lua
local theme_name = "catppuccin"
do
	local f = io.open(theme_file, "r")
	if f ~= nil then
		local name = f:read("*l")
		if name ~= nil and name ~= "" and palettes[name] ~= nil then
			theme_name = name
		end
		f:close()
	end
end
for k, v in pairs(palettes[theme_name]) do
	th[k] = v
end
```

Switching is a write plus a reload. The write is synchronous on purpose: the
reload re-runs this whole file, and the re-run has to see the new name.

```lua
local function switch_theme(name)
	os.execute("mkdir -p -- " .. shell_quote(theme_dir))
	local f = io.open(theme_file, "w")
	if f ~= nil then
		f:write(name .. "\n")
		f:close()
	end
	kiln.reload()
end
```

![The same desktop under the gruvbox, catppuccin and nord palettes, stacked](/img/kiln/rc/rc-themes.png)

There is no theme framework behind this: `th` is a plain table the stdlib
reads, and a palette is nine writes into it. See
[Theming](/kiln/tutorials/theming) and the
[theme variable reference](/kiln/reference/theme-variables).

## Assets: the config makes its own images

The desktop's look is made of images: line-art glyphs for the layoutbox, the
titlebar buttons, the menu rows and the submenu chevron, plus a gradient
wallpaper with the logo centered on it. The renderer draws only rectangles,
borders, text and images. The config writes SVG strings, renders them to
cached PNGs with `rsvg-convert` through `kiln.asset`, and declares the PNGs
as image leaves (`image = { path }`).

### The glyph set

Every glyph is a 24x24 viewBox drawn with a 2px round-capped stroke, so a new
entry matches the others:

```lua
local glyph_body = {
	close = '<path d="M6 6 18 18"/><path d="M18 6 6 18"/>',
	move = '<path d="M12 3v18"/><path d="M3 12h18"/>' ..
		'<path d="m9 6 3-3 3 3"/><path d="m9 18 3 3 3-3"/>' ..
		'<path d="m6 9-3 3 3 3"/><path d="m18 9 3 3-3 3"/>',
	maximize = '<path d="M4 9V4h5"/><path d="M15 4h5v5"/>' ..
		'<path d="M20 15v5h-5"/><path d="M9 20H4v-5"/>',
	chevron = '<path d="m10 6 6 6-6 6"/>',
```

The table continues with one shape per layout family, one per menu row, and
the three titlebar buttons. `glyph_svg` wraps a body in the shared `<svg>`
envelope with the stroke color filled in:

```lua
local GLYPH_PX = 64

local function glyph_svg(name, color)
	return string.format(
		'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" ' ..
		'viewBox="0 0 24 24" fill="none" stroke="%s" stroke-width="2" ' ..
		'stroke-linecap="round" stroke-linejoin="round">%s</svg>',
		color, glyph_body[name])
end
```

The rendering is batched: `want(name, color)` lists every name-and-color pair
the config will need (the color is part of the file, so the titlebar's two ink
states are two entries), then the config requests them all and flushes once.
All glyphs render in one `rsvg-convert` batch at load; the wallpaper renders
once per output size and scale.

```lua
local G = {}
for _, u in ipairs(glyph_use) do
	local svg = glyph_svg(u[1], u[2])
	u[3] = asset.request(u[1], GLYPH_PX, GLYPH_PX, svg)
end
asset.flush()
for _, u in ipairs(glyph_use) do
	G[u[1]] = G[u[1]] or {}
	G[u[1]][u[2]] = asset.path(u[3]) or false
end

local function glyph(name, color)
	local by = G[name]
	return (by ~= nil and by[color]) or nil
end
```

`glyph(name, color)` returns a readable PNG path, or `nil`. `nil` is not an
error: every call site is written to take it. Every glyph rasterizes at 64px
(`GLYPH_PX`) and downscales into its cell, which stays sharp at 1x and 2x
both. On a system without `rsvg-convert` the desktop degrades to text and
colored blocks instead of erroring.

### The wallpaper

The wallpaper uses the same trick at screen size: the theme gradient corner to
corner, the kiln mark centered on it, generated at the screen's *physical*
pixel count so the ramp is free of banding and the mark stays true under any
scale.

![The stock desktop with no clients: the gradient wallpaper with the kiln mark centered, under the bar](/img/kiln/rc/rc-wallpaper.png)

The wallpaper cache key is the physical size and the scale:

```lua
	local dims = w .. "x" .. h
	local hit = wallpapers[dims .. "@" .. scale]
	if hit ~= nil then
		return hit or nil
	end
```

The scale has to be in the key even though the pixel count already is: a pure
scale change on a fixed mode leaves the physical size alone (logical shrinks
by exactly what the scale grew), so a size-only key would serve the old
picture, whose mark was sized for the old scale. The rest of the function
builds one SVG string (gradient, then a nested `<svg>` carrying the logo's own
viewBox, so every number written into the document is an integer) and hands it
to `asset.svg`, memoized per size and scale.

The [wallpaper guide](/kiln/guides/wallpaper) rebuilds the pattern in
isolation.

## Defaults and one history list

```lua
local terminal = os.getenv("TERMINAL") or "foot"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor
local conffile = (debug.getinfo(1, "S").source:match("^@(.+)$")) or "kilnrc.lua"

local eval_history = {}
```

`conffile` is the config file's own path, read off the running chunk; it feeds
the "edit config" menu item. `eval_history` keeps the Lua prompt's history out
of the shared run-command history.

## Helpers the bindings and widgets share

Nine plain functions, all public-API arithmetic. The two the rest depend on
are `view_relative`, which views the tag `delta` steps from the current
selection, wrapping (shared by the arrow keys, the taglist scroll and the
backdrop wheel), and `visible_union`, which returns the screen's visible
client stack in declare order, deduped: clients on selected tags, then sticky
clients. It is the basis for focus and swap by index.

```lua
local function view_relative(s, delta)
	local sel = s.selected_tag
	if sel == nil or #s.tags == 0 then
		return
	end
	for i, t in ipairs(s.tags) do
		if t == sel then
			s.tags[(i - 1 + delta) % #s.tags + 1]:view()
			return
		end
	end
end

local function visible_union(s)
	local out, seen = {}, {}
	for _, t in ipairs(s.tags) do
		if t.selected then
			for _, c in ipairs(t.clients) do
				if not seen[c] and c.mapped and not c.minimized
						and not c.override_redirect then
					seen[c] = true
					out[#out + 1] = c
				end
			end
		end
	end
	for _, t in ipairs(s.tags) do
		for _, c in ipairs(t.clients) do
			if c.sticky and not seen[c] and c.mapped and not c.minimized then
				seen[c] = true
				out[#out + 1] = c
			end
		end
	end
	return out
end
```

On top of `visible_union` sit `focus_byidx` and `swap_byidx` (walk the stack
by index, wrapping), and `focus_screen_relative` (jump to the next monitor's
most recent client). Beside them: `layout_prev` (because `kiln.layout.next`
has no prev twin), `restore_minimized` (unminimize the most recently minimized
client on a selected tag), `jump_urgent` (view the urgent client's tag and
focus it), and `path_bins` (the `$PATH` executable list for the run prompt's
completion, memoized, shelled to `ls` because Lua has no readdir).

## The layout cycle

```lua
kiln.layout.list = {
	kiln.layout.tile,
	kiln.layout.tile.left,
	kiln.layout.tile.bottom,
	kiln.layout.tile.top,
	kiln.layout.carousel,
	kiln.layout.fair,
	kiln.layout.fair.horizontal,
	kiln.layout.max,
	kiln.layout.corner.nw,
	kiln.layout.floating,
	kiln.layout.spiral,
	kiln.layout.dwindle,
	kiln.layout.magnifier,
}
```

This is the cycle `mod+space` walks. No fullscreen layout is in it by
construction: fullscreen is a client property (`c:toggle_fullscreen()`), not a
tiling arrangement. See the [layout reference](/kiln/reference/layout).

## The menu

Menu items are `{ label, action }` pairs. A table as the second element nests
a submenu, and `icon = <path>` renders a leading image cell:

```lua
local function menu_items(s)
	return {
		{ "hotkeys", icon = glyph("keys", th.fg), function()
			kiln.hotkeys.show(s)
		end },
		{ "terminal", icon = glyph("terminal", th.fg),
			function() kiln.spawn(terminal) end },
		{ "theme", icon = glyph("palette", th.fg), {
			{ "gruvbox", function() switch_theme("gruvbox") end },
			{ "catppuccin", function() switch_theme("catppuccin") end },
			{ "nord", function() switch_theme("nord") end },
		} },
		{ "edit config", icon = glyph("edit", th.fg), function()
			kiln.spawn(editor_cmd .. " " .. shell_quote(conffile))
		end },
		{ "lock", icon = glyph("lock", th.fg), kiln.lock },
		{ "restart", icon = glyph("restart", th.fg), kiln.reload },
		{ "quit", icon = glyph("power", th.fg), kiln.quit },
	}
end

th.menu_submenu_icon = glyph("chevron", th.muted)

local function main_menu(s)
	return {
		{ "kiln", icon = glyph("palette", th.fg), menu_items(s) },
		{ "open terminal", icon = glyph("terminal", th.fg),
			function() kiln.spawn(terminal) end },
	}
end
```

The chevron line is the whole wiring for submenu markers: the stdlib menu
renders `th.menu_submenu_icon` as an image when it is set and keeps its text
`>` when it is not. The main menu opens from three places: the launcher glyph
in the bar, `mod+w`, and a right-click on the desktop.

![The main menu open under the launcher glyph, with the kiln submenu and the theme submenu open beside it](/img/kiln/rc/rc-menu.png)

See [Menus](/kiln/guides/menus).

## The app launcher: one replaced filter

`mod+p` opens `kiln.launcher`: every installed `.desktop` application behind a
type-to-filter entry. The launcher itself is stdlib; what stays in the config
is the one thing about it that is this desktop's choice rather than the
stdlib's, the ranking:

```lua
local default_rank = kiln.launcher.default_filter
kiln.launcher.filter = function(text)
	local out, term = {}, {}
	for _, a in ipairs(default_rank(text)) do
		if a.exec:sub(1, #terminal) == terminal then
			term[#term + 1] = a
		else
			out[#out + 1] = a
		end
	end
	for _, a in ipairs(term) do
		out[#out + 1] = a
	end
	return out
end
```

`launcher.filter` is the whole extension point: this override keeps the
stdlib's ranking and moves terminal apps to the end of it, because a launcher
opened by keyboard is usually not reaching for one. The `exec` test is a plain
prefix compare, not a pattern: `terminal` comes from `$TERMINAL`, and a dash in
it would be a Lua pattern metacharacter. The
[app launcher guide](/kiln/guides/app-launcher) builds the idea up from parts.

## The bar widgets

The bar's widgets are hand-rolled wrappers over
[`kiln.widgets`](/kiln/reference/widgets). The stock
`widgets.taglist`/`widgets.tasklist`/`widgets.layoutbox` wire only the one
gesture they can name; these wrappers pass an
`on = { press = ..., scroll = ... }` table that branches on the press button
and modifiers. A handler that returns a truthy value preempts the stock
behavior; falling off the end declines to it.

### The launcher glyph

The blocky "s" in the bar's corner is not an image. It is a Clay-composed
square in the accent color with two thin cuts floated over it in the bar
color, at one third and two thirds of its height:

```lua
local function launcher_glyph(s)
	local size = th.bar_height - 4
	local cut = math.max(1, math.floor(size / 9))
	ui.box({
		id = "launcher",
		w = size, h = size, color = th.accent, radius = 2, align = "center",
		on_press = function()
			if kiln.menu.open ~= nil then
				kiln.menu.close()
			else
				kiln.menu.show { under = "launcher", screen = s,
					items = main_menu(s) }
			end
		end,
	}, function()
		ui.box({
			float = { to = "parent",
				anchor = { parent = "right_top", element = "right_top" },
				offset = { x = 0, y = math.floor(size / 3) } },
			w = math.floor(size * 2 / 3), h = cut, color = th.bg,
		})
		ui.box({
			float = { to = "parent",
				anchor = { parent = "left_top", element = "left_top" },
				offset = { x = 0, y = math.floor(size * 2 / 3) } },
			w = math.floor(size * 2 / 3), h = cut, color = th.bg,
		})
	end)
end
```

![The launcher glyph magnified: an accent square with two bar-colored cuts forming a blocky s](/img/kiln/rc/rc-launcher.png)

Pressing it toggles the main menu, anchored under the element by id:
`kiln.menu.show { under = "launcher", ... }`.

### The taglist

The widget declares the cells, the squares and the plain-click default. Only
the added gestures live here:

```lua
local function taglist(s)
	widgets.taglist(s, { on = {
		press = function(t, ev)
			local mod = ev ~= nil and ev.mods ~= nil and ev.mods[kiln.modkey]
			local btn = (ev ~= nil and ev.button) or 1
			local c = client.focus
			if btn == 1 and mod then
				if c ~= nil then
					c.tags = { t }
				end
				return true
			elseif btn == 3 and mod then
				if c ~= nil then
					local nt, has = {}, false
					for _, tt in ipairs(c.tags) do
						if tt == t then
							has = true
						else
							nt[#nt + 1] = tt
						end
					end
					if not has then
						nt[#nt + 1] = t
					end
					if #nt > 0 then
						c.tags = nt
					end
				end
				return true
			elseif btn == 3 then
				t:toggle()
				return true
			end
		end,
		scroll = function(ev)
			view_relative(s, (ev.dy or 0) > 0 and 1 or -1)
		end,
	} })
end
```

A plain left press is not handled, so the stdlib default views the tag.

### The tasklist

```lua
local function tasklist(s)
	widgets.tasklist(s, {
		filter = function(c, sc)
			if c.sticky then
				return true
			end
			return widgets.filter.currenttags(c, sc)
		end,
		on = {
			press = function(c, ev)
				local btn = (ev ~= nil and ev.button) or 1
				if btn == 3 then
					kiln.menu.client_list { screen = s }
					return true
				elseif c == client.focus then
					c.minimized = true
					return true
				end
			end,
			scroll = function(ev)
				focus_byidx((ev.dy or 0) > 0 and 1 or -1)
			end,
		},
	})
end
```

A left press on any row but the focused one is not handled, so the stdlib
default unminimizes and focuses it. The filter adds sticky clients to the
default predicate.

### The layoutbox

The cell draws a glyph rather than the layout's name. The glyphs reach the
widget the way the menu chevron does, as a theme key, keyed by layout
*family*, so every variant of `tile` shares the tile glyph:

```lua
th.layout_icons = {}
for family, name in pairs(layout_glyph) do
	th.layout_icons[family] = glyph(name, th.fg)
end

local function layoutbox(s)
	widgets.layoutbox(s, { on = {
		press = function(t, ev)
			if ev ~= nil and ev.button == 3 then
				t.layout = layout_prev(t.layout)
				return true
			end
		end,
		scroll = function(ev)
			local sel = s.selected_tag
			if sel == nil then
				return
			end
			if (ev.dy or 0) > 0 then
				sel.layout = kiln.layout.next(sel.layout)
			else
				sel.layout = layout_prev(sel.layout)
			end
		end,
	} })
end
```

A plain left press is not handled, so the stdlib default steps forward. The
widget falls back to its text label for any family the table does not name.

### The backdrop

The wallpaper enters the tree here: one image leaf floated to root in the
background band. It also carries the root wheel binding, so a scroll over
empty desktop walks the tags. The `screen.on("changed")` line above it
re-renders the wallpaper when an output's size or scale changes.

```lua
screen.on("changed", function(s) wallpaper(s) end)
local function backdrop(s)
	local wp = os.getenv("KILN_WALLPAPER")
	if wp == nil or wp == "" then
		wp = wallpaper(s)
	end
	ui.box({
		id = "backdrop",
		float = { to = "root", band = "background", passthrough = true },
		w = "grow", h = "grow",
		color = (wp == nil or wp == "") and th.bg or nil,
		image = (wp ~= nil and wp ~= "") and { path = wp } or nil,
		on_scroll = function(ev)
			view_relative(s, (ev.dy or 0) > 0 and 1 or -1)
		end,
	})
end
```

`passthrough = true` is not decoration: a background float defaults to
capture, and a captured full-screen root float would sit over the bar's
in-flow widgets in Clay's pointer test, taking clicks meant for the bar.
Passthrough keeps the bar hittable while the backdrop still catches the wheel
over empty desktop. The theme color is written only when no wallpaper
resolved, because a `color` on an image box tints the image.
`KILN_WALLPAPER` wins when set; with no wallpaper, the box is filled with
`th.bg`.

## Titlebars

The stock `widgets.titlebar` draws icon, title, maximize and close. This
config overrides it with a version that adds the floating toggle, keeping the
stock ids (`{"close", c.handle}` etc.) so code that looks buttons up by id
still works. `widgets.client` calls `widgets.titlebar` through the module
table, so the override is a public-symbol swap, zero stdlib edits.

```lua
local function titlebar_button(id, name, color, press)
	ui.box({
		id = id, w = 14, h = 14, radius = 2, align = "center",
		on_press = press,
	}, function()
		local g = glyph(name, color)
		if g ~= nil then
			ui.image(g, { w = 12, h = 12 })
		else
			ui.box({ w = 12, h = 12, color = color, radius = 2 })
		end
	end)
end

kiln.widgets.titlebar = function(c, focused)
	ui.row({
		id = { "titlebar", c.handle },
		w = "grow", h = th.titlebar_height,
		color = focused and th.titlebar_focus or th.titlebar,
		pad = { x = 4 }, gap = 4, align = { y = "center" },
		on_press = function(ev)
            c:focus()
			if ev ~= nil and ev.button == 3 then
				c:grab_resize_nearest()
			else
				c:grab_move()
			end
		end,
	}, function()
		local ic = kiln.icon.client(c)
		if ic ~= nil then
			ui.image(ic, { w = 12, h = 12 })
		else
			ui.box({ w = 12, h = 12, color = th.accent, radius = 2 })
		end
		ui.box({ w = "grow", align = "center", clip={horizontal=true} }, function()
			ui.text(c.title or c.app_id or "",
				{ color = focused and th.fg or th.muted, ellipsize=true })
		end)
		local ink = focused and th.fg or th.muted
		titlebar_button({ "float", c.handle }, "move", ink, function()
			c.floating = not c.floating
		end)
		titlebar_button({ "maximize", c.handle }, "maximize", ink,
			function() c:toggle_maximized() end)
		titlebar_button({ "close", c.handle }, "close", th.close,
			function() c:close() end)
	end)
end
```

![A floating client's titlebar with the icon, the growing title cell, and the float, maximize and close buttons called out](/img/kiln/rc/rc-titlebar.png)

When no glyph rendered, `titlebar_button` falls back to a plain colored block,
because a pressable button has to be visible. The title sits in one growing,
clipped cell and is ellipsized, so a long title cannot push the buttons off a
narrow client. A press focuses the client, then left drags and right resizes
from the nearest corner. The line-art ink follows focus, and the two colors
are two glyph cache entries, because the color is part of the file.

## The screen: tags and the bar

Everything per-screen happens in one handler:

```lua
screen.on("added", function(s)
	tag.new { name = "dev", screen = s, layout = kiln.layout.tile }
	tag.new { name = "web", screen = s, layout = kiln.layout.tile }
	tag.new { name = "chat", screen = s, layout = kiln.layout.tile }
	tag.new { name = "files", screen = s, layout = kiln.layout.tile }
	tag.new { name = "media", screen = s, layout = kiln.layout.tile }
	s.tags[1]:view()

	wallpaper(s)

	ui.bar(s, { edge = "top", dir = "row", h = th.bar_height,
		color = th.bg, pad = { x = 8 } }, function()
		backdrop(s)
		ui.row({ w = "33.33%", h = "grow", gap = 6,
				clip = { horizontal = true },
				align = { y = "center" } }, function()
			launcher_glyph(s)
			taglist(s)
			tasklist(s)
		end)
		ui.row({ w = "33.33%", h = "grow", align = "center" }, function()
			ui.box({ id = "clock", color = th.bg2, radius = 4,
				pad = { x = 8 },
				on_hover = ui.tooltip(function()
					return os.date("%A %d %B %Y")
				end),
			}, widgets.clock)
		end)
		ui.row({ w = "33.33%", h = "grow", gap = 6,
				clip = { horizontal = true },
				align = { x = "right", y = "center" } }, function()
			widgets.systray()
			layoutbox(s)
		end)
	end)
end)
```

`screen.on("added")` fires once per output, at boot and whenever a monitor is
plugged in, so tags and bars exist on every screen without special-casing
multi-monitor. `tag.new` creates a tag with a layout; `t:view()` selects it.
The `wallpaper(s)` call warms the render outside the frame path; `backdrop()`
would ask again and memoize either way.

`ui.bar(s, cfg, fn)` registers a bar whose `fn` is a declare function: it runs
again on every dirty frame and states what the bar contains right now. The
body is three percent-third regions in a row. The thirds are the centering
mechanism: Clay sizes a percent child unconditionally, so the middle region's
center is the bar's center however wide the tasklist gets, and the side
regions clip so an overfull tasklist truncates at its third instead of pushing
into the middle. Nothing floats and nothing computes a position.

![The stock bar with the taglist, tasklist, clock and layoutbox called out under the cells they declared](/img/kiln/rc/rc-bar.png)

The clock is a plain box in the middle region; `ui.tooltip(fn)` returns its
`on_hover` handler:

![The clock with its tooltip open underneath, showing the full date](/img/kiln/rc/rc-tooltip.png)

The full build-up of a bar like this one is
[A bar from scratch](/kiln/tutorials/a-bar-from-scratch).

## Key bindings

Every binding is one `key{}` call: mods, key, a press handler, plus `desc` and
`group`. The sheet on `mod+s` is stdlib (`kiln.hotkeys.toggle`); it reads the
same registry these calls fill, so the desc and group on every binding below
are the whole of what the config contributes to it:

![The hotkeys sheet listing every binding in the file, grouped: kiln, launcher, tag, client, screen, audio, brightness, screenshot, layout](/img/kiln/rc/rc-hotkeys.png)

The groups:

### kiln

Session verbs, most of them one-line bindings to stdlib functions:

```lua
key { mods = { "mod" }, key = "s", desc = "show help", group = "kiln",
	press = kiln.hotkeys.toggle }
key { mods = { "mod" }, key = "w", desc = "show main menu", group = "kiln",
	press = function()
		local s = screen.focused
		kiln.menu.show { under = "launcher", screen = s, items = main_menu(s) }
	end }
key { mods = { "mod", "ctrl" }, key = "r", desc = "reload kiln", group = "kiln",
	press = kiln.reload }
key { mods = { "mod", "shift" }, key = "q", desc = "quit kiln", group = "kiln",
	press = kiln.quit }
```

Three more bindings in this group sit at the very end of the file:

```lua
key {mods={"alt"},key="Escape",desc="quit kiln",group="kiln",press=kiln.quit}

key {mods={"mod","shift"},key="Escape",desc="lock screen",group="kiln",press=kiln.lock}

key { mods = { "mod", "shift" }, key = "i", desc = "toggle clay inspector",
    group = "kiln", press = function() kiln.inspector() end }
```

`alt+Escape` quits without the modkey. The inspector is Clay's own debug panel over the live desktop;
it takes 400px off the right of the screen while it is up, so the desktop
reflows into what is left rather than being covered (see
[Inspect the Live Element Tree](/kiln/guides/inspector)).

`mod+x` is a Lua prompt against the running compositor. Try an expression
first, fall back to a statement, notify the result either way:

```lua
key { mods = { "mod" }, key = "x", desc = "lua execute prompt", group = "kiln",
	press = function()
		kiln.prompt.run {
			label = "Run Lua code: ",
			history = eval_history,
			done = function(str)
				if str == "" then
					return
				end
				local chunk, cerr = loadstring("return " .. str)
				if chunk == nil then
					chunk = loadstring(str)
				end
				if chunk == nil then
					kiln.notify { title="Lua error", message=tostring(cerr) }
					return
				end
				local ok, res = pcall(chunk)
				kiln.notify { title=ok and "=" or "Lua error", message=tostring(res) }
			end,
		}
	end }
```

Notifications sent while `notification.suspended` is true are queued. So
enabling do-not-disturb sends the confirmation before suspending, and
disabling unsuspends (flushing the queue) before confirming:

```lua
key { mods={"mod","shift"}, key="d", desc="toggle do-not-disturb", group="kiln",
    press=function()
        if notification.suspended then
            notification.suspended=false
            kiln.notify {title="Notifications",message="Resumed",timeout=2}
        else
            kiln.notify {title="Notifications",message="Do Not Disturb",timeout=2}
            notification.suspended=true
        end
    end }
```

### launcher

```lua
key { mods = { "mod" }, key = "Return", desc = "open a terminal", group = "launcher",
	press = function() kiln.spawn(terminal) end }
key { mods = { "mod" }, key = "r", desc = "run prompt", group = "launcher",
	press = function()
		kiln.prompt.run {
			label = "Run: ",
			completion = kiln.prompt.completion(function() return path_bins() end),
			done = function(cmd)
				if cmd ~= "" then
					kiln.spawn(cmd)
				end
			end,
		}
	end }
key { mods = { "mod" }, key = "p", desc = "show the menubar", group = "launcher",
	press = function() kiln.launcher.open() end }
```

### tag

The arrows walk tags through `view_relative`; `mod+Escape` restores the
previous selection through `tag.history`; `mod+shift+r` renames the current
tag through a prompt pre-filled with its name:

```lua
key { mods = { "mod" }, key = "Left", desc = "view previous", group = "tag",
	press = function() view_relative(screen.focused, -1) end }
key { mods = { "mod" }, key = "Right", desc = "view next", group = "tag",
	press = function() view_relative(screen.focused, 1) end }
key { mods = { "mod" }, key = "Escape", desc = "go back", group = "tag",
	press = function() tag.history.restore(screen.focused) end }
```

Then the numrow. `"1-9"` is a range: one `key{}` call expands to nine chords,
and the handler receives the index. Four Mod variants cover the whole
tag-number vocabulary:

```lua
key { mods = { "mod" }, key = "1-9", desc = "only view tag", group = "tag",
	press = function(i)
		local t = screen.focused.tags[i]
		if t ~= nil then
			t:view()
		end
	end }
```

`mod+ctrl+1-9` toggles the tag into the selection, `mod+shift+1-9` moves the
focused client to it, and `mod+ctrl+shift+1-9` toggles the focused client onto
it with the same add-or-remove loop the taglist's mod+right-click uses.

### client and screen

Focus and swap walk `visible_union` by index; `mod+Tab` jumps through the
focus history:

```lua
key { mods = { "mod" }, key = "j", desc = "focus next by index", group = "client",
	press = function() focus_byidx(1) end }
key { mods = { "mod" }, key = "k", desc = "focus previous by index", group = "client",
	press = function() focus_byidx(-1) end }
key { mods = { "mod" }, key = "Tab", desc = "go back", group = "client",
	press = function()
		local c = client.history.previous()
		if c ~= nil then
			c:focus()
			c:raise()
		end
	end }
key { mods = { "mod" }, key = "u", desc = "jump to urgent client", group = "client",
	press = jump_urgent }
```

`mod+shift+j` and `mod+shift+k` are the swap twins, and `mod+ctrl+n` restores
the most recently minimized client. The screen group is two bindings over
`focus_screen_relative`.

### audio, brightness, screenshot

The media keys shell out; every `kiln.spawn` string runs via `/bin/sh -c`:

```lua
key { mods = {}, key = "XF86AudioRaiseVolume", desc = "raise volume", group = "audio",
	press = function() kiln.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") end }
```

Volume and mute use `wpctl`, brightness uses `brightnessctl`, and screenshots
use `grim`:

```lua
key { mods = {}, key = "Print", desc = "screenshot full output", group = "screenshot",
	press = function()
		kiln.spawn(
			"mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png")
	end }
```

The "interactive screenshot" chord (`mod+ctrl+p`) is the same
`slurp | grim -g -` region pipeline the Shift+Print binding uses. `slurp`
draws the selection and `grim` captures it; there is no compositor overlay.

### layout

The tiling knobs are tag properties, so every handler is a property write on
`screen.focused.selected_tag`:

```lua
key { mods = { "mod" }, key = "l", desc = "increase master width factor",
	group = "layout",
	press = function()
		local t = screen.focused.selected_tag
		if t ~= nil then
			t.master_width_factor = math.min(0.95,
				(t.master_width_factor or 0.5) + 0.05)
		end
	end }
```

`mod+h` decreases it; `mod+shift+h/l` walk `master_count`, `mod+ctrl+h/l` walk
`column_count`, and `mod+space` / `mod+shift+space` walk the layout cycle
declared above. Layout-by-number is nine explicit numpad bindings, generated
in a loop because key ranges only expand single digits or letters:

```lua
for i = 1, 9 do
	key { mods = { "mod" }, key = "KP_" .. i, desc = "select layout " .. i,
		group = "layout",
		press = function()
			local t = screen.focused.selected_tag
			if t ~= nil then
				t.layout = kiln.layout.list[i] or t.layout
			end
		end }
end
```

### per-client verbs

All wrapped in `kiln.focused`, which runs the verb on the focused client or
no-ops:

```lua
key { mods = { "mod" }, key = "f", desc = "toggle fullscreen", group = "client",
	press = kiln.focused(function(c)
		c:toggle_fullscreen()
		c:raise()
	end) }
key { mods = { "mod", "shift" }, key = "c", desc = "close", group = "client",
	press = kiln.focused(function(c) c:close() end) }
key { mods = { "mod", "ctrl" }, key = "space", desc = "toggle floating",
	group = "client",
	press = kiln.focused(function(c)
		c.floating = not c.floating
	end) }
key { mods = { "mod", "ctrl" }, key = "Return", desc = "move to master",
	group = "client",
	press = kiln.focused(function(c)
		local s = (c.tag ~= nil and c.tag.screen) or screen.focused
		if s == nil then
			return
		end
		for _, o in ipairs(visible_union(s)) do
			if o ~= c and not o.floating then
				c:swap(o)
				return
			end
		end
	end) }
```

`c:close()` asks politely; `c:kill()` is SIGKILL, and no chord binds it. The
rest of the group is one-line property toggles: move to screen (`mod+o`), keep
on top (`mod+t`), sticky (`mod+comma`), minimize (`mod+n`), maximize
(`mod+m`).

Maximized is one boolean, so the per-axis chords both toggle the same state:

```lua
key { mods = { "mod", "ctrl" }, key = "m", desc = "(un)maximize vertically",
	group = "client",
	press = kiln.focused(function(c)
		c:toggle_maximized()
		c:raise()
	end) }
```

`mod+shift+m` ("horizontally") is the same handler. The
[keybindings tutorial](/kiln/tutorials/keybindings) covers the `key{}`
mechanism from scratch.

## Mouse bindings

```lua
button { mods = {}, button = 3, on = "root", press = function()
	local s = screen.focused
	if kiln.menu.open ~= nil then
		kiln.menu.close()
	else
		kiln.menu.show { under = "launcher", screen = s, items = main_menu(s) }
	end
end }
button { mods = { "mod" }, button = 1, press = function(c) c:grab_move() end }
button { mods = { "mod" }, button = 3,
	press = function(c) c:grab_resize_nearest() end }
```

Root right-click toggles the main menu, opened at the launcher anchor rather
than the pointer, because a button handler receives only the client (`nil` on
the root), not the pointer position. The root *wheel* is not here: it is
handled by the backdrop's `on_scroll`, declared with the wallpaper. Plain
left-click on a client focuses (the built-in default); mod+left drags;
mod+right resizes from the nearest corner.

## Rules

Three `rule{}` calls: global placement, floating apps, and routing for nested
compositors.

```lua
rule { match = { fn = function() return true end },
	on = function(c)
		kiln.placement.no_overlap(c)
		kiln.placement.no_offscreen(c)
	end }
rule { match_any = {
		app = { "pinentry", "Blueman%-manager", "Gpick" },
		instance = { "pinentry" },
		class = { "Blueman%-manager", "Gpick" },
		role = { "pop%-up" },
	},
	props = { floating = true } }
rule { match_any = { app = { "^kiln$" }, class = { "^kiln$" } },
	props = { tag = "media", focus = false } }
```

Rules run when a client maps: selectors (`match`, `match_any`, `except`)
against `app`, `class`, `instance`, `title`, `role`, `dialog`, or an arbitrary
predicate; `props` are property writes; `on` is a callback. Note:

- An empty match clause matches *nothing*, because a fire-on-everything rule
  is a mistake worth catching. "All clients" is therefore spelled
  `match = { fn = function() return true end }`.
- Apps are named in both their Wayland (`app`) and X11 (`class`/`instance`)
  forms, so the rule fires whichever way the client arrives. The dash in
  `pop-up` is escaped because a rule string is a Lua pattern.
- A tag assignment does not switch the view. `focus = false` suppresses focus
  on map; later activation requests use a separate policy.

Titlebars need no rule: they are on by default and opted out per client with
`titlebar = false`. See [Client rules](/kiln/guides/client-rules).

## What is deliberately not here

The config does not configure notifications or replace any of the ten
`kiln.defaults.*` functions; the stdlib defaults apply. Its only added policy
is focus-follows-mouse:

```lua
client.on("mouse::enter", function(c) c:focus() end)
```

Focus follows the mouse, and focus does not raise. Swapping a default
wholesale is the same shape in reverse:
`client.off("request::activate", kiln.defaults.activate)`, then `client.on`
with your own. See
[Replace default policies](/kiln/guides/replace-default-policies) and the
[defaults reference](/kiln/reference/defaults).

## Where to go next

Work through the tutorials in order:

- [Basics](/kiln/tutorials/basics): drive the stock desktop, then reload a change
- [Keybindings](/kiln/tutorials/keybindings)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [Widgets](/kiln/tutorials/widgets)
- [Theming](/kiln/tutorials/theming)
