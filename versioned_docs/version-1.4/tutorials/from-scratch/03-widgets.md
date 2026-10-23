---
title: "Widgets: Clock, Volume, Battery, WiFi"
description: "Build clock, volume, battery, and WiFi widgets with shared theme settings and asynchronous updates."
sidebar_label: "03 · Widgets"
---

import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# Widgets: Clock, Volume, Battery, WiFi

<span id="widgets-wrappers-clock-volume-battery-wifi" />
<span id="where-we-are" />
<span id="the-widget-tree" />
<span id="shared-vocabulary-wrapperslua" />
<span id="the-clock-timers" />
<span id="volume-async-reads-and-signals" />
<span id="the-nervous-system" />
<span id="battery-a-widget-with-an-api" />
<span id="parsing-by-key-not-by-line" />
<span id="hiding-when-there-is-no-battery" />
<span id="wifi-nothing-new" />
<span id="wiring-it-into-the-bar" />
<span id="try-it" />

<ChapterNav chapter="03" />

Build status widgets and add them to the stock bar. Start from [chapter 02](02-keybindings.md). The [03-widgets checkpoint](https://github.com/trip-zip/awesome-from-scratch/tree/03-widgets) contains the complete files used below.

## Prepare the theme

Copy the checkpoint's `icons/` directory beside `rc.lua`. In `theme/theme.lua`, add the icon helper after `theme.icon_dir` and the existing `recolor` definition:

```lua
-- theme/theme.lua
local icon_cache = {}
function theme.icon(name, tint)
  tint = tint or theme.fg_normal
  local key = name .. "|" .. tostring(tint)
  if not icon_cache[key] then
    icon_cache[key] = recolor(theme.icon_dir .. "/" .. name, tint)
  end
  return icon_cache[key]
end
```

`beautiful.icon(name, tint)` loads and recolours an image. It caches each name-and-colour pair so repeated updates reuse the surface. With no tint, it uses `theme.fg_normal`.

Before `return theme`, add the shared spacing values:

```lua
-- theme/theme.lua
theme.widget_icon_margins = theme.wibar_height / 4 -- padding above/below an icon
theme.widget_icon_spacing = dpi(4) -- gap between an icon and its own label
theme.widget_spacing = dpi(10) -- gap between neighbouring widgets
theme.widget_group_spacing = theme.wibar_height * 0.5 -- gap between groups in the bar
```

## Build the clock

Create `widgets/clock.lua`:

```lua
-- widgets/clock.lua
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local clock_widget = wibox.widget({
  {
    {
      id = "icon",
      image = beautiful.icon("clock.svg"),
      halign = "center",
      valign = "center",
      widget = wibox.widget.imagebox,
    },
    margins = beautiful.widget_icon_margins,
    widget = wibox.container.margin,
  },
  {
    id = "text",
    widget = wibox.widget.textbox,
  },
  spacing = beautiful.widget_icon_spacing,
  layout = wibox.layout.fixed.horizontal,
})

local function set_clock()
  clock_widget:get_children_by_id("text")[1].text = os.date("%I:%M")
end

gears.timer({
  timeout = 5,
  autostart = true,
  call_now = true,
  callback = set_clock,
})

return clock_widget
```

The imagebox and textbox are children of a horizontal layout. A margin container pads the icon. The `id` fields let update functions find the children later.

The timer fills the text immediately with `call_now`, then updates it every five seconds. `return clock_widget` makes the widget available through `require`.

In `rc.lua`, after theme initialisation, load `local clock = require("widgets.clock")`. Replace `mytextclock` in the bar's right group with `clock`, then reload. You should see the clock icon and time. Change `%I:%M` to `%H:%M` and reload to check 24-hour formatting.

## Read volume asynchronously

Add the checkpoint's `widgets/volume.lua`. It uses the same icon-and-text structure, plus an `awful.tooltip`.

The volume command prefers `pamixer`, then `wpctl`:

```lua
-- widgets/volume.lua
local function get_volume_cmd()
  return [[
    if command -v pamixer >/dev/null 2>&1; then
      pamixer --get-volume
    elif command -v wpctl >/dev/null 2>&1; then
      wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
    else
      echo "0"
    fi
  ]]
end
```

`awful.spawn.easy_async_with_shell` runs the command without blocking the compositor. Its callback parses the reading, updates the text, then reads mute state and selects an icon. If the command returns no usable number, this example displays 0%.

The module reads once on load and refreshes on a custom signal:

```lua
-- widgets/volume.lua
update_volume()

awesome.connect_signal("volume::update", function()
  update_volume()
end)
```

The chapter 02 media bindings emit `volume::update` immediately after spawning `wpctl`. That can race the command, and changes made elsewhere emit no signal. To refresh after a keybinding completes, replace its helper with:

```lua
-- keybindings.lua, inside media_helpers
raise_volume = function()
  awful.spawn.easy_async({ "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+" }, function()
    awesome.emit_signal("volume::update")
  end)
end,
```

Apply the same ordering to lower and mute. Use a timer or an audio-service event listener if the widget must follow changes from other applications. See [widget timers](../../guides/widget-timers.md).

## Share battery readings

Add the checkpoint's `widgets/battery.lua`. It returns a table with a widget and functions:

| Member | Use |
| --- | --- |
| `widget` | Display in the bar |
| `get_status(callback)` | Read percentage, state, and time estimates asynchronously |
| `level_color(percent)` | Choose the theme colour for a charge level |
| `level_icon(percent, charging)` | Choose a battery glyph |

The command reads one battery through `upower`, falling back to `/sys/class/power_supply/BAT*`. Parse labelled fields because time estimates may be absent:

```lua
-- widgets/battery.lua
function M.get_status(cb)
  awful.spawn.easy_async_with_shell(status_cmd, function(stdout)
    stdout = stdout or ""
    local percentage = tonumber(stdout:match("percentage:%s*(%d+)%%"))
    local state = stdout:match("state:%s*([%w%-]+)") or "unknown"
    local charging = state:lower():find("charging") ~= nil and state:lower():find("discharging") == nil

    cb({
      percentage = percentage,
      state = state,
      charging = charging,
      time_to_empty = stdout:match("time to empty:%s*([^\n]-)%s*\n"),
      time_to_full = stdout:match("time to full:%s*([^\n]-)%s*\n"),
    })
  end)
end
```

The module polls every ten seconds and emits `battery::update` with the result. It hides its widget if no percentage is available. Later dashboard and lockscreen modules reuse this API.

## Add WiFi and assemble the bar

Add `widgets/wifi.lua` from the checkpoint. It reads the first wireless interface through `iw`, falling back to `iwgetid`, every 60 seconds. With no connection, it shows a disconnected icon. Its shell parser trims and collapses whitespace in SSIDs.

Create `widgets/init.lua`:

```lua
-- widgets/init.lua
return {
  battery = require("widgets.battery"),
  clock = require("widgets.clock"),
  volume = require("widgets.volume"),
  wifi = require("widgets.wifi"),
}
```

Replace the temporary clock import in `rc.lua` with `local widgets = require("widgets")`, after theme initialisation. In the bar's right group, replace `clock` with:

```lua
-- rc.lua, inside the right-hand widget group
widgets.volume,
widgets.wifi,
widgets.battery.widget,
widgets.clock,
```

Reload. Check the clock, volume tooltip, SSID, and battery percentage if available. Use `widgets.battery.widget` here because `widgets.battery` is the module table.

![The stock bar with volume, WiFi, battery, and clock widgets](/img/from-scratch/03-widgets-bar.png)

## Checkpoint

Compare with [the `03-widgets` branch](https://github.com/trip-zip/awesome-from-scratch/tree/03-widgets):

```bash
git diff origin/02-keybindings origin/03-widgets
```

Keep your edits on a separate branch before checking out a checkpoint. Use the [nested-session commands](index.md#running-your-work-safely) to test it.

<NextChapter chapter="03" />
