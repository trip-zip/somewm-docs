---
sidebar_position: 6
title: Screenshots
description: "Three tools: awful.screenshot for interactive snipping with no dependencies, somewm-client screenshot from a shell, and grim with slurp for pipelines and the clipboard. Bindings, a window capture, a delay, a module, annotation."
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Screenshots

| Tool | Use it for |
| --- | --- |
| `awful.screenshot` | interactive region selection from a keybinding, no external programs |
| `somewm-client screenshot` <SomewmOnly /> | a capture from a shell or a script |
| `grim` and `slurp` | pipelines, the clipboard, annotation |

## Interactive snipping

```lua
awful.key({ modkey }, "Print", function()
    local s = awful.screenshot {
        interactive = true,
        directory = os.getenv("HOME") .. "/Pictures/screenshots/",   -- default $HOME; prefix= names the file
    }
    s:connect_signal("file::saved", function(_, path)
        naughty.notification { title = "Screenshot saved", message = path, timeout = 3 }
    end)
    s:refresh()
end, { description = "interactive screenshot", group = "screenshot" }),
```

HiDPI needs nothing: the capture is one image element of the overlay and the selection a box Clay places ([how it works](/docs/concepts/screenshots)). For menus that close on focus loss, `auto_save_delay = 3` counts down first, and `timer::tick` carries the remaining seconds for a notification.

## From a shell

```bash
somewm-client screenshot save ~/Pictures/shot.png        # every output; --transparent keeps alpha
somewm-client screenshot screen ~/Pictures/shot.png 1    # one screen
somewm-client screenshot client ~/Pictures/shot.png      # the focused window
somewm-client screenshot interactive ~/Pictures/shot.png
```

The path is required and is resolved by the compositor, so make it absolute.

```bash
grim ~/Pictures/screenshot.png                     # full screen
grim -g "$(slurp)" ~/Pictures/screenshot.png       # a region
grim -o DP-1 ~/Pictures/screenshot.png             # one output; grim -l lists them
grim - | wl-copy                                   # to the clipboard
grim -g "$(slurp)" - | wl-copy
grim -g "$(slurp)" - | swappy -f -                 # annotate before saving
sleep 3 && grim ~/Pictures/screenshot.png
```

`grim`, `slurp`, `wl-clipboard` and `swappy` are in every distribution's repositories.

## A module on keys

`~/.config/somewm/screenshot.lua`:

```lua
local awful = require("awful")
local naughty = require("naughty")

local screenshot = { directory = os.getenv("HOME") .. "/Pictures" }

local function filename()
    return screenshot.directory .. "/" .. os.date("screenshot_%Y%m%d_%H%M%S.png")
end

local function notify(message)
    return function() naughty.notification { title = "Screenshot", message = message, timeout = 3 } end
end

function screenshot.full()
    local f = filename()
    awful.spawn.easy_async_with_shell("grim " .. f, notify("Saved: " .. f))
end

function screenshot.region()
    awful.spawn.with_shell('grim -g "$(slurp)" ' .. filename())
end

function screenshot.full_clipboard()
    awful.spawn.easy_async_with_shell("grim - | wl-copy", notify("Copied to clipboard"))
end

function screenshot.region_clipboard()
    awful.spawn.with_shell('grim -g "$(slurp)" - | wl-copy')
end

function screenshot.window()
    local c = client.focus
    if not c then return end
    local g = c:geometry()
    awful.spawn.with_shell(string.format('grim -g "%d,%d %dx%d" %s', g.x, g.y, g.width, g.height, filename()))
end

return screenshot
```

```lua
local screenshot = require("screenshot")
awful.keyboard.append_global_keybindings({
    awful.key({}, "Print", screenshot.full),
    awful.key({ "Shift" }, "Print", screenshot.region),
    awful.key({ "Control" }, "Print", screenshot.full_clipboard),
    awful.key({ "Control", "Shift" }, "Print", screenshot.region_clipboard),
    awful.key({ modkey }, "Print", screenshot.window),
})
```

If `grim` fails to create a screenshot, `echo $WAYLAND_DISPLAY` should name a socket; if `wl-copy` does nothing, `echo test | wl-copy && wl-paste` tests the clipboard.

[awful.screenshot reference](/docs/reference/awful/screenshot) has every option and signal.
