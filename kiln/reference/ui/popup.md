---
title: kiln.ui.popup
description: Popup options, keyboard claims and controller methods.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "./_lua/ui-popup.mdx";

# kiln.ui.popup

`ui.popup(spec)` registers a declare hook. Its content is declared only while
open. Construction does not display it or claim input.

![A status popup positioned directly below its anchor button](/img/reference/kiln/ui-popup.png)

The content popup is registered after the figure that declares its anchor.

<WidgetSource>

Save the [Lua file](/img/reference/kiln/ui-popup.lua) as `/tmp/kiln-figure.lua`, then run:

```sh
kiln-client eval 'dofile("/tmp/kiln-figure.lua")'
```

It opens on the focused screen and closes after two minutes. To close it early:

```sh
kiln-client eval 'if kiln_reference_figure then kiln_reference_figure.stop() end'
```

<FigureLua />

</WidgetSource>

## Example

Create once during config setup:

```lua
local popup = ui.popup {
  id = "status-popup", w = 240, pad = 12, color = "#282828",
  keys = { Escape = "close" }, scrim = true,
  fn = function() ui.text("Connected") end,
}
```

Call `popup:toggle()` from an input handler.

## Options

| Spec field | Behaviour |
|---|---|
| `id` | Required unique plain string. A duplicate live popup ID raises. Reserve `id .. ":scrim"` too. |
| `fn(popup, screen)` | Declares the content inside a column. Called on each frame while open. |
| `screen` | Default for `:show()`. Otherwise uses the focused screen, then the first screen. |
| `keys` | A function `(ev, popup)`, or a table mapping key names to `"close"` or functions `(ev, popup)`. `any` is the fallback table entry. Only key presses invoke handlers. |
| `scrim` | Screen-sized background that closes on an outside press. Default absent. `true` uses `"#00000001"`; a colour spec sets its fill. |
| `under` | Element ID to attach below. Takes precedence over `at`. Closes if the anchor has not been declared before the popup in the current frame. |
| `at` | `{x = ..., y = ...}` in output-local logical coordinates. Attaches to the root's top-left unless `anchor` overrides it. |
| `anchor` | A float anchor. Default centre when neither `under` nor `at` is set; below-left when using `under`. |
| `band` | Default `"overlay"`. The popup uses z 1 and the scrim z 0 within the band. |
| `fit` | Default true. Keeps the popup within the workarea after layout settles. |
| `w`, `h`, `color`, `radius`, `pad`, `gap`, `align`, `border`, `clip` | Passed to the content column. |
| `style(popup)` | Returns per-frame overrides for `fn`, `scrim`, `under`, `at`, `anchor`, `band`, `fit` and the content column fields. Missing fields use the original spec. |
| `on_close(popup)` | Called after an open popup closes and releases its keyboard claim. |

When `keys` is present, the popup claims the keyboard and consumes all keys,
including unmatched ones. A new keyboard grab closes it. Without `keys`,
bindings and client keyboard input continue normally. A scrim affects pointer
input only.

## Controller

| Controller member | Behaviour |
|---|---|
| `:show(s?)` | Open on a live screen and return the controller; return nil if it cannot open. Moving an open popup redraws both screens. |
| `:close()` | Close and release the keyboard. No-op if already closed. |
| `:toggle(s?)` | Close if open; otherwise show on `s`. |
| `:destroy()` | Close and unregister the declare hook. The ID can be reused. |
| `.open` | The screen while open, otherwise nil. Read it; use methods to change state. |

Removing the popup's screen closes it. Reload closes and unregisters
config-created popups; recreate them during config setup. A retained old
controller cannot reopen after reload or destruction.
See [Create a popup](../../guides/popups.md) for a complete example.
