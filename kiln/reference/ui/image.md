---
title: kiln.ui.image
description: Image sizing, caching, tinting and pointer input.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/ui-image.mdx";

# kiln.ui.image

Draws an image loaded from a file.

![An image at different sizes and aspect ratios, followed by a solid recoloured version](/img/reference/kiln/ui-image.png)

Recolouring keeps alpha and replaces RGB. The opaque terminal mark disappears along with the original colours.

<WidgetSource>

Requires `rsvg-convert`.

Save the [Lua file](/img/reference/kiln/ui-image.lua) as `/tmp/kiln-figure.lua`, then run:

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
ui.image(path, cfg?)
```

## Example

```lua
ui.image(os.getenv("HOME") .. "/.config/kiln/icon.png", {
  w = 24, h = 24, recolor = "#8ec07c",
})
```

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `id` | element ID | `nil` | ID for readback or input. |
| `w` | sizing | `"fit"` | Width. |
| `h` | sizing | `"fit"` | Height. |
| `aspect` | number | `nil` | Width divided by height. |
| `radius` | number | `0` | Corner radius. |
| `recolor` | colour | `nil` | Replaces RGB while preserving the image's alpha mask. |
| `on_press` | function | `nil` | Pointer press callback `(ev)`. |

## Behaviour

Images have no intrinsic layout size. Set both axes, or one axis and `aspect`.
Decoded images are cached by path. Unused images may be evicted when the cache
exceeds its budget. `core.image_reload(path)` invalidates a cached file; call
`kiln.dirty()` to redraw it. A failed decode logs an error and draws no image.
The image constructor accepts only the fields above. Wrap it in a box for
borders, padding or other handlers.
