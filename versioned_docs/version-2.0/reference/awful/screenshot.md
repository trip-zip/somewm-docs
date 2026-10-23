---
sidebar_position: 3
title: awful.screenshot
description: Screenshot capture and interactive snipping tool
---

# awful.screenshot

Screenshot capture with support for full screen, screen, client, geometry, and interactive region selection.

**Upstream documentation:** [awful.screenshot](https://awesomewm.org/apidoc/classes/awful.screenshot.html)

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
local s = awful.screenshot({ screen = screen.primary })
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
| `auto_save_delay` | integer | `nil` | Delay before automatic capture. Leave unset for manual capture, or use `0` to capture immediately |
| `auto_save_tick_duration` | number | `1.0` | Seconds between `timer::tick` signals |
| `minimum_size` | table/integer | `{width=3, height=3}` | Minimum selection size (rejects smaller) |
| `accept_buttons` | table | `{awful.button({}, 1)}` | Mouse buttons to confirm selection |
| `reject_buttons` | table | `{awful.button({}, 3)}` | Mouse buttons to cancel selection |
| `accept_keys` | table | `{awful.key({}, "Return")}` | Keys to accept selection |
| `reject_keys` | table | `{awful.key({}, "Escape")}` | Keys to cancel selection |

Use one of `screen`, `client`, or `geometry`. With none set, capture uses `root.content()` for the entire desktop. A nil `client`, including an absent `client.focus`, therefore captures the desktop. Coordinates are logical pixels.

## Methods

### refresh()

Captures the screenshot. In interactive mode, this also starts the snipping overlay.

```lua
local surfaces = s:refresh()
```

Returns a table of `{method = surface}` pairs.

### save(file_path)

Writes a PNG. The directory must already exist. In 2.0, `save()` does not check Cairo’s write status, so neither its return nor `file::saved` proves that the file exists.

```lua
s:save()                    -- Use default path
s:save("/tmp/shot.png")     -- Override path
```

In interactive mode, `save()` is called automatically after `accept()`.

### accept()

Confirms the interactive selection and saves the screenshot. Called automatically when the user releases the accept button.

```lua
local accepted = s:accept()
```

Returns `false` if the selection is below `minimum_size` or empty. Outside interactive mode it returns `true` without saving.

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
| `auto_save_delay` | integer | Delay before capture. Setting nil raises an error in 2.0 |
| `auto_save_tick_duration` | number | Seconds between timer ticks, set before starting the delay |
| `accept_buttons` | table | Confirm buttons |
| `reject_buttons` | table | Cancel buttons |
| `accept_keys`, `reject_keys` | table | Accept and cancel key bindings |

## Signals

| Signal | Arguments | Description |
|--------|-----------|-------------|
| `snipping::start` | `self` | Interactive overlay is shown |
| `snipping::success` | `self` | Selection accepted, immediately before `save()` |
| `snipping::cancelled` | `self, reason` | Selection cancelled (reason: `"mouse_button"`, `"key"`, `"no_selection"`, `"too_small"`, or `"reject_called"`) |
| `file::saved` | `self, file_path, method` | PNG write attempted. The Cairo status is not checked |
| `timer::started` | `self` | Auto-save delay timer started |
| `timer::tick` | `self, remaining` | Timer tick (seconds remaining) |
| `timer::timeout` | `self` | Timer expired, capture starting |

Writable properties emit `property::<name>` with the new value. Interactive selection also emits `property::selected_geometry`.

## Theme Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `beautiful.screenshot_frame_color` | `"#ff0000"` | Default selection rectangle color |
| `beautiful.screenshot_frame_shape` | `gears.shape.rectangle` | Default selection shape |

## Interactive Mode Internals

`refresh()` captures the image, shows an overlay, and starts mouse and keyboard grabbers. Releasing the accept button or pressing Return crops and saves the selection. Escape or the reject button cancels it.

The [screenshots guide](../../guides/screenshots.md) documents the 2.0 workaround for a slow HiDPI overlay. It uses private fields, which are not a stable API.

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
local c = assert(client.focus, "No focused client")
local s = awful.screenshot({ client = c })
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

- [Screenshots Guide](/docs/2.0/guides/screenshots) - Practical setup and keybindings
- [Screenshots Concepts](/docs/2.0/concepts/screenshots) - How the capture pipeline works
- [Display Scaling](/docs/2.0/concepts/display-scaling) - HiDPI and logical vs physical pixels
