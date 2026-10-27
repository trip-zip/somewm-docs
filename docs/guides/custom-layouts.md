---
sidebar_position: 2.5
title: Write a client layout
description: Create your own tiling layout from scratch
---

# Write a client layout

Create a Lua table with a `name` and an `arrange(p)` function. In SomeWM 2.1, the function assigns rectangles to `p.geometries[client]`. The layout library applies borders and gaps afterward. SomeWM converts these rectangles to Clay elements labelled `legacy`. Built-in layouts instead supply Clay descriptions. See [client layouts](../concepts/clients-in-the-tree.md#a-layout-is-a-tree).

## A Practical Example: Centered Column

<span id="a-centred-split" />

Save this as `~/.config/somewm/layouts/centered_column.lua`. It stacks tiled clients in one centred column:

```lua
local centered_column = { name = "centered_column" }

function centered_column.arrange(p)
    local n = #p.clients
    if n == 0 then return end

    local wa = p.workarea
    local t = screen[p.screen].selected_tag
    local fraction = t and t.master_width_factor or 0.6
    local width = math.floor(wa.width * fraction)
    local x = wa.x + math.floor((wa.width - width) / 2)

    for i, c in ipairs(p.clients) do
        local top = math.floor((i - 1) * wa.height / n)
        local bottom = math.floor(i * wa.height / n)
        p.geometries[c] = {
            x = x,
            y = wa.y + top,
            width = width,
            height = bottom - top,
        }
    end
end

return centered_column
```

Rounding each boundary, rather than rounding one shared height, keeps division remainders from leaving unused space at the bottom.

## Register and Use It

<span id="register-it" />

Require the module near the top of `rc.lua`, then add it to the existing `request::default_layouts` handler:

```lua
local centered_column = require("layouts.centered_column")

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        centered_column,
    })
end)
```

Replace the existing handler rather than adding another copy of the default layouts. Select the layout with **Mod4+Space**, or assign it directly:

```lua
local t = awful.screen.focused().selected_tag
if t then
    t.layout = require("layouts.centered_column")
    t.master_width_factor = 0.6
end
```

## Read the Workarea

<span id="what-p-holds" />

`p.workarea` contains `x`, `y`, `width` and `height` after struts are removed. In 2.1, the screen method ignores the requested padding and outer gap margin. Write rectangles within that area. The layout library then insets each rectangle by `p.useless_gap` and subtracts borders and gaps from its size.

`p.clients` contains tiled clients in layout order. `p.screen` is the screen index. There is no `p.tag` field in 2.1. Use `screen[p.screen].selected_tag` to read tag settings.

## Using Tag Properties

<span id="rules" />

The example reads `master_width_factor` as its column width. The default **Mod4+h** and **Mod4+l** bindings adjust it.

A layout with a master section can also read `master_count`. The default **Mod4+Shift+h** increases that count and **Mod4+Shift+l** decreases it. This centred-column example has no separate master section, so it does not use the count. See [Master and Stack](../concepts/master-and-stack.md) for those properties.

## Skipping Gaps

<span id="gaps" />

Add a `skip_gap` function to your layout to suppress gaps for a single client:

```lua
local centered_column = require("layouts.centered_column")
centered_column.skip_gap = function(nclients)
    return nclients == 1
end
```

This takes effect only when the tag's `gap_single_client` is `false`. If that setting is `true`, the layout library keeps gaps regardless of `skip_gap`.

## Test the Layout

Use a [nested compositor](testing-with-nested-compositor.md). Open zero, one, two and several windows. Change the screen size, gap, border width and column fraction. Check that rectangles stay inside the workarea and do not overlap.

Keep `arrange` limited to computing `p.geometries`. To request another arrangement during development, call `awful.layout.arrange(s)` for the screen being tested.

## See Also

- [Layout Protocol Reference](../reference/awful/layout.md)
- [Master and Stack](../concepts/master-and-stack.md)
- [AwesomeWM Layout API](https://awesomewm.org/apidoc/libraries/awful.layout.html)
