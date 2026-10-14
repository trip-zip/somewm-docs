---
sidebar_position: 11
title: Animation
description: Ease layout changes, client appearance, focus borders, wibox visibility and widget properties from the theme, a rule or one field, and turn any of it off.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Animation <SomewmOnly />

SomeWM animates by declaring a transition on a node of the tree and letting the solver move it. Nothing is interpolated in Lua. Every animation is off until a duration is set, and a duration of 0 is off.

The `.animation` property stores a persistent policy on clients, wiboxes and widgets. The widget method `:animate{...}` requests one change without replacing that policy. Policy assignments emit `property::animation`.

## Layout changes

Set the layout duration and every client box eases to its new place on a resize, a tag's layout change or a carousel scroll. When a client maps or closes, the other clients ease. The client itself appears or goes in one frame unless it has an entrance.

```lua
theme.animation_layout_duration = 0.15   -- seconds
```

From code, `somewm.animation.layout_duration` sets it; `theme.animation_layout_duration` and `theme.animation_duration` both win over it when set. Requiring `somewm.layout_animation` still sets it to 0.15, as it did in 1.4 and 2.0, and that module is deprecated. A client's first frame after the duration is set, or after a reload, does not animate.

## Clients

A client reads its durations and entrances from `c.animation`, a table with one key per trigger, and falls back to the theme.

| Trigger | When | Theme duration | Theme entrance |
| --- | --- | --- | --- |
| `appear` | the client maps | `animation_appear_duration` | `animation_appear` |
| `disappear` | the client closes | `animation_disappear_duration` | `animation_disappear` |
| `tag` | the client enters or leaves the view with a tag switch | `animation_tag_duration` | `animation_tag`; default `grow` |
| `focus` | the border colour changes with focus | `animation_focus_duration` | |
| `maximize` | maximized or fullscreen toggles | `animation_maximize_duration` | |
| `floating` | floating toggles | `animation_floating_duration` | |

`theme.animation_duration` is the duration for every trigger that has none of its own, layout included.

An entrance is one of `grow`, `slide_left`, `slide_right`, `slide_up`, `slide_down` or `fade`. `grow` scales the frame from nothing; the slides come in from that edge of the screen; `fade` blends the frame in from invisible. The same word runs backwards on the way out.

From a rule:

```lua
ruled.client.append_rule {
    rule = { class = "mpv" },
    properties = { animation = { appear = "fade", disappear = "fade", tag = "slide_left" } },
}
```

One key holds either an entrance word or a duration. A client that names an entrance takes its duration from the theme, so this rule animates nothing until `theme.animation_appear_duration`, `animation_disappear_duration` and `animation_tag_duration` are set.

Or from the theme for every client:

```lua
theme.animation_appear = "grow"
theme.animation_appear_duration = 0.2
theme.animation_tag_duration = 0.15
theme.animation_focus_duration = 0.1
```

A number in `c.animation` is a duration for that trigger, and `c.animation.focus = 0.3` eases that one client's border over 0.3 seconds. `c.animation = false` turns every animation off for that client.

With a tag duration above 0, from `theme.animation_tag_duration`, `theme.animation_duration` or a number in `c.animation.tag`, a tag switch grows clients in and out. `c.animation.tag` or `theme.animation_tag` can name another entrance. A client on its way out animates its frame, the border and titlebars; the window's own pixels snap away on the first frame.

## Wiboxes and popups

A wibox or `awful.popup` animates its visibility:

```lua
local popup = awful.popup {
    widget = my_widget,
    animation = { visible = { duration = 0.2, enter = "fade", exit = "fade" } },
}
```

`enter` and `exit` take the same words as a client. Setting `visible` then eases the box in or out. A wibox leaving the screen keeps its box and border for the duration, and its shadow goes on the first frame.

## Widgets

A widget eases a property with `widget.animation`, a table of property to duration in seconds:

```lua
local box = wibox.container.background()
box.animation = { bg = 0.3 }
box.bg = "#ff0000"       -- eases over 0.3 s once the box has been drawn
```

A widget's first frame never animates, so the change eases only once the widget has been drawn with `animation` set.

Properties that animate:

| Widget | Properties |
| --- | --- |
| `wibox.container.background` | `bg`, `border_color`, `border_width` |
| any widget | `forced_width`, `forced_height` |
| `wibox.widget.progressbar` | `value` |
| `wibox.widget.slider` | `value` |

Any other property in the table warns once and that property snaps. On a `wibox.container.background` whose shape is not a rounded rectangle, `bg`, `border_color` and `border_width` snap and warn once. A widget's position inside its layout always snaps, so a spacing change moves it in one frame while its own size eases.

For one change without a standing field, call the method:

```lua
box:animate { bg = "#ff0000", duration = 0.3 }
```

It sets each named property and eases it once; the next plain assignment snaps again.

`widget.animation = false` turns animation off for that widget and everything inside it, including children that set their own `animation`. The `:animate{}` method remains callable and applies its values immediately while animation is disabled.

Each output keeps 200 transition records. A tree that animates more nodes than that warns once, and the nodes past the budget snap.

## Turning it all off

```lua
require("somewm.animation").enabled = false
```

Every client and widget transition then has a duration of 0, but a wibox's or popup's `animate.visible` still runs. While a `mousegrabber` runs, client and widget changes snap, so a drag never fights an easing box.

[Clients in the Tree](/docs/next/concepts/clients-in-the-tree) for the frame these transitions move.
