---
sidebar_position: 0
title: The Object Model
description: How outputs, screens, tags, clients and widgets relate.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# The Object Model

Outputs describe connected displays. Screens hold tags and panels. Tags select which application windows are visible, and widgets provide the content of panels, popups and titlebars.

## The Core Objects

### Output <SomewmOnly />

An `output` represents a display connector such as `HDMI-A-1` or `eDP-1`. It exposes hardware information and display settings, including mode, position, scale and enabled state.

Disabling an output removes its screen but keeps the output object. Re-enabling it creates a screen again. Disconnecting the display invalidates the output object.

```lua
for o in output do
    print(o.name, o.make, o.enabled)
end
```

Use `output.get_by_name("HDMI-A-1")` to find a connector. `o.screen` is its active screen, or `nil` when disabled.

### Screen

A `screen` represents an active display area, including a virtual output in a nested session. `s.geometry` gives its logical position and size. `s.workarea` excludes reserved panel space.

`s.tags` lists its tags, and `s.selected_tags` lists those currently shown. `screen.primary` identifies the primary screen. `awful.screen.focused()` selects a screen using the focus policy.

### Tag

A tag is a label assigned to clients on a screen. A client can have several tags, and a screen can display several selected tags at once. Each tag belongs to one screen.

`t:view_only()` selects one tag. `awful.tag.viewtoggle(t)` toggles its selection without clearing the others. Layout settings such as `master_width_factor` belong to tags.

### Client

A `client` represents a managed application window. It has a screen, tag membership and properties such as `name`, `class`, `floating`, `minimized` and `fullscreen`.

`client.get()` lists managed clients. `client.focus` is the client selected for keyboard focus, or `nil`. Layer-shell panels and launchers are separate surfaces, not clients.

```lua
local c = client.focus
if c then
    print(c.name, c.screen.index)
    for _, t in ipairs(c:tags()) do
        print(t.name)
    end
end
```

Client layout order, [visual stacking](client-stack.md) and [focus history](focus-history.md) are separate.

### Wibox and Wibar

A `wibox` is a compositor-owned window containing a widget. An `awful.wibar` attaches a wibox to a screen edge and normally reserves space in the workarea. An `awful.popup` sizes and positions a wibox around its content.

### Widget

Widgets compose by nesting content inside containers and layouts:

| Type | Purpose | Examples |
| --- | --- | --- |
| Content | Display text, images or values | `textbox`, `imagebox`, `progressbar` |
| Container | Wrap a child | `background`, `margin`, `constraint` |
| Layout | Arrange children | `fixed`, `flex`, `align` |

```lua
local wibox = require("wibox")
local greeting = wibox.widget {
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

Assign `greeting` to a wibox's `widget` property to display it. The [widget tutorial](../tutorials/widgets.md) covers creating and updating widgets.

## The Hierarchy

An enabled output has a screen. The screen owns tags and may have wibars. Clients belong to a screen and can share several of its tags. Wibars and other wiboxes contain widget trees.

Tags therefore do not form an exclusive parent-child tree of windows. The same client can appear in several tag lists.

## Focus vs Selection

| Term | Meaning |
| --- | --- |
| Focused client | The client selected to receive keyboard input |
| Selected tag | A tag whose clients are shown on its screen |
| Stacking order | Which overlapping window appears in front |

Selecting tags changes visibility. Focusing a client and raising it are separate operations, although activation helpers can request both.

### Focus flow

The compositor checks input handlers and keybindings before forwarding unhandled events to the focused application. Keygrabbers, session locks and layer-shell surfaces can receive input instead of a client.

## Common Operations

| Action | API |
| --- | --- |
| Select one tag | `t:view_only()` |
| Toggle a tag's visibility | `awful.tag.viewtoggle(t)` |
| Move a client to a tag | `c:move_to_tag(t)` |
| Move a client to a screen | `c:move_to_screen(s)` |
| Request that a client close | `c:kill()` |
| Toggle floating | `c.floating = not c.floating` |
| Focus the next client in client order | `awful.client.focus.byidx(1)` |
| Focus the next screen | `awful.screen.focus_relative(1)` |

## Accessing Objects

<span id="from-anywhere" />
<span id="from-a-client" />
<span id="from-a-screen" />
<span id="from-a-tag" />

| Starting point | Related objects |
| --- | --- |
| Global | `client.get()`, `client.focus`, `screen.primary`, `output.get_by_name(name)` |
| Client `c` | `c.screen`, `c:tags()`, `c.first_tag` |
| Screen `s` | `s.output`, `s.tags`, `s.selected_tags`, `s.clients` |
| Tag `t` | `t.screen`, `t:clients()`, `t.layout` |

## Signals: Reacting to Changes

Objects emit signals for events such as `manage`, `focus`, `property::name` and `property::selected`. Handlers receive the emitting object for instance signals. Global signals have their own argument lists. See [Signals](signals.md).

## Next Steps

- [Architecture](architecture.md)
- [Basics](../tutorials/basics.md)
- [Widgets](../tutorials/widgets.md)
