---
sidebar_position: 6
title: Screenshots
description: Taking screenshots with SomeWM
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import SomewmOnly from '@site/src/components/SomewmOnly';

# Screenshots

<YouWillLearn>

- Taking screenshots with somewm-client
- Using grim and slurp for flexible screenshots
- Setting up screenshot keybindings
- Copying screenshots to clipboard

</YouWillLearn>

SomeWM provides built-in screenshot support via `somewm-client`, and you can also use external Wayland-native tools like grim and slurp.

## Method 1: somewm-client <SomewmOnly />

The simplest method - use `somewm-client screenshot`:

```bash
# Full screen screenshot
somewm-client screenshot

# Save to specific path
somewm-client screenshot ~/Pictures/screenshot.png
```

This captures the focused screen and saves to the specified path (or a default location).

### From Lua

```lua
-- Take screenshot via IPC
awful.spawn("somewm-client screenshot ~/Pictures/screenshot.png")
```

## Method 2: grim + slurp (Recommended)

For more flexibility, use the external Wayland-native tools:

```bash
# Install on Arch
pacman -S grim slurp wl-clipboard

# Install on Debian/Ubuntu
apt install grim slurp wl-clipboard
```

### Full Screen

```bash
grim ~/Pictures/screenshot.png
```

### Select Region

```bash
grim -g "$(slurp)" ~/Pictures/screenshot.png
```

`slurp` lets you draw a rectangle to capture.

### Specific Output (Monitor)

```bash
# List outputs
grim -l

# Capture specific output
grim -o DP-1 ~/Pictures/screenshot.png
```

### To Clipboard

```bash
# Full screen to clipboard
grim - | wl-copy

# Region to clipboard
grim -g "$(slurp)" - | wl-copy
```

## Keybinding Setup

Add these keybindings to your rc.lua:

```lua
awful.keyboard.append_global_keybindings({
    -- Print: Full screen screenshot
    awful.key({}, "Print", function()
        local filename = os.date("~/Pictures/screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.with_shell("grim " .. filename)
        naughty.notify { title = "Screenshot", text = "Saved to " .. filename }
    end, { description = "screenshot full screen", group = "screenshot" }),

    -- Shift+Print: Select region
    awful.key({ "Shift" }, "Print", function()
        local filename = os.date("~/Pictures/screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.with_shell('grim -g "$(slurp)" ' .. filename)
    end, { description = "screenshot region", group = "screenshot" }),

    -- Ctrl+Print: Full screen to clipboard
    awful.key({ "Control" }, "Print", function()
        awful.spawn.with_shell("grim - | wl-copy")
        naughty.notify { title = "Screenshot", text = "Copied to clipboard" }
    end, { description = "screenshot to clipboard", group = "screenshot" }),

    -- Ctrl+Shift+Print: Region to clipboard
    awful.key({ "Control", "Shift" }, "Print", function()
        awful.spawn.with_shell('grim -g "$(slurp)" - | wl-copy')
    end, { description = "screenshot region to clipboard", group = "screenshot" }),
})
```

## Screenshot Module

For a reusable screenshot module, create `~/.config/somewm/screenshot.lua`:

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
        naughty.notify {
            title = "Screenshot",
            text = "Saved: " .. f,
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
        naughty.notify {
            title = "Screenshot",
            text = "Copied to clipboard",
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

## Screenshot with Delay

For menus or dropdowns that dismiss on focus loss:

```bash
# 3 second delay
sleep 3 && grim ~/Pictures/screenshot.png

# Or in Lua
awful.spawn.with_shell("sleep 3 && grim ~/Pictures/screenshot.png")
```

## Screenshot Specific Window

Using window geometry from Lua:

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

## Annotating Screenshots

After capturing, open in an annotation tool:

```lua
-- Take screenshot and open in swappy for annotation
awful.key({}, "Print", function()
    awful.spawn.with_shell('grim -g "$(slurp)" - | swappy -f -')
end)
```

Install swappy:

```bash
pacman -S swappy  # Arch
apt install swappy  # Debian/Ubuntu
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

Install wl-clipboard:

```bash
pacman -S wl-clipboard
# or
apt install wl-clipboard
```

Test it:

```bash
echo "test" | wl-copy
wl-paste  # Should print "test"
```

## See Also

- **[CLI Control](/guides/cli-control)** - More somewm-client commands
- **[Keybindings](/tutorials/keybindings)** - Setting up keybindings
