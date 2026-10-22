---
title: "Widgets: Wrappers, Clock, Volume, Battery, WiFi"
description: "Build the widget system: the wibox widget tree, shared wrapper helpers, timers, async shell reads, and custom signals."
sidebar_label: "03 · Widgets"
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import ChapterNav from '@site/src/components/FromScratch/ChapterNav';
import NextChapter from '@site/src/components/FromScratch/NextChapter';

# Widgets: Wrappers, Clock, Volume, Battery, WiFi

<ChapterNav chapter="03" />

<YouWillLearn>

- How the wibox widget tree works: leaf widgets, containers, and layouts composed declaratively
- Shared helpers for icons and labels
- How to poll system state without freezing the compositor, using `gears.timer` and `awful.spawn.easy_async_with_shell`
- Updating widgets from keybindings through signals
- Why the battery widget exports an API instead of just a widget

</YouWillLearn>

## Where We Are

Build clock, volume, battery, and WiFi widgets and add them to the stock bar. [Chapter 04](./04-wibar.md) replaces the bar itself.

To catch up: `git checkout 02-keybindings`.

## The Widget Tree

Everything you see in an AwesomeWM bar, popup, or notification is built from **widgets**, and every widget is one of three kinds:

- **Leaf widgets** draw actual content. `wibox.widget.textbox` draws text, `wibox.widget.imagebox` draws an image. They have no children.
- **Containers** wrap exactly one child and change how it is drawn: `wibox.container.margin` adds space around it, `wibox.container.background` paints a color behind it and can clip it to a shape.
- **Layouts** arrange multiple children: `wibox.layout.fixed.horizontal` places them in a row, each taking its natural width.

You compose these into a tree, and you do it **declaratively**: instead of constructing objects and calling `add()` on them, you pass `wibox.widget()` a nested table describing the whole tree. Each table level names its own type with a `widget = ...` key (for leaves and containers) or a `layout = ...` key (for layouts), and any array-part entries become children. Every other key is set as a property on that widget.

## Shared helpers: wrappers.lua {#shared-vocabulary-wrapperslua}

Create the shared helpers in `widgets/wrappers.lua`.

The first helper turns an SVG file into an icon that matches the theme:

```lua
-- widgets/wrappers.lua
M.image_widget = function(image, color, hover_color)
  local widget = wibox.widget({
    image = recolor(beautiful.icon_dir .. image, color),
    widget = wibox.widget.imagebox,
    halign = "center",
    valign = "center",
  })
  widget:connect_signal("mouse::enter", function(c)
    c.image = recolor(beautiful.icon_dir .. image, hover_color or color)
  end)
  widget:connect_signal("mouse::leave", function(c)
    c.image = recolor(beautiful.icon_dir .. image, color)
  end)
  return widget
end
```

`recolor` is `gears.color.recolor_image`: it takes an image path and a colour and returns the tinted image. The SVGs are in `icons/`.

Signals are named events. Attach handlers with `connect_signal`. Here, `mouse::enter` and `mouse::leave` change the icon colour; each handler receives the widget as `c`.

The second helper is the shape almost every bar widget takes, an icon with a text label next to it:

```lua
-- widgets/wrappers.lua
M.icon_with_text = function(w, text)
  return wibox.widget({
    {
      w,
      margins = {
        top = beautiful.wibar_height / 4,
        bottom = beautiful.wibar_height / 4,
      },
      widget = wibox.container.margin,
    },
    {
      id = "text",
      text = text,
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.horizontal,
  })
end
```

`get_children_by_id("text")` returns a list of widgets with `id = "text"`. Use `widget:get_children_by_id("text")[1]` to update this textbox later.

The last helper is a spacer for the bar:

```lua
-- widgets/wrappers.lua
M.vertical_separator = function(width)
  return wibox.widget({
    bg = beautiful.bg_normal,
    forced_width = width,
    widget = wibox.container.background,
  })
end
```

