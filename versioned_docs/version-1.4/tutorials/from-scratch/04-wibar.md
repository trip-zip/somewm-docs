---
title: "Wibar: Our Own Bar"
description: "Replace the stock bar with a wibar factory: named tags with icons, a custom taglist, a centered clock, and a styled systray."
sidebar_label: "04 · Wibar"
---

import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# Wibar: Our Own Bar

<span id="where-we-are" />
<span id="one-bar-per-screen" />
<span id="workspaces-as-data" />
<span id="the-bar-skeleton" />
<span id="a-clock-in-the-actual-middle" />
<span id="the-taglist" />
<span id="the-right-side" />
<span id="try-it" />

<ChapterNav chapter="04" />

Replace the stock bar with icon tags, a clock, and the status widgets from [chapter 03](03-widgets.md). Use the [04-wibar checkpoint](https://github.com/trip-zip/awesome-from-scratch/tree/04-wibar) for the complete taglist module and `rc.lua` edits.

## Name the tags

Replace the nine numbered tags with this table near the top of `rc.lua`:

```lua
-- rc.lua
local tags = {
  { name = "code", icon = "terminal.svg" },
  { name = "web", icon = "chrome.svg" },
  { name = "chat", icon = "slack.svg" },
  { name = "db", icon = "server.svg" },
  { name = "games", icon = "play.svg" },
}
```

In `request::desktop_decoration`, create the tags from that table:

```lua
-- rc.lua, inside request::desktop_decoration
for i, t in ipairs(tags) do
  awful.tag.add(t.name, {
    screen = s,
    layout = awful.layout.layouts[1],
    selected = i == 1,
    icon_name = t.icon,
  })
end
```

`icon_name` is a custom tag property used by the taglist. Remove the stock tag save-and-restore block as shown in the checkpoint. This config recreates tags from the table when a screen appears.

## Build the icon taglist

Add `widgets/taglist.lua` from the checkpoint and export it as `taglist = require("widgets.taglist")` in `widgets/init.lua`.

Each entry has an imagebox with `id = "icon_role"` and a background with `id = "indicator"`. Both `create_callback` and `update_callback` use this function:

```lua
-- widgets/taglist.lua
local update_tag = function(widget, tag, index, taglist)
    local w = widget:get_children_by_id("icon_role")[1]
    local indicator = widget:get_children_by_id("indicator")[1]
    local icon_name = tag.icon_name or "grid.svg"
    local color

    if tag.selected then
      color = beautiful.primary_color
      indicator.bg = beautiful.primary_color
    elseif tag.urgent then
      color = beautiful.bg_urgent
      indicator.bg = beautiful.bg_normal
    elseif #tag:clients() > 0 then
      color = beautiful.active_hover
      indicator.bg = beautiful.bg_normal
    else
      color = beautiful.fg_normal
      indicator.bg = beautiful.bg_normal
    end

    w.image = beautiful.icon(icon_name, color)
  end
```

The selected tag gets the primary colour and an indicator. Urgent and occupied tags get different colours. The callback uses `beautiful.icon` from chapter 03.

The module's buttons select a tag on left-click, toggle it on right-click, and cycle tags on scroll. Holding Mod4 moves or toggles the focused client's tag membership instead.

## Create the bar

Save this as `wibar.lua`:

```lua
-- wibar.lua
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local widgets = require("widgets")
local dpi = require("beautiful.xresources").apply_dpi

return function(s)
  local right = {
    spacing = beautiful.widget_group_spacing,
    layout = wibox.layout.fixed.horizontal,
  }
  if s == screen.primary then
    table.insert(right, {
      {
        {
          wibox.widget.systray(),
          margins = dpi(4),
          widget = wibox.container.margin,
        },
        bg = beautiful.bg_focus,
        shape = beautiful.shape_small,
        widget = wibox.container.background,
      },
      left = dpi(8),
      right = dpi(8),
      top = dpi(4),
      bottom = dpi(4),
      widget = wibox.container.margin,
    })
  end
  table.insert(right, {
    widgets.volume,
    widgets.wifi,
    widgets.battery.widget,
    spacing = beautiful.widget_spacing,
    layout = wibox.layout.fixed.horizontal,
  })

  table.insert(right, {
    {
      s.mylayoutbox,
      forced_height = beautiful.wibar_height * 0.6,
      forced_width = beautiful.wibar_height * 0.6,
      widget = wibox.container.constraint,
    },
    halign = "center",
    valign = "center",
    widget = wibox.container.place,
  })

  local wibar = awful.wibar({
    position = "top",
    screen = s,
    widget = {
      {
        widgets.taglist(s),
        s.mypromptbox,
        spacing = beautiful.widget_group_spacing,
        layout = wibox.layout.fixed.horizontal,
      },
      {
        nil,
        widgets.clock,
        nil,
        expand = "none",
        layout = wibox.layout.align.horizontal,
      },
      right,
      layout = wibox.layout.align.horizontal,
    },
  })
  return wibar
end
```

The function builds one bar per screen. It adds the tray only on the primary screen and uses `table.insert` to keep the right-hand group free of holes.

The outer align layout gives the middle slot the space left between the side groups. Its nested `expand = "none"` centres the clock within that space. To centre on the bar itself, set `expand = "none"` on the outer align layout instead.

## Connect it in rc.lua

Load `local wibar = require("wibar")` after theme initialisation. In the existing `request::desktop_decoration` handler, keep the promptbox and layoutbox setup, then replace the old bar construction with:

```lua
-- rc.lua, inside request::desktop_decoration
s.mywibox = wibar(s)
```

Remove the old tasklist and taglist setup. This bar omits the tasklist. [Chapter 09](09-switcher.md) adds a window switcher.

Reload. Check the five icon tags, clock, status widgets, and layoutbox. Press **Mod4+r** to verify the prompt is visible. Open a client on an empty tag and check that its icon changes colour, then switch tags to check the indicator.

To change spacing, edit `theme.widget_spacing` and `theme.widget_group_spacing`, then reload. The [theme chapter](01-theme.md) defines the bar's height and margins.

![The custom bar with icon tags, clock, and status widgets](/img/from-scratch/04-wibar-final.png)

## Checkpoint

Compare with [the `04-wibar` branch](https://github.com/trip-zip/awesome-from-scratch/tree/04-wibar):

```bash
git diff origin/03-widgets origin/04-wibar
```

Keep your edits on a separate branch before checking out a checkpoint. Use the [nested-session commands](index.md#running-your-work-safely) to test it.

<NextChapter chapter="04" />
