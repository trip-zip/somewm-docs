---
title: Theme Variables
description: Every kiln.theme key, its default, and what it styles, plus kiln.modkey.
sidebar_position: 13
---

# Theme Variables

`kiln.theme` is a plain Lua table. There is no theme engine and no reload step: assign a key at load or at any time, and everything that reads it picks up the new value on the next frame, because chrome reads the theme at declare.

```lua
local kiln = require("kiln")

kiln.theme.accent = "#c05068"
kiln.theme.gap = 12
kiln.theme.bar_height = 28
```

Colors take any form `ui.color` accepts: `"#rrggbb"`, `"#rrggbbaa"`, or `{ r, g, b, a }`.

## The keys

| Key | Default | Used for |
|---|---|---|
| `bg` | `"#181820"` | Base background: root, bar, menu, tooltip, prompt. |
| `bg2` | `"#101014"` | Secondary background: workarea, cells, notifications. |
| `fg` | `"#dcdce6"` | Default text color. |
| `accent` | `"#5078be"` | Focus ring, selection, caret, active tag. |
| `muted` | `"#3c3c4b"` | Dim text, placeholders, quiet borders. |
| `font` | `"Sans"` | Default font family, a Pango description without a size (`ui.text`'s `font` cfg overrides per leaf). |
| `font_size` | `14` | Default text size. |
| `gap` | `8` | Workarea inset and the space between layout cells. Per-tag override: `t.gap`. |
| `bar_height` | `32` | Bar height; notifications offset below it. |
| `titlebar_height` | `22` | Titlebar row height. |
| `titlebar` | `"#22222c"` | Unfocused titlebar background. |
| `titlebar_focus` | `"#2c2c3a"` | Focused titlebar background. |
| `close` | `"#c05068"` | Close button. |
| `urgent` | `"#e0a050"` | Urgent client border, critical notification border. |
| `client_radius` | `4` | Client corner radius. |
| `border_width` | `2` | Focus ring weight. |
| `resize_handle` | `6` | Width of the invisible resize edge band, in px. |
| `min_size` | `60` | Floor a resize will not shrink a client below. |
| `menu_width` | `200` | Menu column width. |
| `menu_height` | `24` | Menu row height. |
| `tooltip_gap` | `4` | How far a tooltip hangs off its target. |
| `notification_width` | `320` | Notification popup width (height fits the text). |
| `notification_offset` | `12` | Inset from the screen edges. |
| `notification_gap` | `8` | Space between stacked popups. |
| `notification_radius` | `0` | Notification corner radius. |
| `notification_timeout` | `{ low = 5, normal = 5, critical = 0 }` | Seconds per urgency; 0 means sticky. What a client's "server decides" timeout resolves to. |
| `prompt_width` | `"50%"` | Prompt width; takes any ui sizing form. |
| `prompt_offset` | `80` | Prompt offset from the top of the screen. |
| `cursors` | `{ move = "grabbing", resize = { n/s/e/w/ne/nw/se/sw = "<edge>-resize" } }` | Xcursor names for the move grab and each resize edge (compass-point keys). |
| `menu_submenu_icon` | unset | Image path for the submenu marker; unset, menus draw a text `>`. The default config sets it to a generated chevron glyph. |
| `layout_icons` | unset | Table of layout family name to image path for `ui.layoutbox`; unset, the box draws the layout name as text. |

## kiln.modkey

Not a theme key, but the same kind of knob: `kiln.modkey` (default `"alt"`) is what `"mod"` resolves to in key and button bindings. Set it before your `key {}` calls.

```lua
kiln.modkey = "super"
```

## See also

- [Theming](/kiln/tutorials/theming)
- [kiln.ui](/kiln/reference/ui)
- [Notifications](/kiln/guides/notifications)
- [Keys, Buttons, and Rules](/kiln/reference/keybindings-and-rules)
