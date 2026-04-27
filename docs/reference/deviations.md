---
sidebar_position: 100
title: Deviations from AwesomeWM
description: Comprehensive reference of every API and behavioral difference between somewm and AwesomeWM.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Deviations from AwesomeWM

This page is the dense reference for every place somewm's behavior or API surface differs from AwesomeWM. Architectural differences come from Wayland vs X11; stubs exist so configs don't error; somewm-only APIs add what AwesomeWM has no equivalent for.

## Looking for...

| If you want | Read |
|---|---|
| The why and the philosophy | [Why somewm](../concepts/why-somewm.md), [AwesomeWM Compatibility](/docs/concepts/awesomewm-compat) |
| Background on the X11 vs Wayland split | [Wayland vs X11](/docs/concepts/wayland-vs-x11) |
| Step-by-step migration help | [Migrating from AwesomeWM](/docs/getting-started/migrating) |

## Architectural Differences

Wayland's design forces these to differ from AwesomeWM. The Lua API stays the same; the implementation underneath does not.

| Feature | AwesomeWM (X11) | somewm (Wayland) | Reason |
|---|---|---|---|
| Systray | X11 `_NET_SYSTEMTRAY` embed | StatusNotifierItem D-Bus (SNI) | X11 tray protocol doesn't exist on Wayland |
| Titlebar borders | Outside frame (X server draws) | Inset by `border_width` | Scene graph positioning differs |
| Window visibility | `xcb_map_window()` shows immediately | Content must exist before showing | Prevents smearing artifacts |
| Map-time geometry | WM sends `ConfigureNotify` before map | Client commits first, then receives configure | Deferred arrange must flush before scene node enables |
| WM restart | `execvp` replaces process; X server keeps clients | In-process Lua state rebuild via `awesome.restart()`; wlroots keeps clients. `awesome.quit(1)` does a cold restart via `somewm-session` | DRM/GPU state can't survive `exec`; the Lua VM can be rebuilt in place |

### Detail

**SNI systray.** AwesomeWM uses X11's `_NET_SYSTEMTRAY` to embed tray windows. somewm uses StatusNotifierItem D-Bus. Most modern apps (NetworkManager, Discord, Bluetooth applet) speak SNI. Legacy XEmbed-only apps won't appear. Implementation: `objects/systray.c` (D-Bus watcher), `lua/awful/statusnotifierwatcher.lua`, `wibox.widget.systray`.

**Titlebar border positioning** (`objects/client.c`). On X11 borders sit outside the frame. On Wayland borders are scene rects at geometry edges, so titlebars start `border_width` inside.

**Map-time geometry** (`somewm.c:mapnotify`). On X11 the WM sends a configure with the tiled geometry before the window maps, so the client never renders at the wrong size. On Wayland the client commits its preferred size first, so `awful.layout.arrange()` (deferred via `timer.delayed_call`) must flush before the configure goes out. `luaA_emit_refresh()` after manage signals forces the deferred arrange so `c->geometry` holds the tiled dimensions before the configure flushes.

**Window visibility timing** (`objects/drawin.c`). The scene node stays disabled until `drawin_refresh_drawable()` signals content ready. Prevents visual smearing during initial render.

**Restart model.** `awesome.restart()` rebuilds the Lua state in process while wlroots keeps running. Clients survive. Use `awesome.quit(1)` for a cold restart via `somewm-session`; that is needed only when DRM state has gone bad.

## Stubbed APIs

These exist so configs don't error, but do nothing meaningful.

| API | Status | Reason |
|---|---|---|
| `awesome.register_xproperty()` | Stub | X11 properties don't exist on Wayland |
| `awesome.get_xproperty()` | Stub, returns `nil` | Same |
| `awesome.set_xproperty()` | Stub, no-op + warning | Same |
| `client:get_xproperty()` | Stub, returns `nil` | Same |
| `client:set_xproperty()` | Stub, no-op | Same |
| `spawn::change` / `spawn::canceled` | Not applicable | Wayland XDG Activation is fire and forget; no progress or cancel concept |

