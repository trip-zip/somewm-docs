---
title: Create or port a custom widget
description: Build a reusable widget, replace old draw and fit callbacks, or display a Cairo image in SomeWM 2.1.
---

# Create or port a custom widget

Build custom widgets by combining textboxes, images, backgrounds and layouts, then add your own methods, signals and input handlers. The returned component is a widget that you can put inside another layout, a bar or a popup.

You can write that composition inline with `wibox.widget { ... }` or return it from a Lua module. A constructor function is useful when you want several independent instances, such as a status badge for each screen. It is optional.

## Widget content and its window

| Call | What it creates | When to use it |
| --- | --- | --- |
| `wibox { ... }` | A window with a position, size and visibility. Its `widget` property holds the content. | Create a place on screen for widgets. An existing wibar or popup already provides one. |
| `wibox.widget { ... }` | Widgets, containers and layouts assembled from a Lua table. | Build a custom component from existing parts, with any methods or behaviour you need. |
| `wibox.widget.base.make_widget(...)` | A base widget object with signals, button handling and common widget properties. It has no visible content by default. | Implement a new primitive or widget layout, or wrap a child in a proxy widget. |

The composition approach does not require a direct call to `make_widget()`. The built-in constructors create their own widget objects. `make_widget()` is useful when you need that object machinery without choosing an existing component as your starting point. It does not create a window or provide a drawing implementation.

