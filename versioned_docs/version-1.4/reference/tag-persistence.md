---
sidebar_position: 5
title: Tag Persistence
description: Signals and state structure for tag save/restore across hotplug
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

Tag persistence saves and restores tag state across monitor hotplug. The save handler lives in `awful.permissions` (connected automatically), and the restore handler lives in `somewmrc.lua`. Both are implemented in Lua, not in the C core.

## Signals

Two signals drive the save/restore cycle:

### `tag` `request::screen`

Fired when a tag's screen is about to be removed.

| Argument | Type | Description |
|----------|------|-------------|
| `t` | tag | The tag losing its screen |
| `reason` | string | Why the screen is being lost (`"removed"` on disconnect) |

The default handler is `awful.permissions.tag_screen`. It checks `reason == "removed"` and saves the tag's metadata into `awful.permissions.saved_tags`, keyed by `t.screen.output.name`.

:::tip
The default handler is a named function connected automatically. To replace it, disconnect it first, then connect your own:

```lua
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)
tag.connect_signal("request::screen", function(t, reason)
    -- your custom handler
end)
```

If no handler is connected, tags will be garbage collected when their screen is removed.
:::

### `screen` `request::desktop_decoration`

Fired when a new screen is created and needs tags and wibars.

| Argument | Type | Description |
|----------|------|-------------|
| `s` | screen | The new screen |

The default handler checks for saved state matching `s.output.name`. If found, it restores saved tags. Otherwise, it creates default tags `"1"` through `"9"`.

## Saved State Structure

Each tag is saved as a table with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Tag name |
| `selected` | boolean | Whether the tag was selected (visible) |
| `layout` | function | Layout algorithm (`awful.layout.suit.*`) |
| `master_width_factor` | number | Master area width ratio (0.0 to 1.0) |
| `master_count` | number | Number of master windows |
| `gap` | number | Spacing between tiled clients in pixels |
| `clients` | table | Array of client objects that were on this tag |

Tags are grouped by connector name in `awful.permissions.saved_tags`:

```lua
-- awful.permissions.saved_tags structure
awful.permissions.saved_tags = {
    ["HDMI-A-1"] = {
        { name = "1", selected = true, layout = ..., clients = {...}, ... },
        { name = "2", selected = false, layout = ..., clients = {...}, ... },
        -- ...
    },
    ["DP-2"] = {
        -- ...
    },
}
```

## Restore Behavior

The restore handler uses a two-pass approach so that clients on multiple tags keep their full tag list:

1. **Pass 1:** For each saved tag entry, `awful.tag.add()` creates the tag with the saved properties. Valid clients are collected into a per-client tag list.
2. **Pass 2:** Each client is moved to the screen once via `c:move_to_screen(s)`, then assigned all its tags at once via `c:tags(tags)`.

After restore, the saved state for that connector is cleared (`awful.permissions.saved_tags[output_name] = nil`).

## Default Implementation

The save handler lives in `awful.permissions` and is connected automatically:

```lua
-- awful/permissions/init.lua

awful.permissions.saved_tags = {}

function awful.permissions.tag_screen(t, context)
    if context ~= "removed" then return end
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
        gap = t.gap,
        clients = t:clients(),
    })
end

tag.connect_signal("request::screen", awful.permissions.tag_screen)
```

The restore handler lives in `somewmrc.lua`'s `request::desktop_decoration`. It uses a two-pass approach to correctly preserve clients that belong to multiple tags:

```lua
-- somewmrc.lua

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
                gap = td.gap,
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
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" },
                  s, awful.layout.layouts[1])
    end
    -- ... wibar setup follows
end)
```

## Related Properties

These `output` properties are used for keying saved state:

| Property | Type | Description |
|----------|------|-------------|
| `output.name` | string | Connector name (e.g. `"HDMI-A-1"`, `"eDP-1"`) |
| `output.make` | string or nil | Monitor manufacturer |
| `output.model` | string or nil | Monitor model |
| `output.serial` | string or nil | Monitor serial number |

See the [output reference](/docs/reference/output) for the full property list.

## See Also

- **[Tag Persistence Concepts](/docs/concepts/tag-persistence)** - Why this feature exists and its limitations
- **[Tag Persistence Guide](/docs/guides/tag-persistence)** - Customize save/restore behavior
- **[Multi-Monitor Setup](/docs/guides/multi-monitor)** - General multi-monitor configuration
- **[screen Reference](/docs/reference/screen)** - Screen object API
- **[Signals Reference](/docs/reference/signals)** - All signal types
