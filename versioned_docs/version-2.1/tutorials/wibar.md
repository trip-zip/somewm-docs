---
sidebar_position: 5
title: Wibar
description: Build a status bar in a factory module, fill its three align sections with the standard widgets, add separators and a custom widget, style it from the theme, and bind a toggle.
---

# Wibar

Build one bar per screen in `request::desktop_decoration`. Use `wibox.layout.align.horizontal` for left, centre and right sections.

## An empty bar

Create `~/.config/somewm/wibar.lua`, a factory that takes a screen:

```lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

return function(s)
    return awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 24,
        widget = {
            { layout = wibox.layout.fixed.horizontal },   -- left
            { layout = wibox.layout.fixed.horizontal },   -- centre
            { layout = wibox.layout.fixed.horizontal },   -- right
            layout = wibox.layout.align.horizontal,
        },
    }
end
```

In `rc.lua`, replace the `request::desktop_decoration` handler that builds the default bar:

```lua
local wibar = require("wibar")

screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
    s.mywibox = wibar(s)
end)
```

Mod4 + Ctrl + r. The default bar is replaced by an empty strip. Each step below adds to it and ends with a reload.

## The standard widgets

```lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

return function(s)
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

    return awful.wibar {
        position = "top",
        screen = s,
        widget = {
            { layout = wibox.layout.fixed.horizontal, s.mytaglist, s.mypromptbox },
            s.mytasklist,
            { layout = wibox.layout.fixed.horizontal,
              wibox.widget.systray(), wibox.widget.textclock(), s.mylayoutbox },
            layout = wibox.layout.align.horizontal,
        },
    }
end
```

Reload. Check the tags on the left, tasklist in the centre, and tray, clock and layout icon on the right. Click a tasklist entry to minimise its window, and scroll the taglist to switch tags.

## Separators and your own widgets

```lua
local function separator()
    return wibox.widget {
        {
            widget = wibox.widget.separator,
            orientation = "vertical",
            forced_width = 1,
            color = beautiful.fg_normal .. "40",   -- 25% alpha
        },
        margins = { left = 8, right = 8 },
        widget = wibox.container.margin,
    }
end

local my_clock = require("widgets.clock")   -- from the Widgets tutorial

-- right section
{ layout = wibox.layout.fixed.horizontal,
  wibox.widget.systray(), separator(), my_clock, separator(), s.mylayoutbox },
```

A widget you built drops into a section like a stock one ([Widgets](widgets.md)).

## Styling

In `theme.lua`:

```lua
theme.wibar_bg = "#282828"
theme.wibar_fg = "#ebdbb2"
theme.wibar_height = 28
```

`bg`, `fg` and `height` can also be passed to `awful.wibar` for one bar ([wibar reference](../reference/wibox/wibar.md)).

## Complete example

```lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local modkey = "Mod4"   -- rc.lua's modkey is a local

local function separator()
    return wibox.widget {
        {
            orientation = "vertical",
            forced_width = 1,
            color = beautiful.fg_normal .. "30",
            widget = wibox.widget.separator,
        },
        top = 6, bottom = 6, left = 8, right = 8,
        widget = wibox.container.margin,
    }
end

return function(s)
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
                if client.focus then client.focus:move_to_tag(t) end
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

    return awful.wibar {
        position = "top",
        screen = s,
        height = beautiful.wibar_height or 28,
        bg = beautiful.wibar_bg,
        fg = beautiful.wibar_fg,
        widget = {
            { layout = wibox.layout.fixed.horizontal,
              s.mytaglist, separator(), s.mypromptbox },
            { layout = wibox.layout.flex.horizontal, s.mytasklist },
            { layout = wibox.layout.fixed.horizontal,
              wibox.widget.systray(), separator(),
              awful.widget.keyboardlayout(), separator(),
              wibox.widget.textclock(" %a %b %d, %H:%M "), separator(),
              s.mylayoutbox },
            layout = wibox.layout.align.horizontal,
        },
    }
end
```

## A second bar, and a toggle

A screen takes any number of wibars, and each reserves its own strip of the workarea. After `s.mywibox = wibar(s)`:

```lua
s.mybottombar = awful.wibar {
    position = "bottom",
    screen = s,
    widget = wibox.widget.textclock(" %A %B %d "),
}
```

Reload: the date along the bottom, and the windows shrink between the two bars. A global keybinding to hide the top bar:

```lua
awful.key({ modkey }, "b", function()
    local s = awful.screen.focused()
    s.mywibox.visible = not s.mywibox.visible
end, { description = "toggle wibar", group = "awesome" }),
```

Mod4 + b hides it and the windows take its space; again brings it back.

## If something is off

- No bar: the factory must `return` it, and the handler must call the factory.
- Widgets cut off: raise `height`.
- No systray icons: `wibox.widget.systray()` can exist once; put it on `screen.primary` only.

[Wibar reference](../reference/wibox/wibar.md) has every property; [awful.wibar upstream](https://awesomewm.org/apidoc/classes/awful.wibar.html) the inherited API.
