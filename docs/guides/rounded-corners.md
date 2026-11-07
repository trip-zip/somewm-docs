---
sidebar_position: 3
title: Round client corners
description: Round application content independently of its frame, or use the shared shape radius.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Round client corners <SomewmOnly />

Set `client.content_radius` to round all four application corners inside a rectangular frame. Use `client.shape` for the shared window and titlebar shape.

`content_radius` is unreleased and unavailable in 2.1.2.

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

The callback clears an earlier rule's shape. Setting `shape = nil` in the properties table would omit the entry, leaving that shape unchanged.

All four content corners reveal `border_color`, even with `border_width = 0`. Match your titlebar backgrounds to this color for a continuous frame.

![Rounded terminal content inside a square purple frame at 1.5× output scale](/img/clients/content-radius.png)

*Live capture at 1.5× scale with a radius of 27 logical pixels and four square titlebars. The pale outline is a separate widget.*

For four titlebars with move, resize, minimise, maximise and close controls, download [rounded-content.lua](/examples/rounded-content.lua) into your configuration directory. Use its returned function as the rule callback:

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

Place this rule inside your existing `request::rules` handler, after general rules. The function sets the frame color and radius and replaces the titlebars. Tags and floating state are unchanged.

The radius uses logical pixels: 18 becomes 27 device pixels at 1.5× scale. Do not scale the value yourself.

## Change or remove content rounding

For a client `c`:

```lua
c.content_radius = 24
c.content_radius = nil
```

Nil or zero restores the corners derived from `shape`, border width and titlebars. Content becomes square only if `shape` supplies no rounding.

Fullscreen suppresses rounding until exit. Exposed inner corners belong to the client frame; they do not pass pointer events to the application or the window below. Shadows follow the outer frame.

See [Client corners](../reference/client-corners.md) for property types, defaults and signals.

## Share a radius between content and titlebars

With `content_radius` unset, use `shape` in your `rc.lua`:

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

### Remove the square border

Set `border_width = 0` to remove the rectangular border. Border width reduces the shared shape radius, down to zero; it does not reduce `content_radius`. Explicit border widths survive focus changes.

With no border and no `content_radius`, clicks in the shared shape's cut corners reach the window below.

### Keep titlebars

- A titlebar on an edge takes that edge's corners. The window takes the remaining corners.
- With a top titlebar, the titlebar has rounded top corners and the window has rounded bottom corners.
- Fullscreen clients stay square, even when `shape` is set.

## Try open windows

Apply a shared radius to every open client without reloading:

```bash
somewm-client eval 'for _, c in ipairs(client.get()) do c.content_radius = nil; c.shape = 14; c.border_width = 0 end'
```

Clear both properties to make them square:

```bash
somewm-client eval 'for _, c in ipairs(client.get()) do c.shape = nil; c.content_radius = nil end'
```

Border width stays at zero. See [somewm-client](../reference/somewm-client.md#eval-constraints) for `eval` constraints.

## If corners stay square

- Use a number, `gears.shape.rounded_rect`, or a function that draws the same rounded rectangle path.
- Custom shape functions clip the whole frame, including rounded content, to their path.
- `gears.shape.rectangle` stays square without a warning.
- `shape_bounding`, `shape_clip` and `shape_input` have no effect and return `nil`.
- `client.content_radius` sets an independent radius on the content. `gears.surface.apply_shape_bounding` sets `client.shape`.
