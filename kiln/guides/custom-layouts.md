---
title: Custom Layouts
description: Write your own tiling layout as a plain Lua function over ui containers, and register it on a tag.
sidebar_position: 2
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Custom Layouts

<YouWillLearn>

- The layout contract: one function that declares cells
- Building a two-column layout from `ui.row` and `ui.client`
- Reading tag parameters like `master_width_factor`
- Registering a layout on a tag and in the cycle
- When you need pixel math from `area`, and when you do not

</YouWillLearn>

A layout in kiln is not an object or a class. It is one function:

```lua
function my_layout(clients, area, tag)
	-- declare cells for the clients
end
```

The runtime calls it every frame with the tiled clients of the visible tag, in stacking order, inside a workarea container it has already opened. The function declares [ui containers](/kiln/reference/ui) and one `ui.client(c)` leaf per client; the solver turns those declarations into geometry and configures every client to its cell. There is no arrange pass, no geometry storage, and nothing to invalidate: the function just runs again whenever the screen redraws.

## 1. The smallest layout

A vertical stack: one column, every client a growing cell.

```lua
local some = require("somewm")
local ui = some.ui

local function stack(cs, area, t)
	if #cs == 0 then
		return
	end
	local gap = (t and t.gap) or some.theme.gap
	ui.column({ w = "grow", h = "grow", gap = gap }, function()
		for _, c in ipairs(cs) do
			ui.client(c)
		end
	end)
end
```

Two things every layout should copy from this:

- Guard the empty case. An empty `"grow"` container is not invisible to the solver: it is a sibling that takes its share of space. Declaring one next to real cells hands half the screen to a hole.
- Read the gap from the tag with a theme fallback, so per-tag `t.gap` overrides work.

`ui.client(c)` declares the full composite (border, titlebar, surface). Sizing accepts numbers (pixels), `"grow"`, `"fit"`, and percent strings like `"60%"`.

## 2. A two-column layout

Split the client list in half, one column each side:

```lua
local function twocol(cs, area, t)
	if #cs == 0 then
		return
	end
	local gap = (t and t.gap) or some.theme.gap
	local half = math.ceil(#cs / 2)
	ui.row({ w = "grow", h = "grow", gap = gap }, function()
		ui.column({ w = "grow", h = "grow", gap = gap }, function()
			for i = 1, half do
				ui.client(cs[i])
			end
		end)
		if #cs > half then
			ui.column({ w = "grow", h = "grow", gap = gap }, function()
				for i = half + 1, #cs do
					ui.client(cs[i])
				end
			end)
		end
	end)
end
```

The second column is only declared when it has clients, for the empty-container reason above. With one client, the layout degrades to a single full column automatically.

## 3. Read the tag's parameters

Layouts take their knobs from plain tag properties. The stock layouts read `master_width_factor` (default 0.5), `master_count` (1), `column_count` (1), `gap` (theme default), and `carousel_width` (0.5). Writing any of them redraws the screen, so a keybinding that nudges `master_width_factor` reshapes your layout live with no extra wiring.

To make the left column's width configurable, size it with a percent string derived from the factor, the same way the stock `tile` does:

```lua
local function twocol(cs, area, t)
	if #cs == 0 then
		return
	end
	local f = (t and t.master_width_factor) or 0.5
	local gap = (t and t.gap) or some.theme.gap
	local half = math.ceil(#cs / 2)
	-- The percent form only makes sense when both columns exist.
	local left_w = #cs > half and (f * 100) .. "%" or "grow"
	ui.row({ w = "grow", h = "grow", gap = gap }, function()
		ui.column({ w = left_w, h = "grow", gap = gap }, function()
			for i = 1, half do
				ui.client(cs[i])
			end
		end)
		if #cs > half then
			ui.column({ w = "grow", h = "grow", gap = gap }, function()
				for i = half + 1, #cs do
					ui.client(cs[i])
				end
			end)
		end
	end)
end
```

