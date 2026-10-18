---
sidebar_position: 2.8
title: "Carousel: Gestures"
description: "make_gesture_binding() pans the viewport with a three-finger swipe and snaps to the nearest column on release. The vertical variant, animation speed, and removing the binding."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Carousel: Gestures <SomewmOnly />

```lua
awful.layout.suit.carousel.make_gesture_binding()
awful.layout.suit.carousel.vertical.make_gesture_binding()   -- vertical swipes for the vertical variant; both can be active
```

A three-finger swipe on a screen in the carousel layout records the scroll position, pans the viewport with the fingers one to one (fingers left reveals columns on the right), and on release centres the column nearest the viewport's centre and focuses its first client.

The snap animates like every layout change, over the layout duration:

```lua
theme.animation_layout_duration = 0.1   -- seconds; 0 snaps instantly
```

`somewm.layout_animation` is deprecated; requiring it still sets the duration to 0.15. [Animation](animation.md) has the rest.

`carousel.scroll_duration` is gone and does nothing.

`make_gesture_binding()` returns the binding; `binding:remove()` unbinds it.

[Carousel reference](../reference/awful/carousel.md), [Centering](carousel-centering.md), [Scrollable Tiling](../concepts/scrollable-tiling.md).
