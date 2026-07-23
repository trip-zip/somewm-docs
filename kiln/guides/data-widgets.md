---
title: Data Widgets
description: Progress bars, history graphs, sliders, and toggles built from plain boxes and fed by some.spawn.watch.
sidebar_position: 14
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Data Widgets

<YouWillLearn>

- A progress bar from two boxes and percent sizing
- A history graph from a ring buffer and `ui.each`
- A slider driven by `on_press`, `on_scroll`, and `some.mousegrabber`
- A checkbox from a bordered box and `on_press`
- Feeding all of them from `some.spawn.watch`

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui = some.ui
local th = some.theme
```

kiln has no canvas or drawing API, and bar meters do not need one. A meter is boxes: fixed and grow sizing, percent widths, colors, and handlers. The data lives in plain Lua variables; a shell command polled by `some.spawn.watch` updates them and marks the screen dirty, and the next frame declares the new numbers.

:::note
Widget state is ordinary Lua. Changing a local variable draws nothing by itself; call `some.dirty()` after every update so the next frame renders it. See [frames and dirty](/kiln/concepts/frames-and-dirty).
:::

## Feeding data: some.spawn.watch

`some.spawn.watch(cmd, interval, cb)` runs a command, feeds each output line to your callback, and re-runs it `interval` seconds after it exits. A memory fraction, polled every 5 seconds:

```lua
local mem = 0

some.spawn.watch("free -b", 5, function(line)
  local total, used = line:match("^Mem:%s+(%d+)%s+(%d+)")
  if total ~= nil then
    mem = tonumber(used) / tonumber(total)
    some.dirty()
  end
end)
```

The returned handle has a `:stop()` if you ever need to cancel the poll.

## A progress bar

Two boxes: an outer track with a fixed width, and an inner fill sized as a percentage of it. The `"N%"` sizing form does the arithmetic:

```lua
local function progressbar(id, fraction, width)
  ui.box({
    id = id, w = width, h = 8,
    color = th.bg2, radius = 4,
    align = { y = "center" },
  }, function()
    ui.box({
      w = math.floor(fraction * 100 + 0.5) .. "%",
      h = "grow",
      color = th.accent, radius = 4,
    })
  end)
end

-- inside the bar function:
progressbar("mem-bar", mem, 120)
```

## A history graph

A graph is a row of thin grow boxes whose heights come from a ring buffer. Give each sample a monotonic sequence number so its identity is stable as it slides left, and declare the row through `ui.each`, keyed by that number:

```lua
local cpu_hist, cpu_seq = {}, 0
local prev_idle, prev_total
local SAMPLES = 30

some.spawn.watch("head -1 /proc/stat", 2, function(line)
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
    some.dirty()
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

A slider is a progress bar that writes back. On press, set the value from the pointer's x inside the track, then take the pointer with `some.mousegrabber` so dragging keeps updating until the button releases. `core.box(id)` reads the track's solved geometry, which is in the same coordinate space as the event's `x`:

```lua
local function slider(id, width, get, set)
  local function apply(px)
    local b = core.box(id)
    if b == nil or b.width == 0 then return end
    set(math.max(0, math.min(1, (px - b.x) / b.width)))
    some.dirty()
  end
  ui.box({
    id = id, w = width, h = 8,
    color = th.bg2, radius = 4,
    align = { y = "center" },
    on_scroll = function(ev)
      set(math.max(0, math.min(1, get() - (ev.dy or 0) * 0.05)))
      some.dirty()
    end,
    on_press = function(ev)
      apply(ev.x)
      local grab
      grab = some.mousegrabber {
        motion = function(mev) apply(mev.x) end,
        button = function(bev)
          if not bev.pressed then grab:stop() end
        end,
      }
    end,
  }, function()
    ui.box({
      w = math.floor(get() * 100 + 0.5) .. "%", h = "grow",
      color = th.accent, radius = 4,
    })
  end)
end
```

Wired to volume:

```lua
local vol = 0.5

-- inside the bar function:
slider("vol-slider", 100,
  function() return vol end,
  function(f)
    vol = f
    some.spawn(string.format(
      "wpctl set-volume @DEFAULT_AUDIO_SINK@ %d%%",
      math.floor(f * 100 + 0.5)))
  end)
```

To keep the slider honest against volume changed elsewhere, add a `some.spawn.watch` on `wpctl get-volume @DEFAULT_AUDIO_SINK@` that parses the number back into `vol`.

## A checkbox

A toggle is a bordered box that fills when on, empties when off, and flips its state on press. Do-not-disturb, backed by the notification module's own switch:

```lua
ui.box({
  id = "dnd-toggle", w = 14, h = 14, radius = 3,
  align = { y = "center" },
  color = notification.suspended and th.accent or nil,
  border = { width = 1, color = th.accent },
  on_press = function()
    notification.suspended = not notification.suspended
    some.dirty()
  end,
})
```

Any boolean works the same way: fill from the state, flip in `on_press`, dirty.

## Complete example

The meters assembled into a bar. The watchers and helpers above sit at the top level of your config; the bar function only declares:

```lua
screen.on("added", function(s)
  tag.new { name = "main", screen = s }

  ui.bar(s, { edge = "top", height = 28, color = th.bg }, function()
    ui.taglist(s)
    ui.spacer()
    ui.text("cpu", { size = 12, color = th.muted })
    cpu_graph("cpu-graph", 18)
    ui.text("mem", { size = 12, color = th.muted })
    progressbar("mem-bar", mem, 120)
    ui.text("vol", { size = 12, color = th.muted })
    slider("vol-slider", 100,
      function() return vol end,
      function(f)
        vol = f
        some.spawn(string.format(
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ %d%%",
          math.floor(f * 100 + 0.5)))
      end)
    ui.box({
      id = "dnd-toggle", w = 14, h = 14, radius = 3,
      align = { y = "center" },
      color = notification.suspended and th.accent or nil,
      border = { width = 1, color = th.accent },
      on_press = function()
        notification.suspended = not notification.suspended
        some.dirty()
      end,
    })
    ui.clock()
  end)
end)
```

## See also

- [Widgets tutorial](/kiln/tutorials/widgets)
- [ui reference](/kiln/reference/ui)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
- [some reference](/kiln/reference/some), for `spawn.watch`, `spawn.pipe`, and the grabbers
