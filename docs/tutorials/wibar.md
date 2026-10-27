---
sidebar_position: 5
title: Build a bar
description: Build a custom status bar from scratch
---

# Build a bar

Replace the default 2.1 bar with a small module, keeping its existing taglist, tasklist, prompt, and layoutbox. Start with the default `rc.lua` so those widgets are already defined.

## Create the module

<span id="an-empty-bar" />
<span id="the-standard-widgets" />
<span id="complete-example" />

Save this as `wibar.lua` beside `rc.lua`:

```lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

return function(s)
    return awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 28,
        widget = {
            {
                s.mytaglist,
                s.mypromptbox,
                spacing = 8,
                layout = wibox.layout.fixed.horizontal,
            },
            s.mytasklist,
            {
                wibox.widget.systray(),
                wibox.widget.textclock(" %a %b %d, %H:%M "),
                s.mylayoutbox,
                spacing = 8,
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        },
    }
end
```

The function takes a screen and returns its bar. The outer `align.horizontal` layout gives the left and right groups their natural widths. The tasklist uses the remaining space between them. That middle region is not necessarily centred on the screen.

## Replace the default bar

<span id="if-something-is-off" />

After `beautiful.init(...)` in `rc.lua`, add:

```lua
local config_dir = gears.filesystem.get_configuration_dir()
package.path = config_dir .. "?.lua;" .. config_dir .. "?/init.lua;" .. package.path
local make_wibar = require("wibar")
```

Find the existing `request::desktop_decoration` handler. Keep its tag creation and definitions of `s.mypromptbox`, `s.mylayoutbox`, `s.mytaglist`, and `s.mytasklist`. Replace only the `s.mywibox = awful.wibar { ... }` construction with:

```lua
s.mywibox = make_wibar(s)
```

Use the existing handler. Adding another would create duplicate bars or tags.

Reload with **Mod4+Ctrl+r**. Check that the new bar shows tags, open windows, the clock, and the layout indicator. Click a tag and a tasklist entry, then press **Mod4+r** to check the run prompt.

The systray is shared across the session and displays on its configured screen, the primary screen by default. It can be empty when no applications have tray icons.

## Add your clock

<span id="separators-and-your-own-widgets" />

If you completed [Widgets](widgets.md), add this near the top of `wibar.lua`:

```lua
local my_clock = require("widgets.clock")
```

Replace the `wibox.widget.textclock(...)` entry with `my_clock`, then reload. The custom clock should appear in the same position. Keep the module import after theme initialisation in `rc.lua`.

## Change its appearance

<span id="styling" />

In the `awful.wibar` properties, after `screen = s`, add:

```lua
bg = "#282828",
fg = "#ebdbb2",
border_width = 1,
border_color = "#504945",
```

Reload to see the colours and border. Set `position = "bottom"` to move the bar to the bottom edge, then reload again. Tiled windows adjust to the space it reserves.

For a theme shared by several bars, put the corresponding `theme.wibar_*` values in your [theme file](theme.md) and remove these explicit properties. See the [wibar reference](../reference/wibox/wibar.md) for sizing, margins, and placement.

## Toggle visibility

<span id="a-second-bar-and-a-toggle" />

Add this to `rc.lua` after `modkey` is defined:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Control" }, "b", function()
        local s = awful.screen.focused()
        if s.mywibox then
            s.mywibox.visible = not s.mywibox.visible
        end
    end, { description = "toggle wibar", group = "awesome" }),
})
```

Reload and press **Mod4+Ctrl+b** twice to hide and restore the bar.
