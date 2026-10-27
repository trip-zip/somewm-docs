---
title: wibox.widget.textbox
description: Plain or Pango-markup text in a chosen font, aligned, cut with an ellipsis or wrapped.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-textbox.mdx";

# wibox.widget.textbox

Shows one string of text. Set `text` for plain text or `markup` for a Pango markup subset (`<b>`, `<i>`, `<u>`, `<s>`, `<span foreground=... background=...>`). The box takes the text's size unless an ancestor sizes it; a textbox with no text takes no size.

```lua
local clock = wibox.widget {
    text   = "12:00",
    font   = "DejaVu Sans Bold 11",
    halign = "center",
    widget = wibox.widget.textbox,
}
clock.text = os.date("%H:%M")
```

![Textbox properties: text, markup, halign, valign, ellipsize and font, each in an outlined slot](/img/reference/wibox/widget-textbox.png)

Each row sets one property. The outline is the box the widget was given, so you can see where the text sits in it and where it was cut.

<WidgetSource>

Save this as `/tmp/widget-textbox.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-textbox.lua")'
```

It opens the figure on your focused screen and closes after two minutes. Every row is a stock textbox with one property set; the labels and slots are stock widgets too.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-textbox.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.textbox(text, ignore_markup)`. `text` is interpreted as markup unless `ignore_markup` is true. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.textbox.html).

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `text` | string | `""` | The text, shown as is. `\n` starts a new line. | |
| `markup` | string | `self.text` | The text with Pango markup. Invalid markup is an error; use `set_markup_silently` to get a return value instead. | The first font in the markup is used for the whole text. Color, alpha, background, underline and strikethrough spans draw. Other attributes, such as a size or weight that changes mid-text, warn once and are not drawn. |
| `font` | string | `beautiful.font` | A Pango font description, such as `"DejaVu Sans Bold 11"`. The number is the size in points. | A description without a size warns once and draws nothing. |
| `halign` | `"left"`, `"center"`, `"right"` | `"left"` | Horizontal position of the text inside the box. | |
| `valign` | `"top"`, `"center"`, `"bottom"` | `"center"` | Vertical position of the text inside the box. | |
| `ellipsize` | `"end"`, `"none"`, `"start"`, `"middle"` | `"end"` | What happens when the text is wider than the box. | `"end"` keeps one line per `\n` and cuts the line with an ellipsis. `"none"` wraps at words. `"start"` and `"middle"` warn once and behave as `"end"`. AwesomeWM wraps and then ellipsizes at the bottom; SomeWM does one or the other. |
| `wrap` | `"word"`, `"char"`, `"word_char"` | `"word_char"` | Where a wrapped line breaks. | Lines always break at words. `"char"` warns once. |
| `justify` | boolean | `false` | Stretch wrapped lines to the box width. | Not applied. Warns once. |
| `indent` | number | `0` | Indent of the first line in points, negative for a hanging indent. | Not applied. Warns once. |
| `line_spacing_factor` | number or nil | `nil` | Line height as a factor of the font's, `nil` for the font's own. | Not applied. Warns once. |

Setting a property emits `property::<name>`. The text color is the `fg` of the nearest [background](../container/background.md) container or of the wibox; a `fg` that is not a solid color warns once and draws the text transparent.

## Methods

| Method | Returns | What it does |
| --- | --- | --- |
| `:set_markup_silently(markup)` | `true`, or `false, error` | Sets `markup` and reports invalid markup instead of raising. |
| `:get_preferred_size(s)` | width, height | The size the text takes on screen `s` when nothing limits its width, in whole pixels. |
| `:get_preferred_size_at_dpi(dpi)` | width, height | The same at a given DPI, measured on the primary screen. |
| `wibox.widget.textbox.get_markup_geometry(markup, s, font)` | `{x, y, width, height}` | The preferred size of `markup` in `font` without creating a visible textbox. |

Gone in SomeWM 2.1: `get_height_for_width` and `get_height_for_width_at_dpi`. Let the container size the text, or give the container a width. See the [compatibility list](../../deviations.md#widget-methods-and-drawing).

The [common properties, methods and signals](../common.md) apply: `forced_width`, `forced_height`, `visible`, `opacity`, `buttons`, mouse signals.