A background container without a child is a coloured block. `forced_width` sets its width. The file also includes a `square_icon` helper for an icon on a coloured background.

## The Clock: Timers

Create `widgets/clock.lua`:

```lua
-- widgets/clock.lua
local clock = wrappers.image_widget("/clock.svg", beautiful.fg_normal)
local clock_widget = wrappers.icon_with_text(clock)

local set_clock = function()
  local time = " " .. os.date("%I:%M")
  local tbox = clock_widget:get_children_by_id("text")[1]
  tbox.text = time
end
```

Call `set_clock` on a timer:

```lua
-- widgets/clock.lua
gears.timer({
  timeout = 5,
  autostart = true,
  call_now = true,
  callback = function()
    set_clock()
  end,
})

return clock_widget
```

A **timer** runs its callback every `timeout` seconds. `autostart` starts it on creation; `call_now` also runs the callback immediately. Return the widget so the bar can load it with `require("widgets.clock")`.

## Volume: Async Reads and Signals

Use `awful.spawn.easy_async_with_shell(cmd, callback)` to read the volume without blocking the compositor. The callback receives the output when the command finishes. A blocking call such as `io.popen("wpctl ..."):read()` freezes the session until it returns.

Use `pamixer` or `wpctl`, depending on which is installed:

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

`pamixer` prints an integer; `awk` converts `wpctl` output such as `Volume: 0.45` to the same format. `get_mute_cmd()` handles mute state similarly.

Attach a tooltip:

```lua
-- widgets/volume.lua
volume_widget.tooltip = awful.tooltip({
  objects = { volume_widget },
})
```

`awful.tooltip` creates a small hover popup and attaches it to every widget in `objects`; setting its `text` property later changes what it shows. Now the update function:

```lua
-- widgets/volume.lua
local function update_volume()
  awful.spawn.easy_async_with_shell(get_volume_cmd(), function(vol)
    -- INFO: This stdout contains a \n character that messes up how the tooltip looks.
    local vol_string = string.gsub(vol, "\n", "")

    -- If there is no audio sink at all (a VM, a nested test instance, a machine with
    -- PipeWire down) the command above prints nothing, and tonumber gives back nil.
    -- Every comparison below would then throw, so pin it to a number here.
    local volume_level = tonumber(vol_string) or 0

    local tbox = volume_widget:get_children_by_id("text")[1]
    volume_widget.tooltip.text = " " .. volume_level .. "%"
    tbox.text = " " .. volume_level .. "%"
```

The rest of the callback reads mute state with `get_mute_cmd()` and selects a muted, low, medium, or high volume icon. The complete function is in the checkpoint branch.

### Updating on a signal {#the-nervous-system}

The media helpers from chapter 02 emit `volume::update`:

```lua
-- keybindings.lua
local media_helpers = {
  raise_volume = function()
    awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
    awesome.emit_signal("volume::update")
  end,
```

`volume::update` is a custom signal. It passes no arguments; the widget reads the volume when it receives the signal.

On the other end, the widget subscribes:

```lua
-- widgets/volume.lua
update_volume()

awesome.connect_signal("volume::update", function()
  update_volume()
end)
```

The initial `update_volume()` call sets the display before any signal arrives.

## Battery: A Widget With an API

The battery module returns a table:

```lua
-- widgets/battery.lua
-- The one battery implementation in this config. The wibar shows M.widget;
-- the dashboard profile and the lockscreen call M.get_status() and share the
-- same thresholds through M.level_color() / M.level_icon(), so all three
-- always agree about what the battery is doing.
local M = {}
```

The bar uses `M.widget`. The dashboard in [chapter 11](./11-dashboard.md) and lockscreen in [chapter 12](./12-lockscreen.md) use `M.get_status(cb)`, `M.level_color(percent)`, and `M.level_icon(percent, charging)`.

### Parsing by Key, Not by Line

Read labelled fields from one battery. `upower -e | grep BAT` can match several devices, so the shell command selects one with `head -n1`. Parse by label: fully charged batteries omit time estimates, which changes the line order.

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

