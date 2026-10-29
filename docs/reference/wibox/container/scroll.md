---
title: wibox.container.scroll
description: A child wider or taller than its box, scrolling through it.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/container-scroll.mdx";

# wibox.container.scroll

Shows a child that does not fit, moving it through the box over time. The usual use is a long song title or window title in a bar. The scrolling runs on a timer at `fps` frames per second while the widget is visible.

![Four scroll containers mid-scroll: a long line in 300 pixels, the same with extra space, the same with a waiting step function, and four lines scrolling through 40 pixels](/img/reference/wibox/container-scroll.png)

Each row sets one property. The outline is the box the container was given.

<WidgetSource>

Save this as `/tmp/container-scroll.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/container-scroll.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a textbox in a scroll container with one setting.

<FigureLua />

[Download the Lua file](/img/reference/wibox/container-scroll.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructors: `wibox.container.scroll.horizontal(widget, fps, speed, extra_space, expand, max_size, step_function, space_for_scrolling)` and `wibox.container.scroll.vertical(...)`. In a declarative table use `layout = wibox.container.scroll.horizontal` and the setting names below as fields. [Upstream page](https://awesomewm.org/apidoc/widget_containers/wibox.container.scroll.html).

```lua
local title = wibox.widget {
    {
        text   = "A long window title that does not fit the bar",
        widget = wibox.widget.textbox,
    },
    max_size      = 200,
    speed         = 40,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    layout        = wibox.container.scroll.horizontal,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `widget` | widget or nil | `nil` | The child. | A scroll container inside a rotate or mirror is left out with a warning. |

The settings below are set through methods, or as fields of the declarative table.

## Methods

| Method | Default | What it does |
| --- | --- | --- |
| `:set_max_size(pixels)` | none | The box size in the scroll direction. Without it the box is as large as the child and nothing scrolls. |
| `:set_speed(pixels_per_second)` | `10` | How fast the child moves. The step function decides what the number means. |
| `:set_fps(frames)` | `20` | How often the position updates. |
| `:set_extra_space(pixels)` | `0` | Empty space between the end of the child and its next repetition. |
| `:set_space_for_scrolling(pixels)` | no limit | A cap on the child's size in the scroll direction. |
| `:set_step_function(fn)` | `linear_increase` | `fn(elapsed, size, visible_size, speed, extra_space)` returns the offset. The ready-made ones are in `wibox.container.scroll.step_functions`: `linear_increase`, `linear_decrease`, `linear_back_and_forth`, `nonlinear_back_and_forth`, `waiting_nonlinear_back_and_forth`. |
| `:set_direction("h" or "v")` | from the constructor | Scroll direction. |
| `:set_expand(boolean)` | `false` | Kept for compatibility. The extra space stays empty either way. |
| `:pause()`, `:continue()` | | Stop and resume the timer. |
| `:reset_scrolling()` | | Put the child back at the start. |

Gone in SomeWM 2.1: `context`, `first_x`, `first_y`, `fit_width`, `fit_height`, `hierarchy`, `surface_width` and `surface_height`. The container is a scroll element of the tree.

The [common properties, methods and signals](../common.md) apply.
