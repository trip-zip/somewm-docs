---
sidebar_position: 9
title: Tag Persistence
description: Customize tag save and restore across monitor hotplug
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Tag Persistence <SomewmOnly />

Keep the default save and restore handlers to recover tags when a monitor reconnects. Replace both when you need additional properties or a different monitor key.

## How the Default Config Works

`awful.permissions.tag_screen` saves tag state on `request::screen` with context `"removed"`. It stores names, selection, layout, master width and count, gap and client membership in `awful.permissions.saved_tags`, keyed by connector name.

The default `request::desktop_decoration` handler restores that state when the connector returns. This table is in memory only and is lost when the Lua state is rebuilt. Hot-reload preservation of active tags is separate, described below.

## Save Additional Properties

To also preserve `column_count` and `volatile`, replace the default save handler with this one:

```lua
local awful = require("awful")
local function output_key(s)
    return s and s.output and s.output.name
end

tag.disconnect_signal("request::screen", awful.permissions.tag_screen)
tag.connect_signal("request::screen", function(t, context)
    if context ~= "removed" then return end
    local key = output_key(t.screen)
    if not key then return end
    local saved = awful.permissions.saved_tags
    saved[key] = saved[key] or {}
    table.insert(saved[key], {
        name = t.name,
        selected = t.selected,
        layout = t.layout,
        master_width_factor = t.master_width_factor,
        master_count = t.master_count,
        column_count = t.column_count,
        gap = t.gap,
        volatile = t.volatile,
        clients = t:clients(),
    })
end)
```

In the same file, define the matching restore function:

```lua
local function restore_tags(s)
    local key = output_key(s)
    local saved = key and awful.permissions.saved_tags[key]
    if not saved then return false end
    awful.permissions.saved_tags[key] = nil
    local client_tags = {}
    for _, data in ipairs(saved) do
        local t = awful.tag.add(data.name, {
            screen = s,
            layout = data.layout,
            selected = data.selected,
            master_width_factor = data.master_width_factor,
            master_count = data.master_count,
            column_count = data.column_count,
            gap = data.gap,
            volatile = data.volatile,
        })
        for _, c in ipairs(data.clients) do
            if c.valid then
                client_tags[c] = client_tags[c] or {}
                table.insert(client_tags[c], t)
            end
        end
    end
    for c, tags in pairs(client_tags) do
        c:move_to_screen(s)
        c:tags(tags)
    end
    return true
end
```

Replace only the tag-creation portion of the existing decoration handler with this body. Keep its wibar and other widget setup afterward:

```lua
if not restore_tags(s) then
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.suit.tile)
end
```

The two-pass restoration collects every saved tag for each client before assigning membership. Otherwise, a client on several tags would end up on only the last one. Closed clients are skipped. The example restores saved clients even if they moved elsewhere while the output was absent.

## Persist Different Tags Per Output

In that final block, replace the default `awful.tag` call with connector-specific names:

```lua
local name = output_key(s) or ""
local names = name:match("^eDP")
    and { "code", "web", "chat", "music" }
    or { "1", "2", "3", "4", "5" }
awful.tag(names, s, awful.layout.suit.tile)
```

This runs only when no saved state exists.

## Match by Monitor Identity Instead of Connector

Replace `output_key` in the paired example above with:

```lua
local function output_key(s)
    local o = s and s.output
    if not o then return nil end
    if o.make and o.make ~= "" and o.model and o.model ~= ""
        and o.serial and o.serial ~= "" then
        return o.make .. ":" .. o.model .. ":" .. o.serial
    end
    return o.name
end
```

Both save and restore must use the same key. Some monitors omit a serial or report identical identity fields. In that case, use connector names or your own explicit mapping.

## Across a Hot-Reload

In 1.4.6, `awesome.restart()` rebuilds Lua while keeping applications connected. Active tags are matched by name on the same screen. There is no positional fallback for renamed tags.

The reload restores client membership, selected tags, explicitly stored master and gap values, column count and floating state. It restores a layout by name only if that name exists in the rebuilt tag's allowed layouts. Rules run afterward and can override client properties or placement.

Matched clients receive `request::tag` with `hints.reason = "restart"` and the matched objects in `hints.tags`. The default `awful.permissions.tag` handler applies them. Unmatched clients fall back to normal placement. Arbitrary widget state and disconnected-monitor entries in `saved_tags` do not survive the Lua rebuild.

## Disable Tag Persistence

Disconnect the save handler:

```lua
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)
```

Then replace the restoration branch in your existing decoration handler with ordinary tag creation. This disables unplug/replug restoration, not the C core's active-tag preservation during hot-reload.

## Troubleshooting

<span id="tags-not-restored-after-reconnect" />
<span id="clients-missing-after-restore" />
<span id="state-lost-on-compositor-restart" />

- **Tags do not return:** check that save and restore use the same connector or identity key and that both handlers are installed.
- **Only one membership returns:** collect all restored tags before calling `c:tags`, as above.
- **State disappears after reload:** entries for disconnected outputs are Lua state and are not preserved.
- **A client returns to a rule-selected tag:** rules run during management, including after reload.

## See Also

- [Tag Persistence Concepts](../concepts/tag-persistence.md)
- [Tag Persistence Reference](../reference/tag-persistence.md)
- [Multi-Monitor Setup](multi-monitor.md)
- [Output Reference](../reference/output.md)