Missing fields return `nil`. Check both `charging` and `discharging`, since the latter contains the former. `status_cmd` uses `upower` when available, otherwise `/sys/class/power_supply/BAT*`, with the same labels for both.

Define the colour thresholds:

```lua
-- widgets/battery.lua
function M.level_color(percent)
  if percent > 50 then
    return beautiful.active_hover
  elseif percent > 20 then
    return beautiful.accent_hover
  else
    return beautiful.urgent_hover
  end
end
```

All battery displays use these thresholds. `M.level_icon` selects a battery glyph, or the charging glyph when charging.

### Hiding When There Is No Battery

The bar widget polls every 10 seconds. Emit the result for other displays and hide the widget when no battery is found:

```lua
-- widgets/battery.lua
local function update()
  M.get_status(function(status)
    -- Broadcast for every other battery display (the dashboard profile
    -- listens), so the whole config shares this one 10-second poll
    awesome.emit_signal("battery::update", status)

    -- No percentage means no battery: hide the widget rather than parking a
    -- permanent "N/A" in the bar.
    if not status.percentage then
      M.widget.visible = false
      return
    end
    M.widget.visible = true
```

`battery::update` passes the `status` table so other displays can reuse the reading. A widget with `visible = false` takes no layout space. The rest of `update()` sets the percentage, icon, and time estimate tooltip.

## WiFi {#wifi-nothing-new}

`widgets/wifi.lua` reads the SSID with `iw` or `iwgetid` every 60 seconds, then updates its textbox, tooltip, and icon:

```lua
-- widgets/wifi.lua
    if string.find(ssid, "Not connected") or ssid == "" then
      wifi.image = recolor(beautiful.icon_dir .. "/wifi-off.svg", icon_color)
    else
      wifi.image = recolor(beautiful.icon_dir .. "/wifi.svg", icon_color)
    end
```

## Wiring It Into the Bar

`widgets/init.lua` makes the folder importable as one module. Lua resolves `require("widgets")` to `widgets/init.lua`, which just aggregates:

```lua
-- widgets/init.lua
return {
  battery = require("widgets.battery"),
  clock = require("widgets.clock"),
  volume = require("widgets.volume"),
  wifi = require("widgets.wifi"),
  wrappers = require("widgets.wrappers"),
}
```

Then the only change to `rc.lua` is requiring that table and swapping the stock text clock for our widgets in the bar's right section:

```lua
-- rc.lua
        layout = wibox.layout.fixed.horizontal,
        mykeyboardlayout,
        wibox.widget.systray(),
        widgets.volume,
        widgets.wifi,
        widgets.battery.widget,
        widgets.clock,
        s.mylayoutbox,
```

Use `widgets.battery.widget` in the bar. `widgets.battery` is the module table, not a widget.

Reload with `Mod4+Ctrl+R` and the stock bar now shows live volume, your SSID, battery percentage if you have one, and the clock. Tap a volume key and watch the number move instantly. Hover the widgets for tooltips.

## Try It

1. **Make the clock 24-hour.** One `os.date` format change in `widgets/clock.lua`. While you are in there, give the clock a tooltip (`awful.tooltip`, exactly like volume's) showing the full date on hover.
2. **Put signal strength in the WiFi tooltip.** `iw dev <interface> link` also prints a `signal: -52 dBm` line. Extend the shell command to keep it, parse it by key, and append it to the tooltip text after the SSID.

![The stock bar carrying the new volume, wifi, battery, and clock widgets](/img/from-scratch/03-widgets-bar.png)

## Checkpoint

The finished code for this chapter is on [the `03-widgets` branch](https://github.com/trip-zip/awesome-from-scratch/tree/03-widgets).

```bash
git checkout 03-widgets
somewm-client test start --config "$PWD/rc.lua" --name afs
```

Compare your work: `git diff 02-keybindings 03-widgets`

<NextChapter chapter="03" />
