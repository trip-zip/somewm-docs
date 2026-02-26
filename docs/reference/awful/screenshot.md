---
sidebar_position: 3
title: awful.screenshot
description: Screenshot capture and interactive snipping tool
---

# awful.screenshot

Screenshot capture with support for full screen, screen, client, geometry, and interactive region selection.

**Upstream documentation:** [awful.screenshot](https://awesomewm.org/apidoc/popups_and_டlayouts/awful.screenshot.html)

## Usage

```lua
local awful = require("awful")

-- Full screen screenshot
local s = awful.screenshot()
s:refresh()
s:save()

-- Interactive region selection
local s = awful.screenshot({ interactive = true })
s:refresh()
-- User draws a rectangle, screenshot auto-saves on release
```

## Constructor

```lua
awful.screenshot(args) -> screenshot
```

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `interactive` | boolean | `false` | Enable mouse-driven region selection |
| `screen` | screen | `nil` | Capture a specific screen |
| `client` | client | `nil` | Capture a specific client window |
| `geometry` | table | `nil` | Capture a specific `{x, y, width, height}` region |
| `directory` | string | `$HOME` | Save directory |
| `prefix` | string | `"Screenshot-"` | Filename prefix |
| `file_path` | string | auto | Override full file path |
| `file_name` | string | auto | Override filename (within `directory`) |
| `date_format` | string | `"%Y%m%d%H%M%S"` | Date format for auto-generated filenames |
| `cursor` | string | `"crosshair"` | Cursor shape during interactive mode |
| `frame_color` | color | `"#ff0000"` | Selection rectangle color |
| `frame_shape` | shape | `rectangle` | Selection rectangle shape |
| `auto_save_delay` | integer | `nil` | Seconds to wait before capture (`nil` = no delay) |
| `auto_save_tick_duration` | number | `1.0` | Seconds between `timer::tick` signals |
| `minimum_size` | table/integer | `{width=3, height=3}` | Minimum selection size (rejects smaller) |
| `accept_buttons` | table | `{awful.button({}, 1)}` | Mouse buttons to confirm selection |
| `reject_buttons` | table | `{awful.button({}, 3)}` | Mouse buttons to cancel selection |

If none of `screen`, `client`, or `geometry` are set, captures the entire desktop via `root.content()`.

## Methods

### refresh()

Captures the screenshot. In interactive mode, this also starts the snipping overlay.

```lua
s:refresh() -> table
```

Returns a table of `{method = surface}` pairs.

### save(file_path)

Saves the captured screenshot to disk.

```lua
s:save()                    -- Use default path
s:save("/tmp/shot.png")     -- Override path
```

In interactive mode, `save()` is called automatically after `accept()`.

### accept()

Confirms the interactive selection and saves the screenshot. Called automatically when the user releases the accept button.

```lua
s:accept() -> boolean  -- true if saved, false if rejected
```

Returns `false` if the selection is below `minimum_size` or empty.

### reject(reason)

Cancels the interactive selection without saving.

```lua
s:reject()               -- Manual cancel
s:reject("mouse_button") -- With reason
```

## Properties

### Read-only

| Property | Type | Description |
|----------|------|-------------|
| `surface` | image | The captured screenshot surface |
| `surfaces` | table | All captured surfaces keyed by method |
| `selected_geometry` | table | Current selection `{x, y, width, height, surface, method}` |
| `content_widget` | wibox.widget.imagebox | The screenshot as an imagebox widget |
| `keygrabber` | awful.keygrabber | The keygrabber used in interactive mode |

### Read-write

| Property | Type | Description |
|----------|------|-------------|
| `directory` | string | Save directory |
| `prefix` | string | Filename prefix |
| `file_path` | string | Full file path |
| `file_name` | string | Filename within directory |
| `date_format` | string | Date format suffix |
| `cursor` | string | Interactive cursor shape |
| `interactive` | boolean | Interactive mode toggle |
| `frame_color` | color | Selection rectangle color |
| `frame_shape` | shape | Selection rectangle shape |
| `minimum_size` | table/integer | Minimum selection dimensions |
| `auto_save_delay` | integer | Delay before capture |
| `accept_buttons` | table | Confirm buttons |
| `reject_buttons` | table | Cancel buttons |

## Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `snipping::start` | `self` | Interactive overlay is shown |
| `snipping::success` | `self` | Selection accepted, screenshot saved |
| `snipping::cancelled` | `self, reason` | Selection cancelled (reason: `"mouse_button"`, `"key"`, `"no_selection"`, `"too_small"`) |
| `file::saved` | `self, file_path, method` | File written to disk |
| `timer::started` | `self` | Auto-save delay timer started |
| `timer::tick` | `self, remaining` | Timer tick (seconds remaining) |
| `timer::timeout` | `self` | Timer expired, capture starting |

All properties also emit `property::<name>` signals.

## Theme Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `beautiful.screenshot_frame_color` | `"#ff0000"` | Default selection rectangle color |
| `beautiful.screenshot_frame_shape` | `gears.shape.rectangle` | Default selection shape |

## Interactive Mode Internals

When `interactive = true` and `refresh()` is called:

1. The appropriate capture method runs (default: `root.content()` for full desktop)
2. A fullscreen wibox is created with the captured image and a selection widget
3. A mousegrabber tracks mouse position and button state
4. A keygrabber handles accept/reject keys (Return/Escape by default)
5. On accept: the captured surface is cropped to the selection and saved

Key internal fields available in signal handlers:

| Field | Type | Description |
|-------|------|-------------|
| `self._private.frame` | wibox | The fullscreen overlay wibox |
| `self._private.imagebox` | wibox.widget.imagebox | The screenshot background widget |
| `self._private.selection_widget` | wibox.widget.separator | The selection rectangle |

These are used for the [HiDPI performance optimization](/guides/screenshots#smooth-interactive-mode-on-hidpi) where the imagebox is hidden in `snipping::start`.

## Examples

### Programmatic Screenshot

```lua
-- Screenshot of a specific screen
local s = awful.screenshot({ screen = screen.primary })
s:refresh()
s:save("/tmp/screen.png")
```

### Client Screenshot

```lua
-- Screenshot of the focused client
local s = awful.screenshot({ client = client.focus })
s:refresh()
s:save("/tmp/window.png")
```

### Geometry Screenshot

```lua
-- Screenshot of a specific region
local s = awful.screenshot({ geometry = { x = 100, y = 100, width = 500, height = 300 } })
s:refresh()
s:save("/tmp/region.png")
```

### Widget Integration

```lua
-- Display screenshot in a wibox
local s = awful.screenshot({ screen = screen.primary })
s:refresh()

local popup = awful.popup {
    widget = s.content_widget,
    placement = awful.placement.centered,
    visible = true,
}
```

## See Also

- [Screenshots Guide](/guides/screenshots) - Practical setup and keybindings
- [Screenshots Concepts](/concepts/screenshots) - How the capture pipeline works
- [Display Scaling](/concepts/display-scaling) - HiDPI and logical vs physical pixels
