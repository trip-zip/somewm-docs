---
sidebar_position: 3
title: Rounded Corners
description: Round client corners with a rule, remove the square border, and try a radius on open windows without reloading.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Rounded Corners <SomewmOnly />

SomeWM 2.1 draws rounded corners on Wayland clients through `client.shape`.

## Set a rule

Add this to your `rc.lua`:

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

- Set `border_width = 0` on rounded clients.
- SomeWM subtracts the border width from the corner radius, down to zero.
- The border is a plain rectangle around the rounded window. A 2px theme border makes the outer corners look square.
- A border width set by a rule or by hand is kept when focus changes.
- Without a border, a click in a cut corner reaches what is below the window.

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
- A squircle or another custom path stays square. SomeWM warns once per client and function, naming the client's class or name.
- `gears.shape.rectangle` stays square without a warning.
- `shape_bounding`, `shape_clip` and `shape_input` accept assignments but are never read. They return `nil`.
- `client.shape` is the only property that sets client corners. `gears.surface.apply_shape_bounding` with a rounded rectangle sets it too.
