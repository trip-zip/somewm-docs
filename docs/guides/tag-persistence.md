---
sidebar_position: 9
title: Tag Persistence
description: Customize tag save and restore across monitor hotplug
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

SomeWM's default config saves tag state when a monitor disconnects and restores it when the monitor reconnects. This guide shows how to customize that behavior.

## How the Default Config Works

The default `somewmrc.lua` handles two signals:

1. **`tag` `request::screen`** fires when a screen is removed. The handler saves each tag's metadata keyed by connector name.
2. **`screen` `request::desktop_decoration`** fires when a screen is added. The handler checks for saved state and restores tags instead of creating defaults.

This means unplugging and replugging a monitor restores your tag names, layouts, and window placement automatically.

## Save Additional Properties

The default config saves a core set of properties. To save additional state, add fields to the save table in `request::screen` and apply them in `request::desktop_decoration`.

For example, to also save `column_count` and `volatile`:

```lua
local _saved_tags = {}

tag.connect_signal("request::screen", function(t, reason)
    if reason ~= "removed" then return end
    local s = t.screen
    local output_name = s and s.output and s.output.name
    if not output_name then return end
    if not _saved_tags[output_name] then
        _saved_tags[output_name] = {}
    end
    table.insert(_saved_tags[output_name], {
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

Then in the restore handler:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    local output_name = s.output and s.output.name
    local restore = output_name and _saved_tags[output_name]
    if restore then
        _saved_tags[output_name] = nil
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
                    c:move_to_screen(s)
                    c:tags({t})
                end
            end
        end
    else
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    end

    -- ... rest of desktop_decoration (wibar, etc.)
end)
```

## Disable Tag Persistence

To opt out entirely, remove the `request::screen` handler from your config and use a plain `request::desktop_decoration` that always creates fresh tags:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    -- ... wibar setup
end)
```

Without a `request::screen` handler, disconnected tags are simply dropped, matching AwesomeWM's default behavior.

## Persist Different Tags Per Output

You can combine tag persistence with per-output tag names. The restore handler runs first, so only new (never-seen) outputs get custom defaults:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    local output_name = s.output and s.output.name
    local restore = output_name and _saved_tags[output_name]
    if restore then
        _saved_tags[output_name] = nil
        for _, td in ipairs(restore) do
            local t = awful.tag.add(td.name, {
                screen = s,
                layout = td.layout,
                selected = td.selected,
                -- ... other properties
            })
            for _, c in ipairs(td.clients) do
                if c.valid then
                    c:move_to_screen(s)
                    c:tags({t})
                end
            end
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

The default config keys saved state by connector name (`HDMI-A-1`). If you use a USB-C dock where connector names can change, you can key by a combination of make, model, and serial instead:

```lua
local function output_key(s)
    local o = s.output
    if not o then return nil end
    if o.make and o.model and o.serial then
        return o.make .. ":" .. o.model .. ":" .. o.serial
    end
    return o.name
end

tag.connect_signal("request::screen", function(t, reason)
    if reason ~= "removed" then return end
    local key = output_key(t.screen)
    if not key then return end
    if not _saved_tags[key] then
        _saved_tags[key] = {}
    end
    table.insert(_saved_tags[key], {
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
    local restore = key and _saved_tags[key]
    if restore then
        _saved_tags[key] = nil
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
