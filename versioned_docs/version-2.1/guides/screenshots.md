---
sidebar_position: 6
title: Screenshots
description: Taking screenshots with SomeWM
---

import SomewmOnly from '@site/src/components/SomewmOnly'

# Screenshots

Use `somewm-client` for a direct capture, `awful.screenshot` for Lua integration, or `grim` with `slurp` for shell-based region selection.

## Method 1: awful.screenshot (Interactive)

<span id="interactive-snipping" />

Create the destination directory first:

```bash
mkdir -p ~/Pictures/screenshots
```

Add one binding to `rc.lua`:

```lua
local awful = require("awful")
local naughty = require("naughty")
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "Print", function()
        local shot = awful.screenshot {
            interactive = true,
            directory = os.getenv("HOME") .. "/Pictures/screenshots/",
            prefix = "shot",
        }
        shot:connect_signal("file::saved", function(_, path)
            naughty.notification { title = "Screenshot saved", message = path }
        end)
        shot:refresh()
    end, { description = "select screenshot region", group = "screenshot" }),
})
```

The `file::saved` signal reports that saving was attempted, but 2.1 does not check Cairo's write status before emitting it. Check the destination file if nothing appears.

Drag a rectangle to select the crop. Accepting the selection saves it. Escape cancels. Without `directory`, the default destination is `$HOME`.

The capture and selection use logical pixels at every output scale. See [capture behaviour](../concepts/screenshots.md).

### Delayed Capture

To wait three seconds before selection:

```lua
local shot = awful.screenshot {
    interactive = true,
    auto_save_delay = 3,
}
```

For a noninteractive capture, call `shot:save(path)` rather than only `refresh()`. `refresh()` captures the image without saving it.

## Method 2: somewm-client <SomewmOnly />

<span id="from-a-shell" />

Every command requires a destination path:

```bash
somewm-client screenshot save ~/Pictures/screenshot.png
somewm-client screenshot save ~/Pictures/transparent.png --transparent
somewm-client screenshot screen ~/Pictures/screen.png 1
somewm-client screenshot client ~/Pictures/window.png
somewm-client screenshot interactive ~/Pictures/region.png
```

`interactive` waits until you accept or cancel the selection. Cancellation returns an error status.

`save` captures the combined desktop. `screen` takes a screen index. `client` uses the focused window unless you append a client ID from `client list`.

Use absolute paths. Relative paths are resolved in the compositor's working directory. A shell expands unquoted `~`, but an `awful.spawn` argument table does not:

```lua
awful.spawn({ "somewm-client", "screenshot", "save",
    os.getenv("HOME") .. "/Pictures/screenshot.png" })
```

## Method 3: grim + slurp

Install `grim`, `slurp` and `wl-clipboard` from your distribution. Run these inside the Wayland session:

```bash
# Whole desktop
grim ~/Pictures/screenshot.png

# A selected region
grim -g "$(slurp)" ~/Pictures/region.png

# One output, using its connector name
grim -o DP-1 ~/Pictures/output.png

# Copy a capture to the clipboard
grim - | wl-copy

# Select a region and copy it
grim -g "$(slurp)" - | wl-copy
```

Use `wlr-randr` to find output names. `grim -l` sets PNG compression level, so it is not an output-listing command.

### Keybinding Setup

<span id="a-module-on-keys" />

For a full capture, an argument table avoids shell quoting problems in paths:

```lua
awful.keyboard.append_global_keybindings({
    awful.key({}, "Print", function()
        local path = os.getenv("HOME") .. "/Pictures/"
            .. os.date("screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async({ "grim", path }, function(_, stderr, _, code)
            naughty.notification {
                title = code == 0 and "Screenshot saved" or "Screenshot failed",
                message = code == 0 and path or stderr,
            }
        end)
    end, { description = "capture desktop", group = "screenshot" }),
})
```

For a pipeline, use `awful.spawn.with_shell`, such as `awful.spawn.with_shell('grim -g "$(slurp)" - | wl-copy')`. A geometry crop captures what is visible in that rectangle, including overlapping windows. Use `screenshot client` when you want the client's own content.

## Screenshot with Delay

```bash
sleep 3 && grim ~/Pictures/screenshot.png
```

## Annotating Screenshots

With `swappy` installed:

```bash
grim -g "$(slurp)" - | swappy -f -
```

## Troubleshooting

- **Capture fails:** check the command's error output, destination directory and `WAYLAND_DISPLAY`.
- **No output with the requested name:** check the current connector names with `wlr-randr`.
- **Clipboard is empty:** test `printf 'test' | wl-copy`, then `wl-paste`.
- **Wrong dimensions or missing areas:** see [Screenshots](../concepts/screenshots.md) for the built-in capture's logical-coordinate and output-layout limits.

## See Also

- [Screenshot API](../reference/awful/screenshot.md)
- [CLI Control](cli-control.md)
- [Keybindings](../tutorials/keybindings.md)
