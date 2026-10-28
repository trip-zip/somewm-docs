---
title: Tag Persistence
description: Restore client tags after monitor reconnection or config reload.
sidebar_position: 17
---

# Tag Persistence

Unplugging a monitor moves its clients to a surviving screen's selected tag.
Reconnecting it creates a new screen; clients stay on the survivor.

The first recipe restores one tag per client when that monitor returns. It
assumes stable output names and unique tag names per screen. It restores only
the first selected tag and does not retain layout parameters such as gaps.
For config reload, use the separate
[membership recipe](#keep-client-tags-across-reload).

Snippets assume the standard config preamble:

```lua
local kiln = require("kiln")
local ui = kiln.ui
local th = kiln.theme
```

## The removal contract

When an output disappears, the runtime does this, in order: the screen leaves `screen.all()`, focus moves to a survivor, every client on the dead screen is retagged onto the survivor's selected tag, and only then does the screen emit `removed`.

The ordering matters for this recipe. In your `removed` handler, `s.tags` is intact: the tag objects are still there with their names, layouts, and per-tag settings, so the tag structure can be recorded at removal time. But their `clients` lists are already empty, because the rehoming ran first. Client membership therefore has to be recorded while the screen is alive, not read in `removed`.

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

Every tag change emits `tagged` and `untagged` on the client, with the tag as payload. Mirror them into the record. During removal, `untagged` fires for tags whose screen has already left `screen.all()`; skip those so the record keeps the last arrangement:

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

Note the rehome also fires `tagged` for the survivor's tag, which updates the survivor's record, not the dead output's. Because the record is keyed by output name, the survivor's `tagged` events do not overwrite the removed output's entries.

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
    kiln.widgets.taglist(s)
    kiln.widgets.tasklist(s)
    ui.spacer()
    kiln.widgets.clock()
  end)
end)
```

Clients that closed while the monitor was away are removed from the record.
The `app_id` fallback can match another window of the same application; remove
that fallback if only the original windows should return.

:::note
Reload recreates the local `saved` table. This recipe handles monitor
reconnection only. To retain a record across compositor restarts, write tag
names and application identifiers to a file; handles and Lua function values
cannot identify clients or layouts in a new process.
:::

## Keep client tags across reload

Reload announces screens before replaying clients. Save memberships before
requesting reload, then restore each client in its `map` listener, after rules
have run. Store screen and tag names, since reload retires the old tag objects.

Add this after your existing `screen.on("added")` registration. That handler
must recreate the named tags. This recipe preserves multiple memberships,
including memberships on different screens. It does not preserve tag selection,
layout settings, floating geometry or focus.

```lua
local pending_tags = kiln_reload_tags or {}
kiln_reload_tags = nil

client.on("map", function(c)
  local saved_tags = pending_tags[c.handle]
  if saved_tags == nil then return end
  pending_tags[c.handle] = nil
  local tags = {}
  for _, entry in ipairs(saved_tags) do
    for _, s in ipairs(screen.all()) do
      if s.name == entry.screen then
        for _, t in ipairs(s.tags) do
          if t.name == entry.tag then
            tags[#tags + 1] = t
            break
          end
        end
      end
    end
  end
  if #tags > 0 then c.tags = tags end
end)

function reload_with_tags()
  local saved = {}
  for _, c in ipairs(client.all()) do
    local tags = {}
    for _, t in ipairs(c.tags) do
      tags[#tags + 1] = { screen = t.screen.name, tag = t.name }
    end
    saved[c.handle] = tags
  end
  kiln_reload_tags = saved
  if not kiln.reload() then kiln_reload_tags = nil end
end

kiln.key {
  mods = { "mod", "ctrl" }, key = "r",
  press = reload_with_tags,
}
```

The two globals retain the snapshot across `dofile` and expose the wrapper to
IPC. Use the wrapper for every reload that should preserve memberships:

```sh
kiln-client eval 'reload_with_tags()'
```

Calling `kiln.reload()` directly does not take a snapshot. Missing tags are
skipped; if none remain, the client keeps the membership assigned by the new
config. Unique tag names per screen are required. This snapshot lasts only
within the running compositor.

## See also

- [Multi-monitor](/kiln/guides/multi-monitor)
- [screen reference](/kiln/reference/screen)
- [tag reference](/kiln/reference/tag)
- [Signals reference](/kiln/reference/signals)
