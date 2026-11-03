---
title: wibox.widget.systray
description: Systray styling options, theme variables, per-application overrides and version limits.
---

import WidgetSource from "@site/src/components/WidgetSource";
import FigureLua from "../_lua/widget-systray.mdx";

# wibox.widget.systray

Shows the icons that applications publish over StatusNotifierItem, the D-Bus tray protocol. There is one systray per session: every call to the constructor returns the same widget, so its settings are shared across bars. Applications that only speak XEmbed do not appear; see [Wayland vs X11](../../../concepts/wayland-vs-x11.md).

## Styling options

| Appearance | Settings | Available choices |
| --- | --- | --- |
| [Size and layout](#properties) | `base_size`, `horizontal`, `reverse` | Icon size in pixels, row or column, reversed order. |
| [Tray background and spacing](#tray-layout) | `bg_systray`, `systray_icon_spacing`, `systray_paddings`, `systray_max_rows` | Background, gaps, outer padding. One row; larger `systray_max_rows` values are not applied. |
| [Icon image](#icon-images) | `icon_theme`, per-application `icon_override` | Icon-theme lookup. `icon_override` is not applied in this version. |
| [Hover](#hover) | `systray_hover_bg`, `systray_hover_scale` | Background. Hover scaling is not applied in this version. |
| [Attention](#attention-indicators) | `systray_urgent_bg`, `systray_urgent_style` | Background. Dot, ring and glow indicators are not rendered in this version. |
| [Application badges](#application-badges) | `systray_show_overlay`, `systray_overlay_*` | Show or hide; size; four corners; circle, rounded rectangle or rectangular background. |
| [Per-application styles](#per-application-styles) | `systray_icon_style` | Exact ID/name rules or a function that returns a style table. |
| [Context menus](#context-menus) | `systray_menu_*` | Colours, border, font, dimensions and a callback to change menu entries. |

A **badge** is an overlay image supplied by the application. An **attention indicator** is a dot, ring or border drawn by SomeWM. They have separate settings. This version can use a badge to trigger an attention background, but cannot replace it with a ring.

For screenshots and complete examples, see [Customise the systray](../../../guides/customise-systray.md).

![The session's tray: two icons at 32 pixels](/img/reference/wibox/widget-systray.png)

The row is the session's own tray. What it shows depends on what is running.

<WidgetSource>

Save this as `/tmp/widget-systray.lua`, then run:

```sh
somewm-client eval 'dofile("/tmp/widget-systray.lua")'
```

It opens the figure on your focused screen and closes after two minutes. The figure shows the tray of the session it runs on.

<FigureLua />

[Download the Lua file](/img/reference/wibox/widget-systray.lua). To close it early:

```sh
somewm-client eval 'if somewm_reference_figure then somewm_reference_figure.stop() end'
```

</WidgetSource>

Constructor: `wibox.widget.systray(reverse)`, returning the one instance. [Upstream page](https://awesomewm.org/apidoc/widgets/wibox.widget.systray.html).

```lua
local tray = wibox.widget.systray()
tray.base_size = 20
```

## Properties

| Property | Type | Default | What it does | In SomeWM |
| --- | --- | --- | --- | --- |
| `base_size` | integer or nil | `nil` | Icon size in pixels. `nil` uses 24 pixels. | |
| `horizontal` | boolean | `true` | Icons in a row, or in a column. | |
| `reverse` | boolean | `false` | Reverses the item order. | |
| `screen` | screen, `"primary"` or nil | `"primary"` | Stores the requested screen. | Does not filter the rendered icons by screen. |

For a tray on one monitor, include the widget only in that monitor's bar.

Setting a property emits `property::<name>`. The properties belong to the one instance, so the last value set wins wherever it was set.

## Theme variables

These names are fields on `beautiful`, for example `beautiful.systray_hover_bg = "#458588"`. Defaults below apply when the theme does not supply a value. Theme settings normally go after `beautiful.init(...)` and before bar creation.

Each setting lists its theme variable and, where supported, its **Per-application** key inside `systray_icon_style`. An omitted field inherits its theme variable. Settings marked **Global only** cannot be overridden through that table.

Tray, hover, attention and overlay backgrounds accept solid colours and gradients. Other Cairo patterns warn once and render transparent.

### Tray layout {#tray-layout}

| Setting | Default and behaviour |
| --- | --- |
| `bg_systray`<br />Global only | **Default:** `nil`.<br />Tray background. Accepts a solid colour or gradient. Other patterns warn once and render transparent. |
| `systray_icon_spacing`<br />Global only | **Default:** `0`.<br />Integer gap between icons, in pixels. |
| `systray_paddings`<br />Global only | **Default:** `0`.<br />Integer outer padding on all sides, in pixels. |
| `systray_max_rows`<br />Global only | **Default:** `1`.<br />Positive integer. Values above `1` warn once and still render as one row. |

### Icon images {#icon-images}

| Setting | Default and behaviour |
| --- | --- |
| `icon_theme`<br />Global only | **Default:** `"hicolor"`.<br />Icon-theme name used for icon-name lookup. Application pixmaps and icons found in the application's own icon directory take precedence. |
| `icon_override`<br />Per-application only | **Default:** `nil`.<br />**Not applied in this version.** In 1.4 and 2.0 this accepts a replacement image path or icon-theme name. |

### Hover {#hover}

| Setting | Default and behaviour |
| --- | --- |
| `systray_hover_bg`<br />Per-application: `hover_bg` | **Default:** `nil`.<br />Background while the pointer is over the icon. `nil` means no global hover background. |
| `systray_hover_scale`<br />Per-application: `hover_scale` | **Default:** `1.0`.<br />**Not applied in this version.** Values other than `1` warn once when hovered. |

### Attention indicators {#attention-indicators}

Attention styling appears when the item reports `NeedsAttention`. `systray_overlay_triggers_urgent` can also trigger it while an application overlay is present. Only the attention background is rendered in this version.

| Setting | Default and behaviour |
| --- | --- |
| `systray_urgent_bg`<br />Per-application: `urgent_bg` | **Default:** `nil`.<br />Background while the item needs attention. When set, it takes precedence over the hover background. |
| `systray_urgent_style`<br />Per-application: `urgent_style` | **Default:** `"none"`.<br />**Not rendered in this version.** The declared choices `"none"`, `"dot"`, `"ring"` and `"glow"` apply to 1.4 and 2.0. |
| `systray_urgent_color`<br />Per-application: `urgent_color` | **Default:** `"#ff3333"`.<br />**Not applied in this version.** Indicator colour. |
| `systray_urgent_outline_color`<br />Per-application: `urgent_outline_color` | **Default:** `"#ffffff"`.<br />**Not applied in this version.** Outline colour around the dot. Does not set the ring colour. |
| `systray_urgent_position`<br />Per-application: `urgent_position` | **Default:** `"top_right"`.<br />**Not applied in this version.** Dot position: `"top_left"`, `"top_right"`, `"bottom_left"` or `"bottom_right"`. |
| `systray_urgent_size`<br />Per-application: `urgent_size` | **Default:** `0.25`.<br />**Not applied in this version.** Dot size. Numbers up to `1` are fractions of the icon size; larger numbers are pixels. Minimum 6 pixels in 1.4/2.0. |
| `systray_urgent_shape`<br />Per-application: `urgent_shape` | **Default:** `gears.shape.circle`.<br />**Not applied in this version.** Shape function `(cr, width, height)` for the dot and ring. Does not affect `"glow"`. |
| `systray_overlay_triggers_urgent`<br />Per-application: `overlay_triggers_urgent` | **Default:** `false`.<br />Boolean. An application overlay triggers attention styling even if the item status is `Active`. Works when the overlay is hidden. |
| `systray_icon_change_triggers_urgent`<br />Per-application: `icon_change_triggers_urgent` | **Default:** `false`.<br />**Not applied in this version.** Icon changes do not trigger attention styling. |

`systray_show_overlay = false` hides the badge. Combined with `systray_overlay_triggers_urgent = true` and `systray_urgent_bg`, the badge can trigger a background instead. Setting `systray_urgent_style = "ring"` has no effect in this version.

### Application badges {#application-badges}

A badge is the item's overlay image. These settings do not create a badge or notification count. The application must supply the overlay.

| Setting | Default and behaviour |
| --- | --- |
| `systray_show_overlay`<br />Global only | **Default:** `true`.<br />Boolean. Show or hide application overlays. |
| `systray_overlay_position`<br />Per-application: `overlay_position` | **Default:** `"bottom_right"`.<br />`"top_left"`, `"top_right"`, `"bottom_left"` or `"bottom_right"`. |
| `systray_overlay_size`<br />Per-application: `overlay_size` | **Default:** `0.33`.<br />Number. Up to `1`: fraction of the icon size. Above `1`: pixels. Rounded to whole pixels. |
| `systray_overlay_bg`<br />Per-application: `overlay_bg` | **Default:** `nil`.<br />Background behind the overlay. `nil` draws no global background. |
| `systray_overlay_shape`<br />Per-application: `overlay_shape` | **Default:** `"circle"`.<br />`"circle"`, `"rounded_rect"` or `"rect"`. Shapes the background, not the overlay image; has no visible effect without `overlay_bg`. |
| `systray_overlay_padding`<br />Per-application: `overlay_padding` | **Default:** `2`.<br />Padding around the overlay within its background, in pixels. Used only when the background is set. |

`systray_overlay_triggers_urgent` controls whether a badge also triggers [attention styling](#attention-indicators). Hiding the badge does not disable that trigger.

### Per-application styles {#per-application-styles}

`beautiful.systray_icon_style` defaults to `nil`. It accepts either:

- A table mapping an exact `item.id` or `item.app_name` to a style table. The ID match takes precedence; the two matching tables are not merged.
- A function `function(item)` returning a style table. Errors and non-table return values are ignored.

The style table accepts every key labelled **Per-application** above. It does not accept the global-only layout, menu or `systray_show_overlay` settings. Fields marked **Not applied** or **Not rendered** remain ineffective inside a per-application rule.

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

Gone in SomeWM 2.1: `awesome.systray`, the C entry point. `wibox.widget.systray_icon` is the per-item widget the tray lays out.

The [common properties, methods and signals](../common.md) apply.

[Tray source](https://github.com/trip-zip/somewm/blob/main/lua/wibox/widget/systray.lua), [icon styles and menus](https://github.com/trip-zip/somewm/blob/main/lua/wibox/widget/systray_icon.lua), [renderer](https://github.com/trip-zip/somewm/blob/main/lua/wibox/clay.lua).
