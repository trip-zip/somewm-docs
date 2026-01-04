---
sidebar_position: 1
title: Architecture
description: Understanding SomeWM's three-layer design
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Architecture

<YouWillLearn>

- The three-layer design and what each layer does
- How the layers communicate via signals, properties, and methods
- The order things load at startup
- Where to look when you want to change something

</YouWillLearn>

SomeWM uses a three-layer architecture inherited from AwesomeWM. Understanding this separation helps you know where to make changes and what's possible.

## The Three Layers

```
┌─────────────────────────────────────┐
│         User Configuration          │  ~/.config/somewm/rc.lua
│         (Customization)             │  ~/.config/somewm/theme.lua
├─────────────────────────────────────┤
│         Lua Libraries               │  awful.*, gears.*, wibox.*
│         (Default Behavior)          │  naughty, beautiful, ruled
├─────────────────────────────────────┤
│         C Core                      │  Compositor, wlroots bindings
│         (Primitives)                │  Wayland protocols
└─────────────────────────────────────┘
```

### C Core (Primitives)

The C core is the compositor itself. It handles:

- **Wayland protocols** - communicating with applications
- **wlroots integration** - rendering, input, output management
- **Core objects** - clients, screens, tags, drawins (raw wibox)
- **Input handling** - keyboard and pointer event routing
- **Lua bindings** - exposing objects and functions to Lua

You don't modify the C core. It provides primitives that the Lua layers build upon.

**What C provides to Lua:**
- `client` - window objects with properties like `name`, `floating`, `geometry`
- `screen` - display objects with `geometry`, `workarea`, `tags`
- `tag` - workspace objects
- `awesome` - global functions like `restart()`, `quit()`, `emit_signal()`
- `root` - root window functions for global keybindings

### Lua Libraries (Default Behavior)

The Lua libraries provide sensible defaults and convenience functions. These are copied from AwesomeWM and live in SomeWM's installation directory.

| Library | Purpose |
|---------|---------|
| `awful.*` | Window management, keybindings, layouts, spawning |
| `gears.*` | Utilities: timers, shapes, filesystem, tables |
| `wibox.*` | Widget system: primitives, containers, layouts |
| `beautiful` | Theming system |
| `naughty` | Notifications |
| `ruled` | Rules for clients and notifications |

**Don't modify these files directly.** They're part of the SomeWM installation and will be overwritten on updates. Instead, override their behavior from your config.

### User Configuration

Your configuration lives in `~/.config/somewm/` and consists of:

- **`rc.lua`** - Main configuration: keybindings, tags, rules, layout
- **`theme.lua`** - Colors, fonts, spacing, widget appearances

Your config *uses* the Lua libraries to customize behavior:

```lua
-- rc.lua uses awful.key from the Lua libraries
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod4" }, "Return", function()
        awful.spawn("alacritty")
    end),
})
```

## How Layers Communicate

The layers talk to each other through three mechanisms:

### Signals

**Signals** are events that flow from C to Lua (or between Lua objects). When something happens, a signal fires and your callbacks run.

```lua
-- C emits "manage" when a new window appears
client.connect_signal("manage", function(c)
    -- Your Lua code reacts
    c.border_width = 2
end)

-- Objects emit property change signals
client.connect_signal("property::floating", function(c)
    if c.floating then
        c.ontop = true
    end
end)
```

Common signal patterns:
- `object.connect_signal("name", callback)` - subscribe to events
- `object.emit_signal("name", ...)` - send custom signals
- `property::X` signals fire when property X changes

### Properties

**Properties** are readable/writable attributes on objects. Setting a property from Lua tells C to make a change.

```lua
-- Read a property
local name = c.name
local is_floating = c.floating

-- Write a property (C applies the change)
c.floating = true
c.maximized = false
c.geometry = { x = 100, y = 100, width = 800, height = 600 }
```

Properties are the main way to control objects. When you write `c.floating = true`, Lua tells the C core to update the window state.

### Methods

**Methods** are functions you call on objects to perform actions.

```lua
-- Client methods
c:kill()                    -- Close the window
c:move_to_tag(tag)          -- Move to a tag
c:move_to_screen(s)         -- Move to a screen
c:raise()                   -- Bring to front

-- Tag methods
t:view_only()               -- Show only this tag
t:clients()                 -- Get clients on this tag
```

## Startup Order

When SomeWM starts, things happen in this order:

1. **C core initializes** - compositor starts, wlroots sets up displays
2. **Lua VM starts** - embedded Lua interpreter begins
3. **Built-in libraries load** - awful, gears, wibox become available
4. **rc.lua executes** - your configuration runs top-to-bottom
5. **`beautiful.init()`** - theme loads (should be early in rc.lua)
6. **Screen signals fire** - `request::desktop_decoration` for each screen
7. **Existing windows appear** - `manage` signal for any pre-existing clients
8. **Event loop starts** - compositor is now running

Your rc.lua runs *once* at startup (and again if you reload config). Code at the top level executes immediately; signal callbacks run later when events occur.

```lua
-- This runs immediately at startup
print("Config loading...")

-- This runs later, for each screen
screen.connect_signal("request::desktop_decoration", function(s)
    -- Create wibar, tags, etc.
end)

-- This runs later, when windows appear
client.connect_signal("manage", function(c)
    -- Configure new windows
end)
```

## Where Things Live

When you want to change something, here's where to look:

| Want to change... | Look in... | Using... |
|-------------------|------------|----------|
| Keybindings | `rc.lua` | `awful.keyboard.append_global_keybindings` |
| Colors and fonts | `theme.lua` | `beautiful` variables |
| Layouts | `rc.lua` | `awful.layout.layouts` table |
| Window rules | `rc.lua` | `ruled.client.append_rule` |
| Tags (workspaces) | `rc.lua` | `awful.tag()` |
| Wibar (panel) | `rc.lua` | `awful.wibar{}` inside screen signal |
| Notifications | `rc.lua` | `naughty.config` / `ruled.notification` |
| Input settings | `rc.lua` | `awful.input` properties |

## Example: Tracing a Keybind

Here's how a keypress flows through the layers:

1. **C Core** - wlroots receives keyboard event from Wayland
2. **C Core** - Event matches a registered keybinding
3. **Lua callback** - Your `awful.key` callback function runs
4. **Lua libraries** - `awful.spawn()` forks a process
5. **C Core** - New window appears via Wayland
6. **Lua callback** - `manage` signal fires, you apply rules

```lua
-- You define this in rc.lua (User Configuration layer)
awful.key({ "Mod4" }, "Return", function()
    -- This uses awful.spawn (Lua Libraries layer)
    awful.spawn("alacritty")
    -- C Core handles the actual process spawning
end)
```

## See Also

- **[The Object Model](/concepts/object-model)** - Understanding screens, tags, clients, widgets
- **[AwesomeWM Compatibility](/concepts/awesomewm-compat)** - How SomeWM maintains compatibility
- **[My First SomeWM](/tutorials/my-first-somewm)** - Put these concepts into practice
