---
sidebar_position: 11
title: Animation
description: Ease layout changes, client appearance, focus borders, wibox visibility and widget properties from the theme, a rule or one field, and turn any of it off.
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import AnimationDemo from '@site/src/components/AnimationDemo';

# Animation <SomewmOnly />

SomeWM animates by declaring a transition on a node of the tree and letting the solver move it. Nothing is interpolated in Lua. Every animation is off until a duration is set, and a duration of 0 is off.

The `.animation` property stores a persistent policy on clients, wiboxes, popups and widgets. Policies are copied on assignment and access. To change one, edit a copy and assign it back; assignments emit `property::animation`. The widget method `:animate{...}` requests one change without replacing that policy.

## Layout changes

Set the layout duration and every client box eases to its new place on a resize, a tag's layout change or a carousel scroll. When a client maps or closes, the other clients ease. The client itself appears or goes in one frame unless it has an entrance.

```lua
theme.animation_layout_duration = 0.15   -- seconds
```

From code, `somewm.animation.layout_duration` sets it; `theme.animation_layout_duration` and `theme.animation_duration` both win over it when set. Requiring `somewm.layout_animation` still sets it to 0.15, as it did in 1.4 and 2.0, and that module is deprecated. A client's first frame after the duration is set, or after a reload, does not animate.

<AnimationDemo name="layout" title="Layout resize and swap">
  Tiled windows ease into their new geometry when the master width changes and when the windows swap places.
</AnimationDemo>

## Clients

A client reads its durations and entrances from `c.animation`, a table with one key per trigger, and falls back to the theme.

<div style={{overflowX: 'auto', marginBottom: '1rem'}} tabIndex={0} role="region" aria-label="Client animation triggers">

| Trigger | When | Theme duration | Theme entrance |
| --- | --- | --- | --- |
| `appear` | the client maps | `animation_appear_duration` | `animation_appear` |
| `disappear` | the client closes | `animation_disappear_duration` | `animation_disappear` |
| `tag` | the client enters or leaves the view with a tag switch | `animation_tag_duration` | `animation_tag`; default `grow` |
| `focus` | the border colour changes with focus | `animation_focus_duration` | |
| `maximize` | maximized or fullscreen toggles | `animation_maximize_duration` | |
| `floating` | floating toggles | `animation_floating_duration` | |

</div>

`theme.animation_duration` is the duration for every trigger that has none of its own, layout included.

<AnimationDemo name="window-states" title="Maximise, restore, float and tile">
  The same window moves between maximised, tiled and floating states, with a different duration for each transition.
</AnimationDemo>

An entrance is one of `grow`, `slide_left`, `slide_right`, `slide_up`, `slide_down` or `fade`. `grow` scales the frame from nothing; the slides come in from that edge of the screen; `fade` blends the frame in from invisible. The same word runs backwards on the way out.

A list runs several effects together in one transition, with one duration:

```lua
theme.animation_appear = { "fade", "slide_left" }
```

- One slide, `grow` and `fade` combine, in any order.
- A second slide direction warns once and the first one named stays.
- A repeated word counts once. `collapse` is another name for `grow`.

`{ "slide_left", "slide_right" }` logs:

```
transition.enter: slide_left + slide_right conflict; slide_right is ignored, slide_left remains active
```

`none` names no entrance. Beside another effect it warns the same way. An explicit `disappear = "none"` closes the client without an animation instead of using the tag exit.

From a rule:

```lua
ruled.client.append_rule {
    rule = { class = "mpv" },
    properties = { animation = { appear = "fade", disappear = "fade", tag = "slide_left" } },
}
```

One key holds an entrance word, a list of them, or a duration. A client that names an entrance takes its duration from the theme. Each trigger in this rule animates when its own duration key (`theme.animation_appear_duration`, `animation_disappear_duration` or `animation_tag_duration`) is above 0, or when that key is unset and `theme.animation_duration` is above 0. The triggers can be enabled independently.

<AnimationDemo name="fade" title="Fade">
  A client fades in and out, followed by a popup using the same entrance and exit style.
</AnimationDemo>

Or from the theme for every client:

```lua
theme.animation_appear = "grow"
theme.animation_appear_duration = 0.2
theme.animation_tag_duration = 0.15
theme.animation_focus_duration = 0.1
```

A number in `c.animation` is a duration for that trigger. To ease one client's focus border over 0.3 seconds, reassign its policy:

