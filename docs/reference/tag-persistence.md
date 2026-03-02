---
sidebar_position: 5
title: Tag Persistence
description: Signals and state structure for tag save/restore across hotplug
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Tag Persistence <SomewmOnly />

Tag persistence saves and restores tag state across monitor hotplug. It is implemented entirely in Lua via the default `somewmrc.lua`, not in the C core.

## Signals

Two signals drive the save/restore cycle:

### `tag` `request::screen`

Fired when a tag's screen is about to be removed.

| Argument | Type | Description |
|----------|------|-------------|
| `t` | tag | The tag losing its screen |
| `reason` | string | Why the screen is being lost (`"removed"` on disconnect) |

The default handler checks `reason == "removed"` and saves the tag's metadata into a table keyed by `t.screen.output.name`.

:::tip
If you connect your own `request::screen` handler, it replaces the default behavior entirely. You must handle tag migration yourself or tags will be garbage collected.
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

Tags are grouped by connector name in the save table:

```lua
-- Internal structure
_saved_tags = {
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

When restoring, for each saved tag entry:

1. `awful.tag.add()` creates the tag with the saved properties
2. Each client in `clients` is checked for `valid == true`
3. Valid clients are moved to the screen via `c:move_to_screen(s)`
4. Valid clients are assigned to the restored tag via `c:tags({t})`

After restore, the saved state for that connector is cleared (`_saved_tags[output_name] = nil`).

## Default Implementation

The complete default implementation from `somewmrc.lua`:

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
        gap = t.gap,
        clients = t:clients(),
    })
end)

-- In the request::desktop_decoration handler:
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
                gap = td.gap,
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

See the [output reference](/reference/output) for the full property list.

## See Also

- **[Tag Persistence Concepts](/concepts/tag-persistence)** - Why this feature exists and its limitations
- **[Tag Persistence Guide](/guides/tag-persistence)** - Customize save/restore behavior
- **[Multi-Monitor Setup](/guides/multi-monitor)** - General multi-monitor configuration
- **[screen Reference](/reference/screen)** - Screen object API
- **[Signals Reference](/reference/signals)** - All signal types
