---
title: kiln.ui.text
description: Text options, font selection and clipping for ellipses.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/ui-text.mdx";

# kiln.ui.text

Draws text using the configured font.

![Text examples showing font size, bold and italic faces, colour, word wrapping and ellipsizing](/img/reference/kiln/ui-text.png)

The last row clips the parent horizontally before ellipsizing the text.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/ui-text.lua) as `/tmp/kiln-figure.lua`, then run:

```sh
kiln-client eval 'dofile("/tmp/kiln-figure.lua")'
```

It opens on the focused screen and closes after two minutes. To close it early:

```sh
kiln-client eval 'if kiln_reference_figure then kiln_reference_figure.stop() end'
```

<FigureLua />

</WidgetSource>

```lua
ui.text(str, cfg?)
```

## Example

```lua
ui.box({ w = 180, clip = { horizontal = true } }, function()
  ui.text("A title longer than its container", { ellipsize = true })
end)
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `color` | colour | `theme.fg` | Text colour. |
| `size` | number | `theme.font_size` | Font size in logical pixels. |
| `font` | string | `theme.font` | Pango font description without a size. |
| `wrap` | string | `"words"` | `"words"`, `"newlines"` or `"none"`. |
| `align` | string | `"left"` | `"left"`, `"center"` or `"right"`. Aligns lines within the text box. |
| `line_height` | number | `0` | Logical pixels per line. Zero uses the font height. |
| `ellipsize` | boolean | `false` | Truncates at a horizontal clipping ancestor and adds an ellipsis. |

Text has no `w`, `h`, `id` or input handlers. Use a parent box for those fields.
For single-line placement, set the parent's `align`.

## Fonts

```lua
ui.text("Handgloves", { font = "Sans Bold", size = 14 })
ui.text("Handgloves", { font = "Serif Italic" })
```

A size in `font`, such as `"Sans Bold 14"`, raises an error. Set `size`
separately. Pango substitutes for an unavailable font family without an error.
The selected font is used for both measurement and rendering.

## Truncation

`ellipsize` requires a horizontally clipping ancestor whose width is constrained
independently of the text. Without one, it has no effect and raises no error.
A horizontal clip leaves text at its full width, so the example stays on one
line even with `wrap = "words"`.

The clip follows the ancestor's outer box. An ellipsis can therefore reach into
its padding. Put the clip on an inner box to keep the text inside the padding.
