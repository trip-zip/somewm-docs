---
sidebar_position: 5.5
title: Carousel Layout
description: Your first session with the scrollable tiling carousel
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Carousel Layout <SomewmOnly />

<span id="1-enable-the-carousel-layout" />
<span id="2-open-windows" />
<span id="3-navigate-between-columns" />
<span id="4-resize-columns" />
<span id="5-stack-windows-vertically" />
<span id="6-set-up-gesture-scrolling" />
<span id="7-choose-a-centering-mode" />
<span id="whats-next" />

Set up a scrollable row of window columns, then resize and stack three terminals. Start with the default 2.0 `rc.lua` and an installed terminal.

## Enable the layout

In the existing `request::default_layouts` handler, replace the layout list with:

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.carousel,
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.max,
    })
end)
```

Replace the handler rather than adding a second one. Reload with **Mod4+Ctrl+r**, then cycle with **Mod4+Space** until carousel is selected. Reload can preserve an existing tag's layout.

## Open three terminals

Press **Mod4+Return** three times. Each terminal gets a column, one viewport wide by default. The viewport scrolls to the focused column, so earlier terminals move offscreen.

Use **Mod4+j** and **Mod4+k** to change focus. Focusing an offscreen column brings it into view.

## Add controls

Add this block after `modkey` is defined:

```lua
local carousel = awful.layout.suit.carousel
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "Home", carousel.focus_first_column,
        { description = "first column", group = "carousel" }),
    awful.key({ modkey }, "End", carousel.focus_last_column,
        { description = "last column", group = "carousel" }),
    awful.key({ modkey }, "bracketright", function()
        carousel.cycle_column_width()
    end, { description = "cycle column width", group = "carousel" }),
    awful.key({ modkey, "Control" }, "bracketright", function()
        carousel.consume_window(1)
    end, { description = "stack from right", group = "carousel" }),
    awful.key({ modkey, "Control" }, "bracketleft", function()
        carousel.expel_window()
    end, { description = "separate window", group = "carousel" }),
})
```

Reload and select carousel again if needed.

1. Press **Mod4+Home** to focus the first column.
2. Press **Mod4+]** several times. Its width cycles through one-third, one-half, two-thirds, and full viewport width. Narrow columns reveal neighbours.
3. With a column to its right, press **Mod4+Ctrl+]**. A window from that column joins the focused column, stacked vertically.
4. Focus either stacked window, then press **Mod4+Ctrl+[**. It moves into its own column.

For exact widths and more stacking actions, see [column widths](../guides/carousel-column-widths.md) and [stacking](../guides/carousel-stacking.md).

## Try centring and gestures

Add this after the controls:

```lua
beautiful.carousel_center_mode = "always"
```

Reload, make a column half-width, and focus it. It should remain centred. The default `"on-overflow"` mode scrolls when part of the focused column is outside the viewport. The theme value overrides `carousel.center_mode`.

If you have a touchpad, add:

```lua
awful.layout.suit.carousel.make_gesture_binding()
```

Reload and swipe horizontally with three fingers. The viewport pans, then snaps when the gesture ends. See [gesture scrolling](../guides/carousel-gestures.md) for custom bindings and [centring modes](../guides/carousel-centering.md) for the other modes.
