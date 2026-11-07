---
sidebar_position: 3
title: Round client corners
description: Round application content independently of its frame, or use the shared shape radius.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Round client corners <SomewmOnly />

Set `client.content_radius` to round all four application corners inside a rectangular frame. Use `client.shape` for the shared window and titlebar shape.

`content_radius` requires a build containing this property; it is not in the 2.1.2 release.

## Round content inside square titlebars

Add a rule after your general client rules:

```lua
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        id = "rounded-content",
        rule = { class = "firefox" },
        properties = {
            content_radius = 18,
            border_width = 0,
            border_color = "#65517f",
        },
        callback = function(c)
            c.shape = nil
        end,
    }
end)
```

The callback clears any shape set by an earlier rule. A `nil` entry in a Lua table does not override that rule.

All four content corners reveal `border_color`, including when the border width is zero. Set your titlebars' backgrounds to that same color to make the frame continuous. A different titlebar background remains visible as a different color.

![Rounded terminal content inside a square purple frame at 1.5× output scale](/img/clients/content-radius.png)

*Live SomeWM capture at 1.5× scale, with a 27-pixel content radius and four rectangular titlebars. The pale outline is a separate widget in the demo.*

For a complete titlebar setup, download [rounded-content.lua](/examples/rounded-content.lua) into your configuration directory. It returns a function that sets the frame color, content radius, four titlebars, and move, resize, minimize, maximize and close controls. Use it as the rule's callback:

```lua
local decorate = dofile(require("gears.filesystem").get_configuration_dir()
    .. "rounded-content.lua")

ruled.client.append_rule {
    id = "rounded-content-frame",
    rule = { class = "firefox" },
    properties = { titlebars_enabled = false },
    callback = decorate,
}
```

Place this rule inside your existing `request::rules` handler, after general rules. The function replaces the matched client's titlebars; it does not change its tags or floating state.

The radius uses logical pixels. At 1.5× output scale, a radius of 18 occupies 27 device pixels; do not multiply it by the output scale yourself.

## Change or remove content rounding

For a client `c`:

```lua
c.content_radius = 24
c.content_radius = nil
```

Nil or zero restores the corners derived from `shape`, border width and titlebars. It does not force square content when `shape` supplies a radius. With `shape = nil`, removing `content_radius` makes the content square.

Fullscreen suppresses both radii and restores them on exit. The exposed inner corner belongs to the client's frame, so pointing there stays on the client. Shadows continue to follow the outer frame.

See [Client corners](../reference/client-corners.md) for property types, defaults and signals.

## Set a rule

For a shared shape radius instead of independent content rounding, add this to your `rc.lua`:

```lua
local ruled = require("ruled")
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi

ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        id = "rounded", rule = { },
        properties = {
            border_width = 0,
            shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(14)) end,
        }
    }
end)
```

- `rule = { }` matches every client. Put this before more specific rules so they can override it.
- To select particular windows, change the match as described in [Client Rules](./client-rules.md).
- For a radius of 14 pixels without DPI adjustment, replace the `shape` line with `shape = 14,`.
- For the default radius of 10 pixels, use `shape = gears.shape.rounded_rect,`.

## Remove the square border

Set `border_width = 0` to remove the rectangular border around rounded clients. Otherwise, SomeWM subtracts the border width from the corner radius, down to zero. Explicit border widths survive focus changes.

Without a border, a click in a cut corner reaches what is below the window.

## Keep titlebars

- A titlebar on an edge takes that edge's corners. The window takes the remaining corners.
- With a top titlebar, the titlebar has rounded top corners and the window has rounded bottom corners.
- Fullscreen clients stay square, even when `shape` is set.

## Try open windows

Run this from a shell to round every open client without reloading:

```bash
somewm-client eval 'for _, c in ipairs(client.get()) do c.shape = 14; c.border_width = 0 end'
```

Set `shape` back to `nil` to make them square again:

```bash
somewm-client eval 'for _, c in ipairs(client.get()) do c.shape = nil end'
```

This leaves their border width at zero. See [somewm-client](../reference/somewm-client.md#eval-constraints) for the `eval` constraints.

## If corners stay square

- Use a number, `gears.shape.rounded_rect`, or a function that draws the same rounded rectangle path.
- Custom shape functions clip the whole frame and its children to their path. Inner content rounding is also clipped by that path.
- `gears.shape.rectangle` stays square without a warning.
- `shape_bounding`, `shape_clip` and `shape_input` accept assignments but are never read. They return `nil`.
- `client.content_radius` sets an independent radius on the content. `gears.surface.apply_shape_bounding` sets `client.shape`.