```lua
local policy = c.animation or {}
policy.focus = 0.3
c.animation = policy
```

`c.animation = false` turns animation off for the client and its titlebar widgets. `c.animation = nil` removes the override so the client falls back to the theme and its titlebar widgets can use their own policies.

With a tag duration above 0, from `theme.animation_tag_duration`, `theme.animation_duration` or a number in `c.animation.tag`, a tag switch grows clients in and out. `c.animation.tag` or `theme.animation_tag` can name another entrance. A client on its way out animates its frame, the border and titlebars; the window's own pixels snap away on the first frame.

<AnimationDemo name="grow-shrink" title="Grow and shrink">
  Growing entrances and shrinking exits on clients, tag changes and a popup, shown with different durations.
</AnimationDemo>

## Wiboxes and popups

A wibox or `awful.popup` animates its visibility:

```lua
local popup = awful.popup {
    widget = my_widget,
    animation = { visible = { duration = 0.2, enter = "fade", exit = "fade" } },
}
```

`enter` and `exit` take the same words and lists as a client. Setting `visible` then eases the box in or out. A wibox leaving the screen keeps its box and border for the duration, and its shadow goes on the first frame.

Setting the wibox's or popup's `animation = false` disables its transitions and those of its child widgets. Setting `animation = nil` removes that override.

<AnimationDemo name="slides" title="Directional slides">
  A popup enters and exits using `slide_left`, `slide_right`, `slide_up` and `slide_down`.
</AnimationDemo>

## Widgets

A widget eases a property with `widget.animation`, a table of property to duration in seconds:

```lua
local box = wibox.container.background()
box.animation = { bg = 0.3 }
box.bg = "#ff0000"       -- eases over 0.3 s once the box has been drawn
```

A widget's first frame never animates, so the change eases only once the widget has been drawn with `animation` set.

Properties that animate:

<div style={{overflowX: 'auto', marginBottom: '1rem'}} tabIndex={0} role="region" aria-label="Animated widget properties">

| Widget | Properties |
| --- | --- |
| `wibox.container.background` | `bg`, `border_color`, `border_width` |
| any widget | `forced_width`, `forced_height` |
| `wibox.widget.progressbar` | `value` |
| `wibox.widget.slider` | `value` |

</div>

Any other property in the table warns once and that property snaps. On a `wibox.container.background` whose shape is not a rounded rectangle, `bg`, `border_color` and `border_width` snap and warn once. A widget's position inside its layout always snaps, so a spacing change moves it in one frame while its own size eases.

For one change without a standing field, call the method:

```lua
box:animate { bg = "#ff0000", duration = 0.3 }
```

It sets each named property and eases it once; the next plain assignment snaps again.

<AnimationDemo name="widgets" title="Widget timing and pulse">
  Three widgets change size and colour at different speeds. The heart then grows and shrinks twice to make a gentle pulse.
</AnimationDemo>

`widget.animation = false` turns animation off for that widget and everything inside it, including children that set their own `animation`. The `:animate{}` method remains callable and applies its values immediately while animation is disabled. `widget.animation = nil` removes the override; an ancestor's `animation = false` still suppresses the subtree.

Each output keeps 200 transition records, including configured records that are currently idle. When the budget is exhausted, the output warns once and the remaining nodes snap.

## Updating a policy

Clients, wiboxes, popups and widgets copy `.animation` on assignment and access. Edit a copy and assign it back to apply changes:

```lua
local policy = box.animation or {}
policy.bg = 0.5
box.animation = policy
```

Assigning an edited policy notifies `property::animation` observers and schedules the update. Editing the original table or a returned copy alone leaves the stored policy unchanged.

## Disabling animation

Assign `.animation = false` to suppress an object and its descendants, including descendants with their own policies. A client's titlebar widgets are included. Assign `nil` to remove that override; client theme defaults and descendant policies then apply again.

Disable all transitions with:

```lua
require("somewm.animation").enabled = false
```

This disables client and widget transitions and the `animation.visible` transitions on wiboxes and popups. Active transitions finish on the next rendered frame, including retained exits. Set `enabled = true` to let later changes animate again; a completed transition does not restart, and stored policies are unchanged throughout. A running `mousegrabber` suppresses the same transitions, so a drag never fights an easing box.

[Clients in the Tree](/docs/next/concepts/clients-in-the-tree) for the frame these transitions move.
