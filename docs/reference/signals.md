---
sidebar_position: 4
title: Signals Reference
description: Common signals for event handling
---

# Signals Reference

<!-- TODO: Document common signals
     - client signals
     - screen signals
     - tag signals
     - awesome signals
-->

SomeWM uses signals for event-driven programming. Connect to signals to react to changes.

## Client Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `manage` | `c` | New client appeared |
| `unmanage` | `c` | Client closed |
| `focus` | `c` | Client gained focus |
| `unfocus` | `c` | Client lost focus |
| `raised` | `c` | Client moved to top of stack (see [Client Stacking](/concepts/client-stack)) |
| `lowered` | `c` | Client moved to bottom of stack |
| `property::name` | `c` | Title changed |
| `property::class` | `c` | Class changed |
| `property::geometry` | `c` | Size/position changed |
| `property::floating` | `c` | Floating state changed |
| `property::fullscreen` | `c` | Fullscreen state changed |
| `property::ontop` | `c` | Ontop layer state changed |
| `property::above` | `c` | Above layer state changed |
| `property::below` | `c` | Below layer state changed |
| `property::urgent` | `c` | Urgency changed |
| `request::titlebars` | `c` | Client requests titlebars |

## Screen Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `added` | `s` | New screen connected |
| `removed` | `s` | Screen disconnected |
| `property::geometry` | `s` | Screen geometry changed |
| `property::workarea` | `s` | Workarea changed |

## Tag Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `property::selected` | `t` | Tag selection changed |
| `property::activated` | `t` | Tag activated/deactivated |
| `tagged` | `t, c` | Client added to tag |
| `untagged` | `t, c` | Client removed from tag |

## Global Signals

| Signal | Description |
|--------|-------------|
| `startup` | SomeWM finished starting |
| `exit` | SomeWM is shutting down |
| `refresh` | Before redraw |

## Example Usage

```lua
-- React to new clients
client.connect_signal("manage", function(c)
    -- Center new floating windows
    if c.floating then
        awful.placement.centered(c)
    end
end)

-- React to screen changes
screen.connect_signal("added", function(s)
    -- Set up new screen
    awful.tag({ "1", "2", "3" }, s, awful.layout.layouts[1])
end)
```

## See Also

- [AwesomeWM Signals Docs](https://awesomewm.org/doc/api/libraries/gears.object.html)
