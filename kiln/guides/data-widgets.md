---
title: Data Widgets
description: Feed the kiln.widgets form widgets from kiln.spawn.watch, and build the bespoke ones (a history graph) from plain boxes when the stock widgets do not fit.
sidebar_position: 15
---

# Data Widgets

kiln has no canvas or drawing API, and bar meters do not need one. The standard forms (a progress bar, a slider, a toggle) ship on [`kiln.widgets`](/kiln/reference/widgets) as controlled widgets: your config owns the value, the widget draws it. The data lives in plain Lua variables; a shell command polled by `kiln.spawn.watch` updates them and marks the screen dirty, and the next frame declares the new numbers. When no stock widget matches the shape you want, it is boxes all the way down, and the history graph below shows that path.

Snippets assume the standard config preamble:

```lua
local kiln = require("kiln")
local ui = kiln.ui
local widgets = kiln.widgets
local th = kiln.theme
```

:::note
Widget state is ordinary Lua. Changing a local variable draws nothing by itself; call `kiln.dirty()` after every update so the next frame renders it. See [frames and dirty](/kiln/concepts/frames-and-dirty).
:::

## Feeding data: kiln.spawn.watch

`kiln.spawn.watch(cmd, interval, cb)` runs a command, feeds each output line to your callback, and re-runs it `interval` seconds after it exits. A memory fraction, polled every 5 seconds:

```lua
local mem = 0

kiln.spawn.watch("free -b", 5, function(line)
  local total, used = line:match("^Mem:%s+(%d+)%s+(%d+)")
  if total ~= nil then
    mem = tonumber(used) / tonumber(total)
    kiln.dirty()
  end
end)
```

The returned handle has a `:stop()` if you ever need to cancel the poll.

## A progress bar

`widgets.progress` is the track-and-fill pair, drawn from whatever `value` you pass:

```lua
-- inside the bar function:
widgets.progress({ id = "mem-bar", value = mem, w = 120 })
```

Underneath it is exactly two boxes, an outer track and an inner fill sized as a fraction of it, which matters when you outgrow it: the [reference](/kiln/reference/widgets#form-widgets) lists its cfg, and the history graph below is what building a shape the stock widgets lack looks like.

## A history graph

There is no stock graph, and this is the bespoke path. A graph is a row of thin grow boxes whose heights come from a ring buffer. Give each sample a monotonic sequence number so its identity is stable as it slides left, and declare the row through `ui.each`, keyed by that number:

```lua
local cpu_hist, cpu_seq = {}, 0
local prev_idle, prev_total
local SAMPLES = 30

kiln.spawn.watch("head -1 /proc/stat", 2, function(line)
  local n = {}
  for v in line:gmatch("%d+") do n[#n + 1] = tonumber(v) end
  local idle, total = n[4] + (n[5] or 0), 0
  for _, v in ipairs(n) do total = total + v end
  if prev_total ~= nil and total > prev_total then
    cpu_seq = cpu_seq + 1
    cpu_hist[#cpu_hist + 1] = {
      seq = cpu_seq,
      value = 1 - (idle - prev_idle) / (total - prev_total),
    }
    if #cpu_hist > SAMPLES then table.remove(cpu_hist, 1) end
    kiln.dirty()
  end
  prev_idle, prev_total = idle, total
end)

local function cpu_graph(id, height)
  ui.row({
    id = id, w = SAMPLES * 4, h = height, gap = 1,
    align = { y = "bottom" }, color = th.bg2, radius = 3,
  }, function()
    ui.each(cpu_hist, function(sample)
      return "cpu-sample:" .. sample.seq
    end, function(sample, sid)
      ui.box({
        id = sid, w = "grow",
        h = math.max(1, math.floor(sample.value * height)),
        color = th.accent,
      })
    end)
  end)
end
```

`align = { y = "bottom" }` pins the columns to the baseline, so they rise like a bar chart. `ui.each` derives each column's id from the sample's own key, never from its array position, which is the rule for any dynamic list.

## A slider

`widgets.slider` is a progress bar that writes back: press or drag anywhere on the track and `changed` receives the new 0 to 1 value. The drag is a mousegrabber the widget manages, reading the track's solved box through `core.box`, and it ends on the release of the button that started it. Wired to volume:

```lua
local vol = 0.5

-- inside the bar function:
widgets.slider({ id = "vol-slider", w = 100, value = vol,
  changed = function(f)
    vol = f
    kiln.spawn(string.format(
      "wpctl set-volume @DEFAULT_AUDIO_SINK@ %d%%",
      math.floor(f * 100 + 0.5)))
  end })
```

The slider holds no copy of the value: it draws `value` and reports through `changed`, so the fill is honest the frame after your variable changes and never before. To keep it honest against volume changed elsewhere, add a `kiln.spawn.watch` on `wpctl get-volume @DEFAULT_AUDIO_SINK@` that parses the number back into `vol`.

## A toggle

`widgets.toggle` is the same contract for a boolean: `on` in, `press` out. Do-not-disturb, backed by the notification module's own switch:

```lua
-- inside the bar function:
widgets.toggle({ id = "dnd-toggle",
  on = notification.suspended,
  press = function()
    notification.suspended = not notification.suspended
    kiln.dirty()
  end })
```

Any boolean works the same way: draw from the state, flip in `press`, dirty.

## Complete example

The meters assembled into a bar. The watchers and helpers above sit at the top level of your config; the bar function only declares:

```lua
screen.on("added", function(s)
  tag.new { name = "main", screen = s }

  ui.bar(s, { edge = "top", h = 28, color = th.bg }, function()
    widgets.taglist(s)
    ui.spacer()
    ui.text("cpu", { size = 12, color = th.muted })
    cpu_graph("cpu-graph", 18)
    ui.text("mem", { size = 12, color = th.muted })
    widgets.progress({ id = "mem-bar", value = mem, w = 120 })
    ui.text("vol", { size = 12, color = th.muted })
    widgets.slider({ id = "vol-slider", w = 100, value = vol,
      changed = function(f)
        vol = f
        kiln.spawn(string.format(
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ %d%%",
          math.floor(f * 100 + 0.5)))
      end })
    widgets.toggle({ id = "dnd-toggle",
      on = notification.suspended,
      press = function()
        notification.suspended = not notification.suspended
        kiln.dirty()
      end })
    widgets.clock()
  end)
end)
```

## See also

- [Widgets tutorial](/kiln/tutorials/widgets)
- [kiln.widgets reference](/kiln/reference/widgets)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [kiln reference](/kiln/reference/kiln), for `spawn.watch`, `spawn.pipe`, and the grabbers
