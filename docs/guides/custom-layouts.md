---
sidebar_position: 2.5
title: Custom Layouts
description: Create your own tiling layout from scratch
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Custom Layouts

<YouWillLearn>

- The minimal structure of a layout table
- How to register and activate a custom layout
- How to position clients using `p.workarea` and `p.geometries`
- How to read tag properties like `master_count` and `master_width_factor`
- When and how to skip gap application

</YouWillLearn>

A layout is a Lua table with a `name` and an `arrange(p)` function. The compositor calls `arrange` whenever it needs to position tiled clients on screen (window opened, closed, resized, tag properties changed). Your job is to write a geometry entry for each client. The compositor handles borders and gaps after your function returns.

## The Minimal Layout

The simplest useful layout gives every client the full workarea, like `max`:

```lua
local my_max = {
    name = "my_max",
    arrange = function(p)
        for _, c in ipairs(p.clients) do
            p.geometries[c] = {
                x = p.workarea.x,
                y = p.workarea.y,
                width = p.workarea.width,
                height = p.workarea.height,
            }
        end
    end,
}
```

Every client gets the same rectangle. The focused one is drawn on top, so it looks like a maximized layout.

## Register and Use It

Add your layout to the default list so you can cycle to it:

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.max,
        my_max,  -- your layout is now in the cycle
    })
end)
```

Or set it directly on a tag:

```lua
-- Set on a specific tag
local t = awful.screen.focused().selected_tag
t.layout = my_max

-- Set when creating tags
awful.tag({ "1", "2", "3" }, s, my_max)
```

Press your layout-cycle keybinding (default: **Mod4+Space**) to cycle through layouts and confirm yours appears.

## Read the Workarea

The `p.workarea` table gives you the usable screen rectangle. Wibars, struts, and screen padding are already subtracted:

```lua
local wa = p.workarea
-- wa.x, wa.y      = top-left corner
-- wa.width         = usable width
-- wa.height        = usable height
```

You do not need to subtract borders or gaps. The compositor applies those after your `arrange` function returns.

## A Practical Example: Centered Column

This layout arranges all clients in a centered column at 60% of the screen width, splitting the height evenly:

```lua
local centered_column = {
    name = "centered_column",
    arrange = function(p)
        local wa = p.workarea
        local n = #p.clients
        if n == 0 then return end

        local col_width = math.floor(wa.width * 0.6)
        local col_x = wa.x + math.floor((wa.width - col_width) / 2)
        local client_height = math.floor(wa.height / n)

        for i, c in ipairs(p.clients) do
            p.geometries[c] = {
                x = col_x,
                y = wa.y + (i - 1) * client_height,
                width = col_width,
                height = client_height,
            }
        end
    end,
}
```

With three clients on a 1920x1080 screen (after a 30px wibar), each window would be 1152px wide, centered horizontally, and 350px tall stacked vertically.

## Using Tag Properties

Layouts can read properties from `p.tag` to let users control behavior at runtime. The most common are `master_count` and `master_width_factor`. See [Master and Stack](/concepts/master-and-stack) for what each property does.

Here is the centered column layout extended to support a primary/secondary split:

```lua
local centered_split = {
    name = "centered_split",
    arrange = function(p)
        local wa = p.workarea
        local n = #p.clients
        if n == 0 then return end

        local nmaster = math.min(p.tag.master_count, n)
        local nstack = n - nmaster
        local mwfact = p.tag.master_width_factor

        -- Master column: centered, takes mwfact of width
        local master_w = math.floor(wa.width * mwfact)
        local master_x = wa.x + math.floor((wa.width - master_w) / 2)

        for i = 1, nmaster do
            local h = math.floor(wa.height / nmaster)
            p.geometries[p.clients[i]] = {
                x = master_x,
                y = wa.y + (i - 1) * h,
                width = master_w,
                height = h,
            }
        end

        -- Stack: fill the full width below the master
        if nstack > 0 then
            local stack_h = math.floor(wa.height / nstack)
            for i = 1, nstack do
                p.geometries[p.clients[nmaster + i]] = {
                    x = wa.x,
                    y = wa.y + (i - 1) * stack_h,
                    width = wa.width,
                    height = stack_h,
                }
            end
        end
    end,
}
```

Users can now adjust the split with the standard keybindings: **Mod4+l** / **Mod4+h** to change `master_width_factor`, **Mod4+Shift+l** / **Mod4+Shift+h** to change `master_count`.

## Skipping Gaps

Add a `skip_gap` function when gaps don't make sense for your layout. The compositor calls `skip_gap(nclients, tag)` before applying `useless_gap`. Return `true` to suppress gaps.

```lua
my_max.skip_gap = function(nclients, tag)
    return true  -- max layout: clients overlap, gaps are meaningless
end
```

For layouts where a single client fills the screen, skip the gap only when there is one client:

```lua
centered_column.skip_gap = function(nclients, tag)
    return nclients == 1
end
```

## Tips

- **Keep `arrange` pure.** Only write to `p.geometries`. Do not call `c:geometry()`, emit signals, or produce other side effects.
- **Handle zero clients.** `p.clients` can be empty. Return early with `if #p.clients == 0 then return end`.
- **Force a re-layout.** Call `awful.layout.arrange(screen)` during development to trigger your layout without opening/closing windows.
- **Use `math.floor`.** Pixel coordinates must be integers. Rounding errors from division can cause 1px gaps or overlaps.
- **Test edge cases.** Try your layout with 1 client, 2 clients, and many clients. Resize the screen. Change `master_count` and `master_width_factor` to values you didn't expect.

## See Also

- **[Layout Protocol Reference](/reference/awful/layout)** - Full `arrange(p)` contract, all fields, built-in layouts
- **[Master and Stack](/concepts/master-and-stack)** - How tag properties control primary/secondary splits
- **[AwesomeWM awful.layout docs](https://awesomewm.org/apidoc/libraries/awful.layout.html)** - Full upstream API reference