### X-property family

On X11, windows have arbitrary named properties (atoms) used for IPC and persistent state. Wayland has no equivalent: apps communicate via Wayland protocols, and persistent state belongs in compositor-side storage or D-Bus. There is no path forward for these stubs without changing the data model.

## Partially Implemented

| Feature | Status | Notes |
|---|---|---|
| XKB toggle options (`grp:alt_shift_toggle` etc.) | Keybindings required | Toggle options don't trigger layout changes automatically |

### XKB layout toggle

On X11 these toggles work because the X server intercepts the combination and runs the switch. On Wayland the keypress is just a keypress. Workaround: bind explicitly via `awesome.xkb_set_layout_group()`.

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ "Mod1", "Shift" }, "space", function()
        local current = awesome.xkb_get_layout_group()
        awesome.xkb_set_layout_group((current + 1) % 2)
    end),
})
```

Static XKB options like `ctrl:nocaps` and `compose:ralt` work normally; only `grp:*` toggles are affected.

## somewm-only APIs <SomewmOnly />

These extend the AwesomeWM API with capabilities AwesomeWM has no equivalent for, usually because Wayland exposes something X11 didn't.

### `awful.input` - Input device configuration

18 properties for pointer (libinput) and keyboard settings. AwesomeWM delegated this to `xinput`, `xset`, and `setxkbmap` on X11.

```lua
local awful = require("awful")

-- Pointer
awful.input.tap_to_click       = 1
awful.input.natural_scrolling  = 1
awful.input.pointer_speed      = 0.5
awful.input.scroll_button      = 274  -- middle mouse
awful.input.left_handed        = 0

-- Keyboard
awful.input.xkb_layout         = "us"
awful.input.xkb_variant        = ""
awful.input.xkb_options        = "ctrl:nocaps"
awful.input.repeat_rate        = 25
awful.input.repeat_delay       = 600
```

See [`awful.input`](/docs/reference/awful/input) for the full property list.

### NumLock at startup

Wayland compositors start with NumLock off. AwesomeWM had no equivalent because X11 inherited NumLock state from the display server.

```lua
awesome._set_keyboard_setting("numlock", true)
```

Implementation: `some_set_numlock()` in `somewm_api.c` toggles the Mod2 lock mask via `wlr_keyboard_notify_modifiers()` on every keyboard, matching Sway's `input * xkb_numlock enabled`. Mod2 is stripped from `CLEANMASK`, so keybindings work whether NumLock is on or off.

### `somewm-client` - IPC CLI

About 45 commands for external control. Replaces ad-hoc `awesome-client` use.

```bash
somewm-client ping
somewm-client client list
somewm-client client focus <id>
somewm-client input tap_to_click 1
somewm-client eval "return 1+1"
somewm-client screenshot
```

See [`somewm-client`](/docs/reference/somewm-client) for the full command set.

### `output` - Physical monitor object

First-class Lua object representing a connector. Persists from plug to unplug, unlike `screen`, which is destroyed on disable. Read-write access to scale, transform, mode, position, adaptive sync. Replaces `xrandr` and the implicit X11 RandR plumbing.

```lua
for o in output do
    if o.name == "eDP-1" then
        o.scale = 1.5
    end
end

output.connect_signal("added", function(o)
    if o.name:match("^HDMI") then
        o.mode     = { width = 2560, height = 1440 }
        o.position = { x = 1920, y = 0 }
    end
end)

