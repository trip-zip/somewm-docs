---
sidebar_position: 100
title: AwesomeWM compatibility reference
description: Supported behaviour, platform differences and compatibility limits in SomeWM 1.4.
---

# AwesomeWM compatibility reference

SomeWM 1.4 uses AwesomeWM’s Lua API with the Wayland differences listed below.

<span id="looking-for" />

<span id="see-also" />

| Need | Documentation |
| --- | --- |
| Move an AwesomeWM configuration to Wayland | [Migrating from AwesomeWM](../getting-started/migrating.md) |
| Change SomeWM releases | [Upgrade from 1.4 to 2.0](/docs/2.0/getting-started/upgrading-from-1.4) |
| Understand the compatibility policy | [AwesomeWM compatibility](../concepts/awesomewm-compat.md) |
| Understand the platform | [Wayland vs X11](../concepts/wayland-vs-x11.md) |

<span id="detail" />

## Platform differences {#architectural-differences}

| Area | SomeWM behaviour |
| --- | --- |
| System tray | `wibox.widget.systray` uses StatusNotifierItem over D-Bus. XEmbed-only tray applications do not appear. |
| Clipboard | Wayland clipboard and primary-selection protocols replace X selections. See [protocol support](wayland-protocols.md). |
| Screenshots | The compositor captures the scene. See [screenshots](../guides/screenshots.md). |
| Monitor and input configuration | The compositor owns these settings. See [`output`](output.md) and [`awful.input`](awful/input.md). |
| Configuration paths | SomeWM uses `somewm/` configuration and cache directories. See [configuration search order](../getting-started/first-launch.md#configuration-locations). |
| GTK theme discovery | `beautiful.gtk` reads GTK settings files instead of creating GTK widgets. GTK CSS is not fully represented. The fallback is Adwaita Dark. |
| Xresources | `gears.xresources` reads `~/.Xresources`, with fallback values. Updating the X server's resource database with `xrdb` does not update these values. |

### Screen bounds

In 1.4, `screen:get_bounding_geometry()` honours `honor_workarea` but ignores padding, margins, and alternate bounding rectangles. `screen.outputs` is a numeric array of output metadata, rather than a table keyed by output name. See [screen](screen.md#screen-management).

### Drawing and shapes

Widgets paint into drawable surfaces. The compositor places these surfaces alongside application surfaces in its scene. See [Architecture](../concepts/architecture.md).

Client X11 shape masks have no Wayland implementation. See the [wibox reference](wibox/index.md) for widget and wibox shapes.

Client geometry excludes the border. Titlebars occupy space inside the decorated client geometry. The border surrounds the client frame.

### Restart and reload

`awesome.restart()` rebuilds the Lua state in the existing compositor. Application clients remain connected. It does not load a newly installed compositor executable.

Modules holding GLib sources or D-Bus registrations must release them on `exit` before their Lua state closes. See [signals](signals.md) and [tag persistence](../guides/tag-persistence.md).

`awesome.quit(1)` requests a new process when launched through `somewm-session`. Applications lose their Wayland connections during a process restart.

## X-property APIs {#stubbed-apis}

| API | Behaviour |
| --- | --- |
| `awesome.register_xproperty(name, type)` | Accepts the declaration but registers no X11 property. |
| `awesome.get_xproperty`, `awesome.set_xproperty` | Not defined. Calling either raises a Lua error. |
| `client:get_xproperty`, `client:set_xproperty` | See [client properties](#x-property-family) below. |

### Client properties {#x-property-family}

`client:get_xproperty(name)` returns `nil`. `client:set_xproperty(name, value)` does nothing. These client methods allow configurations to load, but do not persist values across a Lua reload.

## Keyboard layouts {#partially-implemented}

`awesome.xkb_get_group_names()`, `awesome.xkb_get_layout_group()` and `awesome.xkb_set_layout_group()` are implemented. Layout indices are zero-based.

### Layout toggles {#xkb-layout-toggle}

The `grp:*` XKB toggle options do not reliably switch the compositor's keyboard group. Explicit bindings can call `awesome.xkb_set_layout_group()` instead. Static options such as `ctrl:nocaps` and `compose:ralt` work. See [keyboard layouts](../guides/keyboard-layouts.md).

<span id="clientxdg_fullscreen---protocol-level-fullscreen-state" />

## Client metadata and state

Native Wayland clients provide an application ID, exposed as `client.class`. X11 `instance`, `machine` and `icon_name` metadata is unavailable for native clients. Match rules by `class` instead. XWayland clients can supply X11 metadata.

| Property | Behaviour |
| --- | --- |
| `client.id` | Compositor-assigned client identifier, also used by `somewm-client`. |
| `client.aspect_ratio` | Width-to-height constraint. `0` or `nil` disables it. |
| `client.xdg_fullscreen` | Read-only fullscreen state scheduled for an XDG client. Falls back to `client.fullscreen` for other clients. |
| `client.shadow` | Per-client shadow configuration. See [shadows](shadows.md). |

Protocol fullscreen state can differ from Lua state. `client.xdg_fullscreen` exposes that distinction.

## Signals

The 1.4 line preserves AwesomeWM signal dispatch semantics. The [signal reference](signals.md) lists signal names and arguments.

`spawn::change` and `spawn::canceled` are not emitted: Wayland activation does not provide X11 startup-notification progress and cancellation. Key press and release handlers, `root.fake_input()` and dynamic keybinding removal through `root._remove_key()` are supported.

## XWayland limits

These limits concern X11 applications running through XWayland, not native Wayland clients.

| EWMH property | Limit |
| --- | --- |
| `_NET_FRAME_EXTENTS` | SomeWM does not publish frame extents. |
| `_NET_DESKTOP_GEOMETRY` | The EWMH value is fixed at 1920 by 1080, rather than the output layout's size. |
| `_NET_WM_DESKTOP` at initial map | The requested desktop is read but does not assign the client's tag. Configure placement through [client rules](../guides/client-rules.md). |

<span id="somewm-only-apis-" />

<span id="awfulinput---input-device-configuration" />

<span id="numlock-at-startup" />

<span id="somewm-client---ipc-cli" />

<span id="output---physical-monitor-object" />

<span id="screenscale---fractional-output-scaling" />

<span id="tag-persistence-across-monitor-hotplug" />

<span id="idle-management" />

## SomeWM extensions {#somewm-only-apis}

| Area | API and documentation |
| --- | --- |
| Input devices and NumLock | [`awful.input`](awful/input.md) and [NumLock configuration](../guides/keyboard-layouts.md) |
| Lua utilities | `gears.xresources` reads resource files. `gears.bitwise` provides bitwise operations on Lua versions without the operators |
| IPC | [`somewm-client`](somewm-client.md), backed by `awful.ipc` |
| Outputs and scaling | [`output`](output.md), [`screen.scale`](screen.md) |
| Capture | [`screen.content`](screen.md), [`awful.screenshot`](awful/screenshot.md) |
| Cursor themes | `root.cursor_theme`, `root.cursor_size`, see [input devices](../guides/input-devices.md#cursor-theming) |
| Shadows | Client and wibox shadows, see [shadow reference](shadows.md) |
| Tray integration | `awful.systray`, `awful.statusnotifierwatcher`, `wibox.widget.systray_icon`, see [wibox widgets](wibox/index.md) |
| Layer-shell rules | `ruled.layer_surface`, see [layer surfaces](layer_surface/index.md) |
| Scrolling layouts | `awful.layout.suit.carousel`, see [carousel](awful/carousel.md) |
| Monitor reconnection | [Tag persistence](tag-persistence.md). Saved state is keyed by connector name |
| Idle and locking | [Lock, idle and DPMS](lock.md), [session lock](lockscreen.md) |


### Drawable scale {#drawinsurface_scale---hidpi-surface-override}

`drawin.surface_scale` overrides the drawable's raster scale: `0` selects the output scale, and a positive value selects that factor. Changing it recreates the surface. See [display scaling](../concepts/display-scaling.md).

## Testing compatibility {#testing-implications}

Tests relying on X11 properties or native clients' X11 metadata need a Wayland-specific expectation. Supported key release, keyboard-layout and input-injection APIs can be tested directly. [Nested compositor testing](../guides/testing-with-nested-compositor.md) keeps configuration checks separate from the desktop session.