Start with the composition below. [Custom Clay descriptions](#register-a-clay-description) and [Cairo image surfaces](#draw-to-an-image-surface) are additional options when the existing components do not express the content you need. For a widget with its own `fit` or `draw`, the [meter comparison](#register-a-clay-description) keeps its API and behaviour while replacing those methods. The [upgrade checklist](../getting-started/upgrading-from-2.0.md) covers other removed APIs.

## Compose built-in widgets

Save this module as `~/.config/somewm/badge.lua`. It returns a constructor, so each call creates a separate badge with its own text and state.

```lua
local gears = require("gears")
local wibox = require("wibox")

return function(initial_text)
    local label = wibox.widget.textbox()
    local badge = wibox.widget {
        {
            label,
            margins = 6,
            widget = wibox.container.margin,
        },
        bg = "#458588",
        fg = "#ffffff",
        shape = gears.shape.rounded_rect,
        widget = wibox.container.background,
    }

    function badge:set_text(text)
        label.text = text
    end

    function badge:set_active(active)
        self.bg = active and "#98971a" or "#458588"
    end

    badge:set_text(initial_text or "Ready")
    return badge
end
```

Use it in `rc.lua`:

```lua
local awful = require("awful")
local wibox = require("wibox")
local new_badge = require("badge")

local status = new_badge("Ready")
status:buttons {
    awful.button({}, 1, function()
        status:set_text("Clicked")
        status:set_active(true)
    end),
}

local sample = wibox {
    screen = screen.primary,
    x = screen.primary.geometry.x + 100,
    y = screen.primary.geometry.y + 100,
    width = 180,
    height = 40,
    visible = true,
    widget = status,
}
```

This displays a rounded badge. Clicking it changes its text and background colour. The textbox and background setters notify SomeWM of the changes. The badge needs no drawing or sizing callbacks. You can also put `status` in an existing wibar's widget layout instead of creating `sample`.

For a 2.0 widget that draws a label on a coloured box, move the text into a textbox and the fill, border and shape into a background container. Keep your data collection, setters and button handlers. Use [timers, signals or asynchronous commands](./widget-timers.md) to call the setters when the data changes.

## Register a Clay description

Use this when you need to implement the content or child layout of a new widget directly. For a component built from existing widgets, their descriptions already handle this work.

`wibox.clay.describe_widget(widget, callback, name)` registers a function that returns the widget's content and sizing rules. This is specific to SomeWM. The callback reads widget state and returns a fresh table. It does not receive a Cairo context or the final allocated width and height.

This example ports one custom meter while keeping its state, value setter and signals unchanged. Both versions display a green fill on a black background and prefer a size of 120 by 16 logical pixels.

### Shared state and behaviour

Start with this code in either version:

```lua
local base = require("wibox.widget.base")
local meter = base.make_widget(nil, "meter")
meter._private.value = 0

function meter:set_value(value)
    value = math.max(0, math.min(1, value))
    if value == self._private.value then return end
    self._private.value = value
    self:emit_signal("widget::redraw_needed")
    self:emit_signal("property::value", value)
end
```

Both versions use the same base widget object, including its signal and button support. The setter clamps the value to the range 0 to 1 and emits the same notifications when it changes. Add only the implementation for your version below.

### 2.0: measure and paint

```lua
function meter:fit(context, width, height)
    return 120, 16
end

function meter:draw(context, cr, width, height)
    cr:set_source_rgb(0, 0, 0)
    cr:rectangle(0, 0, width, height)
    cr:fill()

    cr:set_source_rgb(0, 1, 0)
    cr:rectangle(0, 0, width * self._private.value, height)
    cr:fill()
end
```

`fit` reports the preferred size. Once the widget has an allocation, `draw` receives its width and height. The widget calculates the fill's width and paints both rectangles with Cairo.

### 2.1: describe the content

Replace the `fit` and `draw` methods with:

```lua
local clay = require("wibox.clay")

clay.describe_widget(meter, function(self)
    return {
        w = 120, h = 16,
        wsrc = "user", hsrc = "user",
        bg = { 0, 0, 0, 1 },
        specs = {
            {
                w = { percent = self._private.value },
                h = "grow",
                wsrc = "user",
                bg = { 0, 1, 0, 1 },
            },
        },
    }
end, "meter")
```

The description supplies a black background and a green child whose width is a fraction of its parent. Clay calculates their geometry, and SomeWM's renderer draws them. Keep the shared setter and signals unchanged.

### Display and update the meter

Add this after the shared code and your version's implementation:

```lua
local preview = require("wibox") {
    x = 100, y = 100,
    width = 120, height = 16,
    visible = true,
    widget = meter,
}

meter:set_value(0.75)
```

In this allocation, both versions display a 90-pixel green fill inside the 120-pixel meter. In 2.0, `widget::redraw_needed` requests painting. In 2.1, it requests an updated description for layout and rendering. Emit `widget::layout_changed` when a setter changes the preferred size or children. Built-in setters already emit the appropriate signals.

The fields used here mean:

| Field | Meaning |
| --- | --- |
| `w`, `h` | Preferred width and height: a number in logical pixels, `"fit"` for content size, `"grow"` for available space, or `{ percent = fraction }` for a share of the parent. The parent layout also controls the allocation. |
| `wsrc`, `hsrc` | Source labels for numeric and percentage sizes in the tree dump. `"user"` identifies a size chosen by your widget. |
| `bg` | Solid background as red, green, blue and alpha, each from 0 to 1. |
| `specs` | Child descriptions, in order. To include an existing widget, use `{ widget = child }` in this list. |

`wibox.clay.describe_class(class, callback)` installs a description on a class table. Its instances must receive that class's `_clay` entry, as built-in constructors do when copying their class table. Registering each instance with `describe_widget` avoids that extra step.

Register the description before putting the widget in a wibox. Keep the callback free of state changes: SomeWM caches descriptions and may reuse them until a widget emits an update signal. The built-in implementations in `lua/wibox/widget/` and `lua/wibox/layout/` show more complex descriptions. A description can only use features supported by SomeWM's compiler and renderer. It is not a replacement Cairo drawing context.

### Choose children from the available size

The callback's fifth argument, `offer`, holds the size the wibox and its containers give the widget before Clay solves the layout. `offer.w` and `offer.h` are in logical pixels, less any margins. An axis is `nil` where its size depends on the solve: along a layout's direction, such as the width inside `wibox.layout.flex.horizontal`, and inside a container that sizes to its content, such as `wibox.container.place`. SomeWM calls the callback again when the offer changes.

This replaces a 2.0 `layout` method that arranged its children by the width it was given:

```lua
local clay = require("wibox.clay")
local wibox = require("wibox")

local function columns(left, right, breakpoint)
    local side_by_side = wibox.layout.flex.horizontal(left, right)
    local stacked = wibox.layout.fixed.vertical(left, right)
    local widget = wibox.widget.base.make_widget(nil, "columns")
    clay.describe_widget(widget, function(self, _, _, _, offer)
        local narrow = offer.w and offer.w < breakpoint
        return { specs = { { widget = narrow and stacked or side_by_side, w = "grow", h = "grow" } } }
    end, "columns")
    return widget
end
```

In a 600-pixel wibox, `columns(left, right, 400)` places the two widgets side by side. In a 300-pixel wibox it stacks them. Where `offer.w` is `nil`, they stay side by side.

## Draw to an image surface

An imagebox accepts a Cairo image surface. You can keep custom drawing code by rendering into a surface of a size you choose, then assigning that surface to the imagebox:

```lua
local cairo = require("lgi").cairo
local wibox = require("wibox")

local icon = wibox.widget.imagebox()
icon.forced_width = 32
icon.forced_height = 32

local function set_colour(red, green, blue)
    local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, 32, 32)
    local cr = cairo.Context(surface)
    cr:set_source_rgb(red, green, blue)
    cr:arc(16, 16, 12, 0, 2 * math.pi)
    cr:fill()
    icon.image = surface
end

set_colour(0.2, 0.7, 0.4)

local sample = wibox {
    screen = screen.primary,
    x = screen.primary.geometry.x + 100,
    y = screen.primary.geometry.y + 200,
    width = 32, height = 32,
    bg = "#282828",
    visible = true,
    widget = icon,
}
```

This displays a green circle. Calling `set_colour` again creates and assigns a new surface. The drawing runs when your code calls it. SomeWM does not call a `draw` method on `icon`.

This approach requires you to choose the image resolution. Scaling the imagebox scales the raster image. It does not rerun the Cairo code at the new allocation. Generate a suitably sized image if you need sharp results at a different size or output scale. If the old widget depends on being handed its final size on every draw, its sizing and update logic also needs to change.

## Find a widget that disappeared

Under `somewm-session`, watch the log while reloading the configuration:

```bash
journalctl --user -u somewm.service -f
```

When SomeWM runs directly from a terminal, read its standard error there. A warning like this names the widget, its unsupported methods, and the file and line of the first one:

```text
W: awesome: wibox.clay: badge defines :draw, :fit at ~/.config/somewm/badge.lua:4, which 2.1 never calls. The widget and its children are left out of the tree. See https://somewm.org/docs/guides/custom-widgets
```

`has no describer` means the widget has no registered description. A plain `make_widget()` has an empty description, so it needs a proxy child or a description of its own to display content.

Run `somewm-client clay tree` to inspect the displayed widgets and their sizes. [Reading the tree](../concepts/reading-the-tree.md) explains the output. The [upgrade guide](../getting-started/upgrading-from-2.0.md) lists other removed methods and changed properties.
