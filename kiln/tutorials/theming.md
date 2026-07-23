---
title: Theming
description: "The some.theme table: what the keys control, editing them in your rc, per-tag gaps, and live-tweaking colors over IPC."
sidebar_position: 5
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Theming

<YouWillLearn>

- What `some.theme` is and when its values are read
- The key groups: palette, metrics, chrome, popups
- Overriding theme values in your rc
- Per-tag gap overrides with `t.gap`
- Live-tweaking the theme over IPC and watching the next frame
- A small cohesive example theme

</YouWillLearn>

## 1. What some.theme is

`some.theme` is one plain Lua table of colors and metrics. Everything the
stdlib draws (the focus ring, the bar, taglist cells, titlebars, menus,
tooltips, notifications, the prompt) reads it at declare time, on every dirty
frame. There is no theme file format and no style engine: assign to the
table, mark the screen dirty, and the next frame wears the new values.

Because it is a plain table (not a signal-emitting object), writing to it
does not redraw by itself. In your rc that never matters (the first frame
comes after the config runs); at runtime you follow a write with
`some.dirty()`.

## 2. The keys

The full list with defaults lives in the
[theme variable reference](/kiln/reference/theme-variables). The groups:

- Palette: `bg`, `bg2`, `fg`, `accent`, `muted`, `urgent`, `close`. `accent`
  works hardest: focus ring, selected tag, focused tasklist entry, caret,
  selection.
- Metrics: `font_size`, `gap` (workarea inset and space between layout
  cells), `bar_height`, `border_width`, `client_radius`, `min_size`,
  `resize_handle`.
- Client chrome: `titlebar`, `titlebar_focus`, `titlebar_height`.
- Popups: `menu_width`, `menu_height`, `tooltip_gap`, `prompt_width`,
  `prompt_offset`, the `notification_*` keys, and `cursors` (the xcursor
  names used by move and resize grabs).

## 3. Edit theme values in your rc

The default config does exactly this, near the top:

```lua
local some = require("somewm")
local th = some.theme

some.modkey = "alt"
th.bg = "#1c1c28"
th.accent = "#7aa2f7"
```

Any key you do not set keeps its default. Colors are `"#rrggbb"` or
`"#rrggbbaa"` strings.

One subtlety: values the stdlib reads at declare time follow later changes
automatically, but values you copy into a cfg table are fixed at that call.
In `ui.bar(s, { color = th.bg }, ...)` the bar captured the current `th.bg`;
change the theme later and that bar keeps its captured color until the config
reloads. Omit `color` from the cfg and the bar reads `theme.bg` live instead.

## 4. Per-tag gap

`theme.gap` sets the workarea inset and the space between layout cells
everywhere. A tag can override it: `t.gap` wins on that tag, and writing it
redraws immediately (tag layout parameters are on the dirty list).

```lua
screen.on("added", function(s)
	local t = tag.new { name = "media", screen = s, layout = some.layout.max }
	t.gap = 0
end)
```

A zero-gap `max` tag gives you edge-to-edge video while every other tag keeps
its breathing room. Try it live on the current tag:

```bash
scripts/kiln-eval 'screen.focused.selected_tag.gap = 0'
```

## 5. Live-tweak over IPC

Every kiln exposes a Lua socket, so theme iteration needs no reload loop.
Change the accent and watch the very next frame:

```bash
scripts/kiln-eval 'local some = require("somewm") some.theme.accent = "#ff9e64" some.dirty()'
scripts/kiln-eval 'local some = require("somewm") some.theme.gap = 16 some.dirty()'
scripts/kiln-eval 'local some = require("somewm") some.theme.client_radius = 10 some.dirty()'
```

(The `require("somewm")` is needed because `some` is a local in your rc, not a
global the socket can see; requiring returns the same live module.)

Focus ring, selected tag, tasklist highlight all flip together. When a
combination sticks, copy the assignments into your rc. Remember `some.dirty()`:
without it the values change but nothing redraws until something else
dirties the screen. More on the socket in
[IPC and scripting](/kiln/guides/ipc-and-scripting).

## Complete example

A cohesive cool-gray theme with a teal accent, as the top of an rc:

```lua
local some = require("somewm")
local th = some.theme

-- palette
th.bg = "#2e3440"
th.bg2 = "#242933"
th.fg = "#d8dee9"
th.accent = "#88c0d0"
th.muted = "#4c566a"
th.urgent = "#d08770"
th.close = "#bf616a"

-- client chrome
th.titlebar = "#3b4252"
th.titlebar_focus = "#434c5e"
th.client_radius = 6
th.border_width = 2

-- metrics
th.font_size = 13
th.gap = 10
th.bar_height = 30
```

Everything downstream (bar, taglist, titlebars, menus, notifications,
prompt) picks these up with no further wiring, because they are all declared
from the same table on the next frame.

## See also

- [Theme variable reference](/kiln/reference/theme-variables)
- [A bar from scratch](/kiln/tutorials/a-bar-from-scratch)
- [IPC and scripting](/kiln/guides/ipc-and-scripting)
