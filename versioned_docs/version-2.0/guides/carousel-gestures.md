---
sidebar_position: 2.8
title: "Carousel: Gestures"
description: Set up touchpad gesture scrolling for the carousel layout
---

import SomewmOnly from '@site/src/components/SomewmOnly';
import YouWillLearn from '@site/src/components/YouWillLearn';

# Carousel: Gestures <SomewmOnly />

<YouWillLearn>

- How to enable 3-finger swipe viewport panning
- How the gesture tracking and snap behavior works
- How to set up gestures for the vertical variant
- How to adjust scroll animation speed
- How to remove a gesture binding

</YouWillLearn>

## Enable 3-Finger Swipe

One line in your `rc.lua` enables touchpad gesture scrolling:

```lua
awful.layout.suit.carousel.make_gesture_binding()
```

This creates a 3-finger swipe binding that pans the carousel viewport horizontally. Place it after your keybinding setup.

## How It Works

The gesture has three phases:

1. **Trigger.** When a 3-finger swipe begins on a screen using the carousel layout, the current animation is stopped and the starting scroll position is recorded.
2. **Track.** During the swipe, the viewport follows your fingers 1:1. Moving three fingers left scrolls the strip to the right (revealing columns on the right).
3. **Snap.** On release, the viewport animates to center the column nearest to the viewport's center and focuses that column's first client.

The snap animation uses the same `scroll_duration` and easing curve as keyboard-driven scrolling.

## Vertical Variant

For the vertical carousel, use the vertical gesture binding:

```lua
awful.layout.suit.carousel.vertical.make_gesture_binding()
```

This responds to vertical 3-finger swipes (dy axis) instead of horizontal.

You can enable both if you use both carousel orientations:

```lua
local carousel = awful.layout.suit.carousel
carousel.make_gesture_binding()
carousel.vertical.make_gesture_binding()
```

## Adjust Animation Speed

The snap animation on release uses `carousel.scroll_duration`. To make it faster or slower:

```lua
-- Snappy 100ms snap
awful.layout.suit.carousel.scroll_duration = 0.1

-- Slower 400ms snap
awful.layout.suit.carousel.scroll_duration = 0.4

-- Instant snap (no animation)
awful.layout.suit.carousel.scroll_duration = 0
```

This also affects keyboard-driven scroll animations.

## Remove a Gesture Binding

`make_gesture_binding()` returns a gesture binding object. Store it and call `:remove()` to unbind:

```lua
local carousel = awful.layout.suit.carousel
local binding = carousel.make_gesture_binding()

-- Later, to remove it:
binding:remove()
```

## See Also

- **[Carousel API Reference](/docs/reference/awful/carousel)** - Full property and function documentation
- **[Centering Modes Guide](/docs/guides/carousel-centering)** - Control how the viewport follows focus
- **[Scrollable Tiling](/docs/concepts/scrollable-tiling)** - How the animation system works
