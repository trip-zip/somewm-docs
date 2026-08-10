---
sidebar_position: 5
title: Wibar
description: Build a custom status bar from scratch
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# Wibar

<YouWillLearn>

- How to attach a wibar via `request::desktop_decoration`
- The three-section align layout pattern
- How to add standard widgets, custom widgets, and separators
- How to style and toggle visibility

</YouWillLearn>

## How Wibars Work

A wibar is created with `awful.wibar` and attached to a screen. The default setup creates one wibar per screen inside the `request::desktop_decoration` signal:

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
        widget = wibox.widget.textclock(),
    }
end)
```

The `widget` property contains your entire bar layout; a single clock here, but typically a tree organized into left, center, and right sections.

## The Three-Section Pattern

Most wibars use `wibox.layout.align.horizontal` to create three sections:

```lua
widget = {
    { -- Left section
        layout = wibox.layout.fixed.horizontal,
        -- widgets go here
    },
    { -- Center section
        layout = wibox.layout.flex.horizontal,
        -- widgets go here
    },
    { -- Right section
        layout = wibox.layout.fixed.horizontal,
        -- widgets go here
    },
    layout = wibox.layout.align.horizontal,
}
```

- **Left** - Fixed width, grows from left edge
- **Center** - Takes remaining space, centers content
- **Right** - Fixed width, grows from right edge

## Creating a Wibar Factory

Create `~/.config/somewm/wibar.lua`:

```lua
-- wibar.lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Factory function that creates a wibar for each screen
return function(s)
    local wibar = awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 24,
        widget = {
            { -- Left section
                layout = wibox.layout.fixed.horizontal,
                -- We'll add widgets here
            },
            { -- Center section
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right section
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal,
        },
    }
    return wibar
end
```

Now wire it in. In your `rc.lua`, find the existing `request::desktop_decoration` handler (the one that builds the default wibar) and replace it:

```lua
local wibar = require("wibar")

screen.connect_signal("request::desktop_decoration", function(s)
    -- Create tags for this screen
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

    -- Create wibar for this screen
    s.mywibox = wibar(s)
end)
```

Reload with **Mod4 + Ctrl + r**. The default bar is gone, and in its place is a thin, completely empty strip. Empty is correct: this is *your* bar now, and you haven't put anything in it yet. Every section below adds something and ends with a reload, so you can watch it fill up.

## Adding Standard Widgets

Replace your `wibar.lua` with a version that builds the four standard widgets and places them in the three sections:

```lua
-- wibar.lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

