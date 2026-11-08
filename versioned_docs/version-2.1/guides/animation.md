---
sidebar_position: 11
title: Animation
description: Configure layout, client, popup and widget animations.
---

import SomewmOnly from '@site/src/components/SomewmOnly'
import AnimationDemo from '@site/src/components/AnimationDemo'
import AnimationComparison from '@site/src/components/AnimationComparison.mdx'

# Animation <SomewmOnly />

Set a duration in seconds to animate layout or widget-property changes. Appearance and disappearance also need an effect, such as `fade` or `grow`. A duration of 0 applies the change immediately.

Use `.animation` for a persistent policy and `widget:animate{...}` for a single change. See [Updating a policy](#updating-a-policy) to edit an existing policy.

The [animation reference](../reference/animation.md) lists every configuration location, property, effect, default and limit.

## Layout changes

Animate client layout changes, including resize, tag layout changes and carousel scrolling:

```lua
theme.animation_layout_duration = 0.15   -- seconds
```

`somewm.animation.layout_duration` sets the duration from code. Theme values `animation_layout_duration` and `animation_duration` take precedence. The deprecated `somewm.layout_animation` module sets it to 0.15 when required. A client’s first frame after enabling it or reloading does not animate. Appearance and disappearance use separate triggers below.

<AnimationDemo name="layout" title="Layout resize and swap">
  Tiled windows ease into their new geometry when the master width changes and when the windows swap places.
</AnimationDemo>

## Clients

A client reads its durations and effects from `c.animation`, a table with one key per event, and falls back to the theme.

<div style={{overflowX: 'auto', marginBottom: '1rem'}} tabIndex={0} role="region" aria-label="Client animation triggers">

| Event | What animates | Theme duration | Theme effect |
| --- | --- | --- | --- |
| `appear` | The chosen effect brings a newly opened window into view. | `animation_appear_duration` | `animation_appear` |
| `disappear` | The chosen effect removes a closing window's remaining frame. Its client content disappears immediately. | `animation_disappear_duration` | `animation_disappear` |
| `tag` | Windows enter or leave the view when switching tags. | `animation_tag_duration` | `animation_tag`, default `grow` |
| `focus` | The border blends to its new focus colour if the configuration changes it. | `animation_focus_duration` | None |
| `layout` | Tiled windows move and resize into new positions, including during carousel scrolling. | `animation_layout_duration` | None |
| `maximize` | The window moves and resizes when entering or leaving maximised or fullscreen states. | `animation_maximize_duration` | None |
| `floating` | The window moves and resizes when switching between floating and tiled states. | `animation_floating_duration` | None |

</div>

`theme.animation_duration` is the duration for every trigger that has none of its own, layout included.

<AnimationDemo name="window-states" title="Maximise, restore, float and tile">
  The same window moves between maximised, tiled and floating states, with a different duration for each transition.
</AnimationDemo>

Choose an entrance effect:

| Effect | Behaviour |
| --- | --- |
| `grow` | Increases the frame’s layout size from zero. |
| `scale`, `scale_top`, `scale_bottom`, `scale_left`, `scale_right` | Scales the rendered image around its centre or an edge midpoint. Layout size stays unchanged. See [Scale](#scale). |
| `slide_left`, `slide_right`, `slide_up`, `slide_down` | Slides from that screen edge. |
| `fade` | Increases opacity from transparent. |

Exits reverse the effect.

A list runs several effects together in one transition, with one duration:

```lua
theme.animation_appear = { "fade", "slide_left" }
```

- One slide, one size effect (`grow` or one of the scale words) and `fade` combine, in any order.
- A second slide direction, or a second size effect, warns once and the first one named stays.
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

The `appear`, `disappear` and `tag` triggers accept an effect name, a list of effects, or a duration. Other triggers accept durations. Effects use their trigger’s theme duration, falling back to `theme.animation_duration`. The duration must be above 0.

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

Tag transitions default to `grow`. Override the effect with `c.animation.tag` or `theme.animation_tag`. On exit, the remaining frame, including the border and titlebars, animates. The client content disappears on the first frame.

<AnimationDemo name="grow-shrink" title="Grow and shrink">
  Growing entrances and shrinking exits on clients, tag changes and a popup, shown with different durations.
</AnimationDemo>

### Scale

<AnimationComparison />

`scale` transforms the client content, border and titlebars together. Its directional variants keep the named edge’s midpoint fixed. Layout and configure sizes stay unchanged, so neighbours stay in place and clients need not redraw. Pointer events follow the scaled image, including `mouse::enter`.

```lua
ruled.client.append_rule {
    rule = { class = "mpv" },
    properties = { animation = { appear = "scale_top", disappear = "scale_top" } },
}
```

During a transition, `somewm-client clay tree` reports both layout and display geometry. In `scale 0.715333 anchor top presented 29,32 146x161 box 0,32 204x225`, `presented` is the scaled image and `box` is the layout slot.

A popup can scale and fade in together and scale out from its bottom edge:

```lua
local popup = awful.popup {
    visible = false,
    widget = wibox.widget.textbox("hello"),
    placement = awful.placement.centered,
    animation = { visible = { duration = 1, enter = { "scale", "fade" }, exit = "scale_bottom" } },
}
popup.visible = true
```

The dump reports both `fade_alpha` and `scale`. They complete together. `grow` and `scale` conflict, so only the first effect is used.

## Wiboxes and popups

A wibox or `awful.popup` uses `animation.visible` for its frame transition. With entrance and exit effects, it animates visibility:

```lua
local popup = awful.popup {
    visible = false,
    widget = require("wibox").widget.textbox("hello"),
    animation = { visible = { duration = 0.2, enter = "fade", exit = "fade" } },
}
popup.visible = true
```

`enter` and `exit` take the same words and lists as a client. Setting `visible` then eases the box in or out. A wibox leaving the screen keeps its box and border for the duration, and its shadow goes on the first frame.

<AnimationDemo name="slides" title="Directional slides">
  A popup enters and exits using `slide_left`, `slide_right`, `slide_up` and `slide_down`.
</AnimationDemo>

The same policy animates frame changes while the popup stays visible. Select the fields to interpolate, then assign a new target:

```lua
popup.animation = {
    visible = { duration = 0.3, properties = { "width" } },
}
popup.maximum_width = 300
```

`maximum_width` is a limit, not a forced size. The contents must request that much width. See the [complete selector list](../reference/animation.md#transition-property-selectors).

### Animate a viewport

Keep the contents at a fixed size and animate the frame that clips them. This lets a panel open without reflowing its text or moving its buttons. The border follows the visible frame.

Add this after loading your theme in `rc.lua`, or in a module required from there. Left-click the panel to toggle its width; right-click to hide it.

```lua
local awful = require("awful")
local wibox = require("wibox")
local shape = require("gears.shape")

local s = awful.screen.focused()
local area = s.workarea
local contents = wibox.container.background(
    wibox.widget.textbox("The contents keep their full width"), "#282828")
contents.fg = "#ffffff"

local panel = awful.popup {
    screen = s, x = area.x + 24, y = area.y + 24,
    visible = true, ontop = true, shadow = false,
    bg = "#00000000", border_color = "#ffffff", border_width = 2,
    maximum_width = 60,
    widget = wibox.container.constraint(contents, "exact", 300, 100),
    animation = {
        visible = { duration = 0.3, properties = { "width" } },
    },
}
panel.shape = shape.transform(shape.rounded_rect)

local expanded = false
panel:buttons {
    awful.button({}, 1, function()
        expanded = not expanded
        panel.maximum_width = expanded and 300 or 60
    end),
    awful.button({}, 3, function() panel.visible = false end),
}
```

The exact constraint keeps the contents at 300 × 100. The popup limits the visible width to 60 or 300. SomeWM interpolates between those targets; no Lua timer is needed.

The transparent popup puts the fill on the fixed-size child. Assigning the transformed shape after construction keeps clipping on the animated frame's path. A plain `shape.rounded_rect` uses an optimised radius representation whose child clipping can jump to the target width during closing. The transformed shape avoids that jump. Assign it after construction because the constructor does not accept this callable shape table.

## Widgets

Set `widget.animation` to a table of properties and durations in seconds:

```lua
local box = wibox.container.background()
box.animation = { bg = 0.3 }
box.bg = "#ff0000"       -- eases over 0.3 s once the box has been drawn
```

A widget's first frame never animates, so the change eases only once the widget has been drawn with `animation` set.

Properties that animate:

<div style={{overflowX: 'auto', marginBottom: '1rem'}} tabIndex={0} role="region" aria-label="Animated widget properties">

| Widget | Properties | What animates |
| --- | --- | --- |
| `wibox.container.background` | `bg`, `border_color`, `border_width` | The fill and outline blend to their new colours; the outline thickens or thins to its new width. |
| Supported widgets, containers and layouts | `forced_width`, `forced_height` | The widget expands or contracts to its new size, subject to its surrounding layout's sizing rules. |
| `wibox.widget.progressbar` | `value` | The filled portion lengthens or shortens to represent the new value. |
| `wibox.widget.slider` | `value` | The filled portion lengthens or shortens. The handle moves to the new value immediately. |

</div>

Any other property in the table warns once and that property snaps. On a `wibox.container.background` whose shape is not a rounded rectangle, `bg`, `border_color` and `border_width` snap and warn once. A widget's position inside its layout always snaps, so a spacing change moves it in one frame while its own size eases.

For a single change:

```lua
box:animate { bg = "#ff0000", duration = 0.3 }
```

It sets each named property and eases it once. Later plain assignments use the persistent `.animation` policy, or snap if none is set.

<AnimationDemo name="widgets" title="Widget timing and pulse">
  Three widgets change size and colour at different speeds. The heart then grows and shrinks twice to make a gentle pulse.
</AnimationDemo>

When animation is disabled, `:animate{}` still applies its values immediately.

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

Assign `.animation = false` to disable an object and its descendants, including a client’s titlebar widgets. This overrides descendant policies. Assign `nil` to remove the override. Theme defaults and descendant policies then apply, unless an ancestor still disables them.

Disable all transitions with:

```lua
require("somewm.animation").enabled = false
```

Active transitions finish on the next rendered frame, including retained exits. Setting `enabled = true` enables future changes. It does not restart completed transitions or alter stored policies. A running `mousegrabber` also suppresses transitions during a drag.

See [Clients in the Tree](../concepts/clients-in-the-tree.md) for the geometry these transitions change.
