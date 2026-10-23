---
sidebar_position: 2.8
title: "Carousel: Gestures"
description: Set up touchpad gesture scrolling for the carousel layout
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Carousel: Gestures <SomewmOnly />

Register a three-finger touchpad swipe in `rc.lua` to pan the carousel viewport.

## Enable 3-Finger Swipe

<span id="how-it-works" />

```lua
local binding = awful.layout.suit.carousel.make_gesture_binding()
```

The binding acts when the focused screen uses the horizontal carousel. Swiping left reveals columns to the right. On release, it centres the column nearest the viewport centre and focuses that column's first client.

## Vertical Variant

For vertical carousel tags, register the vertical binding too:

```lua
local vertical_binding = awful.layout.suit.carousel.vertical.make_gesture_binding()
```

Each binding checks the active layout, so both can be registered together.

## Adjust Animation Speed

Set the snap duration in seconds:

```lua
awful.layout.suit.carousel.scroll_duration = 0.1
```

The default is `0`. Use `0` for an immediate snap. This also changes keyboard-driven scroll animations. During a swipe, the viewport follows finger movement directly.

## Remove a Gesture Binding

Keep the object returned during registration, then remove it when needed:

```lua
binding:remove()
```

## See Also

- [Carousel API](../reference/awful/carousel.md)
- [Centering Modes](carousel-centering.md)
- [Scrollable Tiling](../concepts/scrollable-tiling.md)