local s = screen.primary
print(s.output.name)
```

Properties: `name`, `description`, `make`, `model`, `serial`, `enabled`, `scale`, `transform`, `mode`, `position`, `adaptive_sync`, `screen`, `valid`, `virtual`. See [`output`](/docs/reference/output).

### `screen.scale` - Fractional output scaling

```lua
screen.primary.scale = 1.5
print(screen.primary.scale)  -- 1.5
```

```bash
somewm-client screen scale
somewm-client screen scale 1.5
somewm-client screen scale 1 1.5
```

Apps that support `wp_fractional_scale_v1` render at native resolution. Struts and workarea recompute on scale change.

### `drawin.surface_scale` - HiDPI surface override

Override the drawable surface scale for individual drawins. At HiDPI scales (e.g. 1.5), drawable surfaces are created at physical resolution, which forces CPU-intensive upscaling for large `imagebox` content like screenshot overlays. Setting `surface_scale = 1.0` forces logical resolution and lets the GPU do the upscale.

```lua
local ss = awful.screenshot { interactive = true }
ss:connect_signal("snipping::start", function(self)
    if self._private.frame then
        self._private.frame.surface_scale = 1.0
    end
end)
```

- `0` (default): auto, use output scale for HiDPI
- `> 0`: force this scale factor

Implementation: `drawin_t.scale_override` in `drawable_get_scale()` and `drawin_get_effective_scale()`. The setter recreates the drawable surface.

### Tag persistence across monitor hotplug

The default `somewmrc.lua` saves and restores tag state when monitors disconnect and reconnect. Tags are keyed by connector name (`eDP-1`, `HDMI-A-1`, ...).

Wayland hotplug is everyday (laptop lids, USB-C docks, power saving). X11 RandR doesn't destroy and recreate screens the same way; on X11, disconnecting a monitor deletes its tags and dumps clients to a fallback screen, and reconnecting creates fresh defaults with no memory of the previous state.

What gets saved: tag name, selected state, layout, `master_width_factor`, `master_count`, `gap`, client references.

Customize or disable:

```lua
-- Disable
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)

-- Replace: move to primary instead of saving
tag.connect_signal("request::screen", function(t, context)
    if context ~= "removed" then return end
    t.screen = screen.primary
end)
```

Limitation: state is keyed by connector name. If connectors enumerate differently across reboots (USB-C dock reorder, for example), saved state won't match.

See [Tag Persistence](/docs/concepts/tag-persistence).

### `client.xdg_fullscreen` - Protocol-level fullscreen state

Read-only. For XDG shell clients reads `xdg_toplevel.scheduled.fullscreen` (what the compositor told the client). For X11 / others falls back to `c.fullscreen`.

AwesomeWM had no equivalent because X11 fullscreen is server-side. On Wayland the compositor must explicitly send a configure for fullscreen, so Lua state and client state can drift. This property exists for diagnostics and tests.

```lua
assert(c.xdg_fullscreen == c.fullscreen)
```

### Idle management

Wayland-native idle detection and inhibition. AwesomeWM relied on external screensavers and power managers for this on X11.

| API | Behavior |
|---|---|
| `awesome.set_idle_timeout(name, seconds, callback)` | Named idle timeout; reuse the same name to replace |
| `awesome.idle` / `awesome.idle_inhibited` | State queries |
| `awesome.idle_inhibit` | Lua-level inhibition; OR-ed with protocol inhibitors |
| `idle::start` / `idle::stop` | Signals |

Inhibition combines: protocol inhibitors (e.g., media players using `zwp_idle_inhibitor_v1`) and `awesome.idle_inhibit` are OR-ed together. Both must be inactive for idle to resume. Implementation: `some_recompute_idle_inhibit()` in `somewm.c`.

## Testing implications

| Test pattern | Issue | Workaround |
|---|---|---|
| X-property tests | APIs are stubs | Skip or use D-Bus alternatives |

`root.fake_input()` and `awesome.restart()` work on Wayland and can be used in tests.

## See also

- [Why somewm](../concepts/why-somewm.md) - what somewm commits to and what's open
- [AwesomeWM Compatibility](/docs/concepts/awesomewm-compat) - compatibility status overview
- [Wayland vs X11](/docs/concepts/wayland-vs-x11) - protocol-level background
- [Migrating from AwesomeWM](/docs/getting-started/migrating) - step-by-step migration
