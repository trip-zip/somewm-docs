---
sidebar_position: 9
title: Tag Persistence
description: Replace the default save and restore handlers to persist more tag properties, key saved state by monitor identity instead of connector, give new outputs their own tags, or turn persistence off.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

Two handlers do the work ([how it works](../concepts/tag-persistence.md)). `awful.permissions.tag_screen`, connected to `tag` `request::screen` when `awful.permissions` loads, saves each tag of a removed screen into `awful.permissions.saved_tags[connector]`. The `request::desktop_decoration` handler in `somewmrc.lua` restores from that table when a screen appears, and creates the default tags otherwise. Customising means replacing one or both.

## Save more properties

Replace the save handler with one that records extra fields, here `column_count` and `volatile`:

```lua
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)

tag.connect_signal("request::screen", function(t, reason)
    if reason ~= "removed" then return end
    local name = t.screen and t.screen.output and t.screen.output.name
    if not name then return end
    awful.permissions.saved_tags[name] = awful.permissions.saved_tags[name] or {}
    table.insert(awful.permissions.saved_tags[name], {
        name = t.name, selected = t.selected, layout = t.layout,
        master_width_factor = t.master_width_factor, master_count = t.master_count,
        column_count = t.column_count, gap = t.gap, volatile = t.volatile,
        clients = t:clients(),
    })
end)
```

And restore them. Two passes keep a client that was on several tags on all of them:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    local name = s.output and s.output.name
    local restore = name and awful.permissions.saved_tags[name]
    if restore then
        awful.permissions.saved_tags[name] = nil
        local client_tags = {}
        for _, td in ipairs(restore) do
            local t = awful.tag.add(td.name, {
                screen = s, layout = td.layout, selected = td.selected,
                master_width_factor = td.master_width_factor, master_count = td.master_count,
                column_count = td.column_count, gap = td.gap, volatile = td.volatile,
            })
            for _, c in ipairs(td.clients) do
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
    else
        awful.tag({ "dev", "web", "chat", "files", "media" }, s, awful.layout.layouts[1])
    end
    -- wibar and the rest
end)
```

## Variations

- **Different defaults per output.** In the `else` branch, test the connector: `name:match("^eDP")` gets the laptop's tags, anything else the external monitor's. Saved state still wins when it exists.
- **Key by monitor identity.** On a dock whose connector names move, key both handlers by `o.make .. ":" .. o.model .. ":" .. o.serial`, falling back to `o.name` when a field is nil, as virtual and older outputs report.
- **Turn it off.** Disconnect `awful.permissions.tag_screen` and create fresh tags unconditionally in `request::desktop_decoration`. Disconnected tags are dropped, as in AwesomeWM.

## When tags do not come back

- The connector name changed: `somewm-client eval "return screen.primary.output.name"` shows the current one, and the state is under the old one.
- A client that exited while the monitor was away has `valid == false` and is skipped; one you moved by hand is not on the restored tag.
- State is in memory. A compositor restart starts fresh.

[Tag Persistence reference](../reference/tag-persistence.md) has the signals and the saved-state table; [output reference](../reference/output.md) the identity fields.
