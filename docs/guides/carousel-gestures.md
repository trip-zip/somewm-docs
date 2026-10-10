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

The snap animates through `somewm.layout_animation` like every layout change, so its speed is that module's:

```lua
local layout_anim = require("somewm.layout_animation")
layout_anim.duration = 0.1      -- seconds
layout_anim.enabled = false     -- snap instantly
```

`carousel.scroll_duration` is gone and does nothing.

`make_gesture_binding()` returns the binding; `binding:remove()` unbinds it.

[Carousel reference](/docs/reference/awful/carousel), [Centering](/docs/guides/carousel-centering), [Scrollable Tiling](/docs/concepts/scrollable-tiling).
