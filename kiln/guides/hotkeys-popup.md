---
title: Hotkeys Popup
description: Use the built-in keybinding cheat sheet, and build your own replacement from the key registry when the stock one is not enough.
sidebar_position: 12
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Hotkeys Popup

<YouWillLearn>

- Showing, closing, and toggling the built-in cheat sheet with `some.hotkeys`
- What the stock sheet renders, and where its content comes from
- Reading every binding back from `some.key.all()`
- Declaring a custom sheet as an overlay float with a dismissing scrim

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui, key = some.ui, some.key
local th = some.theme
```

## The built-in sheet

Every `key { ... }` call records itself in a registry, including the `desc`
and `group` you gave it. The stdlib ships a cheat sheet that reads that
registry at declare, so it lists whatever your config binds, always current:

```lua
key { mods = { "mod" }, key = "s", desc = "show help", group = "kiln",
  press = some.hotkeys.toggle }
```

That is the whole wiring, and it is exactly what the default config does. The
API is three functions and one field:

| Symbol | Meaning |
|---|---|
| `some.hotkeys.show(s?)` | open the sheet on screen `s` (default: focused) |
| `some.hotkeys.close()` | close it |
| `some.hotkeys.toggle(s?)` | one or the other |
| `some.hotkeys.open` | the screen the sheet is open on, or nil |

The stock sheet:

- groups bindings by their `group` field, in first-seen declaration order,
  and deals the groups into three columns of roughly equal height
- shows each binding's resolved chord (`super+s`, not `mod+s`) next to its
  `desc`
- floats centered in the `overlay` band over a screen-sized scrim
- holds the keyboard while open: any key press dismisses it, and nothing
  leaks to the binding underneath. A press outside the sheet dismisses too.

A range binding (`key = "1-9"`) is one row reading `"1-9"`, not nine expanded
rows. There is no update path to manage: the registry is the model and the
declare is the render, so a binding added at any time is on the sheet the
next time it opens.

## Rolling your own

The rest of this page replaces the stock sheet with your own layout. The
same registry powers it: `some.key.all()` returns a copy of every binding as
written.

### Step 1: read the registry

```lua
for _, k in ipairs(some.key.all()) do
  -- k.mods, k.key, k.desc, k.group, k.label
end
```

`k.label` is the chord as the user reads it, resolved through `some.modkey`
at bind time (`"super+s"`). `k.mods` keeps the compact form you wrote, with
`"mod"` unresolved, if you want to format chords yourself. Rebinding a chord
replaces its registry row in place, so labels stay unique.

### Step 2: group

Bucket the registry by `group`, keeping first-seen order so the sheet reads
in declaration order rather than hash order:

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

### Step 3: declare the overlay

The popup is chrome in the screen's tree, declared while a boolean is set and
not declared at all when it is not. Two floats in the `overlay` band: a
screen-sized scrim that dismisses on any press outside, and the sheet one z
above it:

```lua
local hotkeys_open = false

local function declare_hotkeys(s)
  if not hotkeys_open then return end
  ui.box({
    id = "my-hotkeys-scrim",
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
    id = "my-hotkeys",
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
                function() ui.text(k.label, { size = 12 }) end)
              ui.text(k.desc or "", { size = 12, color = th.muted })
            end)
          end
        end)
      end
    end)
  end)
end
```

Press dispatch is innermost-first, so a press on the sheet hits the sheet and
never reaches the scrim; a press anywhere else closes.

:::warning
If you add ids to the chord rows for scripting, use plain strings
(`"hkkey:" .. k.label`). A table id's second element must be numeric (a
client handle, a tag index); a string there is not valid.
:::

### Step 4: wire it in and toggle it

Call `declare_hotkeys(s)` at the end of your bar function so the sheet rides
every frame while open. Then bind a toggle, and put the binding in the same
registry so the sheet lists its own summon key:

```lua
ui.bar(s, { edge = "top", color = th.bg }, function()
  -- taglist, tasklist, clock ...
  declare_hotkeys(s)
end)

key { mods = { "mod" }, key = "s", desc = "show keys", group = "system",
  press = function()
    hotkeys_open = not hotkeys_open
    some.dirty(screen.focused.name)
  end }
```

`some.dirty` forces the redraw: the boolean is plain Lua state, and changing
it does not redraw anything on its own.

### Step 5 (optional): dismiss on any key

The scrim closes on a press. To match the stock sheet and also close on any
keystroke, take the keyboard with `some.keygrabber` while the sheet is open,
and route both dismissal paths through one function so the grab is always
released:

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

Use `close_hotkeys` in the scrim's `on_press` too. While the grab holds, no
binding fires, which is fine: the first key press closes the sheet and
releases the keyboard.

## See also

- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Keybindings and rules reference](/kiln/reference/keybindings-and-rules)
- [Nodes, floats, and bands](/kiln/concepts/nodes-floats-and-bands)
- [Frames and dirty](/kiln/concepts/frames-and-dirty)
