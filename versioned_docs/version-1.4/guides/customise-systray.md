---
title: Customise the systray
description: Systray effects with screenshots and complete configuration examples.
---

# Customise the systray

Each example configures the shared `wibox.widget.systray` widget independently. Theme settings go after `beautiful.init(...)` in `rc.lua`.

## Small icons

16-pixel icons with 4 pixels between them and 2 pixels of outer padding.

<img src="/img/guides/systray/spacing.png" alt="Slack, Discord and 1Password tray icons at 16 pixels, with four pixels between them." width="120" height="64" style={{imageRendering: 'pixelated'}} />

```lua
local beautiful = require("beautiful")
local wibox = require("wibox")

beautiful.bg_systray = "#282828"
beautiful.systray_icon_spacing = 4
beautiful.systray_paddings = 2
wibox.widget.systray.set_base_size(16)
```

## Hover background

A teal background behind the icon under the pointer.

<img src="/img/guides/systray/hover.png" alt="The 16-pixel tray icons with a teal background behind Discord in its hover state." width="120" height="64" style={{imageRendering: 'pixelated'}} />

```lua
local beautiful = require("beautiful")
local wibox = require("wibox")

beautiful.bg_systray = "#282828"
beautiful.systray_icon_spacing = 4
beautiful.systray_paddings = 2
beautiful.systray_hover_bg = "#458588"
wibox.widget.systray.set_base_size(16)
```

Both screenshots show these spacing and hover settings on a live 2.1.1 tray at 2× size.

## Attention highlight

The rightmost item reports `NeedsAttention` and gets a red background.

| Active | NeedsAttention |
| --- | --- |
| <img src="/img/guides/systray/attention-normal.png" alt="The demo tray item without an attention background." width="160" height="64" style={{imageRendering: 'pixelated'}} /> | <img src="/img/guides/systray/attention.png" alt="The demo tray item with a red attention background." width="160" height="64" style={{imageRendering: 'pixelated'}} /> |

```lua
local beautiful = require("beautiful")
local wibox = require("wibox")

beautiful.bg_systray = "#282828"
beautiful.systray_icon_spacing = 4
beautiful.systray_paddings = 2
beautiful.systray_urgent_bg = "#cc241d"
wibox.widget.systray.set_base_size(16)
```

The application controls its status. Captured on 2.1.1 with a temporary StatusNotifierItem reporting `Active`, then `NeedsAttention`.

## A different colour for one application

Discord gets a teal hover background and a red background when it reports `NeedsAttention`.

```lua
local beautiful = require("beautiful")

beautiful.systray_icon_style = {
    ["discord_status_icon_1"] = {
        hover_bg = "#458588",
        urgent_bg = "#cc241d",
    },
}
```

The key is the application's exact tray ID. Keep application rules in one `systray_icon_style` table; assigning another table replaces the previous rules.

<details>
<summary>Find tray IDs</summary>

```sh
somewm-client eval '
local ids = {}
for _, item in ipairs(systray_item.get_items()) do
    ids[#ids + 1] = item.id
end
return table.concat(ids, "\n")
'
```

</details>

## A custom icon

Discord uses this replacement PNG. Its clicks, scrolling and menus still work.

<img src="/img/guides/systray/custom-chat.png" alt="An orange speech bubble with two dark lines." width="64" height="64" style={{imageRendering: 'pixelated'}} />

Save the [PNG](/img/guides/systray/custom-chat.png) as `icons/discord.png` in your SomeWM configuration directory.

```lua
local beautiful = require("beautiful")
local gears = require("gears")

beautiful.systray_icon_style = {
    ["discord_status_icon_1"] = {
        icon_override = gears.filesystem.get_configuration_dir() .. "icons/discord.png",
    },
}
```

The PNG must exist. An unreadable replacement falls back to the application's icon. Add any per-application colours to this same rule.

## An attention dot

A yellow dot at the top right when an application reports `NeedsAttention`.

```lua
local beautiful = require("beautiful")

beautiful.systray_urgent_style = "dot"
beautiful.systray_urgent_color = "#fabd2f"
beautiful.systray_urgent_position = "top_right"
beautiful.systray_urgent_size = 0.25
```

Use `"ring"` for an outline or `"glow"` for a solid border.

## Larger icons on hover

The icon grows by 10% while the pointer is over it.

```lua
local beautiful = require("beautiful")

beautiful.systray_hover_scale = 1.1
```

The size changes immediately, without animation. Large values can clip at the icon's edge.

## An application badge

An application-supplied overlay at the top right, at 40% of the icon size, with a dark circular background.

```lua
local beautiful = require("beautiful")

beautiful.systray_show_overlay = true
beautiful.systray_overlay_position = "top_right"
beautiful.systray_overlay_size = 0.4
beautiful.systray_overlay_bg = "#282828"
beautiful.systray_overlay_shape = "circle"
```

This requires the application to supply an overlay. It does not create a badge or notification count.

See [all systray styling options](../reference/wibox/widget/systray.md#styling-options) for accepted values, defaults and per-application fields.
