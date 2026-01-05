---
sidebar_position: 3
title: Multi-Monitor Setup
description: Configure multiple screens and outputs
---

# Multi-Monitor Setup

SomeWM handles multiple monitors automatically. Each monitor becomes a `screen` object with its own tags, wibar, and workspace.

## Screen Detection

When SomeWM starts, it automatically detects all connected monitors. Each becomes a screen:

```lua
-- Print all connected screens
for s in screen do
    print("Screen " .. s.index .. ": " .. s.geometry.width .. "x" .. s.geometry.height)
end
```

### Accessing Screens

```lua
-- The primary screen (usually the first one)
local primary = screen.primary

-- Get screen by index (1-based)
local first = screen[1]
local second = screen[2]

-- The screen with keyboard focus
local focused = awful.screen.focused()

-- Iterate all screens
for s in screen do
    -- Do something with each screen
end
```

## Per-Screen Setup

The default config uses `connect_for_each_screen` to set up tags and wibars for every screen. This runs once for each existing screen, and again whenever a new screen is added.

```lua
awful.screen.connect_for_each_screen(function(s)
    -- Create tags for this screen
    awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.suit.tile)

    -- Create a wibar for this screen
    s.mywibar = awful.wibar {
        position = "top",
        screen = s,
        widget = {
            layout = wibox.layout.align.horizontal,
            { -- Left
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
            },
            s.mytasklist, -- Middle
            { -- Right
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.textclock(),
            },
        },
    }
end)
```

### Why `connect_for_each_screen`?

Using this pattern instead of a simple loop ensures:
- Each screen gets set up once
- New screens (hotplug) automatically get configured
- The setup code stays DRY

## Moving Windows Between Screens

### Via Keybindings

The default config includes keybindings to move windows between screens:

```lua
awful.keyboard.append_global_keybindings({
    -- Move focused window to next screen
    awful.key({ modkey, "Shift" }, "o", function()
        if client.focus then
            client.focus:move_to_screen()
        end
    end, { description = "move to next screen", group = "screen" }),

    -- Focus next screen
    awful.key({ modkey }, "o", function()
        awful.screen.focus_relative(1)
    end, { description = "focus next screen", group = "screen" }),
})
```

### Programmatically

```lua
-- Move client to a specific screen
c:move_to_screen(screen[2])

-- Move client to next screen (cycles)
c:move_to_screen()

-- Move client to screen by direction
c:move_to_screen(c.screen:get_next_in_direction("right"))
```

## Screen Geometry

Each screen has geometry properties:

```lua
local s = awful.screen.focused()

-- Full screen area
print(s.geometry.x, s.geometry.y)       -- Position
print(s.geometry.width, s.geometry.height) -- Size

-- Workarea (minus panels/struts)
print(s.workarea.x, s.workarea.y)
print(s.workarea.width, s.workarea.height)
```

The `workarea` is the usable space after subtracting wibars and other panels.

## Handling Hotplug

When monitors are connected or disconnected, SomeWM emits signals:

### Screen Added

When a new monitor is connected:

```lua
screen.connect_signal("added", function(s)
    -- Set up the new screen
    -- Note: connect_for_each_screen handles this automatically
    print("New screen: " .. s.index)
end)
```

### Screen Removed

When a monitor is disconnected, windows need somewhere to go:

```lua
screen.connect_signal("removed", function(s)
    -- Windows are automatically moved to another screen
    print("Screen removed: " .. s.index)
end)
```

By default, windows from a removed screen migrate to another available screen. You can customize this:

```lua
-- Custom handling for screen removal
tag.connect_signal("request::screen", function(t)
    -- Called when a tag's screen is removed
    -- Find a new home for this tag
    for s in screen do
        if s ~= t.screen then
            t.screen = s
            return
        end
    end
end)
```

## Different Configurations Per Screen

### Different Tags Per Screen

```lua
awful.screen.connect_for_each_screen(function(s)
    if s == screen.primary then
        -- Primary screen: work-focused tags
        awful.tag({"code", "web", "mail", "chat", "music"}, s, awful.layout.suit.tile)
    else
        -- Secondary screen: reference/monitoring
        awful.tag({"docs", "term", "logs"}, s, awful.layout.suit.tile)
    end
end)
```

### Different Layouts Per Screen

```lua
awful.screen.connect_for_each_screen(function(s)
    local layouts = s == screen.primary
        and { awful.layout.suit.tile, awful.layout.suit.max }
        or { awful.layout.suit.fair, awful.layout.suit.floating }

    awful.tag({"1", "2", "3"}, s, layouts)
end)
```

### Wibar on Primary Only

```lua
awful.screen.connect_for_each_screen(function(s)
    awful.tag({"1", "2", "3"}, s, awful.layout.suit.tile)

    if s == screen.primary then
        s.mywibar = awful.wibar {
            position = "top",
            screen = s,
            -- ...
        }
    end
end)
```

## Common Multi-Monitor Patterns

### Laptop + External Monitor

```lua
awful.screen.connect_for_each_screen(function(s)
    -- Assume laptop is smaller, use it for monitoring
    local is_laptop = s.geometry.width < 1920

    if is_laptop then
        awful.tag({"term", "logs"}, s, awful.layout.suit.tile.bottom)
    else
        awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.suit.tile)
    end
end)
```

### Spawn Apps on Specific Screen

```lua
-- Rule to start Firefox on screen 2
ruled.client.append_rule {
    rule = { class = "firefox" },
    properties = {
        screen = 2,
        tag = "web",
    },
}
```

### Focus Follows Monitor

When switching to a tag, also focus its screen:

```lua
tag.connect_signal("property::selected", function(t)
    if t.selected then
        t.screen:emit_signal("request::activate", "tag_switch", { raise = false })
    end
end)
```

## Troubleshooting

### Screens Not Detected

Check that your displays are connected and recognized by the system:

```bash
# Check Wayland outputs
somewm-client screen list

# Or use wlr-randr
wlr-randr
```

### Wrong Screen Order

Screen indices are assigned in the order they're detected. Use geometry or names to identify specific screens:

```lua
-- Find screen by position (leftmost)
local left_screen = nil
for s in screen do
    if not left_screen or s.geometry.x < left_screen.geometry.x then
        left_screen = s
    end
end
```

### Windows on Wrong Screen After Hotplug

Use rules to ensure specific apps always start on the right screen:

```lua
ruled.client.append_rule {
    rule = { class = "Slack" },
    properties = { screen = screen.primary },
}
```

## See Also

- **[The Object Model](/concepts/object-model)** - Understanding screens and clients
- **[Fractional Scaling](/guides/fractional-scaling)** - HiDPI configuration per screen
- **[AwesomeWM Screen Docs](https://awesomewm.org/doc/api/classes/screen.html)** - Full screen API
