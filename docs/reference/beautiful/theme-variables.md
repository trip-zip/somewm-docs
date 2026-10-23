---
sidebar_position: 2
title: Theme Variables
description: Complete reference of beautiful theme variables in SomeWM
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Theme Variables

The `beautiful` table supplies theme defaults to Lua modules. Annotations come from `@beautiful` LDoc tags in the [SomeWM source](https://github.com/trip-zip/somewm/tree/ea3a2a1a9e/lua). Source: `ea3a2a1a9e`. **477 documented**, 88 used-but-undocumented.

See the [Theme Tutorial](../../tutorials/theme.md) for how to apply these in a custom theme.

<!--
Hand-curated prelude for theme-variables.md. Survives regeneration.
Edits to this file are picked up on the next `npm run generate:reference`.
-->

## Quick-Start Variables

Common theme values. Widgets read them as defaults unless configured otherwise.

| Variable | Type | Description |
| --- | --- | --- |
| `bg_normal` | `color` | Default background |
| `fg_normal` | `color` | Default text |
| `bg_focus` | `color` | Background when focused |
| `fg_focus` | `color` | Text when focused |
| `bg_urgent` | `color` | Background for urgent items |
| `fg_urgent` | `color` | Text for urgent items |
| `font` | `string` | Default Pango font, e.g. `"sans 10"` |
| `border_width` | `number` | Window border thickness in pixels |
| `border_color_normal` | `color` | Unfocused window border |
| `border_color_active` | `color` | Focused window border |
| `useless_gap` | `number` | Gap between tiled windows |
| `wallpaper` | `string` | Path to wallpaper image |

## Cursors

Standard X cursor names like `"left_ptr"`, `"fleur"`, `"cross"`, `"watch"` are accepted.

Set the cursor theme before launching:

```bash
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE="24"
somewm
```

Or change it at runtime (SomeWM-only):

```lua
root.cursor_theme("Adwaita")
root.cursor_size(32)
```

See [cursor theming](../../guides/input-devices.md#cursor-theming).

---

## awful

302 entries.

| Variable | Type | Description | Source |
| --- | --- | --- | --- |
| `accessibility_cursor_finder_animated` <SomewmOnly /> | `boolean` | Animate the locator. With false, rings follow the pointer without shrinking and cursor size changes immediately. | [awful/accessibility.lua:40](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L40) |
| `accessibility_cursor_finder_color` <SomewmOnly /> | `color` | Solid ring colour. | [awful/accessibility.lua:58](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L58) |
| `accessibility_cursor_finder_cooldown` <SomewmOnly /> | `number` | Shake cooldown in seconds after deflation begins or the locator stops. | [awful/accessibility.lua:136](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L136) |
| `accessibility_cursor_finder_deflate_delay` <SomewmOnly /> | `number` | Inactivity in seconds before cursor deflation. | [awful/accessibility.lua:112](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L112) |
| `accessibility_cursor_finder_deflate_duration` <SomewmOnly /> | `number` | Cursor deflation duration in seconds. Zero snaps. | [awful/accessibility.lua:106](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L106) |
| `accessibility_cursor_finder_duration` <SomewmOnly /> | `number` | Ring duration in seconds. | [awful/accessibility.lua:46](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L46) |
| `accessibility_cursor_finder_effect` <SomewmOnly /> | `string` | Visual effect: rings, magnify, or both. | [awful/accessibility.lua:34](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L34) |
| `accessibility_cursor_finder_enabled` <SomewmOnly /> | `boolean` | Allow explicit and shake activation. | [awful/accessibility.lua:28](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L28) |
| `accessibility_cursor_finder_history_window` <SomewmOnly /> | `number` | Shake motion history window in seconds. | [awful/accessibility.lua:118](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L118) |
| `accessibility_cursor_finder_inflate_duration` <SomewmOnly /> | `number` | Cursor inflation duration in seconds. Zero snaps. | [awful/accessibility.lua:100](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L100) |
| `accessibility_cursor_finder_line_width` <SomewmOnly /> | `number` | Ring stroke width in logical pixels. | [awful/accessibility.lua:64](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L64) |
| `accessibility_cursor_finder_magnification` <SomewmOnly /> | `number` | Initial cursor magnification factor. | [awful/accessibility.lua:82](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L82) |
| `accessibility_cursor_finder_max_scale` <SomewmOnly /> | `number` | Maximum cursor magnification factor. | [awful/accessibility.lua:94](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L94) |
| `accessibility_cursor_finder_min_diagonal` <SomewmOnly /> | `number` | Minimum shake bounds diagonal in logical pixels. | [awful/accessibility.lua:130](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L130) |
| `accessibility_cursor_finder_over_magnification` <SomewmOnly /> | `number` | Additional magnification per repeated activation. | [awful/accessibility.lua:88](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L88) |
| `accessibility_cursor_finder_radius` <SomewmOnly /> | `number` | Initial outer ring radius in logical pixels. | [awful/accessibility.lua:52](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L52) |
| `accessibility_cursor_finder_ring_count` <SomewmOnly /> | `integer` | Number of concentric rings. | [awful/accessibility.lua:70](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L70) |
| `accessibility_cursor_finder_sensitivity` <SomewmOnly /> | `number` | Required travelled-distance to bounding-diagonal ratio. | [awful/accessibility.lua:124](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L124) |
| `accessibility_cursor_finder_shake_enabled` <SomewmOnly /> | `boolean` | Enable event-driven shake detection for this instance. | [awful/accessibility.lua:76](https://github.com/trip-zip/somewm/blob/main/lua/awful/accessibility.lua#L76) |
| `calendar_popup_width` <SomewmOnly /> | `number` | The calendar width, when the popup is created without a `width`. With neither, the popup follows the calendar's content. | [awful/widget/calendar_popup.lua:49](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/calendar_popup.lua#L49) |
| `calendar_style` | `cell_properties` | The generic calendar style table. Each table property can also be defined by `beautiful.calendar_[flag]_[property]=val`. | [awful/widget/calendar_popup.lua:43](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/calendar_popup.lua#L43) |
| `carousel_center_mode` <SomewmOnly /> | `string` | Viewport centering mode. | [awful/layout/suit/carousel.lua:56](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/carousel.lua#L56) |
| `carousel_default_column_width` <SomewmOnly /> | `number` | Default column width fraction for new columns. | [awful/layout/suit/carousel.lua:44](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/carousel.lua#L44) |
| `carousel_dynamic_peek_width` <SomewmOnly /> | `number` | Dynamic peek width in pixels. Columns at the edges of the strip will have this applied as their peek width. Negative values are ignored and cause edge columns to use peek_width instead. | [awful/layout/suit/carousel.lua:72](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/carousel.lua#L72) |
| `carousel_peek_width` <SomewmOnly /> | `number` | Peek width in pixels for showing adjacent column edges. | [awful/layout/suit/carousel.lua:67](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/carousel.lua#L67) |
| `column_count` | `integer` | The default number of columns. | [awful/tag.lua:1182](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tag.lua#L1182) |
| `cursor_mouse_move` | `string` | The move cursor name. | [awful/mouse/init.lua:82](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/mouse/init.lua#L82) |
| `cursor_mouse_resize` | `string` | The resize cursor name. | [awful/mouse/init.lua:78](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/mouse/init.lua#L78) |
| `enable_spawn_cursor` | `boolean` | Show busy mouse cursor during spawn. | [awful/startup_notification.lua:23](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/startup_notification.lua#L23) |
| `fullscreen_hide_border` | `boolean` | Hide the border on fullscreen clients. | [awful/permissions/init.lua:49](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L49) |
| `gap_single_client` | `boolean` | Enable gaps for a single client. | [awful/tag.lua:1009](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tag.lua#L1009) |
| `hotkeys_bg` | `color` | Hotkeys widget background color. | [awful/hotkeys_popup/widget.lua:260](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L260) |
| `hotkeys_border_color` | `color` | Hotkeys widget border color. | [awful/hotkeys_popup/widget.lua:272](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L272) |
| `hotkeys_border_width` | `int` | Hotkeys widget border width. | [awful/hotkeys_popup/widget.lua:268](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L268) |
| `hotkeys_description_font` | `string\|lgi.Pango.FontDescription` | Font used for hotkeys' descriptions. | [awful/hotkeys_popup/widget.lua:301](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L301) |
| `hotkeys_fg` | `color` | Hotkeys widget foreground color. | [awful/hotkeys_popup/widget.lua:264](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L264) |
| `hotkeys_font` | `string\|lgi.Pango.FontDescription` | Main hotkeys widget font. | [awful/hotkeys_popup/widget.lua:297](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L297) |
| `hotkeys_group_margin` | `int` | Margin between hotkeys groups. | [awful/hotkeys_popup/widget.lua:305](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L305) |
| `hotkeys_label_bg` | `color` | Background color used for miscellaneous labels of hotkeys widget. | [awful/hotkeys_popup/widget.lua:285](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L285) |
| `hotkeys_label_fg` | `color` | Foreground color used for hotkey groups and other labels. | [awful/hotkeys_popup/widget.lua:289](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L289) |
| `hotkeys_modifiers_fg` | `color` | Foreground color used for hotkey modifiers (Ctrl, Alt, Super, etc). | [awful/hotkeys_popup/widget.lua:281](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L281) |
| `hotkeys_override_label_bgs` <SomewmOnly /> | `boolean` | Override label background colors instead of cycling through xresources colors. | [awful/hotkeys_popup/widget.lua:293](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L293) |
| `hotkeys_rows` <SomewmOnly /> | `int` | Rows in one column. A longer group continues in the next column. | [awful/hotkeys_popup/widget.lua:309](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L309) |
| `hotkeys_shape` | `gears.shape` | Hotkeys widget shape. | [awful/hotkeys_popup/widget.lua:276](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L276) |
| `layout_carousel` <SomewmOnly /> | `surface` | The carousel layout layoutbox icon. | [awful/layout/suit/carousel.lua:39](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/carousel.lua#L39) |
| `layout_cornerne` | `surface` | The cornerne layout layoutbox icon. | [awful/layout/suit/corner.lua:18](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/corner.lua#L18) |
| `layout_cornernw` | `surface` | The cornernw layout layoutbox icon. | [awful/layout/suit/corner.lua:13](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/corner.lua#L13) |
| `layout_cornerse` | `surface` | The cornerse layout layoutbox icon. | [awful/layout/suit/corner.lua:28](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/corner.lua#L28) |
| `layout_cornersw` | `surface` | The cornersw layout layoutbox icon. | [awful/layout/suit/corner.lua:23](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/corner.lua#L23) |
| `layout_dwindle` | `surface` | The dwindle layout layoutbox icon. | [awful/layout/suit/spiral.lua:20](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/spiral.lua#L20) |
| `layout_fairh` | `surface` | The fairh layout layoutbox icon. | [awful/layout/suit/fair.lua:14](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/fair.lua#L14) |
| `layout_fairv` | `surface` | The fairv layout layoutbox icon. | [awful/layout/suit/fair.lua:19](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/fair.lua#L19) |
| `layout_floating` | `surface` | The floating layout layoutbox icon. | [awful/layout/suit/floating.lua:16](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/floating.lua#L16) |
| `layout_fullscreen` | `surface` | The fullscreen layout layoutbox icon. | [awful/layout/suit/max.lua:21](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/max.lua#L21) |
| `layout_magnifier` | `surface` | The magnifier layout layoutbox icon. | [awful/layout/suit/magnifier.lua:20](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/magnifier.lua#L20) |
| `layout_max` | `surface` | The max layout layoutbox icon. | [awful/layout/suit/max.lua:16](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/max.lua#L16) |
| `layout_spiral` | `surface` | The spiral layout layoutbox icon. | [awful/layout/suit/spiral.lua:15](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/spiral.lua#L15) |
| `layout_tile` | `surface` | The tile layout layoutbox icon. | [awful/layout/suit/tile.lua:23](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/tile.lua#L23) |
| `layout_tilebottom` | `surface` | The tile bottom layout layoutbox icon. | [awful/layout/suit/tile.lua:33](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/tile.lua#L33) |
| `layout_tileleft` | `surface` | The tile left layout layoutbox icon. | [awful/layout/suit/tile.lua:38](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/tile.lua#L38) |
| `layout_tiletop` | `surface` | The tile top layout layoutbox icon. | [awful/layout/suit/tile.lua:28](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/layout/suit/tile.lua#L28) |
| `layoutlist_align` | `string` | The selected layout alignment. | [awful/widget/layoutlist.lua:243](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L243) |
| `layoutlist_bg_normal` | `string\|pattern` | The default background color. | [awful/widget/layoutlist.lua:216](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L216) |
| `layoutlist_bg_selected` | `string\|pattern` | The selected layout background color. | [awful/widget/layoutlist.lua:226](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L226) |
| `layoutlist_disable_icon` | `boolean` | Disable the layout icons (only show the name label). | [awful/widget/layoutlist.lua:231](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L231) |
| `layoutlist_disable_name` | `boolean` | Disable the layout name label (only show the icon). | [awful/widget/layoutlist.lua:235](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L235) |
| `layoutlist_fg_normal` | `string\|pattern` | The default foreground (text) color. | [awful/widget/layoutlist.lua:210](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L210) |
| `layoutlist_fg_selected` | `string\|pattern` | The selected layout foreground (text) color. | [awful/widget/layoutlist.lua:221](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L221) |
| `layoutlist_font` | `string` | The layoutlist font. | [awful/widget/layoutlist.lua:239](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L239) |
| `layoutlist_font_selected` | `string` | The selected layout title font. | [awful/widget/layoutlist.lua:247](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L247) |
| `layoutlist_shape` | `gears.shape` | The default layoutlist elements shape. | [awful/widget/layoutlist.lua:255](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L255) |
| `layoutlist_shape_border_color` | `string\|color` | The default layoutlist elements border color. | [awful/widget/layoutlist.lua:263](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L263) |
| `layoutlist_shape_border_color_selected` | `string\|color` | The selected layout border color. | [awful/widget/layoutlist.lua:276](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L276) |
| `layoutlist_shape_border_width` | `number` | The default layoutlist elements border width. | [awful/widget/layoutlist.lua:259](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L259) |
| `layoutlist_shape_border_width_selected` | `number` | The selected layout border width. | [awful/widget/layoutlist.lua:272](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L272) |
| `layoutlist_shape_selected` | `gears.shape` | The selected layout shape. | [awful/widget/layoutlist.lua:268](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L268) |
| `layoutlist_spacing` | `number` | The space between the layouts. | [awful/widget/layoutlist.lua:251](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/layoutlist.lua#L251) |
| `master_count` | `integer` | The default number of master windows. | [awful/tag.lua:1110](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tag.lua#L1110) |
| `master_fill_policy` | `string` | The default fill policy. ** Possible values**: * *expand*: Take all the space * *master_width_factor*: Only take the ratio defined by the `master_width_factor` | [awful/tag.lua:1052](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tag.lua#L1052) |
| `master_width_factor` | `number` | The default master width factor | [awful/tag.lua:591](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tag.lua#L591) |
| `maximized_hide_border` | `boolean` | Hide the border on maximized clients. | [awful/permissions/init.lua:53](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L53) |
| `maximized_honor_padding` | `boolean` | Honor the screen padding when maximizing. | [awful/permissions/init.lua:45](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L45) |
| `menu_bg_focus` | `color` | The default focused item background color. | [awful/menu.lua:81](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L81) |
| `menu_bg_normal` | `color` | The default background color. | [awful/menu.lua:91](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L91) |
| `menu_border_color` | `number` | The menu item border color. | [awful/menu.lua:68](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L68) |
| `menu_border_width` | `number` | The menu item border width. | [awful/menu.lua:72](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L72) |
| `menu_fg_focus` | `color` | The default focused item foreground (text) color. | [awful/menu.lua:76](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L76) |
| `menu_fg_normal` | `color` | The default foreground (text) color. | [awful/menu.lua:86](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L86) |
| `menu_font` | `string` | The menu text font. | [awful/menu.lua:55](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L55) |
| `menu_height` | `number` | The item height. | [awful/menu.lua:60](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L60) |
| `menu_submenu` | `string` | The default sub-menu indicator if no `menu_submenu_icon` is provided. | [awful/menu.lua:96](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L96) |
| `menu_submenu_icon` | `string\|gears.surface` | The icon used for sub-menus. | [awful/menu.lua:51](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L51) |
| `menu_width` | `number` | The default menu width. | [awful/menu.lua:64](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/menu.lua#L64) |
| `prompt_bg` | `color` | The prompt background color. | [awful/widget/prompt.lua:18](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/prompt.lua#L18) |
| `prompt_bg_cursor` | `color` | The prompt cursor background color. | [awful/prompt.lua:102](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/prompt.lua#L102) |
| `prompt_fg` | `color` | The prompt foreground color. | [awful/widget/prompt.lua:13](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/prompt.lua#L13) |
| `prompt_fg_cursor` | `color` | The prompt cursor foreground color. | [awful/prompt.lua:97](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/prompt.lua#L97) |
| `prompt_font` | `string` | The prompt text font. | [awful/prompt.lua:107](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/prompt.lua#L107) |
| `screenshot_frame_color` | `color` | The screenshot interactive frame color. | [awful/screenshot.lua:79](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/screenshot.lua#L79) |
| `screenshot_frame_shape` | `shape` | The screenshot interactive frame shape. | [awful/screenshot.lua:83](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/screenshot.lua#L83) |
| `snap_bg` | `color\|string\|gradient\|pattern` | The snap outline background color. | [awful/mouse/init.lua:62](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/mouse/init.lua#L62) |
| `snap_border_width` | `integer` | The snap outline width. | [awful/mouse/init.lua:66](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/mouse/init.lua#L66) |
| `snap_shape` | `function` | The snap outline shape. | [awful/mouse/init.lua:70](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/mouse/init.lua#L70) |
| `snapper_gap` | `number` | The gap between snapped clients. | [awful/mouse/init.lua:74](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/mouse/init.lua#L74) |
| `taglist_bg_empty` | `color` | The tag list empty elements background color. | [awful/widget/taglist.lua:97](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L97) |
| `taglist_bg_focus` | `color` | The tag list main background color. | [awful/widget/taglist.lua:72](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L72) |
| `taglist_bg_occupied` | `color` | The tag list occupied elements background color. | [awful/widget/taglist.lua:87](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L87) |
| `taglist_bg_urgent` | `color` | The tag list urgent elements background color. | [awful/widget/taglist.lua:82](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L82) |
| `taglist_bg_volatile` | `color` | The tag list volatile elements background color. | [awful/widget/taglist.lua:107](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L107) |
| `taglist_disable_icon` | `boolean` | Do not display the tag icons, even if they are set. | [awful/widget/taglist.lua:141](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L141) |
| `taglist_fg_empty` | `color` | The tag list empty elements foreground (text) color. | [awful/widget/taglist.lua:102](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L102) |
| `taglist_fg_focus` | `color` | The tag list main foreground (text) color. | [awful/widget/taglist.lua:67](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L67) |
| `taglist_fg_occupied` | `color` | The tag list occupied elements foreground (text) color. | [awful/widget/taglist.lua:92](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L92) |
| `taglist_fg_urgent` | `color` | The tag list urgent elements foreground (text) color. | [awful/widget/taglist.lua:77](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L77) |
| `taglist_fg_volatile` | `color` | The tag list volatile elements foreground (text) color. | [awful/widget/taglist.lua:112](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L112) |
| `taglist_font` | `string` | The taglist font. | [awful/widget/taglist.lua:145](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L145) |
| `taglist_shape` | `gears.shape` | The main shape used for the elements. This will be the fallback for state specific shapes. To get a shape for the whole taglist, use `wibox.container.background`. | [awful/widget/taglist.lua:153](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L153) |
| `taglist_shape_border_color` | `color` | The elements shape border color. | [awful/widget/taglist.lua:169](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L169) |
| `taglist_shape_border_color_empty` | `color` | The empty elements shape border color. | [awful/widget/taglist.lua:184](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L184) |
| `taglist_shape_border_color_focus` | `color` | The selected elements shape border color. | [awful/widget/taglist.lua:199](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L199) |
| `taglist_shape_border_color_urgent` | `color` | The urgents elements shape border color. | [awful/widget/taglist.lua:214](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L214) |
| `taglist_shape_border_color_volatile` | `color` | The volatile elements shape border color. | [awful/widget/taglist.lua:229](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L229) |
| `taglist_shape_border_width` | `number` | The shape elements border width. | [awful/widget/taglist.lua:164](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L164) |
| `taglist_shape_border_width_empty` | `number` | The shape used for the empty elements border width. | [awful/widget/taglist.lua:179](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L179) |
| `taglist_shape_border_width_focus` | `number` | The shape used for the selected elements border width. | [awful/widget/taglist.lua:194](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L194) |
| `taglist_shape_border_width_urgent` | `number` | The shape used for the urgent elements border width. | [awful/widget/taglist.lua:209](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L209) |
| `taglist_shape_border_width_volatile` | `number` | The shape used for the volatile elements border width. | [awful/widget/taglist.lua:224](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L224) |
| `taglist_shape_empty` | `gears.shape` | The shape used for the empty elements. | [awful/widget/taglist.lua:174](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L174) |
| `taglist_shape_focus` | `gears.shape` | The shape used for the selected elements. | [awful/widget/taglist.lua:189](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L189) |
| `taglist_shape_urgent` | `gears.shape` | The shape used for the urgent elements. | [awful/widget/taglist.lua:204](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L204) |
| `taglist_shape_volatile` | `gears.shape` | The shape used for the volatile elements. | [awful/widget/taglist.lua:219](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L219) |
| `taglist_spacing` | `number` | The space between the taglist elements. | [awful/widget/taglist.lua:149](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L149) |
| `taglist_squares_resize` | `boolean` | If the background images can be resized. | [awful/widget/taglist.lua:137](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L137) |
| `taglist_squares_sel` | `surface` | The selected elements background image. | [awful/widget/taglist.lua:117](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L117) |
| `taglist_squares_sel_empty` | `surface` | The selected empty elements background image. | [awful/widget/taglist.lua:127](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L127) |
| `taglist_squares_unsel` | `surface` | The unselected elements background image. | [awful/widget/taglist.lua:122](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L122) |
| `taglist_squares_unsel_empty` | `surface` | The unselected empty elements background image. | [awful/widget/taglist.lua:132](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/taglist.lua#L132) |
| `tasklist_above` | `string` | Extra tasklist client property notification icon for clients with the above property set. | [awful/widget/tasklist.lua:219](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L219) |
| `tasklist_align` | `string` | The focused client alignment. | [awful/widget/tasklist.lua:247](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L247) |
| `tasklist_below` | `string` | Extra tasklist client property notification icon for clients with the below property set. | [awful/widget/tasklist.lua:223](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L223) |
| `tasklist_bg_focus` | `string\|pattern` | The focused client background color. | [awful/widget/tasklist.lua:132](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L132) |
| `tasklist_bg_image_focus` | `string` | The focused client background image. | [awful/widget/tasklist.lua:176](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L176) |
| `tasklist_bg_image_minimize` | `string` | The minimized clients background image. | [awful/widget/tasklist.lua:184](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L184) |
| `tasklist_bg_image_normal` | `string` | The elements default background image. | [awful/widget/tasklist.lua:172](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L172) |
| `tasklist_bg_image_urgent` | `string` | The urgent clients background image. | [awful/widget/tasklist.lua:180](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L180) |
| `tasklist_bg_minimize` | `string\|pattern` | The minimized clients background color. | [awful/widget/tasklist.lua:164](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L164) |
| `tasklist_bg_normal` | `string\|pattern` | The default background color. | [awful/widget/tasklist.lua:116](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L116) |
| `tasklist_bg_urgent` | `string\|pattern` | The urgent clients background color. | [awful/widget/tasklist.lua:148](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L148) |
| `tasklist_disable_icon` | `boolean` | Disable the tasklist client icons. | [awful/widget/tasklist.lua:188](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L188) |
| `tasklist_disable_task_name` | `boolean` | Disable the tasklist client titles. | [awful/widget/tasklist.lua:195](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L195) |
| `tasklist_fg_focus` | `string\|pattern` | The focused client foreground (text) color. | [awful/widget/tasklist.lua:124](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L124) |
| `tasklist_fg_minimize` | `string\|pattern` | The minimized clients foreground (text) color. | [awful/widget/tasklist.lua:156](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L156) |
| `tasklist_fg_normal` | `string\|pattern` | The default foreground (text) color. | [awful/widget/tasklist.lua:108](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L108) |
| `tasklist_fg_urgent` | `string\|pattern` | The urgent clients foreground (text) color. | [awful/widget/tasklist.lua:140](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L140) |
| `tasklist_floating` | `string` | Extra tasklist client property notification icon for clients with the floating property set. | [awful/widget/tasklist.lua:227](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L227) |
| `tasklist_font` | `string` | The tasklist font. | [awful/widget/tasklist.lua:254](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L254) |
| `tasklist_font_focus` | `string` | The focused client title alignment. | [awful/widget/tasklist.lua:262](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L262) |
| `tasklist_font_minimized` | `string` | The minimized clients font. | [awful/widget/tasklist.lua:270](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L270) |
| `tasklist_font_urgent` | `string` | The urgent clients font. | [awful/widget/tasklist.lua:278](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L278) |
| `tasklist_icon_size` | `integer` | The icon size. | [awful/widget/tasklist.lua:381](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L381) |
| `tasklist_maximized` | `string` | Extra tasklist client property notification icon for clients with the maximized property set. | [awful/widget/tasklist.lua:231](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L231) |
| `tasklist_maximized_horizontal` | `string` | Extra tasklist client property notification icon for clients with the maximized_horizontal property set. | [awful/widget/tasklist.lua:235](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L235) |
| `tasklist_maximized_vertical` | `string` | Extra tasklist client property notification icon for clients with the maximized_vertical property set. | [awful/widget/tasklist.lua:239](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L239) |
| `tasklist_minimized` | `string` | Extra tasklist client property notification icon for clients with the minimized property set. | [awful/widget/tasklist.lua:243](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L243) |
| `tasklist_ontop` | `string` | Extra tasklist client property notification icon for clients with the ontop property set. | [awful/widget/tasklist.lua:215](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L215) |
| `tasklist_plain_task_name` | `boolean` | Disable the extra tasklist client property notification icons. See the Status icons section for more details. | [awful/widget/tasklist.lua:202](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L202) |
| `tasklist_shape` | `gears.shape` | The default tasklist elements shape. | [awful/widget/tasklist.lua:293](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L293) |
| `tasklist_shape_border_color` | `string\|color` | The default tasklist elements border color. | [awful/widget/tasklist.lua:307](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L307) |
| `tasklist_shape_border_color_focus` | `string\|color` | The focused client border color. | [awful/widget/tasklist.lua:329](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L329) |
| `tasklist_shape_border_color_minimized` | `string\|color` | The minimized clients border color. | [awful/widget/tasklist.lua:351](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L351) |
| `tasklist_shape_border_color_urgent` | `string\|color` | The urgent clients border color. | [awful/widget/tasklist.lua:373](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L373) |
| `tasklist_shape_border_width` | `number` | The default tasklist elements border width. | [awful/widget/tasklist.lua:300](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L300) |
| `tasklist_shape_border_width_focus` | `number` | The focused client border width. | [awful/widget/tasklist.lua:322](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L322) |
| `tasklist_shape_border_width_minimized` | `number` | The minimized clients border width. | [awful/widget/tasklist.lua:344](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L344) |
| `tasklist_shape_border_width_urgent` | `number` | The urgent clients border width. | [awful/widget/tasklist.lua:366](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L366) |
| `tasklist_shape_focus` | `gears.shape` | The focused client shape. | [awful/widget/tasklist.lua:315](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L315) |
| `tasklist_shape_minimized` | `gears.shape` | The minimized clients shape. | [awful/widget/tasklist.lua:337](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L337) |
| `tasklist_shape_urgent` | `gears.shape` | The urgent clients shape. | [awful/widget/tasklist.lua:359](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L359) |
| `tasklist_spacing` | `number` | The space between the tasklist elements. | [awful/widget/tasklist.lua:286](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L286) |
| `tasklist_sticky` | `string` | Extra tasklist client property notification icon for clients with the sticky property set. | [awful/widget/tasklist.lua:211](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/tasklist.lua#L211) |
| `titlebar_bg` | `color` | The titlebar background color. | [awful/titlebar.lua:89](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L89) |
| `titlebar_bg_focus` | `color` | The focused titlebar background color. | [awful/titlebar.lua:107](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L107) |
| `titlebar_bg_normal` | `color` | The titlebar background color. | [awful/titlebar.lua:71](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L71) |
| `titlebar_bg_urgent` | `color` | The urgent titlebar background color. | [awful/titlebar.lua:125](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L125) |
| `titlebar_bgimage` | `gears.surface\|string` | The titlebar background image image. | [awful/titlebar.lua:95](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L95) |
| `titlebar_bgimage_focus` | `gears.surface\|string` | The focused titlebar background image image. | [awful/titlebar.lua:113](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L113) |
| `titlebar_bgimage_normal` | `gears.surface\|string` | The titlebar background image image. | [awful/titlebar.lua:77](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L77) |
| `titlebar_bgimage_urgent` | `gears.surface\|string` | The urgent titlebar background image. | [awful/titlebar.lua:131](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L131) |
| `titlebar_close_button_focus` | `gears.surface\|string` | The focused client close button image. | [awful/titlebar.lua:227](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L227) |
| `titlebar_close_button_focus_hover` | `gears.surface\|string` | The hovered+focused close button image. | [awful/titlebar.lua:233](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L233) |
| `titlebar_close_button_focus_press` | `gears.surface\|string` | The pressed+focused close button image. | [awful/titlebar.lua:239](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L239) |
| `titlebar_close_button_normal` | `gears.surface\|string` | The normal close button image. | [awful/titlebar.lua:167](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L167) |
| `titlebar_close_button_normal_hover` | `gears.surface\|string` | The hovered close button image. | [awful/titlebar.lua:173](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L173) |
| `titlebar_close_button_normal_press` | `gears.surface\|string` | The pressed close button image. | [awful/titlebar.lua:179](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L179) |
| `titlebar_fg` | `color` | The titlebar foreground (text) color. | [awful/titlebar.lua:83](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L83) |
| `titlebar_fg_focus` | `color` | The focused titlebar foreground (text) color. | [awful/titlebar.lua:101](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L101) |
| `titlebar_fg_normal` | `color` | The titlebar foreground (text) color. | [awful/titlebar.lua:65](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L65) |
| `titlebar_fg_urgent` | `color` | The urgent titlebar foreground (text) color. | [awful/titlebar.lua:119](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L119) |
| `titlebar_floating_button_focus` | `gears.surface\|string` | The focused client non-floating button image. | [awful/titlebar.lua:197](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L197) |
| `titlebar_floating_button_focus_active` | `gears.surface\|string` | The floating+focused client button image. | [awful/titlebar.lua:329](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L329) |
| `titlebar_floating_button_focus_active_hover` | `gears.surface\|string` | The hovered+floating+focused button image. | [awful/titlebar.lua:335](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L335) |
| `titlebar_floating_button_focus_active_press` | `gears.surface\|string` | The pressed+floating+focused button image. | [awful/titlebar.lua:341](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L341) |
| `titlebar_floating_button_focus_inactive` | `gears.surface\|string` | The inactive+focused+floating button image. | [awful/titlebar.lua:473](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L473) |
| `titlebar_floating_button_focus_inactive_hover` | `gears.surface\|string` | The hovered+inactive+focused+floating button image. | [awful/titlebar.lua:479](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L479) |
| `titlebar_floating_button_focus_inactive_press` | `gears.surface\|string` | The pressed+inactive+focused+floating button image. | [awful/titlebar.lua:485](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L485) |
| `titlebar_floating_button_normal` | `gears.surface\|string` | The normal non-floating button image. | [awful/titlebar.lua:137](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L137) |
| `titlebar_floating_button_normal_active` | `gears.surface\|string` | The normal floating button image. | [awful/titlebar.lua:257](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L257) |
| `titlebar_floating_button_normal_active_hover` | `gears.surface\|string` | The hovered floating client button image. | [awful/titlebar.lua:263](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L263) |
| `titlebar_floating_button_normal_active_press` | `gears.surface\|string` | The pressed floating client button image. | [awful/titlebar.lua:269](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L269) |
| `titlebar_floating_button_normal_inactive` | `gears.surface\|string` | The inactive+floating button image. | [awful/titlebar.lua:401](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L401) |
| `titlebar_floating_button_normal_inactive_hover` | `gears.surface\|string` | The hovered+inactive+floating button image. | [awful/titlebar.lua:407](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L407) |
| `titlebar_floating_button_normal_inactive_press` | `gears.surface\|string` | The pressed+inactive+floating button image. | [awful/titlebar.lua:413](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L413) |
| `titlebar_maximized_button_focus` | `gears.surface\|string` | The focused client non-maximized button image. | [awful/titlebar.lua:203](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L203) |
| `titlebar_maximized_button_focus_active` | `gears.surface\|string` | The maximized+focused button image. | [awful/titlebar.lua:347](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L347) |
| `titlebar_maximized_button_focus_active_hover` | `gears.surface\|string` | The hovered+maximized+focused button image. | [awful/titlebar.lua:353](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L353) |
| `titlebar_maximized_button_focus_active_press` | `gears.surface\|string` | The pressed+maximized+focused button image. | [awful/titlebar.lua:359](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L359) |
| `titlebar_maximized_button_focus_inactive` | `gears.surface\|string` | The inactive+focused+maximized button image. | [awful/titlebar.lua:491](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L491) |
| `titlebar_maximized_button_focus_inactive_hover` | `gears.surface\|string` | The hovered+inactive+focused+maximized button image. | [awful/titlebar.lua:497](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L497) |
| `titlebar_maximized_button_focus_inactive_press` | `gears.surface\|string` | The pressed+inactive+focused+maximized button image. | [awful/titlebar.lua:503](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L503) |
| `titlebar_maximized_button_normal` | `gears.surface\|string` | The normal non-maximized button image. | [awful/titlebar.lua:143](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L143) |
| `titlebar_maximized_button_normal_active` | `gears.surface\|string` | The maximized client button image. | [awful/titlebar.lua:275](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L275) |
| `titlebar_maximized_button_normal_active_hover` | `gears.surface\|string` | The hozered+maximized client button image. | [awful/titlebar.lua:281](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L281) |
| `titlebar_maximized_button_normal_active_press` | `gears.surface\|string` | The pressed+maximized button image. | [awful/titlebar.lua:287](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L287) |
| `titlebar_maximized_button_normal_inactive` | `gears.surface\|string` | The inactive+maximized button image. | [awful/titlebar.lua:419](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L419) |
| `titlebar_maximized_button_normal_inactive_hover` | `gears.surface\|string` | The hovered+inactive+maximized button image. | [awful/titlebar.lua:425](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L425) |
| `titlebar_maximized_button_normal_inactive_press` | `gears.surface\|string` | The pressed+maximized+inactive button image. | [awful/titlebar.lua:431](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L431) |
| `titlebar_minimize_button_focus` | `gears.surface\|string` | The focused client minimize button image. | [awful/titlebar.lua:209](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L209) |
| `titlebar_minimize_button_focus_hover` | `gears.surface\|string` | The hovered+focused client minimize button image. | [awful/titlebar.lua:215](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L215) |
| `titlebar_minimize_button_focus_press` | `gears.surface\|string` | The pressed+focused minimize button image. | [awful/titlebar.lua:221](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L221) |
| `titlebar_minimize_button_normal` | `gears.surface\|string` | The normal minimize button image. | [awful/titlebar.lua:149](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L149) |
| `titlebar_minimize_button_normal_hover` | `gears.surface\|string` | The hovered minimize button image. | [awful/titlebar.lua:155](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L155) |
| `titlebar_minimize_button_normal_press` | `gears.surface\|string` | The pressed minimize button image. | [awful/titlebar.lua:161](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L161) |
| `titlebar_ontop_button_focus` | `gears.surface\|string` | The focused client non-ontop button image. | [awful/titlebar.lua:245](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L245) |
| `titlebar_ontop_button_focus_active` | `gears.surface\|string` | The ontop+focused button image. | [awful/titlebar.lua:365](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L365) |
| `titlebar_ontop_button_focus_active_hover` | `gears.surface\|string` | The hovered+ontop+focused button image. | [awful/titlebar.lua:371](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L371) |
| `titlebar_ontop_button_focus_active_press` | `gears.surface\|string` | The pressed+ontop+focused button image. | [awful/titlebar.lua:377](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L377) |
| `titlebar_ontop_button_focus_inactive` | `gears.surface\|string` | The inactive+focused+ontop button image. | [awful/titlebar.lua:509](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L509) |
| `titlebar_ontop_button_focus_inactive_hover` | `gears.surface\|string` | The hovered+inactive+focused+ontop button image. | [awful/titlebar.lua:515](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L515) |
| `titlebar_ontop_button_focus_inactive_press` | `gears.surface\|string` | The pressed+inactive+focused+ontop button image. | [awful/titlebar.lua:521](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L521) |
| `titlebar_ontop_button_normal` | `gears.surface\|string` | The normal non-ontop button image. | [awful/titlebar.lua:185](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L185) |
| `titlebar_ontop_button_normal_active` | `gears.surface\|string` | The ontop button image. | [awful/titlebar.lua:293](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L293) |
| `titlebar_ontop_button_normal_active_hover` | `gears.surface\|string` | The hovered+ontop client button image. | [awful/titlebar.lua:299](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L299) |
| `titlebar_ontop_button_normal_active_press` | `gears.surface\|string` | The pressed+ontop client button image. | [awful/titlebar.lua:305](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L305) |
| `titlebar_ontop_button_normal_inactive` | `gears.surface\|string` | The inactive+ontop button image. | [awful/titlebar.lua:437](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L437) |
| `titlebar_ontop_button_normal_inactive_hover` | `gears.surface\|string` | The hovered+inactive+ontop button image. | [awful/titlebar.lua:443](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L443) |
| `titlebar_ontop_button_normal_inactive_press` | `gears.surface\|string` | The pressed+inactive+ontop button image. | [awful/titlebar.lua:449](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L449) |
| `titlebar_sticky_button_focus` | `gears.surface\|string` | The focused client sticky button image. | [awful/titlebar.lua:251](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L251) |
| `titlebar_sticky_button_focus_active` | `gears.surface\|string` | The sticky+focused button image. | [awful/titlebar.lua:383](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L383) |
| `titlebar_sticky_button_focus_active_hover` | `gears.surface\|string` | The hovered+sticky+focused button image. | [awful/titlebar.lua:389](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L389) |
| `titlebar_sticky_button_focus_active_press` | `gears.surface\|string` | The pressed+sticky+focused button image. | [awful/titlebar.lua:395](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L395) |
| `titlebar_sticky_button_focus_inactive` | `gears.surface\|string` | The inactive+focused+sticky button image. | [awful/titlebar.lua:527](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L527) |
| `titlebar_sticky_button_focus_inactive_hover` | `gears.surface\|string` | The hovered+inactive+focused+sticky button image. | [awful/titlebar.lua:533](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L533) |
| `titlebar_sticky_button_focus_inactive_press` | `gears.surface\|string` | The pressed+inactive+focused+sticky button image. | [awful/titlebar.lua:539](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L539) |
| `titlebar_sticky_button_normal` | `gears.surface\|string` | The normal non-sticky button image. | [awful/titlebar.lua:191](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L191) |
| `titlebar_sticky_button_normal_active` | `gears.surface\|string` | The sticky button image. | [awful/titlebar.lua:311](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L311) |
| `titlebar_sticky_button_normal_active_hover` | `gears.surface\|string` | The hovered+sticky button image. | [awful/titlebar.lua:317](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L317) |
| `titlebar_sticky_button_normal_active_press` | `gears.surface\|string` | The pressed+sticky client button image. | [awful/titlebar.lua:323](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L323) |
| `titlebar_sticky_button_normal_inactive` | `gears.surface\|string` | The inactive+sticky button image. | [awful/titlebar.lua:455](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L455) |
| `titlebar_sticky_button_normal_inactive_hover` | `gears.surface\|string` | The hovered+inactive+sticky button image. | [awful/titlebar.lua:461](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L461) |
| `titlebar_sticky_button_normal_inactive_press` | `gears.surface\|string` | The pressed+inactive+sticky button image. | [awful/titlebar.lua:467](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L467) |
| `titlebar_tooltip_align` | `string` | The text horizontal alignment in tooltips. It is used as the `align` parameter passed to the `awful.tooltip` constructor function. Valid values are: * `"right"` * `"top_right"` * `"left"` * `"bottom_left"` * `"top_left"` * `"bottom"` * `"top"` | [awful/titlebar.lua:619](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L619) |
| `titlebar_tooltip_delay_show` | `integer` | The delay in second before the titlebar buttons tooltip is shown. It is used as the `delay_show` parameter passed to the `awful.tooltip` constructor function. | [awful/titlebar.lua:595](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L595) |
| `titlebar_tooltip_margins_leftright` | `integer` | The inner left and right margins for tooltip messages. It is used as the `margins_leftright` parameter passed to the `awful.tooltip` constructor function. | [awful/titlebar.lua:601](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L601) |
| `titlebar_tooltip_margins_topbottom` | `integer` | The inner top and bottom margins for the tooltip messages. It is used as the `margins_topbottom` parameter passed to the `awful.tooltip` constructor function. | [awful/titlebar.lua:607](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L607) |
| `titlebar_tooltip_messages_close` | `string` | The message in the close button tooltip. | [awful/titlebar.lua:545](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L545) |
| `titlebar_tooltip_messages_floating_active` | `string` | The message in the floating button tooltip when then client is floating. | [awful/titlebar.lua:565](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L565) |
| `titlebar_tooltip_messages_floating_inactive` | `string` | The message in the floating button tooltip when then client isn't floating. | [awful/titlebar.lua:570](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L570) |
| `titlebar_tooltip_messages_maximized_active` | `string` | The message in the maximize button tooltip when the client is maximized. | [awful/titlebar.lua:555](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L555) |
| `titlebar_tooltip_messages_maximized_inactive` | `string` | The message in the maximize button tooltip when the client is unmaximized. | [awful/titlebar.lua:560](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L560) |
| `titlebar_tooltip_messages_minimize` | `string` | The message in the minimize button tooltip. | [awful/titlebar.lua:550](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L550) |
| `titlebar_tooltip_messages_ontop_active` | `string` | The message in the onTop button tooltip when the client is onTop. | [awful/titlebar.lua:575](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L575) |
| `titlebar_tooltip_messages_ontop_inactive` | `string` | The message in the onTop button tooltip when client isn't onTop. | [awful/titlebar.lua:580](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L580) |
| `titlebar_tooltip_messages_sticky_active` | `string` | The message in the sticky button tooltip when the client is sticky. | [awful/titlebar.lua:585](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L585) |
| `titlebar_tooltip_messages_sticky_inactive` | `string` | The message in the sticky button tooltip when the client isn't sticky. | [awful/titlebar.lua:590](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L590) |
| `titlebar_tooltip_timeout` | `number` | The time in second before invoking the `timer_function` callback. It is used as the `timeout` parameter passed to the `awful.tooltip` constructor function. | [awful/titlebar.lua:613](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L613) |
| `tooltip_align` | `string` | The default tooltip alignment. | [awful/tooltip.lua:258](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L258) |
| `tooltip_bg` | `color` | The tooltip background color. | [awful/tooltip.lua:77](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L77) |
| `tooltip_border_color` | `color` | The tooltip border color. | [awful/tooltip.lua:73](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L73) |
| `tooltip_border_width` | `number` | The tooltip border width. | [awful/tooltip.lua:89](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L89) |
| `tooltip_fg` | `color` | The tooltip foregound (text) color. | [awful/tooltip.lua:81](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L81) |
| `tooltip_font` | `string` | The tooltip font. | [awful/tooltip.lua:85](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L85) |
| `tooltip_gaps` | `table` | The tooltip margins. | [awful/tooltip.lua:97](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L97) |
| `tooltip_opacity` | `number` | The tooltip opacity. | [awful/tooltip.lua:93](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L93) |
| `tooltip_shape` | `gears.shape` | The default tooltip shape. The default shape for all tooltips is a rectangle. However, by setting this variable they can default to rounded rectangle or stretched octagons. | [awful/tooltip.lua:101](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L101) |
| `useless_gap` | `number` | The default gap. | [awful/tag.lua:957](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tag.lua#L957) |
| `wallpaper_bg` | `color` | The default wallpaper background color. | [awful/wallpaper.lua:315](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wallpaper.lua#L315) |
| `wallpaper_fg` | `gears.color` | The default wallpaper foreground color. This is useful when using widgets or text in the wallpaper. A wallpaper created from a single image wont use this. | [awful/wallpaper.lua:321](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wallpaper.lua#L321) |
| `wibar_align` | `string` | The wibar's alignments. | [awful/wibar.lua:168](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L168) |
| `wibar_bg` | `color` | The wibar's background color. | [awful/wibar.lua:148](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L148) |
| `wibar_bgimage` | `surface` | The wibar's background image. | [awful/wibar.lua:152](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L152) |
| `wibar_border_color` | `string` | The wibar border color. | [awful/wibar.lua:120](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L120) |
| `wibar_border_width` | `integer` | The wibar border width. | [awful/wibar.lua:116](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L116) |
| `wibar_cursor` | `string` | The wibar's mouse cursor. | [awful/wibar.lua:128](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L128) |
| `wibar_fg` | `color` | The wibar's foreground (text) color. | [awful/wibar.lua:156](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L156) |
| `wibar_height` | `integer` | The wibar's height. | [awful/wibar.lua:144](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L144) |
| `wibar_margins` | `number\|table` | The wibar's margins. | [awful/wibar.lua:164](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L164) |
| `wibar_ontop` | `boolean` | If the wibar is to be on top of other windows. | [awful/wibar.lua:124](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L124) |
| `wibar_opacity` | `number` | The wibar opacity, between 0 and 1. | [awful/wibar.lua:132](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L132) |
| `wibar_shape` | `gears.shape` | The wibar's shape. | [awful/wibar.lua:160](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L160) |
| `wibar_stretch` | `boolean` | If the wibar needs to be stretched to fill the screen. | [awful/wibar.lua:97](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L97) |
| `wibar_type` | `string` | The window type (desktop, normal, dock, …). | [awful/wibar.lua:136](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L136) |
| `wibar_width` | `integer` | The wibar's width. | [awful/wibar.lua:140](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/wibar.lua#L140) |
## wibox

89 entries.

| Variable | Type | Description | Source |
| --- | --- | --- | --- |
| `arcchart_bg` | `gears.color` | The radial background. | [wibox/container/arcchart.lua:51](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L51) |
| `arcchart_border_color` | `color` | The progressbar border background color. | [wibox/container/arcchart.lua:23](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L23) |
| `arcchart_border_width` | `number` | The progressbar border width. | [wibox/container/arcchart.lua:31](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L31) |
| `arcchart_color` | `color` | The progressbar foreground color. | [wibox/container/arcchart.lua:27](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L27) |
| `arcchart_paddings` | `table\|number` | The padding between the outline and the progressbar. | [wibox/container/arcchart.lua:35](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L35) |
| `arcchart_rounded_edge` | `boolean` | If the chart has rounded edges. | [wibox/container/arcchart.lua:47](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L47) |
| `arcchart_start_angle` | `number` | The (radiant) angle where the first value start. | [wibox/container/arcchart.lua:55](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L55) |
| `arcchart_thickness` | `number` | The arc thickness. | [wibox/container/arcchart.lua:43](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/arcchart.lua#L43) |
| `bg_systray` | `string` | The systray background color. | [wibox/widget/systray.lua:32](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray.lua#L32) |
| `calendar_font` | `string` | The calendar font. | [wibox/widget/calendar.lua:46](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L46) |
| `calendar_long_weekdays` | `boolean` | Format the weekdays with three characters instead of two | [wibox/widget/calendar.lua:62](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L62) |
| `calendar_spacing` | `number` | The calendar spacing. | [wibox/widget/calendar.lua:50](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L50) |
| `calendar_start_sunday` | `boolean` | Start the week on Sunday. | [wibox/widget/calendar.lua:58](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L58) |
| `calendar_week_numbers` | `boolean` | Display the calendar week numbers. | [wibox/widget/calendar.lua:54](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L54) |
| `checkbox_bg` | `color` | The outer (unchecked area) background color, pattern or gradient. | [wibox/widget/checkbox.lua:29](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L29) |
| `checkbox_border_color` | `color` | The outer (unchecked area) border color. | [wibox/widget/checkbox.lua:34](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L34) |
| `checkbox_border_width` | `number` | The outer (unchecked area) border width. | [wibox/widget/checkbox.lua:24](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L24) |
| `checkbox_check_color` | `number` | The checked part filling color. | [wibox/widget/checkbox.lua:39](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L39) |
| `checkbox_color` | `color` | The checkbox color. This will be used for the unchecked part border color and the checked part filling color. Note that `check_color` and `border_color` have priority over this property. | [wibox/widget/checkbox.lua:59](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L59) |
| `checkbox_paddings` | `table\|number` | The padding between the outline and the progressbar. | [wibox/widget/checkbox.lua:50](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L50) |
| `checkbox_shape` | `gears.shape\|function` | The outer (unchecked area) shape. | [wibox/widget/checkbox.lua:44](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/checkbox.lua#L44) |
| `flex_height` | `boolean` | Allow cells to have flexible height. Flexible height allow cells to adapt their height to fill the empty space at the bottom of the widget. | [wibox/widget/calendar.lua:66](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L66) |
| `graph_bg` | `color` | The graph background color. Used, when the `background_color` property isn't set. | [wibox/widget/graph.lua:239](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/graph.lua#L239) |
| `graph_border_color` | `color` | The graph border color. Used, when the `border_color` property isn't set. | [wibox/widget/graph.lua:245](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/graph.lua#L245) |
| `graph_fg` | `color` | The graph foreground color Used, when the `color` property isn't set. | [wibox/widget/graph.lua:233](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/graph.lua#L233) |
| `piechart_border_color` | `color` | The border color. If none is set, it will use current foreground (text) color. | [wibox/widget/piechart.lua:115](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/piechart.lua#L115) |
| `piechart_border_width` | `number` | The pie elements border width. | [wibox/widget/piechart.lua:129](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/piechart.lua#L129) |
| `piechart_colors` | `table` | The pie chart colors. If no color is set, only the border will be drawn. If less colors than required are set, colors will be re-used in order. | [wibox/widget/piechart.lua:134](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/piechart.lua#L134) |
| `progressbar_bar_border_color` | `color` | The progressbar bar border color. | [wibox/widget/progressbar.lua:226](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L226) |
| `progressbar_bar_border_width` | `number` | The progressbar bar border width. | [wibox/widget/progressbar.lua:221](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L221) |
| `progressbar_bar_shape` | `gears.shape` | The progressbar inner shape. | [wibox/widget/progressbar.lua:215](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L215) |
| `progressbar_bg` | `color` | The progressbar background color. | [wibox/widget/progressbar.lua:189](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L189) |
| `progressbar_border_color` | `color` | The progressbar border color. | [wibox/widget/progressbar.lua:205](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L205) |
| `progressbar_border_width` | `number` | The progressbar outer border width. | [wibox/widget/progressbar.lua:210](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L210) |
| `progressbar_fg` | `color` | The progressbar foreground color. | [wibox/widget/progressbar.lua:194](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L194) |
| `progressbar_margins` | `(table\|number\|nil)` | The progressbar margins. Note that if the `clip` is disabled, this allows the background to be smaller than the bar. | [wibox/widget/progressbar.lua:290](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L290) |
| `progressbar_paddings` | `(table\|number\|nil)` | The progressbar padding. Note that if the `clip` is disabled, this allows the bar to be taller than the background. | [wibox/widget/progressbar.lua:304](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L304) |
| `progressbar_shape` | `shape` | The progressbar shape. | [wibox/widget/progressbar.lua:199](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L199) |
| `radialprogressbar_border_color` | `color` | The progressbar border background color. | [wibox/container/radialprogressbar.lua:25](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/radialprogressbar.lua#L25) |
| `radialprogressbar_border_width` | `number` | The progressbar border width. | [wibox/container/radialprogressbar.lua:35](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/radialprogressbar.lua#L35) |
| `radialprogressbar_color` | `color` | The progressbar foreground color. | [wibox/container/radialprogressbar.lua:30](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/container/radialprogressbar.lua#L30) |
| `separator_border_color` | `color` | The separator border color. | [wibox/widget/separator.lua:109](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/separator.lua#L109) |
| `separator_border_width` | `number` | The separator border width. | [wibox/widget/separator.lua:114](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/separator.lua#L114) |
| `separator_color` | `color` | The separator's color. | [wibox/widget/separator.lua:123](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/separator.lua#L123) |
| `separator_shape` | `shape` | The separator's shape. | [wibox/widget/separator.lua:128](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/separator.lua#L128) |
| `separator_span_ratio` | `number` | The relative percentage covered by the bar. | [wibox/widget/separator.lua:119](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/separator.lua#L119) |
| `separator_thickness` | `number` | The separator thickness. | [wibox/widget/separator.lua:104](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/separator.lua#L104) |
| `slider_bar_active_color` | `color` | The bar (active) color. Only works when both `beautiful.slider_bar_color` and `beautiful.slider_bar_active_color` are hex color strings | [wibox/widget/slider.lua:226](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L226) |
| `slider_bar_color` | `color` | The bar (background) color. | [wibox/widget/slider.lua:221](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L221) |
| `slider_bar_height` | `number` | The bar (background) height. | [wibox/widget/slider.lua:207](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L207) |
| `slider_bar_margins` | `table` | The bar (background) margins. | [wibox/widget/slider.lua:212](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L212) |
| `slider_bar_shape` | `gears.shape` | The bar (background) shape. | [wibox/widget/slider.lua:201](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L201) |
| `slider_handle_border_color` | `color` | The handle border_color. | [wibox/widget/slider.lua:166](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L166) |
| `slider_handle_border_width` | `number` | The handle border width. | [wibox/widget/slider.lua:171](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L171) |
| `slider_handle_color` | `color` | The handle color. | [wibox/widget/slider.lua:181](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L181) |
| `slider_handle_cursor` | `string` | The cursor icon while grabbing the handle. The available cursor names are: | [wibox/widget/slider.lua:192](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L192) |
| `slider_handle_shape` | `gears.shape` | The handle shape. | [wibox/widget/slider.lua:186](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L186) |
| `slider_handle_width` | `number` | The handle width. | [wibox/widget/slider.lua:176](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/slider.lua#L176) |
| `systray_hover_bg` <SomewmOnly /> | `string` | The hover background color. | [wibox/widget/systray_icon.lua:43](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L43) |
| `systray_hover_scale` <SomewmOnly /> | `number` | The hover scale factor. | [wibox/widget/systray_icon.lua:39](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L39) |
| `systray_icon_change_triggers_urgent` <SomewmOnly /> | `boolean` | Whether icon changes trigger urgent styling. When an app changes its icon (e.g., Slack adding a notification badge), this triggers urgent styling instead. Best used with icon_override to show a clean icon while still getting notification indicators. | [wibox/widget/systray_icon.lua:150](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L150) |
| `systray_icon_spacing` | `integer` | The systray icon spacing. | [wibox/widget/systray.lua:42](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray.lua#L42) |
| `systray_icon_style` <SomewmOnly /> | `function\|table` | Per-icon style overrides. Can be a function that receives the systray_item and returns a style table, or a table mapping item.id or item.app_name to style tables. Style tables can contain: - `icon_override`: path to custom icon - `hover_scale`: scale on hover - `hover_bg`: background color on hover - `urgent_bg`: background color when urgent - `urgent_color`: urgent indicator color - `urgent_outline_color`: urgent indicator outline - `urgent_style`: "dot", "ring", "glow", or "none" - `urgent_position`: "top_right", "top_left", "bottom_right", "bottom_left" - `urgent_size`: number, ratio if &lt;= 1, pixels if &gt; 1 - `urgent_shape`: gears.shape function (default: gears.shape.circle) - `icon_change_triggers_urgent`: boolean, icon changes trigger urgent - `overlay_triggers_urgent`: boolean, overlay presence triggers urgent styling - `overlay_position`: "bottom_right", "bottom_left", "top_right", "top_left" - `overlay_size`: number, ratio if &lt;= 1, pixels if &gt; 1 - `overlay_bg`: background color for overlay - `overlay_shape`: "circle", "rounded_rect", "rect" - `overlay_padding`: padding around overlay within background | [wibox/widget/systray_icon.lua:47](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L47) |
| `systray_max_rows` | `integer` | The maximum number of rows for systray icons. | [wibox/widget/systray.lua:37](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray.lua#L37) |
| `systray_menu_bg_focus` <SomewmOnly /> | `string` | Context menu focused background color. | [wibox/widget/systray_icon.lua:85](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L85) |
| `systray_menu_bg_normal` <SomewmOnly /> | `string` | Context menu background color. | [wibox/widget/systray_icon.lua:77](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L77) |
| `systray_menu_border_color` <SomewmOnly /> | `string` | Context menu border color. | [wibox/widget/systray_icon.lua:89](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L89) |
| `systray_menu_border_width` <SomewmOnly /> | `number` | Context menu border width. | [wibox/widget/systray_icon.lua:93](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L93) |
| `systray_menu_callback` <SomewmOnly /> | `function` | Context menu callback for customization. Called with (item, menu_items) before showing menu. Can modify menu_items. | [wibox/widget/systray_icon.lua:109](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L109) |
| `systray_menu_fg_focus` <SomewmOnly /> | `string` | Context menu focused foreground color. | [wibox/widget/systray_icon.lua:81](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L81) |
| `systray_menu_fg_normal` <SomewmOnly /> | `string` | Context menu foreground color. | [wibox/widget/systray_icon.lua:73](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L73) |
| `systray_menu_font` <SomewmOnly /> | `string` | Context menu font. | [wibox/widget/systray_icon.lua:97](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L97) |
| `systray_menu_height` <SomewmOnly /> | `number` | Context menu height. | [wibox/widget/systray_icon.lua:105](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L105) |
| `systray_menu_width` <SomewmOnly /> | `number` | Context menu width. | [wibox/widget/systray_icon.lua:101](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L101) |
| `systray_overlay_bg` <SomewmOnly /> | `string` | Background color for overlay icons. Draws a background shape behind the overlay icon for better visibility. | [wibox/widget/systray_icon.lua:137](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L137) |
| `systray_overlay_padding` <SomewmOnly /> | `number` | Padding around overlay icon within its background. | [wibox/widget/systray_icon.lua:146](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L146) |
| `systray_overlay_position` <SomewmOnly /> | `string` | The position of overlay icons on systray items. | [wibox/widget/systray_icon.lua:126](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L126) |
| `systray_overlay_shape` <SomewmOnly /> | `string` | Shape for overlay background. | [wibox/widget/systray_icon.lua:142](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L142) |
| `systray_overlay_size` <SomewmOnly /> | `number` | The size of overlay icons relative to the main icon. If value is &lt;= 1, treated as a ratio (e.g., 0.33 = 33% of icon size). If value is &gt; 1, treated as absolute pixels. | [wibox/widget/systray_icon.lua:131](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L131) |
| `systray_overlay_triggers_urgent` <SomewmOnly /> | `boolean` | Whether overlay presence triggers urgent styling. When true, icons with an overlay will be rendered with urgent styling even if their status is not "NeedsAttention". | [wibox/widget/systray_icon.lua:120](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L120) |
| `systray_paddings` <SomewmOnly /> | `integer` | The systray paddings (space around icons). | [wibox/widget/systray.lua:47](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray.lua#L47) |
| `systray_show_overlay` <SomewmOnly /> | `boolean` | Whether to show overlay icons. Overlay icons are small badges displayed on top of the main icon, typically used to show status (like number of notifications). | [wibox/widget/systray_icon.lua:114](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L114) |
| `systray_urgent_bg` <SomewmOnly /> | `string` | The urgent background color. Shown when the systray item status is "NeedsAttention". Similar to AwesomeWM's bg_urgent for clients/tags. | [wibox/widget/systray_icon.lua:21](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L21) |
| `systray_urgent_color` <SomewmOnly /> | `string` | The urgent indicator color. | [wibox/widget/systray_icon.lua:27](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L27) |
| `systray_urgent_outline_color` <SomewmOnly /> | `string` | The urgent indicator outline color. | [wibox/widget/systray_icon.lua:31](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L31) |
| `systray_urgent_position` <SomewmOnly /> | `string` | Position of urgent indicators (dot style). | [wibox/widget/systray_icon.lua:157](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L157) |
| `systray_urgent_shape` <SomewmOnly /> | `function` | Shape function for urgent indicators. Used with "dot" and "ring" styles. Receives (cr, width, height). | [wibox/widget/systray_icon.lua:168](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L168) |
| `systray_urgent_size` <SomewmOnly /> | `number` | Size of urgent indicator dot. If value is &lt;= 1, treated as a ratio of icon size. If value is &gt; 1, treated as absolute pixels. | [wibox/widget/systray_icon.lua:162](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L162) |
| `systray_urgent_style` <SomewmOnly /> | `string` | The urgent indicator style. | [wibox/widget/systray_icon.lua:35](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/systray_icon.lua#L35) |
## naughty {#notifications}

47 entries.

| Variable | Type | Description | Source |
| --- | --- | --- | --- |
| `notification_action_bg_normal` | `color` | The background color for normal actions. | [naughty/list/actions.lua:91](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L91) |
| `notification_action_bg_selected` | `color` | The background color for selected actions. | [naughty/list/actions.lua:96](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L96) |
| `notification_action_bgimage_normal` | `gears.surface\|string` | The background image for normal actions. | [naughty/list/actions.lua:111](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L111) |
| `notification_action_bgimage_selected` | `gears.surface\|string` | The background image for selected actions. | [naughty/list/actions.lua:116](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L116) |
| `notification_action_fg_normal` | `color` | The foreground color for normal actions. | [naughty/list/actions.lua:101](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L101) |
| `notification_action_fg_selected` | `color` | The foreground color for selected actions. | [naughty/list/actions.lua:106](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L106) |
| `notification_action_icon_only` | `boolean` | Whether or not the action label should be shown. | [naughty/list/actions.lua:47](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L47) |
| `notification_action_icon_size_normal` | `number` | The action icon size. | [naughty/list/actions.lua:83](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L83) |
| `notification_action_icon_size_selected` | `number` | The selected action icon size. | [naughty/list/actions.lua:87](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L87) |
| `notification_action_label_only` | `boolean` | Whether or not the action icon should be shown. | [naughty/list/actions.lua:51](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L51) |
| `notification_action_shape_border_color_normal` | `color` | The shape border color for normal actions. | [naughty/list/actions.lua:65](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L65) |
| `notification_action_shape_border_color_selected` | `color` | The shape border color for selected actions. | [naughty/list/actions.lua:70](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L70) |
| `notification_action_shape_border_width_normal` | `number` | The shape border width for normal actions. | [naughty/list/actions.lua:75](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L75) |
| `notification_action_shape_border_width_selected` | `number` | The shape border width for selected actions. | [naughty/list/actions.lua:79](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L79) |
| `notification_action_shape_normal` | `gears.shape` | The shape used for a normal action. | [naughty/list/actions.lua:55](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L55) |
| `notification_action_shape_selected` | `gears.shape` | The shape used for a selected action. | [naughty/list/actions.lua:60](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L60) |
| `notification_action_underline_normal` | `boolean` | Whether or not to underline the action name. | [naughty/list/actions.lua:39](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L39) |
| `notification_action_underline_selected` | `boolean` | Whether or not to underline the selected action name. | [naughty/list/actions.lua:43](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L43) |
| `notification_bg` | `color` | Notifications background color. | [naughty/notification.lua:37](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L37) |
| `notification_bg_normal` | `color` | The background color for normal notifications. | [naughty/list/notifications.lua:61](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L61) |
| `notification_bg_selected` | `color` | The background color for selected notifications. | [naughty/list/notifications.lua:66](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L66) |
| `notification_bgimage_normal` | `string\|gears.surface` | The background image for normal notifications. | [naughty/list/notifications.lua:81](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L81) |
| `notification_bgimage_selected` | `string\|gears.surface` | The background image for selected notifications. | [naughty/list/notifications.lua:86](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L86) |
| `notification_border_color` | `color` | Notifications border color. | [naughty/notification.lua:49](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L49) |
| `notification_border_width` | `int` | Notifications border width. | [naughty/notification.lua:45](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L45) |
| `notification_fg` | `color` | Notifications foreground color. | [naughty/notification.lua:41](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L41) |
| `notification_fg_normal` | `color` | The foreground color for normal notifications. | [naughty/list/notifications.lua:71](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L71) |
| `notification_fg_selected` | `color` | The foreground color for selected notifications. | [naughty/list/notifications.lua:76](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L76) |
| `notification_font` | `string\|lgi.Pango.FontDescription` | Notifications font. | [naughty/notification.lua:33](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L33) |
| `notification_height` | `int` | Notifications height. | [naughty/notification.lua:70](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L70) |
| `notification_icon_resize_strategy` | `number` | The default way to resize the icon. | [naughty/widget/icon.lua:28](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/widget/icon.lua#L28) |
| `notification_icon_size` | `number` | The default notification icon size. | [naughty/widget/icon.lua:83](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/widget/icon.lua#L83) |
| `notification_icon_size_normal` | `number` | The notification icon size. | [naughty/list/notifications.lua:53](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L53) |
| `notification_icon_size_selected` | `number` | The selected notification icon size. | [naughty/list/notifications.lua:57](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L57) |
| `notification_margin` | `int` | The margins inside of the notification widget (or popup). | [naughty/notification.lua:62](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L62) |
| `notification_max_width` | `number` | The maximum notification width. | [naughty/layout/box.lua:114](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/layout/box.lua#L114) |
| `notification_opacity` | `int` | Notifications opacity. | [naughty/notification.lua:58](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L58) |
| `notification_position` | `string` | The maximum notification position. Valid values are: * top_left * top_middle * top_right * bottom_left * bottom_middle * bottom_right | [naughty/layout/box.lua:118](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/layout/box.lua#L118) |
| `notification_shape` | `gears.shape` | Notifications shape. | [naughty/notification.lua:53](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L53) |
| `notification_shape_border_color_normal` | `color` | The shape border color for normal notifications. | [naughty/list/notifications.lua:35](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L35) |
| `notification_shape_border_color_selected` | `color` | The shape border color for selected notifications. | [naughty/list/notifications.lua:40](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L40) |
| `notification_shape_border_width_normal` | `number` | The shape border width for normal notifications. | [naughty/list/notifications.lua:45](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L45) |
| `notification_shape_border_width_selected` | `number` | The shape border width for selected notifications. | [naughty/list/notifications.lua:49](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L49) |
| `notification_shape_normal` | `gears.shape` | The shape used for a normal notification. | [naughty/list/notifications.lua:25](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L25) |
| `notification_shape_selected` | `gears.shape` | The shape used for a selected notification. | [naughty/list/notifications.lua:30](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L30) |
| `notification_spacing` | `number` | The spacing between the notifications. | [naughty/notification.lua:74](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L74) |
| `notification_width` | `int` | Notifications width. | [naughty/notification.lua:66](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L66) |
## menubar

8 entries.

| Variable | Type | Description | Source |
| --- | --- | --- | --- |
| `launcher_width` <SomewmOnly /> | `number` | The launcher's width, ahead of `menubar.geometry.width`. Without either, the launcher spans the workarea. | [menubar/init.lua:77](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L77) |
| `menubar_bg_focus` | `color` | Menubar selected item background color. | [menubar/init.lua:69](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L69) |
| `menubar_bg_normal` | `color` | Menubar normal background color. | [menubar/init.lua:53](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L53) |
| `menubar_border_color` | `color` | Menubar border color. | [menubar/init.lua:61](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L61) |
| `menubar_border_width` | `number` | Menubar border width. | [menubar/init.lua:57](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L57) |
| `menubar_fg_focus` | `color` | Menubar selected item text color. | [menubar/init.lua:65](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L65) |
| `menubar_fg_normal` | `color` | Menubar normal text color. | [menubar/init.lua:49](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L49) |
| `menubar_font` | `font` | Menubar font. | [menubar/init.lua:73](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/menubar/init.lua#L73) |
## somewm

19 entries.

| Variable | Type | Description | Source |
| --- | --- | --- | --- |
| `animation_appear` <SomewmOnly /> | `string\|table` | The entrance every client maps with: `grow`, `scale`, `scale_top`, `scale_bottom`, `scale_left`, `scale_right`, `slide_left`, `slide_right`, `slide_up`, `slide_down` or `fade`. A list combines effects simultaneously, with at most one slide, one size effect (`grow` or a scale word) and `fade`. | [somewm/animation.lua:52](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L52) |
| `animation_appear_duration` <SomewmOnly /> | `number` | A client mapping, in seconds. Needs an entrance from `animation_appear` or `c.animation.appear`. | [somewm/animation.lua:33](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L33) |
| `animation_disappear` <SomewmOnly /> | `string\|table` | The exit every client closes with, same words as `animation_appear`. | [somewm/animation.lua:59](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L59) |
| `animation_disappear_duration` <SomewmOnly /> | `number` | A client closing, in seconds. Needs an entrance from `animation_disappear` or `c.animation.disappear`. | [somewm/animation.lua:38](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L38) |
| `animation_duration` <SomewmOnly /> | `number` | The duration for every trigger that has none of its own, in seconds. Applies to layout too. With no duration configured, nothing animates. 0 snaps. | [somewm/animation.lua:15](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L15) |
| `animation_floating_duration` <SomewmOnly /> | `number` | A client toggling floating, in seconds. | [somewm/animation.lua:29](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L29) |
| `animation_focus_duration` <SomewmOnly /> | `number` | The border colour easing on a focus change, in seconds. | [somewm/animation.lua:48](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L48) |
| `animation_layout_duration` <SomewmOnly /> | `number` | Tiled clients moving between slots, in seconds. 0 snaps. Requiring the deprecated `somewm.layout_animation` sets 0.15. | [somewm/animation.lua:20](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L20) |
| `animation_maximize_duration` <SomewmOnly /> | `number` | A client maximizing or going fullscreen, in seconds. | [somewm/animation.lua:25](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L25) |
| `animation_tag` <SomewmOnly /> | `string\|table` | The entrance and exit on a tag switch, same words as `animation_appear`. Defaults to `grow`. `c.animation.tag` can override it. | [somewm/animation.lua:63](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L63) |
| `animation_tag_duration` <SomewmOnly /> | `number` | A tag switch, in seconds. Clients grow in and out unless `c.animation.tag` or `animation_tag` names another entrance. | [somewm/animation.lua:43](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/animation.lua#L43) |
| `inspector_bg` <SomewmOnly /> | `color` | The panel body and its odd rows. | [somewm/inspector.lua:29](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L29) |
| `inspector_bg_alt` <SomewmOnly /> | `color` | The header, the even rows, and the info and warnings panes. | [somewm/inspector.lua:33](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L33) |
| `inspector_bg_selected` <SomewmOnly /> | `color` | The selected tree row. | [somewm/inspector.lua:45](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L45) |
| `inspector_border` <SomewmOnly /> | `color` | Dividers, row borders and dim text (ids, the Offscreen tag). | [somewm/inspector.lua:37](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L37) |
| `inspector_fg` <SomewmOnly /> | `color` | Text and swatch borders. | [somewm/inspector.lua:41](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L41) |
| `inspector_font` <SomewmOnly /> | `string` | The panel font. A size, absolute (`"Monospace 14px"`) or in points (`"Monospace 10"`), sizes the panel's text. Without one Clay's 16px stands. Rows are 30px, so sizes past about 20px overflow them. | [somewm/inspector.lua:58](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L58) |
| `inspector_highlight` <SomewmOnly /> | `color` | The overlay drawn over the hovered element out on the desktop. Its alpha shows the element through. | [somewm/inspector.lua:49](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L49) |
| `inspector_width` <SomewmOnly /> | `number` | The panel width in logical pixels. | [somewm/inspector.lua:54](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/somewm/inspector.lua#L54) |
## root

12 entries.

| Variable | Type | Description | Source |
| --- | --- | --- | --- |
| `awesome_icon` | `string\|gears.surface` | The Awesome icon path. | [beautiful/init.lua:142](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L142) |
| `bg_focus` | `color` | The default focused element background color. | [beautiful/init.lua:105](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L105) |
| `bg_minimize` | `color` | The default minimized element background color. | [beautiful/init.lua:113](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L113) |
| `bg_normal` | `color` | The default background color. The background color can be transparent. If there is a compositing manager such as compton, then it will be real transparency and may include blur (provided by the compositor). When there is no compositor, it will take a picture of the wallpaper and blend it. | [beautiful/init.lua:94](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L94) |
| `bg_urgent` | `color` | The default urgent element background color. | [beautiful/init.lua:109](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L109) |
| `fg_focus` | `color` | The default focused element foreground (text) color. | [beautiful/init.lua:121](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L121) |
| `fg_minimize` | `color` | The default minimized element foreground (text) color. | [beautiful/init.lua:129](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L129) |
| `fg_normal` | `color` | The default focused element foreground (text) color. | [beautiful/init.lua:117](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L117) |
| `fg_urgent` | `color` | The default urgent element foreground (text) color. | [beautiful/init.lua:125](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L125) |
| `font` | `string` | The default font. | [beautiful/init.lua:90](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L90) |
| `icon_theme` | `string` | The icon theme name. It has to be a directory in `/usr/share/icons` or an XDG icon folder. | [beautiful/init.lua:137](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L137) |
| `wallpaper` | `string\|gears.surface` | The wallpaper path. | [beautiful/init.lua:133](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L133) |

## Undocumented (Used in Code)

88 theme variables are read in source but lack an `@beautiful` annotation. Their types and accepted values are not annotated.

| Variable | Used at |
| --- | --- |
| `border_color` | [awful/permissions/init.lua:746](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L746) |
| `border_color_active` | [awful/permissions/init.lua:615](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L615), [naughty/notification.lua:892](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L892) |
| `border_color_floating` | [awful/permissions/init.lua:619](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L619) |
| `border_color_floating_active` | [awful/permissions/init.lua:620](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L620) |
| `border_color_floating_new` | [awful/permissions/init.lua:622](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L622) |
| `border_color_floating_normal` | [awful/permissions/init.lua:621](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L621) |
| `border_color_floating_urgent` | [awful/permissions/init.lua:623](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L623) |
| `border_color_fullscreen` | [awful/permissions/init.lua:629](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L629) |
| `border_color_fullscreen_active` | [awful/permissions/init.lua:630](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L630) |
| `border_color_fullscreen_new` | [awful/permissions/init.lua:632](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L632) |
| `border_color_fullscreen_normal` | [awful/permissions/init.lua:631](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L631) |
| `border_color_fullscreen_urgent` | [awful/permissions/init.lua:633](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L633) |
| `border_color_marked` | [awful/permissions/init.lua:614](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L614), [awful/permissions/init.lua:719](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L719), [awful/permissions/init.lua:720](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L720) |
| `border_color_maximized` | [awful/permissions/init.lua:624](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L624) |
| `border_color_maximized_active` | [awful/permissions/init.lua:625](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L625) |
| `border_color_maximized_new` | [awful/permissions/init.lua:627](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L627) |
| `border_color_maximized_normal` | [awful/permissions/init.lua:626](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L626) |
| `border_color_maximized_urgent` | [awful/permissions/init.lua:628](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L628) |
| `border_color_new` | [awful/permissions/init.lua:617](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L617) |
| `border_color_normal` | [awful/permissions/init.lua:616](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L616), [awful/tooltip.lua:495](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L495), [awful/tooltip.lua:711](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/tooltip.lua#L711) _(+1 more)_ |
| `border_color_urgent` | [awful/permissions/init.lua:618](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L618) |
| `border_focus` | [awful/permissions/init.lua:741](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L741), [awful/permissions/init.lua:742](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L742) |
| `border_marked` | [awful/permissions/init.lua:722](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L722), [awful/permissions/init.lua:723](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L723) |
| `border_normal` | [awful/permissions/init.lua:739](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L739), [awful/permissions/init.lua:740](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L740) |
| `border_width` | [awful/hotkeys_popup/widget.lua:357](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L357), [awful/hotkeys_popup/widget.lua:407](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L407), [awful/permissions/init.lua:710](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L710) _(+1 more)_ |
| `border_width_active` | [awful/permissions/init.lua:634](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L634) |
| `border_width_floating` | [awful/permissions/init.lua:638](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L638) |
| `border_width_floating_active` | [awful/permissions/init.lua:639](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L639) |
| `border_width_floating_new` | [awful/permissions/init.lua:641](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L641) |
| `border_width_floating_normal` | [awful/permissions/init.lua:640](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L640) |
| `border_width_floating_urgent` | [awful/permissions/init.lua:642](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L642) |
| `border_width_fullscreen` | [awful/permissions/init.lua:648](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L648) |
| `border_width_fullscreen_active` | [awful/permissions/init.lua:649](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L649) |
| `border_width_fullscreen_new` | [awful/permissions/init.lua:651](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L651) |
| `border_width_fullscreen_normal` | [awful/permissions/init.lua:650](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L650) |
| `border_width_fullscreen_urgent` | [awful/permissions/init.lua:652](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L652) |
| `border_width_maximized` | [awful/permissions/init.lua:643](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L643) |
| `border_width_maximized_active` | [awful/permissions/init.lua:644](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L644) |
| `border_width_maximized_new` | [awful/permissions/init.lua:646](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L646) |
| `border_width_maximized_normal` | [awful/permissions/init.lua:645](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L645) |
| `border_width_maximized_urgent` | [awful/permissions/init.lua:647](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L647) |
| `border_width_new` | [awful/permissions/init.lua:636](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L636) |
| `border_width_normal` | [awful/permissions/init.lua:635](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L635) |
| `border_width_urgent` | [awful/permissions/init.lua:637](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L637) |
| `calendar_` | [awful/widget/calendar_popup.lua:45](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/widget/calendar_popup.lua#L45) |
| `calendar_flex_height` | [wibox/widget/calendar.lua:422](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/calendar.lua#L422) |
| `clock_bg` | [somewmrc.lua:295](https://github.com/trip-zip/somewm/blob/v2.1.0/somewmrc.lua#L295) |
| `hotkeys_opacity` | [awful/hotkeys_popup/widget.lua:420](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/hotkeys_popup/widget.lua#L420) |
| `load_font` | [beautiful/init.lua:183](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L183) |
| `lockscreen_bg_color` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_border_color` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_clock_format` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_date_format` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_error_color` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_fg_color` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_font` | [lockscreen.lua:300](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L300), [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_font_large` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_input_bg` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `lockscreen_wallpaper` | [lockscreen.lua:309](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L309) |
| `lockscreen_wallpaper_overlay` | [lockscreen.lua:292](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/lockscreen.lua#L292) |
| `notification_` | [naughty/notification.lua:852](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/notification.lua#L852) |
| `notification_action` | [naughty/list/actions.lua:209](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/actions.lua#L209), [naughty/list/notifications.lua:190](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/list/notifications.lua#L190) |
| `notification_padding` | [naughty/layout/box.lua:82](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/naughty/layout/box.lua#L82) |
| `opacity_active` | [awful/permissions/init.lua:668](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L668) |
| `opacity_floating` | [awful/permissions/init.lua:653](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L653) |
| `opacity_floating_active` | [awful/permissions/init.lua:654](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L654) |
| `opacity_floating_new` | [awful/permissions/init.lua:656](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L656) |
| `opacity_floating_normal` | [awful/permissions/init.lua:655](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L655) |
| `opacity_floating_urgent` | [awful/permissions/init.lua:657](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L657) |
| `opacity_fullscreen` | [awful/permissions/init.lua:663](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L663) |
| `opacity_fullscreen_active` | [awful/permissions/init.lua:664](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L664) |
| `opacity_fullscreen_new` | [awful/permissions/init.lua:666](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L666) |
| `opacity_fullscreen_normal` | [awful/permissions/init.lua:665](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L665) |
| `opacity_fullscreen_urgent` | [awful/permissions/init.lua:667](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L667) |
| `opacity_maximized` | [awful/permissions/init.lua:658](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L658) |
| `opacity_maximized_active` | [awful/permissions/init.lua:659](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L659) |
| `opacity_maximized_new` | [awful/permissions/init.lua:661](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L661) |
| `opacity_maximized_normal` | [awful/permissions/init.lua:660](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L660) |
| `opacity_maximized_urgent` | [awful/permissions/init.lua:662](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L662) |
| `opacity_new` | [awful/permissions/init.lua:670](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L670) |
| `opacity_normal` | [awful/permissions/init.lua:669](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L669) |
| `opacity_urgent` | [awful/permissions/init.lua:671](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/permissions/init.lua#L671) |
| `progressbar_clip` | [wibox/widget/progressbar.lua:359](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/wibox/widget/progressbar.lua#L359) |
| `theme_path` | [beautiful/init.lua:147](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/beautiful/init.lua#L147) |
| `titlebar_font` | [awful/titlebar.lua:785](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/awful/titlebar.lua#L785) |
| `wallpaper_colors` | [somewmrc.lua:224](https://github.com/trip-zip/somewm/blob/v2.1.0/somewmrc.lua#L224) |
| `wallpaper_logo_color` | [somewmrc.lua:91](https://github.com/trip-zip/somewm/blob/v2.1.0/somewmrc.lua#L91), [somewmrc.lua:227](https://github.com/trip-zip/somewm/blob/v2.1.0/somewmrc.lua#L227) |
| `xresources_dpi` | [gears/xresources.lua:171](https://github.com/trip-zip/somewm/blob/v2.1.0/lua/gears/xresources.lua#L171) |

## See Also

- [Theme Tutorial](../../tutorials/theme.md) – Build a custom theme
- [Key Names](../key-names.md) – Common keybinding key names
- [beautiful (AwesomeWM upstream docs)](https://awesomewm.org/apidoc/libraries/beautiful.html) – Full upstream API

<!-- generator: scripts/generate-theme-variables.mjs | source ref: main @ ea3a2a1a9e | regenerate with `npm run generate:reference` -->
