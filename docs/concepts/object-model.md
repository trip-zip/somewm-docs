---
sidebar_position: 0
title: The Object Model
description: Understanding screens, tags, clients, and widgets
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# The Object Model

<YouWillLearn>

- What screens, tags, clients, and widgets are
- How these objects relate to each other
- The difference between "focused" and "selected"
- How to think about your desktop hierarchy

</YouWillLearn>

Understanding SomeWM's object model is the foundation for everything else. Once you grasp how screens, tags, clients, and widgets relate, configuration becomes intuitive.

## The Core Objects

### Screen

A **screen** represents a physical or virtual display. If you have two monitors, you have two screens.

```lua
-- Get the primary screen
local s = screen.primary

-- Get all screens
for s in screen do
    print(s.index, s.geometry.width .. "x" .. s.geometry.height)
end

-- Get the currently focused screen
local focused = awful.screen.focused()
```

Each screen has:
- **Geometry** - position and size (`s.geometry`)
- **Workarea** - usable space after subtracting panels (`s.workarea`)
- **Tags** - the virtual workspaces for this screen
- **Wibars** - the panels attached to this screen

### Tag

A **tag** is a virtual workspace. Windows are assigned to tags, and you view tags to see those windows. Unlike traditional workspaces, a window can belong to *multiple* tags simultaneously.

```lua
-- Get tags for a screen
local tags = screen.primary.tags

-- View a specific tag
tags[2]:view_only()

-- Toggle a tag's visibility (show multiple tags at once)
awful.tag.viewtoggle(tags[3])

-- Create tags for a screen
awful.tag({"1", "2", "3", "web", "code"}, s, awful.layout.suit.tile)
```

Key tag concepts:
- **Selected** tags are currently visible on their screen
- A screen can show multiple selected tags at once
- Each screen has its own independent set of tags

### Client

A **client** is a window - any application window you can see and interact with. Terminals, browsers, editors - they're all clients.

```lua
-- Get the focused client
local c = client.focus

-- Get all clients
for _, c in ipairs(client.get()) do
    print(c.name)
end

-- Common client properties
c.floating = true      -- float above tiled windows
c.maximized = true     -- fill the screen
c.minimized = true     -- hide from view
c.ontop = true         -- stay above other windows
```

Clients belong to:
- **One screen** - the display they're on
- **One or more tags** - the workspaces they appear in

### Wibox and Wibar

A **wibox** is a box that holds widgets. A **wibar** is a wibox that's docked to a screen edge (top, bottom, left, or right).

```lua
-- Create a wibar at the top of a screen
s.mywibar = awful.wibar {
    position = "top",
    screen = s,
}

-- Create a floating wibox anywhere
local popup = wibox {
    width = 200,
    height = 100,
    visible = true,
}
```

### Widget

A **widget** is a visual element inside a wibox. Widgets come in three flavors:

| Type | Purpose | Examples |
|------|---------|----------|
| **Primitives** | Display content | `textbox`, `imagebox`, `progressbar` |
| **Containers** | Modify one widget | `background`, `margin`, `constraint` |
| **Layouts** | Arrange multiple widgets | `fixed`, `flex`, `align` |

Widgets compose by nesting:

```lua
-- A textbox inside a margin inside a background
wibox.widget {
    {
        {
            text = "Hello",
            widget = wibox.widget.textbox,
        },
        margins = 8,
        widget = wibox.container.margin,
    },
    bg = "#333333",
    widget = wibox.container.background,
}
```

## The Hierarchy

Here's how everything fits together:

```
Screen 1                          Screen 2
├── Tag "1" (selected)            ├── Tag "1"
│   ├── Client: Firefox           │   └── Client: Slack
│   └── Client: Terminal          │
├── Tag "2"                       ├── Tag "2" (selected)
│   └── Client: VS Code           │   └── Client: Spotify
├── Tag "3" (empty)               │
│                                 └── Wibar (top)
└── Wibar (top)                       └── [widgets...]
    ├── Taglist widget
    ├── Tasklist widget
    └── Clock widget
```

