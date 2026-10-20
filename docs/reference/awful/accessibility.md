---
sidebar_position: 5
title: awful.accessibility
description: Pointer location with rings, magnification, and optional shake activation
---

# awful.accessibility

`awful.accessibility` provides a pointer locator. It can display static or shrinking rings,
temporarily enlarge a themed cursor, or combine both effects. Activation is an
explicit Lua call or an optional shake gesture. Loading `awful` does not enable
shake detection or start a locator.

## Usage

```lua
local a11y = awful.accessibility {
    cursor_finder_effect = "both",
    cursor_finder_shake_enabled = true,
}

awful.keyboard.append_global_keybindings {
    awful.key({modkey}, "c", function() a11y:find_cursor() end,
        {description = "find pointer", group = "accessibility"}),
}
```

The module-level `awful.accessibility.find_cursor()` uses a default instance.
Without theme overrides it displays rings. `awful.accessibility.stop_cursor_finder()` stops
that default instance only.

## Reduced motion and persistent cursor size

```lua
root.cursor_size(48)

local a11y = awful.accessibility {
    cursor_finder_effect = "both",
    cursor_finder_shake_enabled = true,
    cursor_finder_animated = false,
}
```

With `cursor_finder_animated = false`, rings keep their size and opacity while
following the pointer, then disappear after `cursor_finder_duration` seconds.
Magnification changes immediately and restores the base size immediately after
`cursor_finder_deflate_delay` seconds of inactivity. Inflation and deflation
durations are ignored. Repeated activation restarts the lifetimes and adds
magnification up to the configured maximum.

This setting controls pointer-locator animation only. A keyboard binding can
activate the same effects without a shake gesture.

`root.cursor_size(48)` sets the base cursor size; placing it in `rc.lua` reapplies
it when the configuration loads. `XCURSOR_SIZE=48` in the compositor's startup
environment also sets the base size. Temporary magnification multiplies the
configured base size on each output; completion and cancellation restore that
base, including when it is larger than the default. Cursor themes may provide
discrete image sizes. Client-uploaded cursors remain application-controlled.
See [Cursor theming](../../guides/input-devices.md#cursor-theming).

## Constructor

```lua
local a11y = awful.accessibility { ... }
```

The argument table accepts the properties below. Unknown properties and values
outside the documented ranges raise an error.

A property reads its instance override, then the matching `beautiful` theme
variable, then the default. Assigning `nil` removes the instance override.
An explicit `false` remains an override. Every property has a theme variable
named by prefixing it with `accessibility_`, for example
`beautiful.accessibility_cursor_finder_color`.

Theme values are read when properties are accessed. Assign
`a11y.cursor_finder_shake_enabled` to change the motion subscription of an
existing instance; changing a theme variable alone does not reconnect it.

## Properties

All durations are in seconds. Distances are in logical pixels. Magnification
factors are relative to the cursor's normal size on its output.

| Property | Default | Meaning and accepted values |
| --- | --- | --- |
| `cursor_finder_enabled` | `true` | Boolean; assigning `false` ends this instance's active locator and suppresses activation. |
| `cursor_finder_effect` | `"rings"` | `"rings"`, `"magnify"`, or `"both"`. Changing it ends the active locator. |
| `cursor_finder_animated` | `true` | Boolean; `false` holds static rings and changes magnification immediately. Changing it ends the active locator. |
| `cursor_finder_duration` | `0.8` | Ring display duration, 0.01–60, for animated and static rings. |
| `cursor_finder_radius` | `100` | Largest ring's initial radius, 1–512. |
| `cursor_finder_color` | `"#ff6600"` | Solid ring colour. |
| `cursor_finder_line_width` | `3` | Ring stroke width, 1–64. |
| `cursor_finder_ring_count` | `2` | Number of concentric rings, integer 1–8. |
| `cursor_finder_shake_enabled` | `false` | Boolean; observe pointer motion for shakes. |
| `cursor_finder_magnification` | `3` | Initial enlargement, 1–16, limited by `cursor_finder_max_scale`. |
| `cursor_finder_over_magnification` | `1` | Additional enlargement per repeated activation, 0–15. |
| `cursor_finder_max_scale` | `4` | Maximum enlargement, 1–16. Values above 4 can upscale the cached image. |
| `cursor_finder_inflate_duration` | `0.2` | Time to reach an enlarged size, 0–60; 0 applies it immediately. |
| `cursor_finder_deflate_duration` | `1` | Time to return to normal size, 0–60; 0 applies it immediately. |
| `cursor_finder_deflate_delay` | `1.5` | Inactivity before deflation begins, 0.01–60. |
| `cursor_finder_history_window` | `1` | Motion-history window for shake detection, 0.01–10. |
| `cursor_finder_sensitivity` | `4` | Required ratio of travelled distance to the motion bounds' diagonal, 1–100. Larger values require more reversals. |
| `cursor_finder_min_diagonal` | `100` | Minimum diagonal of the motion bounds, 1–4096. |
| `cursor_finder_cooldown` | `0.5` | Shake suppression after deflation begins or the locator stops, 0–60. |

## Methods

### `a11y:find_cursor()`

Starts the selected effects unless the instance is disabled. An explicit call
also works when shake detection is disabled and is not suppressed by the shake
cooldown.

Repeated activation restarts the rings, adds to magnification up to its maximum,
and resets the deflation delay. Direction changes during continued shaking also
extend that delay. Rings finish after their own duration; with both effects,
magnification can remain active after the rings disappear.

### `a11y:stop_cursor_finder()`

Cancels this instance's timers and rings and immediately restores normal cursor
size if this instance owns the active locator. Shake detection remains enabled
if configured; setting `cursor_finder_shake_enabled = false` disables it.

## Signals

| Signal | Arguments after the instance | Emission |
| --- | --- | --- |
| `cursor_finder::start` | None | Once when the locator becomes active. Repeated activation does not emit another start. |
| `cursor_finder::end` | None | Once when the active locator completes, is stopped, is disabled, or another instance takes over. |
| `property::<name>` | Effective value | When a property assignment changes its effective value. |

## Pointer and instance behaviour

Only one locator owns the pointer at a time. Activating another instance stops
the previous one. If an end-signal handler activates a locator, that later
activation takes precedence over the interrupted request. Calling `stop_cursor_finder()` on an inactive instance does not affect the
active instance. Enabling shake detection on another instance disables it on
the previous observer and emits its property-change signal.

Rings pass input through and follow pointer motion. The cursor hotspot stays at
the pointer throughout enlargement. Themed cursors, including shapes requested
by applications through the cursor-shape protocol, can enlarge. Client-uploaded
cursor surfaces retain their normal size; a client hiding its cursor remains
hidden. An uploaded cursor resets magnification so returning to the desktop
does not reveal an accumulated enlargement.

Pointer locking prevents shake detection from receiving movement. Ordinary
pointer grabs do not prevent observation. Coordinate warps alone do not count
as shake samples. Restarting the configuration clears the locator and restores
normal magnification.

Magnification uses the output frame clock and cached cursor images. Shake
detection observes motion events; it does not poll while the pointer is idle.