Now `mod` bindings that adjust `t.master_width_factor` (see the [keybindings tutorial](/kiln/tutorials/keybindings)) drive your layout too.

## 4. The model: how the stock tile works

The stock `tile` is the same two moves at a slightly larger scale, and it is worth internalizing as the idiom. Simplified to its shape:

```lua
local function tile(cs, area, t)
	if #cs == 0 then
		return
	end
	local f = (t and t.master_width_factor) or 0.5
	local n = math.min((t and t.master_count) or 1, #cs)
	local gap = (t and t.gap) or some.theme.gap
	local stacked = #cs > n
	ui.row({ w = "grow", h = "grow", gap = gap }, function()
		-- The master run: a percent-width column while a stack exists,
		-- the whole area when it does not.
		ui.column({ w = stacked and (f * 100) .. "%" or "grow",
				h = "grow", gap = gap }, function()
			for i = 1, n do
				ui.client(cs[i])
			end
		end)
		-- The stack, only when non-empty.
		if stacked then
			ui.column({ w = "grow", h = "grow", gap = gap }, function()
				for i = n + 1, #cs do
					ui.client(cs[i])
				end
			end)
		end
	end)
end
```

Open a container, fill it with runs of grow cells, never declare an empty run. Everything else (the split axis, variants, column counts) is arrangement of the same parts.

## 5. Register it

Assign the function to a tag:

```lua
tag.new { name = "code", screen = s, layout = twocol }
```

or at runtime:

```lua
screen.focused.selected_tag.layout = twocol
```

To include it in the layout cycle (`some.layout.next`, the layoutbox press, `mod+space` style bindings), set the cycle list; it is yours to override:

```lua
some.layout.list = {
	some.layout.tile,
	twocol,
	some.layout.max,
	some.layout.floating,
}
```

:::note
`some.layout.name(fn)` only knows the built-in families, so the stock `ui.layoutbox` shows `?` for a custom layout, and `ui.layoutlist` has no label for it. If you want a name in your bar, render your own indicator, for example `t.layout == twocol and "twocol" or some.layout.name(t.layout)`.
:::

## 6. When you need area, and when you do not

Most layouts never touch the `area` argument: sizing with `"grow"` and percent strings lets the solver do all division, and that is the recommended default. `area` is `{ x, y, width, height }`, the box your layout's container fills, for the cases that genuinely need pixel arithmetic:

- fixed pixel column widths (the stock `carousel` computes its strip offset from `area.width`)
- centered floats sized relative to the workarea (the stock `magnifier` sizes its focused float as `area.width * f`)

`area` comes from the previous frame's solve, so it is one frame stale after a bar or gap change; the first frame falls back to the whole screen. Treat it as a good approximation, not a promise, and prefer solver-driven sizing wherever the design allows.

## Complete example

```lua
local some = require("somewm")
local ui = some.ui

local function twocol(cs, area, t)
	if #cs == 0 then
		return
	end
	local f = (t and t.master_width_factor) or 0.5
	local gap = (t and t.gap) or some.theme.gap
	local half = math.ceil(#cs / 2)
	local left_w = #cs > half and (f * 100) .. "%" or "grow"
	ui.row({ w = "grow", h = "grow", gap = gap }, function()
		ui.column({ w = left_w, h = "grow", gap = gap }, function()
			for i = 1, half do
				ui.client(cs[i])
			end
		end)
		if #cs > half then
			ui.column({ w = "grow", h = "grow", gap = gap }, function()
				for i = half + 1, #cs do
					ui.client(cs[i])
				end
			end)
		end
	end)
end

screen.on("added", function(s)
	tag.new { name = "main", screen = s, layout = twocol }
	s.tags[1]:view()
end)
```

## See also

- [Layout reference](/kiln/reference/layout)
- [UI reference](/kiln/reference/ui)
- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [Tag reference](/kiln/reference/tag)