return function(s)
    -- Create widgets that need the screen
    s.mypromptbox = awful.widget.prompt()

    s.mylayoutbox = awful.widget.layoutbox {
        screen = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
        },
    }

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        },
    }

    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({}, 3, function()
                awful.menu.client_list { theme = { width = 250 } }
            end),
        },
    }

    local wibar = awful.wibar {
        position = "top",
        screen = s,
        widget = {
            { -- Left section
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Center section
            { -- Right section
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                wibox.widget.textclock(),
                s.mylayoutbox,
            },
            layout = wibox.layout.align.horizontal,
        },
    }

    return wibar
end
```

Reload. The bar comes alive: tags 1-5 on the left, the clock and layout icon on the right, and the center fills with a button for each open window. Click a tag and the view switches; click a window's tasklist entry and it minimizes. Scroll on the taglist and you cycle tags: the buttons you declared are all live.

## Adding Custom Widgets

Widgets you build yourself (like the clock from the [Widgets tutorial](/docs/tutorials/widgets)) drop into a section the same way:

```lua
-- At the top of wibar.lua
local my_clock = require("widgets.clock")

-- In the right section:
{ -- Right section
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.systray(),
    my_clock,
    s.mylayoutbox,
},
```

Reload, and your clock renders in the bar next to the built-ins, indistinguishable from them.

## Adding Separators

Create visual separation between widget groups:

```lua
local function separator()
    return wibox.widget {
        {
            widget = wibox.widget.separator,
            orientation = "vertical",
            forced_width = 1,
            color = beautiful.fg_normal .. "40",  -- 25% opacity
        },
        margins = { left = 8, right = 8 },
        widget = wibox.container.margin,
    }
end

-- Use in your layout:
{ -- Right section
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.systray(),
    separator(),
    my_clock,
    separator(),
    s.mylayoutbox,
},
```

Reload. Faint vertical lines now separate the right-side widgets; the margins give each one room to breathe.

## Styling the Wibar

Style the bar from your theme, so it changes with your color scheme. In your `theme.lua`:

```lua
theme.wibar_bg = "#282828"
theme.wibar_fg = "#ebdbb2"
theme.wibar_height = 28
```

Reload, and the bar picks up the new background, text color, and height. (Per-bar overrides like `bg` can also be passed straight to `awful.wibar`; the [Wibar Properties Reference](/docs/reference/wibox/wibar) documents every property.)

## Complete Example

```lua
-- wibar.lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- rc.lua's modkey is a local; define our own for the taglist buttons
local modkey = "Mod4"

-- Optional: import custom widgets
-- local widgets = require("widgets")

-- Separator widget
local function separator()
    return wibox.widget {
        {
            orientation = "vertical",
            forced_width = 1,
            color = beautiful.fg_normal .. "30",
            widget = wibox.widget.separator,
        },
        top = 6,
        bottom = 6,
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    }
end

-- Wibar factory function
return function(s)
    -- Per-screen widgets
    s.mypromptbox = awful.widget.prompt()

    s.mylayoutbox = awful.widget.layoutbox {
        screen = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(-1) end),
            awful.button({}, 5, function() awful.layout.inc(1) end),
        },
    }

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        },
    }

    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({}, 3, function()
                awful.menu.client_list { theme = { width = 250 } }
            end),
            awful.button({}, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({}, 5, function() awful.client.focus.byidx(1) end),
        },
    }

    -- Create the wibar
    local wibar = awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 28,
        bg = beautiful.wibar_bg,
        fg = beautiful.wibar_fg,
        widget = {
            { -- Left section
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                separator(),
                s.mypromptbox,
            },
            { -- Center section
                s.mytasklist,
                layout = wibox.layout.flex.horizontal,
            },
            { -- Right section
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                separator(),
                awful.widget.keyboardlayout(),
                separator(),
                wibox.widget.textclock(" %a %b %d, %H:%M "),
                separator(),
                s.mylayoutbox,
            },
            layout = wibox.layout.align.horizontal,
        },
    }

    return wibar
end
```

{/* TODO: Screenshot needed
   - Custom wibar with all sections visible
   - Show taglist, tasklist, systray, clock, layoutbox
*/}

## Try a Second Bar

A screen can carry any number of wibars. Add one line to your `request::desktop_decoration` handler, after the `s.mywibox = wibar(s)` call:

```lua
s.mybottombar = awful.wibar {
    position = "bottom",
    screen = s,
    widget = wibox.widget.textclock(" %A %B %d "),
}
```

Reload. A second bar appears along the bottom edge showing the date, and your windows shrink to fit between the two bars: each wibar reserves its own strip of the workarea. Remove the line and reload when you've seen it.

## Toggling Visibility

Finish with a quality-of-life binding. Add this to your global keybindings:

```lua
awful.key({ modkey }, "b", function()
    local s = awful.screen.focused()
    s.mywibox.visible = not s.mywibox.visible
end, { description = "toggle wibar", group = "awesome" }),
```

Reload, then press **Mod4 + b**. The bar vanishes and your windows expand into its space; press it again and the bar is back. You have built, styled, and wired up your own wibar.

## Troubleshooting

### Wibar not showing

1. Check that you're returning the wibar from your factory function
2. Verify it's being called in `request::desktop_decoration`
3. Try adding explicit `height` to ensure it has size

### Widgets cut off

The wibar may be too short. Increase the height:

```lua
awful.wibar {
    height = 32,  -- Increase from default
    ...
}
```

### Systray icons not showing

The systray can only be on one screen. Make sure it's only added once:

```lua
-- Only add systray to primary screen
if s == screen.primary then
    -- add wibox.widget.systray()
end
```

## Next Steps

- **[Wibar Properties Reference](/docs/reference/wibox/wibar)** - Complete wibar configuration reference
- **[Widgets](/docs/tutorials/widgets)** - Create custom widgets for your wibar
- **[Theme](/docs/tutorials/theme)** - Style your wibar
- **[awful.wibar (AwesomeWM docs)](https://awesomewm.org/apidoc/classes/awful.wibar.html)** - Upstream API reference
