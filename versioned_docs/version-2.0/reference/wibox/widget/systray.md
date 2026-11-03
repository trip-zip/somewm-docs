---
title: wibox.widget.systray
description: Systray styling options, theme variables, per-application overrides and version limits.
---

# wibox.widget.systray

Displays application icons through StatusNotifierItem over the session D-Bus. Applications that only support XEmbed do not appear. Items with status `Passive` are hidden.

## Styling options

| Appearance | Settings | Available choices |
| --- | --- | --- |
| [Size and layout](#properties) | `base_size`, `horizontal`, `reverse` | Icon size in pixels, row or column, reversed order. |
| [Tray background and spacing](#tray-layout) | `bg_systray`, `systray_icon_spacing`, `systray_paddings`, `systray_max_rows` | Background, gaps, outer padding, multiple rows. |
| [Icon image](#icon-images) | `icon_theme`, per-application `icon_override` | Icon-theme lookup or a replacement image. |
| [Hover](#hover) | `systray_hover_bg`, `systray_hover_scale` | Background and size change. |
| [Attention](#attention-indicators) | `systray_urgent_bg`, `systray_urgent_style` | Background plus `"none"`, `"dot"`, `"ring"` or `"glow"` indicators. |
| [Application badges](#application-badges) | `systray_show_overlay`, `systray_overlay_*` | Show or hide; size; four corners; circle, rounded rectangle or rectangular background. |
| [Per-application styles](#per-application-styles) | `systray_icon_style` | Exact ID/name rules or a function that returns a style table. |
| [Context menus](#context-menus) | `systray_menu_*` | Colours, border, font, dimensions and a callback to change menu entries. |

A **badge** is an overlay image supplied by the application. An **attention indicator** is a dot, ring or border drawn by SomeWM. They have separate settings. [Replace a badge with a ring](#badge-to-ring) combines the two.

For screenshots and complete examples, see [Customise the systray](../../../guides/customise-systray.md).

## Constructor

```lua
local wibox = require("wibox")
local beautiful = require("beautiful")

beautiful.systray_icon_spacing = 4

local tray = wibox.widget.systray()
tray:set_base_size(20)
```

`wibox.widget.systray(reverse)` returns the same widget on every call. The optional `reverse` argument defaults to `false` and is used only on the first call.

## Properties

| Setting | Default | Behaviour |
| --- | --- | --- |
| `base_size` | `nil` | Square icon size in pixels. `nil` uses 24 pixels. |
| `horizontal` | `true` | Orientation at construction. Set with `wibox.widget.systray.set_horizontal(false)` before the first constructor call for a vertical tray. |
| `reverse` | `false` | Reverses the item order. |
| `screen` | `"primary"` | Accepts a screen, `"primary"` or `nil`. The setter stores the value but does not filter the rendered icons by screen. |

Use `tray:set_base_size(size)`, `tray:set_horizontal(boolean)`, `tray:set_reverse(boolean)` and `tray:set_screen(screen)`. These settings belong to the shared instance. Each setter emits `property::<name>`.

For a tray on one monitor, include the widget only in that monitor's bar.

## Theme variables

These names are fields on `beautiful`, for example `beautiful.systray_hover_bg = "#458588"`. Defaults below apply when the theme does not supply a value. Theme settings normally go after `beautiful.init(...)` and before bar creation.

Each setting lists its theme variable and, where supported, its **Per-application** key inside `systray_icon_style`. An omitted field inherits its theme variable. Settings marked **Global only** cannot be overridden through that table.

### Tray layout {#tray-layout}

| Setting | Default and behaviour |
| --- | --- |
| `bg_systray`<br />Global only | **Default:** `nil`.<br />Tray background. Accepts a colour or Cairo pattern. |
| `systray_icon_spacing`<br />Global only | **Default:** `0`.<br />Integer gap between icons, in pixels. |
| `systray_paddings`<br />Global only | **Default:** `0`.<br />Integer outer padding on all sides, in pixels. |
| `systray_max_rows`<br />Global only | **Default:** `1`.<br />Positive integer. Maximum rows in the icon grid. |

### Icon images {#icon-images}

| Setting | Default and behaviour |
| --- | --- |
| `icon_theme`<br />Global only | **Default:** `"hicolor"`.<br />Icon-theme name used for icon-name lookup. Application pixmaps and icons found in the application's own icon directory take precedence. |
| `icon_override`<br />Per-application only | **Default:** `nil`.<br />Replacement image path or icon-theme name. An unreadable image falls back to the application icon. |

### Hover {#hover}

| Setting | Default and behaviour |
| --- | --- |
| `systray_hover_bg`<br />Per-application: `hover_bg` | **Default:** `nil`.<br />Background while the pointer is over the icon. `nil` means no global hover background. |
| `systray_hover_scale`<br />Per-application: `hover_scale` | **Default:** `1.0`.<br />Number. `1.1` enlarges the icon by 10% around its centre. Changes immediately, without animation; the layout slot does not grow. |

### Attention indicators {#attention-indicators}

Attention styling appears when the item reports `NeedsAttention`. `systray_overlay_triggers_urgent` can also trigger it while an application overlay is present. `systray_icon_change_triggers_urgent` can trigger it when the application changes its icon.

| Setting | Default and behaviour |
| --- | --- |
| `systray_urgent_bg`<br />Per-application: `urgent_bg` | **Default:** `nil`.<br />Background while the item needs attention. When set, it takes precedence over the hover background. |
| `systray_urgent_style`<br />Per-application: `urgent_style` | **Default:** `"none"`.<br />`"none"`, `"dot"`, `"ring"` or `"glow"`. See the style table below. |
| `systray_urgent_color`<br />Per-application: `urgent_color` | **Default:** `"#ff3333"`.<br />Indicator colour. |
| `systray_urgent_outline_color`<br />Per-application: `urgent_outline_color` | **Default:** `"#ffffff"`.<br />Outline colour around the dot. Does not set the ring colour. |
| `systray_urgent_position`<br />Per-application: `urgent_position` | **Default:** `"top_right"`.<br />Dot position: `"top_left"`, `"top_right"`, `"bottom_left"` or `"bottom_right"`. |
| `systray_urgent_size`<br />Per-application: `urgent_size` | **Default:** `0.25`.<br />Dot size. Numbers up to `1` are fractions of the icon size; larger numbers are pixels. Minimum 6 pixels in 1.4/2.0. |
| `systray_urgent_shape`<br />Per-application: `urgent_shape` | **Default:** `gears.shape.circle`.<br />Shape function `(cr, width, height)` for the dot and ring. Does not affect `"glow"`. |
| `systray_overlay_triggers_urgent`<br />Per-application: `overlay_triggers_urgent` | **Default:** `false`.<br />Boolean. An application overlay triggers attention styling even if the item status is `Active`. Works when the overlay is hidden. |
| `systray_icon_change_triggers_urgent`<br />Per-application: `icon_change_triggers_urgent` | **Default:** `false`.<br />Boolean. Icon changes away from the recorded baseline trigger attention styling. Useful with a fixed `icon_override`. |

| `systray_urgent_style` | Appearance | Related settings |
| --- | --- | --- |
| `"none"` | No indicator. The attention background can still appear. | `systray_urgent_bg` |
| `"dot"` | Filled shape with a one-pixel outline at a corner. | Colour, outline colour, position, size and shape. |
| `"ring"` | Two-pixel outline around the icon. | Colour and shape. Dot position and size do not apply. |
| `"glow"` | Solid three-pixel border around the icon, without blur. | Colour. |

Icon-change attention clears when the icon returns to its baseline, when the item is activated, or when an explicit `Active` or `NeedsAttention` status arrives. After activation, the next icon becomes the new baseline. These rules do not clear attention caused by `NeedsAttention` or an overlay.

#### Replace a badge with a ring {#badge-to-ring}

This hides the application's overlay image and draws a ring while that overlay is present:

```lua
local beautiful = require("beautiful")

beautiful.systray_show_overlay = false
beautiful.systray_overlay_triggers_urgent = true
beautiful.systray_urgent_style = "ring"
beautiful.systray_urgent_color = "#fabd2f"
```

The ring also appears for `NeedsAttention`. An application must supply an overlay for the overlay trigger to work.

### Application badges {#application-badges}

A badge is the item's overlay image. These settings do not create a badge or notification count. The application must supply the overlay.

| Setting | Default and behaviour |
| --- | --- |
| `systray_show_overlay`<br />Global only | **Default:** `true`.<br />Boolean. Show or hide application overlays. |
| `systray_overlay_position`<br />Per-application: `overlay_position` | **Default:** `"bottom_right"`.<br />`"top_left"`, `"top_right"`, `"bottom_left"` or `"bottom_right"`. |
| `systray_overlay_size`<br />Per-application: `overlay_size` | **Default:** `0.33`.<br />Number. Up to `1`: fraction of the icon size. Above `1`: pixels. Minimum 8 pixels. |
| `systray_overlay_bg`<br />Per-application: `overlay_bg` | **Default:** `nil`.<br />Background behind the overlay. `nil` draws no global background. |
| `systray_overlay_shape`<br />Per-application: `overlay_shape` | **Default:** `"circle"`.<br />`"circle"`, `"rounded_rect"` or `"rect"`. Shapes the background, not the overlay image; has no visible effect without `overlay_bg`. |
| `systray_overlay_padding`<br />Per-application: `overlay_padding` | **Default:** `2`.<br />Padding around the overlay within its background, in pixels. Used only when the background is set. |

`systray_overlay_triggers_urgent` controls whether a badge also triggers [attention styling](#attention-indicators). Hiding the badge does not disable that trigger.

### Per-application styles {#per-application-styles}

`beautiful.systray_icon_style` defaults to `nil`. It accepts either:

- A table mapping an exact `item.id` or `item.app_name` to a style table. The ID match takes precedence; the two matching tables are not merged.
- A function `function(item)` returning a style table. Errors and non-table return values are ignored.

The style table accepts every key labelled **Per-application** above. It does not accept the global-only layout, menu or `systray_show_overlay` settings. 

```lua
local beautiful = require("beautiful")

beautiful.systray_icon_style = {
    ["discord_status_icon_1"] = {
        hover_bg = "#458588",
        urgent_bg = "#cc241d",
        overlay_position = "top_right",
        overlay_triggers_urgent = true,
    },
}
```

The ID is supplied by the tray item, not the window class. [Find tray IDs](../../../guides/customise-systray.md#a-different-colour-for-one-application) shows the inspection command. Assigning another `systray_icon_style` table replaces the previous rules. `false` can disable a per-application boolean trigger even when its global value is `true`.

### Context menus {#context-menus}

These variables style menus SomeWM builds from DBusMenu. They do not style menus drawn by the application itself. All are global-only. A missing systray menu value falls back to the corresponding `beautiful.menu_*` value, then the normal `awful.menu` defaults.

| Setting | Fallback and behaviour |
| --- | --- |
| `systray_menu_fg_normal` | **Fallback:** `beautiful.menu_fg_normal`.<br />Colour of item text. |
| `systray_menu_bg_normal` | **Fallback:** `beautiful.menu_bg_normal`.<br />Menu background colour. |
| `systray_menu_fg_focus` | **Fallback:** `beautiful.menu_fg_focus`.<br />Colour of selected item text. |
| `systray_menu_bg_focus` | **Fallback:** `beautiful.menu_bg_focus`.<br />Selected item background colour. |
| `systray_menu_border_color` | **Fallback:** `beautiful.menu_border_color`.<br />Menu border colour. |
| `systray_menu_border_width` | **Fallback:** `beautiful.menu_border_width`.<br />Number. Border width in pixels. |
| `systray_menu_font` | **Fallback:** `beautiful.menu_font`.<br />Pango font string, such as `"sans 10"`. |
| `systray_menu_width` | **Fallback:** `beautiful.menu_width`.<br />Number. Menu item width in pixels. |
| `systray_menu_height` | **Fallback:** `beautiful.menu_height`.<br />Number. Menu item height in pixels. |
| `systray_menu_callback` | **Fallback:** `nil`.<br />Function `(item, menu_items)` called before a DBusMenu is shown. Can edit `menu_items` or return a replacement table. Returning `nil` keeps the original table, including edits. Errors are ignored. |

## Interaction

Left click activates an item, or opens its menu when the application marks it as a menu. Middle click requests secondary activation. Right click opens its menu. Scroll events are forwarded to the application. The application determines which actions it supports.

[Tray source](https://github.com/trip-zip/somewm/blob/v2.0.1/lua/wibox/widget/systray.lua), [icon styles and menus](https://github.com/trip-zip/somewm/blob/v2.0.1/lua/wibox/widget/systray_icon.lua).
