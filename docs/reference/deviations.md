---
sidebar_position: 100
title: Deviations from AwesomeWM
description: Comprehensive reference of every API and behavioral difference between somewm and AwesomeWM.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Deviations from AwesomeWM

Every place SomeWM's behaviour or API differs from AwesomeWM. Architectural differences come from Wayland; stubs exist so configs do not error; SomeWM-only APIs add what AwesomeWM has no equivalent for.

This is the canonical status list: other pages (FAQ, troubleshooting, compatibility concepts) link here rather than keeping their own copies. Last synced against the SomeWM source: `d053da19d`.

## Looking for...

| If you want | Read |
|---|---|
| The why and the philosophy | [Why somewm](../concepts/why-somewm.md), [AwesomeWM Compatibility](/docs/concepts/awesomewm-compat) |
| Background on the X11 vs Wayland split | [Wayland vs X11](/docs/concepts/wayland-vs-x11) |
| Step-by-step migration help | [Migrating from AwesomeWM](/docs/getting-started/migrating) |
| What 2.1 changed for a 2.0 config | [Upgrading from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md) |

## Architectural Differences

Wayland's design forces these to differ from AwesomeWM. The Lua API stays the same; the implementation underneath does not.

| Feature | AwesomeWM (X11) | somewm (Wayland) | Reason |
|---|---|---|---|
| Systray | X11 `_NET_SYSTEMTRAY` embed | StatusNotifierItem D-Bus (SNI) | X11 tray protocol doesn't exist on Wayland |
| Titlebar borders | Outside frame (X server draws) | Inset by `border_width` | The border is the client frame's padding in the one tree |
| Drawing | Each widget paints itself with cairo | Every widget is a description; one tree per output is solved and drawn by the compositor | No widget holds a surface; see [How SomeWM draws](../concepts/how-somewm-draws.md) |
| Map-time geometry | WM sends `ConfigureNotify` before map | Client commits first, then receives configure | Deferred arrange must flush before scene node enables |
| WM restart | `execvp` replaces process; X server keeps clients | In-process Lua state rebuild via `awesome.restart()`; wlroots keeps clients. `awesome.quit(1)` does a cold restart via `somewm-session` | DRM/GPU state can't survive `exec`; the Lua VM can be rebuilt in place |

### Detail

**SNI systray.** AwesomeWM uses X11's `_NET_SYSTEMTRAY` to embed tray windows. somewm uses StatusNotifierItem D-Bus. Most modern apps (NetworkManager, Discord, Bluetooth applet) speak SNI. Legacy XEmbed-only apps won't appear. Implementation: `objects/systray.c` (D-Bus watcher), `lua/awful/statusnotifierwatcher.lua`, `wibox.widget.systray`.

**Titlebar border positioning** (`lua/awful/client/clay.lua`). On X11 borders sit outside the frame. On Wayland the client's frame is a box whose padding is the border width, so titlebars and the surface start `border_width` inside, and the border is drawn as a scene rect around the frame.

**Map-time geometry** (`somewm.c:mapnotify`). On X11 the WM sends a configure with the tiled geometry before the window maps, so the client never renders at the wrong size. On Wayland the client commits its preferred size first, so `awful.layout.arrange()` (deferred via `timer.delayed_call`) must flush before the configure goes out. `luaA_emit_refresh()` after manage signals forces the deferred arrange so `c->geometry` holds the tiled dimensions before the configure flushes.

**Drawing** (`declare.c`, `render.c`, `lua/wibox/clay.lua`). A wibox has no surface and no widget paints. Each frame, every drawin, client and widget on an output is declared into one tree, the solver sizes it, and the renderer draws the result; a widget with its own `draw`, `fit` or `layout` method is left out with a warning. [How SomeWM draws](../concepts/how-somewm-draws.md) is the full account, and the section below lists what a config notices.

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

25 properties for pointer (libinput) and keyboard settings. AwesomeWM delegated this to `xinput`, `xset`, and `setxkbmap` on X11.

```lua
local awful = require("awful")

-- Pointer
awful.input.tap_to_click       = 1
awful.input.natural_scrolling  = 1
awful.input.accel_speed        = 0.5
awful.input.scroll_button      = 274  -- middle mouse
awful.input.left_handed        = 0

-- Keyboard
awful.input.xkb_layout         = "us"
awful.input.xkb_variant        = ""
awful.input.xkb_options        = "ctrl:nocaps"
awful.input.keyboard_repeat_rate  = 25
awful.input.keyboard_repeat_delay = 600
```

See [`awful.input`](/docs/reference/awful/input) for the full property list.

### NumLock at startup

