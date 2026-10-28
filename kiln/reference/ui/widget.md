---
title: kiln.ui.widget
description: Register signal and timer redraws for a declaration function.
---

# kiln.ui.widget

Registers redraw triggers and returns the supplied declaration function.

```lua
local draw = ui.widget(spec)
```

## Example

Register once during config setup:

```lua
local draw_time = ui.widget {
  every = 1,
  fn = function() ui.text(os.date("%H:%M:%S")) end,
}
```

Call `draw_time()` inside a bar or another declaration.

## Options

| Field | Type | Default | Behaviour |
|---|---|---|---|
| `fn` or `[1]` | function | required | Declaration function. `fn` takes precedence. |
| `watch` | array of strings | `{}` | `"class::signal"` names, such as `"client::focus"`. The class must be a global with an `on` method. |
| `every` | number | `nil` | Redraw interval in seconds. Must be positive. |

## Behaviour

A watched signal or timer marks all outputs dirty. Watches are shared by signal
name. Each `every` registration starts its own repeating timer, including when
its declaration function is not drawn.

There is no per-widget stop handle. Reload removes registered watches and
cancels timers. Register again during config setup. Invalid watch names, a
missing function or a non-positive interval raise an error.
