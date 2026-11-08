---
title: Animation
description: Animation properties, effects, types, defaults and limits.
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Animation <SomewmOnly />

SomeWM animates client geometry, panel visibility and selected widget properties. Durations are in seconds. The configuration differs by object:

| Object | Setting | What it does |
| --- | --- | --- |
| Wibox, popup or wibar | [`panel.animation.visible`](#wiboxes-popups-and-wibars) | Animates the panel's frame when it appears, disappears, moves or resizes. |
| Widget, container or layout | [`widget.animation`](#widgets) | Animates selected property changes, such as a background colour or requested width. |
| Application window | [`c.animation`](#clients) | Animates events such as opening, closing, changing focus or moving between tiled positions. |
| All objects | [`somewm.animation.enabled`](#global-settings) | Enables or disables animation globally. |

Properties select **what changes**. Effects select **how an object appears or disappears**. Neither sets the target size, position or colour; those values still come from the object's properties and layout.

For working examples, see [Animate clients, popups and widgets](../guides/animation.md).

## Panels: `panel.animation.visible` {#wiboxes-popups-and-wibars}

Applies to `awful.popup`, `awful.wibar` and `wibox` objects. `visible` is the only accepted key in `panel.animation`. It controls animation when the panel appears, disappears or changes while visible.

```lua
panel.animation = {
    visible = {
        duration = 0.3,
        properties = { "width" },
    },
}
panel.width = 300
```

On an already drawn wibox, this animates its width from the displayed value to 300 logical pixels over 0.3 seconds. An `awful.popup` derives its size from its contents and constraints; see [Animate a viewport](../guides/animation.md#animate-a-viewport) for a popup example.

### Configuration fields {#transition-fields}

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `duration` | number | `0` | Duration in seconds, from 0 to 1,000,000. Applies to appearance, disappearance and changes while visible. No theme fallback. |
| `enter` | string or nonempty list | Unset | [Effect](#effects) when the panel appears. |
| `exit` | string or nonempty list | Unset | [Effect](#effects) when the panel disappears. Removal is immediate without an exit effect. |
| `exit_order` | string | `"natural"` | Drawing order during disappearance. Values listed below. |
| `properties` | string or nonempty list | [Depends on effects](#selection-defaults) | Selects which frame changes animate over `duration`. Other changes apply immediately, subject to the effect rules below. |

**`exit_order` values**

| Value | Description |
| --- | --- |
| `"above"` | Draws the disappearing item above its siblings. |
| `"natural"` | Preserves its drawing order among siblings. |
| `"underneath"` | Draws the disappearing item below its siblings. |

`exit_order` does not change the panel's stacking layer.

**Additional accepted fields**

| Field | Type | Default | Behaviour on panels |
| --- | --- | --- | --- |
| `exit_duration` | number | `duration` | No separate timing effect. Exits use `duration`. |
| `tag_duration` | number | `duration` | No separate timing effect. Tag-departure timing applies only to client declarations. |
| `tag_exit` | string or nonempty list | Unset | Exit effect used when `exit` is absent. Does not attach the panel to a tag. |

### Animated properties {#transition-property-selectors}

`panel.animation.visible.properties` accepts a string or a nonempty list of strings. Unselected properties change immediately, except where an [effect adds them](#selection-defaults).

**Size and position**

| Value | Animated properties | What it does |
| --- | --- | --- |
| `"box"` | Position, width and height | Moves and resizes the frame together when its geometry changes. |
| `"height"` | Height | Expands or contracts the frame vertically to its new height. Width and position changes apply immediately. |
| `"position"` | Horizontal and vertical position | Moves the frame to its new location. Size changes apply immediately. |
| `"size"` | Width and height | Expands or contracts the frame in both dimensions. Position changes apply immediately. |
| `"width"` | Width | Expands or contracts the frame horizontally to its new width. Height and position changes apply immediately. |

These rows describe each selector used alone. A list combines them; `{ "position", "width" }` animates movement and horizontal resizing while height changes apply immediately.

**Appearance**

| Value | Animated properties | What it does |
| --- | --- | --- |
| `"background"` | Frame background colour | Blends from the old fill colour to the new one. Does not affect a background drawn separately inside the frame. |
| `"border"` | Border colour and thickness | Blends the outline colour and thickens or thins the outline together. |
| `"border_color"` | Border colour | Blends from the old outline colour to the new one. Thickness changes apply immediately. |
| `"border_width"` | Border thickness | Thickens or thins the outline to its new width. Colour changes apply immediately. |

Custom shapes restrict these animations; see [Panel limits](#colour-and-border-limits).

**Unsupported values**

| Value | Behaviour |
| --- | --- |
| `"bg"` | Invalid. Background widgets use [`widget.animation.bg`](#widgets). |
| `"corner_radius"` | Accepted with a warning. Radius changes are immediate. |
| `"forced_width"` | Invalid. Widgets use [`widget.animation.forced_width`](#widgets). |
| `"opacity"` | Invalid. Visibility fading uses the [`fade` effect](#effects). |
| `"x"`, `"y"` | Invalid. Use `"position"` for both axes. |

### Default animated properties {#selection-defaults}

When `properties` is omitted, `enter` and `exit` determine what animates.

| Effect | Default animated properties | Changes while visible |
| --- | --- | --- |
| No effect or `"none"` | Position, width and height | Moves and resizes the frame over `duration`. `"none"` disables the appearance or disappearance effect, not these geometry animations. |
| `"fade"` | Transparency | Size and position changes apply immediately. Add `properties` to animate them too. |
| `"grow"` or `"collapse"` | Width and height | Resizes the frame over `duration`. Position changes apply immediately. |
| Any `scale` effect | Displayed scale | Size and position changes apply immediately. The visibility effect scales the image without changing layout size. |
| Any `slide` effect | Position | Moves the frame over `duration`. Size changes apply immediately. |
| Combined effects | All properties required by the selected effects | For example, `fade` with `slide_left` also animates position changes. |

An explicit `properties` list restricts `grow` to the selected dimensions. Slide effects always add position. Fade and scale effects still apply with an explicit list. `tag_exit` does not determine these defaults.

### Panel limits {#colour-and-border-limits}

| Property | Limit |
| --- | --- |
| Background colour | `"background"` does not animate `panel.bg` when the background is drawn separately from the frame. A background widget can animate its own `bg`. |
| Border colour and thickness | Custom shape paths change these immediately. Path-shaped panel borders also render nonzero red, green and blue channels at full intensity. For example, `#83a598` renders white. |
| Width and height | Resizing does not keep the contents at a fixed size. The [viewport example](../guides/animation.md#animate-a-viewport) supplies that constraint. Borders follow the changing frame size, including custom shapes. |

## Effects {#effects}

Accepted by panel `enter` and `exit`, client `appear`, `disappear` and `tag`, and the corresponding theme fields. An effect describes the starting state when appearing and the final state when disappearing.

**Visibility**

| Value | On appearance | On disappearance |
| --- | --- | --- |
| `"fade"` | Fades from transparent to the object's configured opacity. | Fades to transparent. |
| `"none"` | Appears immediately. | Disappears immediately. |

**Size**

| Value | On appearance | On disappearance |
| --- | --- | --- |
| `"collapse"` | Same as `"grow"`. | Same as `"grow"`. |
| `"grow"` | Expands the frame from zero to its target size. | Contracts the frame to zero size. |
| `"scale"` | Enlarges the entire image from zero around its centre. | Shrinks the image into its centre. |
| `"scale_bottom"` | Enlarges the image with its bottom edge's midpoint fixed. | Shrinks the image into its bottom edge's midpoint. |
| `"scale_left"` | Enlarges the image with its left edge's midpoint fixed. | Shrinks the image into its left edge's midpoint. |
| `"scale_right"` | Enlarges the image with its right edge's midpoint fixed. | Shrinks the image into its right edge's midpoint. |
| `"scale_top"` | Enlarges the image with its top edge's midpoint fixed. | Shrinks the image into its top edge's midpoint. |

`grow` changes width and height. On panels, an explicit `properties` list restricts it to the selected dimensions: `properties = "width"` produces a horizontal expansion or contraction. Scale effects preserve layout size and scale the contents with the frame. Pointer targeting follows the displayed size and position.

**Position**

| Value | On appearance | On disappearance |
| --- | --- | --- |
| `"slide_down"` | Moves in from the screen's bottom edge. | Moves out towards the screen's bottom edge. |
| `"slide_left"` | Moves in from the screen's left edge. | Moves out towards the screen's left edge. |
| `"slide_right"` | Moves in from the screen's right edge. | Moves out towards the screen's right edge. |
| `"slide_up"` | Moves in from the screen's top edge. | Moves out towards the screen's top edge. |

**Effect lists**

| Combination | Behaviour |
| --- | --- |
| One slide, one size effect and `fade` | Run together with one duration. Any subset is accepted. |
| Repeated effect | No additional effect. |
| Multiple slides or multiple size effects | Warns and keeps the first effect in that group. |
| `none` with another effect | Warns and keeps the first choice. |

## Widgets: `widget.animation` {#widgets}

Each entry maps a property name to a duration in seconds. Only named properties animate. Theme durations do not enable widget animation.

```lua
box.animation = { bg = 0.3, forced_width = 0.2 }
box.bg = "#ff0000"
box.forced_width = 300
```

Here `box` is a `wibox.container.background` that has already been drawn. The fill blends to red and the widget resizes to the width allowed by its layout. Properties drawn as one item share the longest duration; see [Widget limits](#widget-limits).

| Property | Available on | What it does |
| --- | --- | --- |
| `bg` | `wibox.container.background` | Blends the solid fill from its previous colour to the newly assigned `bg`. |
| `border_color` | `wibox.container.background` | Blends the outline from its previous colour to the newly assigned `border_color`. |
| `border_width` | `wibox.container.background` | Thickens or thins the outline to the newly assigned `border_width`. |
| `forced_height` | Supported widgets, containers and layouts | Expands or contracts the widget vertically when its requested height changes, subject to the surrounding layout's sizing rules. |
| `forced_width` | Supported widgets, containers and layouts | Expands or contracts the widget horizontally when its requested width changes, subject to the surrounding layout's sizing rules. |
| `value` | `wibox.widget.progressbar`, `wibox.widget.slider` | Lengthens or shortens the filled portion of the bar to represent the new value. A slider's handle moves immediately. |

### Widget limits

| Condition | Behaviour |
| --- | --- |
| First appearance | Immediate. Animation applies to later changes. |
| Multiple properties drawn as one item | All use the longest configured duration, including properties assigned `0`. A progressbar or slider's fill can have a separate duration. |
| Gradient background | `bg` changes warn and apply immediately. |
| Custom shape path | `bg`, `border_color` and `border_width` changes warn and apply immediately. Solid rounded rectangles support these animations. |
| Unsupported property name | Warns and changes immediately. Includes `visible`, `x`, `y` and `shape`. |
| Layout spacing change | Moves children immediately. Their selected sizes can still animate. |

### `widget:animate(args)` {#one-change-with-animate}

Animates one change. Available on widgets, not clients, wiboxes or popups.

| Argument | Type | Required | Description |
| --- | --- | --- | --- |
| `duration` | number | Yes | Duration in seconds, from 0 to 1,000,000. |
| Property names | Property-specific values | No | New values to assign. Supported animations are listed in [`widget.animation`](#widgets). |

Setters run immediately. `widget.animation` remains unchanged. Later assignments use those settings, or change immediately when none are set. Disabling animation does not prevent `:animate` from assigning its values.

## Clients: `c.animation` {#clients}

Applies to application windows. Also accepted as `animation` in a client rule's `properties` table.

```lua
c.animation = { layout = 0.15, focus = 0.1 }
```

This client moves and resizes over 0.15 seconds when its layout changes. Focus border colours blend over 0.1 seconds if the configuration changes them.

| Event | Accepted value | Description |
| --- | --- | --- |
| `appear` | Duration, effect, effect list or `false` | First appearance. Requires an effect to animate. |
| `disappear` | Duration, effect, effect list or `false` | Closing. Requires an effect to animate. The remaining frame, including the border and titlebars, can animate. The client content disappears on the first frame. |
| `floating` | Duration | Moves and resizes the window to its new geometry when switching between floating and tiled states. |
| `focus` | Duration | Focus changes. Animates border colour if the configuration changes it. |
| `layout` | Duration | Moves and resizes tiled windows into their new positions, including tiled resizing and carousel scrolling. |
| `maximize` | Duration | Moves and resizes the window when entering or leaving maximised or fullscreen states. |
| `tag` | Duration, effect, effect list or `false` | Visibility changes on tag/view changes. Default effect is `grow`. |

**Values for `appear`, `disappear` and `tag`**

| Value | Duration | Effect |
| --- | --- | --- |
| Number | Supplied number of seconds. | Theme effect, with `grow` as the tag fallback. |
| Effect name or list | Theme duration. | Supplied effect or list. |
| `false` | Theme duration still applies. | Disables this event's effect, including the theme effect and tag fallback. |

Nested tables such as `appear = { duration = 0.3 }` are invalid. Simultaneous geometry and focus changes use the longer duration.

### Theme variables {#theme-defaults-and-precedence}

Fields on the table returned by `theme.lua`, or on `beautiful` after loading the theme. Apply to clients, not panels or widgets.

| Variable | Type | Default | What it does |
| --- | --- | --- | --- |
| `animation_appear` | string or nonempty list | Unset | Selects how a new window appears, such as fading in or sliding in from an edge. |
| `animation_appear_duration` | number | Unset | Sets how many seconds the appearance effect takes. Requires an appearance effect. |
| `animation_disappear` | string or nonempty list | Unset | Selects how a closing window's remaining frame disappears. |
| `animation_disappear_duration` | number | Unset | Sets how many seconds the disappearance effect takes. Requires a disappearance effect. |
| `animation_duration` | number | Unset | Supplies a duration in seconds for client events without a more specific duration. |
| `animation_floating_duration` | number | Unset | Sets how long the window moves and resizes when switching between floating and tiled states. |
| `animation_focus_duration` | number | Unset | Sets how long the border blends to its new colour when focus changes. |
| `animation_layout_duration` | number | Unset | Sets how long tiled windows move and resize after a layout change or carousel scroll. |
| `animation_maximize_duration` | number | Unset | Sets how long the window moves and resizes when entering or leaving maximised or fullscreen states. |
| `animation_tag` | string or nonempty list | `"grow"` | Selects how windows enter and leave the view when switching tags. |
| `animation_tag_duration` | number | Unset | Sets how many seconds the tag appearance and disappearance effects take. |

All durations are in seconds. An unset duration uses the next fallback below; an effect alone does not enable animation.

**Duration precedence, first match wins**

1. Numeric `c.animation[event]`.
2. `beautiful.animation_<event>_duration`.
3. `beautiful.animation_duration`.
4. `somewm.animation.layout_duration` for `layout`, otherwise `0`.

An explicit `0` stops the fallback search. Effects use the object's setting before the theme, with `grow` as the tag fallback.

## Global settings: `somewm.animation` {#global-settings}

Accessed with `require("somewm.animation")`.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | boolean | `true` | Enables all animations. Setting `false` completes active animations on the next drawn frame. Re-enabling affects future changes only. |
| `layout_duration` | number | `0` | Sets how many seconds client layout movement and resizing take when neither the object nor the theme supplies a duration. |

Requiring the deprecated `somewm.layout_animation` module sets `layout_duration` to `0.15`. Its `duration` and `enabled` fields read and write the corresponding settings above.

## Assignment and disabling {#updating-and-disabling-policies}

| Assignment | Behaviour |
| --- | --- |
| `object.animation = table` | Copies and applies valid settings. Emits `property::animation` and requests an update. |
| `object.animation = false` | Disables the object and all widgets inside it, including a client's titlebar widgets. |
| `object.animation = nil` | Removes local settings. Client theme defaults and settings on contained widgets can apply again, unless an ancestor disables animation. |
| Duration of `0` | Applies changes immediately. Does not disable contained widgets. Properties drawn as one widget item still share the longest duration. |

Reading a valid `.animation` settings table returns a copy. Changing that copy has no effect until it is assigned back to `.animation`. Invalid tables are preserved by reference; see [Validation and runtime limits](#validation-and-limits).

## Custom descriptions: `transition` {#custom-declarations}

Available on an element in a [custom widget or client-layout description](../guides/custom-widgets.md). Accepts the same [fields](#transition-fields), [properties](#transition-property-selectors) and [effects](#effects) as `panel.animation.visible`.

| Setting or condition | Behaviour |
| --- | --- |
| Changes to `w`, `h`, `bg` and other selected fields | Supply new values for that element's animation. |
| Element identity | Must remain stable between descriptions to animate the same element. |
| Element removal | An exit effect keeps it drawn until the animation finishes. It no longer reserves layout space. |
| `exit_duration` | Separate duration for client disappearance only. Other elements use `duration`. |
| `tag_duration` | Separate duration for client tag departure only. Other elements use `duration`. |

## Validation and runtime limits {#validation-and-limits}

| Setting or condition | Contract |
| --- | --- |
| `.animation` type | Accepts a table, `false` or `nil`. Other value types raise an error. Only plain tables without a metatable can supply animation settings. |
| Wrong table structure or table with a metatable | Preserved by reference without enabling animation. Warns once per object. Clients can still use theme defaults. |
| Invalid panel field value | Unknown property name, effect, exit order or out-of-range duration in a correctly structured table raises an error on assignment. |
| Invalid client or widget description | Rejected when compiled for drawing. |
| Duration | Seconds from 0 to 1,000,000. |
| Timing curve | Starts faster and slows near the end. Not configurable. |
| Additional timing controls | No `delay`, `easing`, `repeat`, `on_complete` or `on_update` fields. |
| Animation capacity | 200 drawing elements per screen, including configured elements waiting for changes. Warns when full. Additional elements change immediately. |
| Active `mousegrabber` | Suppresses animation during the grab. Changes apply immediately. |
| Lua property readback | Returns the requested final value, including while animation is running. The [tree dump](../concepts/reading-the-tree.md) shows current displayed geometry. |
| Geometry | Rounded to whole logical pixels. |

## See also

- [Animate clients, popups and widgets](../guides/animation.md): configuration examples and demonstrations.
- [Clients in the Tree](../concepts/clients-in-the-tree.md): the geometry that client animations change.
- [Reading the Tree](../concepts/reading-the-tree.md): inspect requested and displayed geometry during an animation.
