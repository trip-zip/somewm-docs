---
sidebar_position: 6
title: Screenshots
description: Taking screenshots with SomeWM
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Screenshots

This guide shows how to capture the screen, a region, or a window, and how to bind it all to keys. Three tools cover every case, and which to reach for depends on the goal: the built-in `awful.screenshot` for interactive snipping with no external dependencies, `grim` + `slurp` for scriptable pipelines and clipboard work, and `somewm-client screenshot` when you are in a shell.

## Snip a Region Interactively

`awful.screenshot` captures the desktop, shows an overlay, and lets you draw a selection rectangle:

```lua
awful.key({ modkey }, "Print", function()
    local s = awful.screenshot({ interactive = true })
    s:refresh()
end, { description = "interactive screenshot", group = "screenshot" }),
```

The screenshot saves to `$HOME` by default; pass `directory` and `prefix` to change that.

For daily use, two upgrades are worth copying together: the HiDPI overlay tuning (the default overlay repaints the full captured image on every mouse move, which can be slow on HiDPI displays) and a saved-file notification:

```lua
awful.key({ modkey }, "Print", function()
    local s = awful.screenshot({
        interactive = true,
        directory = os.getenv("HOME") .. "/Pictures/screenshots/",
    })
    s:connect_signal("snipping::start", function(self)
        if self._private.frame then
            -- Hide the screenshot background, show selection over live desktop
            self._private.imagebox.visible = false
            self._private.frame.bg = "#00000040"
            self._private.frame.surface_scale = 1.0
        end
    end)
    s:connect_signal("file::saved", function(self, path)
        naughty.notification {
            title = "Screenshot saved",
            message = path,
            timeout = 3,
        }
    end)
    s:refresh()
end, { description = "interactive screenshot", group = "screenshot" }),
```

Why the overlay tuning works:

- `imagebox.visible = false` prevents expensive image repaints on every mouse move
- `bg = "#00000040"` adds a semi-transparent dim so the selection rectangle is visible against the live desktop
- `surface_scale = 1.0` keeps even the dim overlay redraws cheap (no HiDPI upscaling)
- The final crop still uses the pre-captured surface, so the saved screenshot is full quality

## Capture From the Command Line

The quickest capture is one command. With SomeWM's own CLI: <SomewmOnly />

```bash
somewm-client screenshot                          # focused screen
somewm-client screenshot ~/Pictures/shot.png      # to a specific path
```

Or with the Wayland-native tools (`pacman -S grim slurp wl-clipboard` on Arch, `apt install grim slurp wl-clipboard` on Debian/Ubuntu):

```bash
grim ~/Pictures/screenshot.png                    # full screen
grim -g "$(slurp)" ~/Pictures/screenshot.png      # draw a region
grim -o DP-1 ~/Pictures/screenshot.png            # one monitor (grim -l lists them)
```

## Copy to the Clipboard

Pipe grim to `wl-copy` instead of a file:

```bash
grim - | wl-copy                        # full screen
grim -g "$(slurp)" - | wl-copy          # region
```

## Capture a Specific Window

The focused window's geometry becomes grim's region:

```lua
awful.key({ modkey }, "Print", function()
    local c = client.focus
    if not c then return end

    local g = c:geometry()
    local filename = os.date("~/Pictures/window_%Y%m%d_%H%M%S.png")

    awful.spawn.with_shell(string.format(
        'grim -g "%d,%d %dx%d" %s',
        g.x, g.y, g.width, g.height, filename
    ))
end)
```

## Capture After a Delay

For menus and dropdowns that dismiss on focus loss. With the built-in tool, `auto_save_delay` counts down before entering interactive mode:

```lua
local s = awful.screenshot({
    interactive = true,
    auto_save_delay = 3,
})
s:connect_signal("timer::tick", function(self, remaining)
    naughty.notification { title = "Screenshot in " .. remaining .. "s", timeout = 1 }
end)
```

With grim, a plain sleep does it:

```bash
sleep 3 && grim ~/Pictures/screenshot.png
```

## A Screenshot Module, Bound to Keys

To keep all of the above behind consistent keybindings, collect the recipes into `~/.config/somewm/screenshot.lua`:

```lua
-- screenshot.lua
local awful = require("awful")
local naughty = require("naughty")

local screenshot = {}

-- Default save directory
screenshot.directory = os.getenv("HOME") .. "/Pictures"

-- Generate timestamped filename
local function filename()
    return screenshot.directory .. "/" .. os.date("screenshot_%Y%m%d_%H%M%S.png")
end

-- Full screen
function screenshot.full()
    local f = filename()
    awful.spawn.easy_async_with_shell("grim " .. f, function()
        naughty.notification {
            title = "Screenshot",
            message = "Saved: " .. f,
            timeout = 3,
        }
    end)
end

-- Region selection
function screenshot.region()
    local f = filename()
    awful.spawn.with_shell('grim -g "$(slurp)" ' .. f)
end

-- Full screen to clipboard
function screenshot.full_clipboard()
    awful.spawn.easy_async_with_shell("grim - | wl-copy", function()
        naughty.notification {
            title = "Screenshot",
            message = "Copied to clipboard",
            timeout = 3,
        }
    end)
end

-- Region to clipboard
function screenshot.region_clipboard()
    awful.spawn.with_shell('grim -g "$(slurp)" - | wl-copy')
end

-- Focused window
function screenshot.window()
    local c = client.focus
    if not c then return end

    local g = c:geometry()
    local f = filename()
    local region = string.format("%d,%d %dx%d", g.x, g.y, g.width, g.height)

    awful.spawn.with_shell('grim -g "' .. region .. '" ' .. f)
end

return screenshot
```

Use in rc.lua:

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

## Annotate What You Captured

Pipe a capture into swappy (`pacman -S swappy` / `apt install swappy`) to draw on it before saving:

```lua
awful.key({}, "Print", function()
    awful.spawn.with_shell('grim -g "$(slurp)" - | swappy -f -')
end)
```

## Troubleshooting

### grim: failed to create screenshot

Ensure grim is installed and you're running under Wayland:

```bash
echo $WAYLAND_DISPLAY  # Should show something like "wayland-0"
```

### slurp not working

Make sure your compositor supports the `wlr-layer-shell` protocol. SomeWM supports this by default.

### Clipboard not working

Install wl-clipboard, then test it:

```bash
echo "test" | wl-copy
wl-paste  # Should print "test"
```

## See Also

- **[Screenshots Concepts](/docs/concepts/screenshots)** - How the capture pipeline works
- **[awful.screenshot Reference](/docs/reference/awful/screenshot)** - Full API documentation
- **[CLI Control](/docs/guides/cli-control)** - More somewm-client commands
- **[Keybindings](/docs/tutorials/keybindings)** - Setting up keybindings
