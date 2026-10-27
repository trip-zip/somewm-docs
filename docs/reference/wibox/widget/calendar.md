---
title: wibox.widget.calendar
description: A month or a year, one cell per day, with today highlighted.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-calendar.mdx";

# wibox.widget.calendar

Shows a month or a year as a grid of day cells, with the weekday names, the month name and today in bold. For a colored today cell, wrap the `"focus"` cell in a background container through `fn_embed`. Every cell is a textbox you can restyle through `fn_embed`. Give it `forced_width` and `forced_height`, or put it in a box with a size: in a content-sized box, such as a popup sized to its content, the cells take their own sizes and the columns do not line up.

![Calendar for October 2026 four times: plain, with week numbers, starting on Sunday, and with wider spacing](/img/reference/wibox/widget-calendar.png)

Each row sets one property. The outline is the box the widget was given.

<WidgetSource>

Save this as `/tmp/widget-calendar.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-calendar.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a month calendar at a fixed date in a sized box, with one property set.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-calendar.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructors: `wibox.widget.calendar.month(date, font, spacing)` and `wibox.widget.calendar.year(date, font, spacing)`. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.calendar.html).

```lua
local cal = wibox.widget {
    date         = os.date("*t"),
    week_numbers = true,
    widget       = wibox.widget.calendar.month,
}
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `date` | table or nil | `nil` | `{ year = , month = , day = }`. `day` picks the highlighted cell; for a year calendar only `year` matters. `nil` shows nothing. | |
| `font` | string | `beautiful.calendar_font`, else `"Monospace 10"` | Font of every cell. | |
| `spacing` | number | `beautiful.calendar_spacing`, else `5` | Gap between cells in pixels. | A negative value warns once and is 0. |
| `week_numbers` | boolean | `beautiful.calendar_week_numbers`, else `false` | Adds a column with the ISO week number. | |
| `start_sunday` | boolean | `beautiful.calendar_start_sunday`, else `false` | Starts each week on Sunday instead of Monday. | |
| `long_weekdays` | boolean | `beautiful.calendar_long_weekdays`, else `false` | Three-letter weekday names instead of two. | On a scaled output some three-letter headers collapse to an ellipsis. |
| `flex_height` | boolean | `false` | Lets rows grow to fill extra height. | |
| `fn_embed` | function or nil | `nil` | `function(widget, flag, date)` called for every cell and header; returns the widget to show. `flag` is `"header"`, `"weekday"`, `"weeknumber"`, `"normal"`, `"focus"`, `"month"` or `"monthheader"`. | |
| `border_width` | number or table | `0` | Grid lines between cells, in pixels. | A dashed border draws solid; a border color that is not solid warns once and is transparent. |
| `border_color` | color or table | `beautiful.fg_normal` | Color of the grid lines. | |

Setting a property emits `property::<name>`.

Gone in SomeWM 2.1: `empty_cell_mode`, `empty_color` and `empty_widget`, with the theme variable `calendar_empty_color`. Cells outside the month are empty.

The [common properties, methods and signals](../common.md) apply.
