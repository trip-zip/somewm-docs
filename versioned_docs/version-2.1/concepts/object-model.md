---
sidebar_position: 0
title: The Object Model
description: Outputs, screens, tags, clients, wiboxes and widgets, how they relate, which one each common operation acts on, and how to reach each from the others.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# The Object Model

```
Output "HDMI-A-1"                 Output "DP-2"
└── Screen 1                      └── Screen 2
    ├── Tag "1" (selected)            ├── Tag "1"
    │   ├── Client: Firefox           │   └── Client: Slack
    │   └── Client: Terminal          │
    ├── Tag "2"                       ├── Tag "2" (selected)
    │   └── Client: VS Code           │   └── Client: Spotify
    └── Wibar (top)                   └── Wibar (top)
        ├── Taglist widget                └── [widgets...]
        ├── Tasklist widget
        └── Clock widget
```

An output has zero or one screen. A screen owns its tags and wibars. A tag belongs to one screen. A client is on one screen and any number of its tags. Widgets live in wiboxes.

## Output <SomewmOnly />

A physical connector: `HDMI-A-1`, `DP-2`, `eDP-1`. It exists from plug-in to unplug, even while the display is disabled, which makes it the stable key for per-monitor configuration. Its screen is recreated each time the display is enabled.

```lua
for o in output do print(o.name, o.make, o.enabled) end
local hdmi = output.get_by_name("HDMI-A-1")
local o = screen.primary.output
```

Output properties include make, model, serial, physical size, scale, transform, mode, position and enabled state. `screen` is nil while disabled ([output reference](../reference/output.md)).

## Screen

A display with tags and wibars. `s.geometry` is its rectangle; `s.workarea` excludes space reserved by bars.

```lua
local s = screen.primary
for s in screen do print(s.index, s.geometry.width .. "x" .. s.geometry.height) end
local focused = awful.screen.focused()
```

## Tag

A workspace. A client can be on several tags at once, and a screen can show several selected tags at once.

```lua
local tags = screen.primary.tags
tags[2]:view_only()
awful.tag.viewtoggle(tags[3])
awful.tag({ "1", "2", "3", "web", "code" }, s, awful.layout.suit.tile)
```

## Client

A window.

```lua
local c = client.focus
for _, c in ipairs(client.get()) do print(c.name) end
c.floating, c.maximized, c.minimized, c.ontop = true, true, true, true
```

A client has a position in [the stack](./client-stack.md) and in [the focus history](./focus-history.md), and both are independent of its tags.

## Wibox, wibar and widget

A wibox is a box of widgets; a wibar is a wibox docked to a screen edge.

```lua
s.mywibar = awful.wibar { position = "top", screen = s }
local popup = wibox { width = 200, height = 100, visible = true }
```

Widgets declare content, sizing and appearance for [SomeWM to lay out](./widgets-in-the-tree.md). Three kinds compose in nested tables:

| Kind | Role | Examples |
| --- | --- | --- |
| primitive | shows content | `textbox`, `imagebox`, `progressbar` |
| container | modifies one child | `background`, `margin`, `constraint` |
| layout | arranges several | `fixed`, `flex`, `align` |

```lua
wibox.widget {
    { { text = "Hello", widget = wibox.widget.textbox },
      margins = 8, widget = wibox.container.margin },
    bg = "#333333",
    widget = wibox.container.background,
}
```

## Focused and selected

| Term | Applies to | Meaning |
| --- | --- | --- |
| focused | one client in the whole compositor | receives keyboard input |
| selected | tags, several per screen | visible |

Keys go to the focused client first, then to global keybindings. The focused client is always on a selected tag.

```lua
client.focus                   -- the focused client
screen.primary.selected_tags   -- visible tags on that screen
awful.screen.focused()         -- the screen with focus
```

## Common operations

| I want to | Object | Call |
| --- | --- | --- |
| switch workspace | tag | `t:view_only()` |
| show two workspaces | tag | `awful.tag.viewtoggle(t)` |
| move a window to a workspace | client | `c:move_to_tag(t)` |
| move a window to a screen | client | `c:move_to_screen(s)` |
| close a window | client | `c:kill()` |
| toggle floating | client | `c.floating = not c.floating` |
| focus the next window | client | `awful.client.focus.byidx(1)` |
| focus the next screen | screen | `awful.screen.focus_relative(1)` |

## Navigating between objects

```lua
c.screen        c:tags()        c.first_tag
s.output        s.tags          s.selected_tags    s.clients    s.geometry    s.workarea
t.screen        t:clients()     t.selected         t.layout
```

## Signals

Objects emit signals when they change; connect to react ([Signals](./signals.md)).

| Object | Signal | When |
| --- | --- | --- |
| output | `added`, `removed`, `property::scale` | monitor plugged or unplugged, scale changed |
| screen | `added`, `removed` | screen created or destroyed |
| client | `request::manage`, `focus`, `unfocus`, `property::name` | new client, focus moved, title changed |
| tag | `property::selected` | visibility changed |

```lua
client.connect_signal("request::manage", function(c) print("New client: " .. c.name) end)
screen.connect_signal("added", function(s) end)
```
