---
title: Hotkeys Popup
description: Build a keybinding cheat sheet overlay from the key registry, toggled by a bind and dismissed by a press or any key.
sidebar_position: 12
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Hotkeys Popup

<YouWillLearn>

- Reading every binding back from `some.key.all()`
- Grouping bindings by their `group` field
- Declaring the sheet as an overlay float with a dismissing scrim
- Toggling it from a bind, and closing it on any key with a keygrabber

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui, key = some.ui, some.key
local th = some.theme
```

Every `key { ... }` call records itself in a registry, including the `desc` and `group` you gave it. A hotkeys popup is nothing more than a read of that registry, grouped and laid out as an overlay float. There is no popup widget to configure; you build the sheet in about forty lines, and it lists whatever your config binds, always current.

## Step 1: read the registry

`some.key.all()` returns a copy of every binding as written:

```lua
for _, k in ipairs(some.key.all()) do
  -- k.mods, k.key, k.desc, k.group
end
```

A range binding (`key = "1-9"`) is one entry reading `"1-9"`, not nine expanded entries. That is exactly what a cheat sheet wants: the chords the compositor listens for are expanded, but the registry keeps the compact form you wrote.

## Step 2: format the chord

The registry keeps `mods` as written, with `"mod"` unresolved. Resolve it through `some.modkey` the same way a binding does, and join:

```lua
local function chord_label(k)
  local out = ""
  for _, m in ipairs(k.mods) do
    out = out .. (m == "mod" and some.modkey or m) .. "+"
  end
  return out .. k.key
end
```

## Step 3: group

Bucket the registry by `group`, keeping first-seen order so the sheet reads in declaration order rather than hash order:

```lua
local function grouped_keys()
  local groups, order = {}, {}
  for _, k in ipairs(some.key.all()) do
    local g = k.group or "other"
    if groups[g] == nil then
      groups[g] = {}
      table.insert(order, g)
    end
    table.insert(groups[g], k)
  end
  return groups, order
end
```

## Step 4: declare the overlay

The popup is chrome in the screen's tree, declared while a boolean is set and not declared at all when it is not. Two floats in the `overlay` band: a screen-sized scrim that dismisses on any press outside, and the centered sheet one z above it:

```lua
local hotkeys_open = false

local function declare_hotkeys(s)
  if not hotkeys_open then return end
  ui.box({
    id = "hotkeys-scrim",
    float = { to = "root", band = "overlay" },
    w = s.width, h = s.height,
    color = "#00000080",
    on_press = function()
      hotkeys_open = false
      some.dirty(s.name)
    end,
  })
  local groups, order = grouped_keys()
  ui.column({
    id = "hotkeys",
    float = { to = "root", anchor = "center", band = "overlay", z = 1 },
    color = th.bg, radius = 8, pad = 16, gap = 12,
    border = { width = 1, color = th.accent },
  }, function()
    ui.row({ gap = 24, align = { y = "top" } }, function()
      for _, g in ipairs(order) do
        ui.column({ gap = 6 }, function()
          ui.text(g, { size = 12, color = th.accent })
          for _, k in ipairs(groups[g]) do
            ui.row({ gap = 8, align = { y = "center" } }, function()
              ui.box({ color = th.bg2, radius = 3, pad = { x = 6 } },
                function() ui.text(chord_label(k), { size = 12 }) end)
              ui.text(k.desc or "", { size = 12, color = th.muted })
            end)
          end
        end)
      end
    end)
  end)
end
```

Press dispatch is innermost-first, so a press on the sheet hits the sheet and never reaches the scrim; a press anywhere else closes.

:::warning
If you add ids to the chord rows for scripting, use plain strings (`"hkkey:" .. chord_label(k)`). A table id's second element must be numeric (a client handle, a tag index); a string there is not valid.
:::

## Step 5: wire it in and toggle it

Call `declare_hotkeys(s)` at the end of your bar function so the sheet rides every frame while open. Then bind a toggle, and put the binding in the same registry so the sheet lists its own summon key:

```lua
ui.bar(s, { edge = "top", height = 28, color = th.bg }, function()
  -- taglist, tasklist, clock ...
  declare_hotkeys(s)
end)

key { mods = { "mod" }, key = "s", desc = "show keys", group = "system",
  press = function()
    hotkeys_open = not hotkeys_open
    some.dirty(screen.focused.name)
  end }
```

`some.dirty` forces the redraw: the boolean is plain Lua state, and changing it does not redraw anything on its own.

## Step 6 (optional): dismiss on any key

The scrim closes on a press. To also close on any keystroke, take the keyboard with `some.keygrabber` while the sheet is open, and route both dismissal paths through one function so the grab is always released:

```lua
local hotkeys_grab = nil

local function close_hotkeys()
  hotkeys_open = false
  if hotkeys_grab ~= nil then
    hotkeys_grab:stop()
    hotkeys_grab = nil
  end
  some.dirty()
end

local function open_hotkeys(s)
  hotkeys_open = true
  hotkeys_grab = some.keygrabber {
    key = function(ev)
      if ev.pressed then close_hotkeys() end
    end,
  }
  some.dirty(s.name)
end

key { mods = { "mod" }, key = "s", desc = "show keys", group = "system",
  press = function()
    if hotkeys_open then close_hotkeys()
    else open_hotkeys(screen.focused) end
  end }
```

Use `close_hotkeys` in the scrim's `on_press` too. While the grab holds, no binding fires, which is fine: the first key press closes the sheet and releases the keyboard.

## Why there is no update path

A `key { ... }` call added at any time appends to the registry, and the next time the popup declares, it reads the new entry. The registry is the model and the declare is the render; nothing is cached, so nothing goes stale.

## See also

- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