Wayland compositors start with NumLock off. AwesomeWM had no equivalent because X11 inherited NumLock state from the display server.

```lua
awesome._set_keyboard_setting("numlock", true)
```

Implementation: `some_set_numlock()` in `somewm_api.c` toggles the Mod2 lock mask via `wlr_keyboard_notify_modifiers()` on every keyboard, matching Sway's `input * xkb_numlock enabled`. Mod2 is stripped from `CLEANMASK`, so keybindings work whether NumLock is on or off.

### `somewm-client` - IPC CLI

More than 100 commands for external control (run `somewm-client commands` for the full list in your build). Replaces ad-hoc `awesome-client` use.

```bash
somewm-client ping
somewm-client client list
somewm-client client info focused
somewm-client client focus <id>
somewm-client input tap_to_click 1
somewm-client screenshot save ~/shot.png
somewm-client eval "return 1+1"
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

### `client.xdg_maximized` - Protocol-level maximized state

Read-only, same idea as `client.xdg_fullscreen`. For XDG shell clients reads `xdg_toplevel.scheduled.maximized`; for X11 and others falls back to `c.maximized`.

GTK and Chromium draw their own titlebars, so they need the maximized state over the protocol to draw the right button. This property is how you tell "Lua thinks the client is maximized" apart from "the client was told".

```lua
assert(c.xdg_maximized == c.maximized)
```

### Client-drawn titlebar buttons

Clients that draw their own decorations drive window state with `xdg_toplevel.set_maximized`, `unset_maximized` and `set_minimized`. somewm honors all three and routes them into `c.maximized` and `c.minimized`, the same properties a keybinding or a tasklist click would set. `awful.permissions` governs the resulting geometry request exactly as it does for any other source, so a rule that blocks maximizing blocks the titlebar button too.

X11 had no equivalent: the server drew the frame, and applications asked through `_NET_WM_STATE`.

### Idle management

Wayland-native idle detection and inhibition. AwesomeWM relied on external screensavers and power managers for this on X11.

| API | Behavior |
|---|---|
| `awesome.set_idle_timeout(name, seconds, callback)` | Named idle timeout; reuse the same name to replace |
| `awesome.idle` / `awesome.idle_inhibited` | State queries |
| `awesome.idle_inhibit` | Lua-level inhibition; OR-ed with protocol inhibitors |
| `idle::start` / `idle::stop` | Signals |

Inhibition combines: protocol inhibitors (e.g., media players using `zwp_idle_inhibitor_v1`) and `awesome.idle_inhibit` are OR-ed together. Both must be inactive for idle to resume. Implementation: `some_recompute_idle_inhibit()` in `somewm.c`.

## What 2.1 changed <SomewmOnly />

SomeWM 2.1 draws every output from one tree. The Lua API stays AwesomeWM's; these are the differences a 2.0 config can notice. [Upgrading from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md) has the full list with replacements.

| Behaviour | 2.1 | Reason |
|---|---|---|
| A widget with its own `fit`, `draw` or `layout` | Left out of the tree with its subtree, one warning per class | A widget is a description; nothing paints or measures itself |
| A wibox with `opacity` below 1 | Each fill blends at that opacity, so overlapping fills add up | The renderer draws each fill as its own rectangle; nothing blends a finished wibox |
| A `bgimage` function | Not drawn, with a warning; a surface or path draws once at its own size | No surface to paint into |
| A `shape` function | Only the path it traces is used; a rounded rectangle is read as a radius and drawn as a scene rect | Shapes are declarations, not painters |
| A wibox tree above 4096 nodes | Shows nothing, with one warning | One fixed solver arena per output |
| Text under `rotate` or `mirror` | One line; a multi-line textbox, a scroll container, or a rotate inside a rotate is left out with a warning | A rotated run is one text element |
| `wibox.layout.grid` | Columns no longer agree across rows in a non-homogeneous grid; a widget over another is refused; a row span takes its first row | The grid is rows of cells the solver sizes |
| A client's protocol minimum larger than its cell | The client overhangs the cell; the workarea and neighbours keep their size | A size the client asks for is on the surface, not the cell |
| A client that draws a size it was not given | Drawn at the drawn size and cut at its cell | The surface shows the client's pixels; the frame holds the cell |
| `ontop`, `above`, `below` under a layout | Tile into their slot, as in AwesomeWM | The slot is in the tree; only the surface floats at the band |
| A textbox's `wrap` | Not read; every textbox wraps at words | The solver measures text, at words |
| `wibox.container.tile` | Draws one copy of its widget | No tiling primitive in the tree |

A property the tree cannot hold warns once naming the class, the property and what happens instead; the warning forms are listed on the upgrade page.

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
