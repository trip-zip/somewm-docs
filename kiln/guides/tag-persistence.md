---
title: Tag Persistence
description: Remember each monitor's tag arrangement across unplug and replug, and put clients back where they lived.
sidebar_position: 16
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Tag Persistence

<YouWillLearn>

- What kiln does with a monitor's tags and clients when it unplugs
- Recording per-output arrangements in a table keyed by output name
- Why client membership must be tracked live, not read at removal
- Recreating tags and moving clients home when the output returns

</YouWillLearn>

Snippets assume the standard config preamble:

```lua
local some = require("somewm")
local ui = some.ui
local th = some.theme
```

Unplug a monitor and kiln keeps every window alive: the departing screen's clients are moved onto a surviving screen's selected tag, all of them, in one pile. Plug the monitor back in and it comes up as a fresh screen: your `screen.on("added")` handler builds its default tags, and the clients stay in the pile on the survivor. Nothing is lost, but nothing is remembered either.

This guide builds the memory: a config table keyed by output name that records which tags a screen had and which client lived on which tag, then restores the arrangement when the output returns. It works because output names ("eDP-1", "DP-3") are stable across replug within a session.

## The removal contract

When an output disappears, the runtime does this, in order: the screen leaves `screen.all()`, focus moves to a survivor, every client on the dead screen is retagged onto the survivor's selected tag, and only then does the screen emit `removed`.

The ordering matters for this recipe. In your `removed` handler, `s.tags` is intact: the tag objects are still there with their names, layouts, and per-tag settings, so the tag structure can be recorded at removal time. But their `clients` lists are already empty, because the rehoming ran first. Client membership therefore has to be recorded while the screen is alive, not read at the funeral.

## Step 1: the record

One table, keyed by output name:

```lua
-- saved[output_name] = {
--   tags = { { name =, layout =, selected = }, ... },
--   clients = { [handle] = { tag = tag_name, app_id = app_id } },
-- }
local saved = {}

local function record_for(name)
  local rec = saved[name]
  if rec == nil then
    rec = { clients = {} }
    saved[name] = rec
  end
  return rec
end
```

## Step 2: track client membership live

Every tag change emits `tagged` and `untagged` on the client, with the tag as payload. Mirror them into the record. The one subtlety is the removal rehome itself: when the runtime pulls clients off the dying screen, `untagged` fires for tags whose screen is already gone from `screen.all()`. Skip those, and the dead output's record keeps the last real arrangement:

```lua
local function screen_alive(s)
  for _, sc in ipairs(screen.all()) do
    if sc == s then return true end
  end
  return false
end

client.on("tagged", function(c, t)
  if t.screen == nil then return end
  record_for(t.screen.name).clients[c.handle] =
    { tag = t.name, app_id = c.app_id }
end)

client.on("untagged", function(c, t)
  if t.screen == nil or not screen_alive(t.screen) then return end
  local rec = saved[t.screen.name]
  if rec ~= nil then
    local e = rec.clients[c.handle]
    if e ~= nil and e.tag == t.name then
      rec.clients[c.handle] = nil
    end
  end
end)

client.on("destroy", function(c)
  for _, rec in pairs(saved) do
    rec.clients[c.handle] = nil
  end
end)
```

Note the rehome also fires `tagged` for the survivor's tag, which updates the survivor's record, not the dead output's. The freeze falls out of keying by output name.

## Step 3: snapshot the tags at removal

Tags are intact when `removed` fires, so record the structure there:

```lua
screen.on("removed", function(s)
  local rec = record_for(s.name)
  rec.tags = {}
  for _, t in ipairs(s.tags) do
    rec.tags[#rec.tags + 1] = {
      name = t.name,
      layout = t.layout,
      selected = t.selected,
    }
  end
end)
```

## Step 4: restore on return

In your `added` handler, check for a record before building the defaults. Recreate the tags, restore the selection, then walk `client.all()` and move each recorded client home. Match by handle first (stable for a client that stayed alive across the unplug), falling back to `app_id` for a looser reunion:

```lua
local function restore(s, rec)
  for _, spec in ipairs(rec.tags) do
    tag.new { name = spec.name, screen = s, layout = spec.layout }
  end
  for i, spec in ipairs(rec.tags) do
    if spec.selected then
      s.tags[i]:view()
      break
    end
  end
  local by_name = {}
  for _, t in ipairs(s.tags) do by_name[t.name] = t end
  for _, c in ipairs(client.all()) do
    local e = rec.clients[c.handle]
    if e == nil and c.app_id ~= nil then
      for _, entry in pairs(rec.clients) do
        if entry.app_id == c.app_id then
          e = entry
          break
        end
      end
    end
    if e ~= nil and by_name[e.tag] ~= nil then
      c.tags = { by_name[e.tag] }
    end
  end
end

screen.on("added", function(s)
  local rec = saved[s.name]
  if rec ~= nil and rec.tags ~= nil then
    restore(s, rec)
  else
    -- first sight of this output: the normal defaults
    tag.new { name = "dev", screen = s }
    tag.new { name = "web", screen = s }
    tag.new { name = "chat", screen = s }
    s.tags[1]:view()
  end

  ui.bar(s, { edge = "top", color = th.bg }, function()
    ui.taglist(s)
    ui.tasklist(s)
    ui.spacer()
    ui.clock()
  end)
end)
```

Clients that closed while the monitor was away simply have no match and are skipped. A client spawned fresh after the replug has a new handle, which is what the `app_id` fallback catches.

:::note
The record lives in Lua, so it lasts for the session. If you want arrangements to survive a compositor restart, serialize `saved` to a file (tag names and app_ids only; handles do not survive a restart) and read it back at the top of your config. The write is plain `io.open`, config space like everything else here.
:::

## See also

- [Multi-monitor](/kiln/guides/multi-monitor)
- [screen reference](/kiln/reference/screen)
- [tag reference](/kiln/reference/tag)
- [Signals reference](/kiln/reference/signals)
