---
sidebar_position: 9
title: Tag Persistence
description: Customize tag save and restore across monitor hotplug
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

SomeWM's default config saves tag state when a monitor disconnects and restores it when the monitor reconnects. You can customize what gets saved, key by monitor identity instead of connector name, or disable persistence entirely.

## How the Default Config Works

Tag persistence uses two signals with handlers in two different places:

1. **`tag` `request::screen`** fires when a screen is removed. The default handler is `awful.permissions.tag_screen`, which is connected automatically when `awful.permissions` is loaded. It saves each tag's metadata into `awful.permissions.saved_tags`, keyed by connector name.
2. **`screen` `request::desktop_decoration`** fires when a screen is added. The handler in `somewmrc.lua` checks `awful.permissions.saved_tags` for saved state and restores tags instead of creating defaults.

This means unplugging and replugging a monitor restores your tag names, layouts, and window placement automatically.

## Save Additional Properties

The default save handler (`awful.permissions.tag_screen`) saves a core set of properties. To save additional state, disconnect the default handler, connect a replacement that saves extra fields into `awful.permissions.saved_tags`, and update the restore handler in `request::desktop_decoration` to apply them.

For example, to also save `column_count` and `volatile`:

```lua
-- Disconnect the default save handler
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)

-- Connect a replacement that saves extra fields
tag.connect_signal("request::screen", function(t, reason)
    if reason ~= "removed" then return end
    local s = t.screen
    local output_name = s and s.output and s.output.name
    if not output_name then return end
    if not awful.permissions.saved_tags[output_name] then
        awful.permissions.saved_tags[output_name] = {}
    end
    table.insert(awful.permissions.saved_tags[output_name], {
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

Then in the restore handler, use a two-pass approach so clients on multiple tags keep their full tag list:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    local output_name = s.output and s.output.name
    local restore = output_name and awful.permissions.saved_tags[output_name]
    if restore then
        awful.permissions.saved_tags[output_name] = nil
        -- Pass 1: recreate tags and build per-client tag lists
        local client_tags = {}
        for _, td in ipairs(restore) do
            local t = awful.tag.add(td.name, {
                screen = s,
                layout = td.layout,
                master_width_factor = td.master_width_factor,
                master_count = td.master_count,
                column_count = td.column_count,
                gap = td.gap,
                volatile = td.volatile,
                selected = td.selected,
            })
            for _, c in ipairs(td.clients) do
                if c.valid then
                    if not client_tags[c] then
                        client_tags[c] = {}
                    end
                    table.insert(client_tags[c], t)
                end
            end
        end
        -- Pass 2: move clients and assign full tag lists
        for c, tags in pairs(client_tags) do
            c:move_to_screen(s)
            c:tags(tags)
        end
    else
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    end

    -- ... rest of desktop_decoration (wibar, etc.)
end)
```

## Disable Tag Persistence

To opt out entirely, disconnect the default save handler and use a plain `request::desktop_decoration` that always creates fresh tags:

```lua
-- Disconnect the default save handler
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)

screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    -- ... wibar setup
end)
```

Without a `request::screen` handler, disconnected tags are simply dropped, matching AwesomeWM's default behavior.

## Persist Different Tags Per Output

You can combine tag persistence with per-output tag names. The restore handler checks `awful.permissions.saved_tags` first, so only new (never-seen) outputs get custom defaults:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    local output_name = s.output and s.output.name
    local restore = output_name and awful.permissions.saved_tags[output_name]
    if restore then
        awful.permissions.saved_tags[output_name] = nil
        local client_tags = {}
        for _, td in ipairs(restore) do
            local t = awful.tag.add(td.name, {
                screen = s,
                layout = td.layout,
                selected = td.selected,
                -- ... other properties
            })
            for _, c in ipairs(td.clients) do
                if c.valid then
                    if not client_tags[c] then
                        client_tags[c] = {}
                    end
                    table.insert(client_tags[c], t)
                end
            end
        end
        for c, tags in pairs(client_tags) do
            c:move_to_screen(s)
            c:tags(tags)
        end
    elseif output_name and output_name:match("^eDP") then
        -- Laptop screen: work-focused tags
        awful.tag({"code", "web", "chat", "music"}, s, awful.layout.suit.tile)
    else
        -- External monitors: generic tags
        awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.suit.tile)
    end

    -- ... wibar setup
end)
```

## Match by Monitor Identity Instead of Connector

The default handler keys saved state by connector name (`HDMI-A-1`). If you use a USB-C dock where connector names can change, you can disconnect the default handler and key by a combination of make, model, and serial instead:

```lua
local function output_key(s)
    local o = s.output
    if not o then return nil end
    if o.make and o.model and o.serial then
        return o.make .. ":" .. o.model .. ":" .. o.serial
    end
    return o.name
end

-- Disconnect the default save handler
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)

-- Connect a replacement that keys by monitor identity
tag.connect_signal("request::screen", function(t, reason)
    if reason ~= "removed" then return end
    local key = output_key(t.screen)
    if not key then return end
    if not awful.permissions.saved_tags[key] then
        awful.permissions.saved_tags[key] = {}
    end
    table.insert(awful.permissions.saved_tags[key], {
        name = t.name,
        selected = t.selected,
        layout = t.layout,
        master_width_factor = t.master_width_factor,
        master_count = t.master_count,
        gap = t.gap,
        clients = t:clients(),
    })
end)

screen.connect_signal("request::desktop_decoration", function(s)
    local key = output_key(s)
    local restore = key and awful.permissions.saved_tags[key]
    if restore then
        awful.permissions.saved_tags[key] = nil
        -- ... restore tags as shown above
    else
        awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
    end
    -- ... wibar setup
end)
```

:::note
Not all monitors report make, model, or serial. Virtual outputs and some older displays return `nil` for these fields. The example above falls back to connector name when identity info is unavailable.
:::

## Troubleshooting

### Tags Not Restored After Reconnect

- Check that the connector name matches. Run `somewm-client eval "return screen.primary.output.name"` to see the current name. If it changed, saved state is keyed under the old name.
- Ensure your `request::screen` handler runs before the screen is destroyed. The handler must be connected before the disconnect event.

### Clients Missing After Restore

- Clients that exited while the monitor was disconnected will have `valid == false` and are skipped during restore.
- If a client moved to another screen manually, it won't be on the restored tag.

### State Lost on Compositor Restart

Tag persistence is in-memory only. Restarting SomeWM clears saved state. This is by design: compositor restart is a full reset.

## See Also

- **[Tag Persistence Concepts](/concepts/tag-persistence)** - Why this feature exists
- **[Tag Persistence Reference](/reference/tag-persistence)** - Signals and saved state structure
- **[Multi-Monitor Setup](/guides/multi-monitor)** - General multi-monitor configuration
- **[output Reference](/reference/output)** - Output object properties (name, make, model, serial)