Key points:
- Each **screen** has its own tags and wibars
- Each **tag** belongs to exactly one screen
- Each **client** belongs to one screen but can have multiple tags
- **Wibars** are attached to a screen edge
- **Widgets** live inside wibars (or standalone wiboxes)

## Focus vs Selection

These terms are easy to confuse but mean different things:

| Term | Applies to | Meaning |
|------|-----------|---------|
| **Focused** | Clients | Receives keyboard input. Only ONE client is focused globally. |
| **Selected** | Tags | Currently visible. Multiple tags can be selected per screen. |

```lua
-- The focused client (receives keyboard input)
local c = client.focus

-- Selected tags on a screen (currently visible)
local selected = screen.primary.selected_tags

-- The focused screen (where the focused client is)
local s = awful.screen.focused()
```

### Focus flow

When you type, keystrokes go to:
1. The **focused client** (if any)
2. Global keybindings (if not consumed by the client)

The focused client is always on a selected tag of some screen.

## Common Operations

Now that you understand the objects, here's how common operations map to them:

| "I want to..." | Object | API |
|----------------|--------|-----|
| Switch workspace | Tag | `tag:view_only()` |
| View multiple workspaces | Tag | `awful.tag.viewtoggle(tag)` |
| Move window to workspace | Client + Tag | `c:move_to_tag(tag)` |
| Move window to screen | Client + Screen | `c:move_to_screen(s)` |
| Close window | Client | `c:kill()` |
| Toggle floating | Client | `c.floating = not c.floating` |
| Add widget to bar | Wibar | Modify wibar's widget property |
| Focus next window | Client | `awful.client.focus.byidx(1)` |
| Focus next screen | Screen | `awful.screen.focus_relative(1)` |

## Accessing Objects

### From anywhere

```lua
-- All clients
client.get()

-- All screens
for s in screen do ... end

-- Primary screen
screen.primary

-- Currently focused
client.focus
awful.screen.focused()
```

### From a client

```lua
local c = client.focus

c.screen          -- the screen this client is on
c:tags()          -- tags this client belongs to
c.first_tag       -- the first tag (useful for single-tag clients)
```

### From a screen

```lua
local s = awful.screen.focused()

s.tags            -- all tags for this screen
s.selected_tags   -- currently visible tags
s.clients         -- all clients on this screen
s.geometry        -- screen dimensions
s.workarea        -- usable area (minus panels)
```

### From a tag

```lua
local t = awful.screen.focused().selected_tag

t.screen          -- the screen this tag belongs to
t:clients()       -- clients with this tag
t.selected        -- is this tag currently visible?
t.layout          -- current layout for this tag
```

## Signals: Reacting to Changes

Objects emit **signals** when things change. Connect to signals to react:

```lua
-- React when a client is created
client.connect_signal("manage", function(c)
    -- c is the new client
    print("New client: " .. c.name)
end)

-- React when focus changes
client.connect_signal("focus", function(c)
    c.border_color = "#ff0000"
end)

-- React when a screen is added (monitor plugged in)
screen.connect_signal("added", function(s)
    -- Set up tags and wibar for new screen
end)
```

Common signals:

| Object | Signal | When |
|--------|--------|------|
| client | `manage` | New client created |
| client | `focus` / `unfocus` | Focus changes |
| client | `property::name` | Window title changes |
| screen | `added` / `removed` | Monitor (dis)connected |
| tag | `property::selected` | Tag visibility changes |

## Next Steps

Now that you understand the object model:

- **[Architecture](/concepts/architecture)** - How the layers communicate
- **[My First SomeWM](/tutorials/my-first-somewm)** - Hands-on practice with these concepts
- **[First Widget](/tutorials/first-widget)** - Build widgets that use these objects
