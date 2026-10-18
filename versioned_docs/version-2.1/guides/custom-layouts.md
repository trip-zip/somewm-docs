---
sidebar_position: 2.5
title: Custom Layouts
description: "A layout is a table with a name and an arrange(p) function that writes a geometry per client into p.geometries. Register it, read the workarea and tag properties, and skip gaps where they make no sense."
---

# Custom Layouts

A layout is a table with a `name` and an `arrange(p)` function. SomeWM calls `arrange` whenever tiled clients need placing and expects a rectangle for each client in `p.geometries`; borders and gaps are applied afterwards. A layout written this way declares each client floating at the box you computed, with its numbers marked `legacy` in the dump; the stock suites declare Clay trees instead ([Clients and layouts in the same tree](../concepts/clients-in-the-tree.md#a-layout-is-a-tree)).

```lua
local my_max = {
    name = "my_max",
    arrange = function(p)
        for _, c in ipairs(p.clients) do
            p.geometries[c] = {
                x = p.workarea.x, y = p.workarea.y,
                width = p.workarea.width, height = p.workarea.height,
            }
        end
    end,
}
```

Every client gets the workarea; the focused one is on top.

## Register it

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile, awful.layout.suit.floating, awful.layout.suit.max, my_max,
    })
end)

awful.screen.focused().selected_tag.layout = my_max     -- or on one tag
awful.tag({ "1", "2", "3" }, s, my_max)                 -- or at creation
```

Mod4 + Space cycles to it.

## What `p` holds

| Field | Contents |
| --- | --- |
| `p.workarea` | `x`, `y`, `width`, `height` of the usable screen: bars, struts and padding already subtracted; borders and gaps not yet |
| `p.clients` | the tiled clients in creation order |
| `screen[p.screen].selected_tag` | the tag, with `master_count`, `master_width_factor`, `column_count` and the rest |
| `p.geometries` | the table you fill, one rectangle per client |

## A centred split

Master column centred at `master_width_factor` of the width, the stack below it full width. Mod4 + l and h, and Mod4 + Shift + l and h, then work as in `tile`:

```lua
local centered_split = {
    name = "centered_split",
    arrange = function(p)
        local wa, n = p.workarea, #p.clients
        if n == 0 then return end
        local t = screen[p.screen].selected_tag
        local nmaster = math.min(t.master_count, n)
        local nstack = n - nmaster

        local master_w = math.floor(wa.width * t.master_width_factor)
        local master_x = wa.x + math.floor((wa.width - master_w) / 2)
        local h = math.floor(wa.height / nmaster)
        for i = 1, nmaster do
            p.geometries[p.clients[i]] = { x = master_x, y = wa.y + (i - 1) * h, width = master_w, height = h }
        end

        if nstack > 0 then
            local sh = math.floor(wa.height / nstack)
            for i = 1, nstack do
                p.geometries[p.clients[nmaster + i]] = { x = wa.x, y = wa.y + (i - 1) * sh, width = wa.width, height = sh }
            end
        end
    end,
}
```

## Gaps

With `gap_single_client = false`, `skip_gap(nclients, tag)` returns true to suppress gaps:

```lua
my_max.skip_gap = function() return true end                             -- clients overlap
centered_split.skip_gap = function(nclients) return nclients == 1 end
```

## Rules

- Write only to `p.geometries`. No `c:geometry()`, no signals.
- Return early on zero clients.
- `math.floor` every coordinate; a fraction leaves a one-pixel gap or overlap.
- `awful.layout.arrange(s)` re-runs the layout without opening windows.
- Try one, two and many clients, a screen resize, and odd `master_count` and `master_width_factor` values.

[Layout reference](../reference/awful/layout.md) has the full `arrange(p)` contract and every built-in layout; [Master and Stack](../concepts/master-and-stack.md) the tag properties.
