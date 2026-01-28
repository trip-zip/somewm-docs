---
sidebar_position: 2
title: Theme Variables
description: Complete list of beautiful theme variables
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Theme Variables

This is a reference of commonly used theme variables in the `beautiful` module. For a tutorial on creating themes, see [Theme Tutorial](/tutorials/theme).

## Core Colors

| Variable | Description |
|----------|-------------|
| `bg_normal` | Default background color |
| `bg_focus` | Background when focused |
| `bg_urgent` | Background for urgent items |
| `bg_minimize` | Background for minimized items |
| `fg_normal` | Default text color |
| `fg_focus` | Text color when focused |
| `fg_urgent` | Text color for urgent items |
| `fg_minimize` | Text color for minimized items |

## Window Borders

| Variable | Description |
|----------|-------------|
| `border_width` | Window border thickness |
| `border_color_normal` | Unfocused window border |
| `border_color_active` | Focused window border |
| `border_color_marked` | Marked window border |
| `useless_gap` | Gap between tiled windows |

## Fonts

| Variable | Description |
|----------|-------------|
| `font` | Default font (Pango format, e.g., "sans 10") |
| `hotkeys_font` | Font for hotkeys popup |
| `hotkeys_description_font` | Font for hotkeys descriptions |
| `notification_font` | Font for notifications |

## Cursors

Cursor names used during window operations. These accept standard X cursor names like `"left_ptr"`, `"fleur"`, `"cross"`, `"watch"`, etc.

| Variable | Default | Description |
|----------|---------|-------------|
| `cursor_mouse_resize` | `"cross"` | Cursor during window resize |
| `cursor_mouse_move` | `"fleur"` | Cursor during window move |
| `wibar_cursor` | (none) | Cursor when hovering wibar |
| `slider_handle_cursor` | `"fleur"` | Cursor when grabbing slider handle |
| `enable_spawn_cursor` | `true` | Show "watch" cursor during app startup |

:::tip Cursor Theme
The cursor theme can be set via environment variables before launching:
```bash
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE="24"
somewm
```

Or changed at runtime (SomeWM-only):
```lua
root.cursor_theme("Adwaita")
root.cursor_size(32)
```

See [Input Devices: Cursor Theming](/guides/input-devices#cursor-theming) for details.
:::

## Wibar

| Variable | Description |
|----------|-------------|
| `wibar_bg` | Wibar background |
| `wibar_fg` | Wibar text color |
| `wibar_height` | Wibar height |
| `wibar_border_color` | Wibar border color |
| `wibar_border_width` | Wibar border width |

## Taglist

| Variable | Description |
|----------|-------------|
| `taglist_bg_focus` | Focused tag background |
| `taglist_bg_occupied` | Occupied tag background |
| `taglist_bg_empty` | Empty tag background |
| `taglist_bg_urgent` | Urgent tag background |
| `taglist_fg_focus` | Focused tag text |
| `taglist_fg_occupied` | Occupied tag text |
| `taglist_fg_empty` | Empty tag text |
| `taglist_fg_urgent` | Urgent tag text |

## Tasklist

| Variable | Description |
|----------|-------------|
| `tasklist_bg_focus` | Focused task background |
| `tasklist_bg_normal` | Normal task background |
| `tasklist_fg_focus` | Focused task text |
| `tasklist_fg_normal` | Normal task text |
| `tasklist_disable_icon` | Hide task icons (boolean) |

## Notifications

| Variable | Description |
|----------|-------------|
| `notification_bg` | Notification background |
| `notification_fg` | Notification text color |
| `notification_border_color` | Notification border |
| `notification_border_width` | Border width |
| `notification_icon_size` | Icon size |
| `notification_width` | Notification width |
| `notification_max_width` | Maximum width |
| `notification_max_height` | Maximum height |

## Hotkeys Popup

| Variable | Description |
|----------|-------------|
| `hotkeys_bg` | Popup background |
| `hotkeys_fg` | Popup text color |
| `hotkeys_border_color` | Popup border |
| `hotkeys_border_width` | Border width |
| `hotkeys_modifiers_fg` | Modifier key color |
| `hotkeys_label_bg` | Key label background |
| `hotkeys_label_fg` | Key label text |
| `hotkeys_group_margin` | Space between groups |

## Menu

| Variable | Description |
|----------|-------------|
| `menu_bg_normal` | Menu background |
| `menu_bg_focus` | Focused item background |
| `menu_fg_normal` | Menu text |
| `menu_fg_focus` | Focused item text |
| `menu_height` | Menu item height |
| `menu_width` | Menu width |
| `menu_border_color` | Menu border |
| `menu_border_width` | Border width |

## Wallpaper

| Variable | Description |
|----------|-------------|
| `wallpaper` | Path to wallpaper image |

## Shadows <SomewmOnly />

Compositor-level shadows for windows and wiboxes. See [Shadows Reference](/reference/shadows) for full documentation.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `shadow_enabled` | boolean | `false` | Enable shadows globally for clients |
| `shadow_radius` | integer | `12` | Blur radius in pixels |
| `shadow_offset_x` | integer | `-15` | Horizontal offset (negative = left) |
| `shadow_offset_y` | integer | `-15` | Vertical offset (negative = up) |
| `shadow_opacity` | number | `0.75` | Shadow opacity (0.0-1.0) |
| `shadow_color` | string | `"#000000"` | Shadow color as hex |
| `shadow_drawin_enabled` | boolean | (inherits) | Enable shadows for wiboxes |
| `shadow_drawin_radius` | integer | (inherits) | Blur radius for wiboxes |
| `shadow_drawin_offset_x` | integer | (inherits) | Horizontal offset for wiboxes |
| `shadow_drawin_offset_y` | integer | (inherits) | Vertical offset for wiboxes |
| `shadow_drawin_opacity` | number | (inherits) | Opacity for wiboxes |
| `shadow_drawin_color` | string | (inherits) | Color for wiboxes |

## Layout Icons

| Variable | Description |
|----------|-------------|
| `layout_tile` | Tile layout icon |
| `layout_tileleft` | Tile left icon |
| `layout_tilebottom` | Tile bottom icon |
| `layout_tiletop` | Tile top icon |
| `layout_floating` | Floating layout icon |
| `layout_max` | Maximized layout icon |
| `layout_fullscreen` | Fullscreen layout icon |
| `layout_magnifier` | Magnifier layout icon |
| `layout_fair` | Fair layout icon |
| `layout_fairh` | Fair horizontal icon |
| `layout_spiral` | Spiral layout icon |
| `layout_dwindle` | Dwindle layout icon |
| `layout_cornernw` | Corner NW icon |
| `layout_cornerne` | Corner NE icon |
| `layout_cornersw` | Corner SW icon |
| `layout_cornerse` | Corner SE icon |

## See Also

- [Theme Tutorial](/tutorials/theme) - Learn how to create themes
- [beautiful (AwesomeWM docs)](https://awesomewm.org/apidoc/libraries/beautiful.html) - Complete upstream reference
- [Appearance (AwesomeWM docs)](https://awesomewm.org/apidoc/documentation/06-appearance.md.html) - All theme variables including cursors
