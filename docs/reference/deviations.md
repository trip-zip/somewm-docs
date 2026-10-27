---
sidebar_position: 100
title: AwesomeWM compatibility
description: Supported behaviour, platform differences and compatibility limits in SomeWM 2.1.
---

# AwesomeWM compatibility

SomeWM 2.1 develops independently of AwesomeWM. Shared Lua names do not guarantee identical behaviour. The reference for this version defines the supported API.

<span id="looking-for" />

<span id="what-21-changed-" />

<span id="see-also" />

| Need | Documentation |
| --- | --- |
| Move an AwesomeWM configuration to Wayland | [Migrating from AwesomeWM](../getting-started/migrating.md) |
| Change SomeWM releases | [Upgrade from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md) |
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
| Configuration paths | SomeWM uses `somewm/` configuration and cache directories. See [configuration search order](../getting-started/first-launch.md#configuration). |
| GTK theme discovery | `beautiful.gtk` reads GTK settings files instead of creating GTK widgets. GTK CSS is not fully represented. The fallback is Adwaita Dark. |
| Xresources | `gears.xresources` reads `~/.Xresources`, with fallback values. Updating the X server's resource database with `xrdb` does not update these values. |

### Drawing and shapes

Widgets describe elements in one tree per output. `declare.c` declares the tree. `render.c` owns visible scene changes. Custom painter widgets are omitted with a warning. See [How SomeWM draws](../concepts/how-somewm-draws.md) and [widget compatibility](../getting-started/upgrading-from-2.0.md#what-you-will-see).

`client.shape` controls client corners. The mask properties `shape_bounding`, `shape_clip` and `shape_input` are ignored and warn. The corresponding `client_shape_*` getters return `nil`. Wibox masks are also ignored. Use its `shape` property. See [rounded corners](../guides/rounded-corners.md) and [wibox](wibox/index.md).

Client geometry excludes the border. Titlebars occupy space inside the decorated client geometry. The border surrounds the client frame.

### Restart and reload

`awesome.restart()` rebuilds the Lua state in the existing compositor. Application clients remain connected. It does not load a newly installed compositor executable.

Modules holding GLib sources or D-Bus registrations must release them on `exit` before their Lua state closes. See [signals](signals.md) and [tag persistence](../guides/tag-persistence.md).

## X-property APIs {#stubbed-apis}

| API | Behaviour |
| --- | --- |
| `awesome.register_xproperty(name, type)` | Accepts the declaration but registers no X11 property. |
| `awesome.get_xproperty`, `awesome.set_xproperty` | Not defined. Calling either raises a Lua error. |
| `client:get_xproperty`, `client:set_xproperty` | See [client properties](#x-property-family) below. |

### Client properties {#x-property-family}

`client:get_xproperty(name)` reads a client-owned value. A missing name returns `nil`. `client:set_xproperty(name, value)` accepts booleans, numbers and strings. `nil` removes the entry. Other types raise an error. Registration is unnecessary.

The values survive Lua hot reloads and are freed with the client. They are not X11 properties, are not visible to other applications, and do not survive a compositor exit.

## Keyboard layouts {#partially-implemented}

`awesome.xkb_get_group_names()`, `awesome.xkb_get_layout_group()` and `awesome.xkb_set_layout_group()` are implemented. Layout indices are zero-based.

### Layout toggles {#xkb-layout-toggle}

The `grp:*` XKB toggle options do not reliably switch the compositor's keyboard group. Explicit bindings can call `awesome.xkb_set_layout_group()` instead. Static options such as `ctrl:nocaps` and `compose:ralt` work. See [keyboard layouts](../guides/keyboard-layouts.md).

<span id="clientxdg_fullscreen---protocol-level-fullscreen-state" />

<span id="clientxdg_maximized---protocol-level-maximized-state" />

<span id="client-drawn-titlebar-buttons" />

## Client metadata and state

Native Wayland clients provide an application ID, exposed as `client.class`. X11 `instance`, `machine` and `icon_name` metadata is unavailable for native clients. Match rules by `class` instead. XWayland clients can supply X11 metadata.

| Property | Behaviour |
| --- | --- |
| `client.id` | Compositor-assigned client identifier, also used by `somewm-client`. |
| `client.aspect_ratio` | Width-to-height constraint. `0` or `nil` disables it. |
| `client.xdg_fullscreen` | Read-only fullscreen state scheduled for an XDG client. Falls back to `client.fullscreen` for other clients. |
| `client.xdg_maximized` | Read-only maximised state scheduled for an XDG client. Falls back to `client.maximized` for other clients. |
| `client.shadow` | Per-client shadow configuration. See [shadows](shadows.md). |

Client-drawn maximise and minimise buttons request the same Lua state changes as configuration actions. `awful.permissions` handles the resulting geometry requests. Protocol state can differ from Lua state. The `xdg_*` properties expose that distinction.

## Signals

Selected C-generated signals are queued. Lua-emitted signals and synchronous C requests run inline. The [signal reference](signals.md#dispatch) lists the exact dispatch rules.

`spawn::change` and `spawn::canceled` are not emitted: Wayland activation does not provide X11 startup-notification progress and cancellation. Key press and release handlers, `root.fake_input()` and dynamic keybinding removal through `root._remove_key()` are supported. `awesome._active_modifiers` lists the modifiers held right now from the keyboard's xkb state, so a faked press shows until its release:

```lua
root.fake_input("key_press", "Control_L")
root.fake_input("key_press", "Alt_L")
print(table.concat(awesome._active_modifiers, ", "))   -- {"Control", "Mod1"}
root.fake_input("key_release", "Alt_L")
root.fake_input("key_release", "Control_L")
print(table.concat(awesome._active_modifiers, ", "))   -- {}
```

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
| Input devices and NumLock | [`awful.input`](awful/input.md). [`awesome._set_keyboard_setting`](awful/input.md) for NumLock |
| Lua utilities | `gears.xresources` reads resource files. `gears.bitwise` provides bitwise operations on Lua versions without the operators |
| IPC | [`somewm-client`](somewm-client.md), backed by `awful.ipc` |
| Outputs and scaling | [`output`](output.md), [`screen.scale`](screen.md) |
| Capture | [`screen.content`](screen.md), [`awful.screenshot`](awful/screenshot.md) |
| Cursor themes | `root.cursor_theme`, `root.cursor_size`. [input devices](../guides/input-devices.md#cursor-theming) |
| Shadows | Client and wibox shadows. [shadow reference](shadows.md) |
| Tray integration | `awful.systray`, `awful.statusnotifierwatcher`, `wibox.widget.systray_icon`. [wibox widgets](wibox/index.md) |
| Layer-shell rules | `ruled.layer_surface`. [layer surfaces](layer_surface/index.md) |
| Scrolling layouts | `awful.layout.suit.carousel`. [carousel](awful/carousel.md) |
| Monitor reconnection | [Tag persistence](tag-persistence.md). Saved state is keyed by connector name |
| Idle and locking | [Lock, idle and DPMS](lock.md), [session lock](lockscreen.md) |
| Tree inspection | `screen.inspector`, `somewm.inspector`, `somewm-client clay tree`. [Reading the tree](../concepts/reading-the-tree.md) |
| Animation | `somewm.animation`, client and wibox animation policies. [Animation](../guides/animation.md) |

## Changes from 2.0 {#changes-from-20}

For upgrade steps, see [Upgrading from 2.0 to 2.1](../getting-started/upgrading-from-2.0.md). These tables list removed APIs and changed behaviour.

### Removed APIs and properties

Calling a removed function raises `attempt to call ... (a nil value)`. Setting a removed widget, wallpaper or layout_animation property warns once that it is ignored. Setting `surface_scale`, `shape_border` or `carousel.scroll_duration` is silent and does nothing. Remove unused settings and replace calls as listed below.

#### Widget methods and drawing

| Gone | Instead |
| --- | --- |
| `fit`, `draw`, `layout`, `before_draw_children`, `after_draw_children` on every stock widget, container and layout class | Use built-in components, a Clay description or an image surface. See [Port a custom widget](../getting-started/upgrading-from-2.0.md#port-a-custom-widget). |
| `wibox.hierarchy` and all its methods | The old hierarchy API has no replacement. Inspect calculated widget boxes in the tree dump and inspector. |
| `wibox.widget.base.fit_widget`, `layout_widget`, `place_widget_at`, `place_widget_via_matrix`, `rect_to_device_geometry`, and `no_parent_I_know_what_I_am_doing` | Use [widget layouts and containers](wibox/index.md). Clay computes their geometry. |
| `wibox.widget.draw_to_cairo_context`, `draw_to_image_surface`, `draw_to_svg_file`, `wibox:to_widget`, `wibox:save_to_svg` | Use [screen capture](../guides/screenshots.md): `root.content()`, `screen.content` or `somewm-client screenshot`. |
| `wibox.widget.textbox:get_height_for_width`, `get_height_for_width_at_dpi` | The container sizes itself. Give a popup a `maximum_width`. |
| the drawable `refresh` method and `surface` property, the drawin `surface_scale` and `shape_border` properties | Drawables no longer have surfaces. The renderer draws a shaped wibox's border from `border_width` and `border_color`. |
| the scroll container's `context`, `first_x`, `first_y`, `fit_width`, `fit_height`, `hierarchy`, `surface_width`, `surface_height` | The container is a scroll element of the tree. |
| the wibox `__tostring` | `tostring(wibox)` prints the table. |

#### Classes and properties

| Gone | Instead |
| --- | --- |
| `wibox.container.border` | `wibox.container.background` with `border_width`, `border_color` and `shape`. Loading the old module is an error. |
| `horizontal_offset` (stack) | none. Stacked widgets share one box |
| `minimum_column_width`, `superpose` (grid) | none. A widget added over another is refused |
| `inner_fill_strategy` (ratio) | none |
| `stretch_horizontally`, `stretch_vertically` (background) | none. The child fills the container |
| `paddings` (radialprogressbar) | none |
| `horizontal_crop`, `vertical_crop` (tile) | none |
| `auto_dpi`, `source_width` (imagebox) | none. The output's scale applies |
| `ticks_gap` (progressbar) | none |
| `bar_border_color`, `bar_border_width`, `handle_margins` (slider) | none |
| `empty_cell_mode`, `empty_color`, `empty_widget` (calendar) | none |
| `check_border_color`, `check_border_width`, `check_shape` (checkbox) | `shape` draws the check |
| `awful.wallpaper` `uncovered_areas_color`, `dpi`, `get_dpi` | the root wallpaper shows in uncovered areas. The output scale applies |
| `awful.client.shape`: `get_transformed`, `update.all`, `update.bounding`, `update.clip`, `update.input` | `client.shape` |
| `carousel.scroll_duration` | `theme.animation_layout_duration`. See [Animation](../guides/animation.md). |
| `somewm.layout_animation.easing` | No equivalent. Use the built-in animation curves. |
| `awesome.start_animation` | Use [object animation policies](../guides/animation.md). `somewm.layout_animation` is also deprecated. |
| `awesome.systray` | `wibox.widget.systray`. The C painter entry point is gone |
| `_wibox` | `wibox`. The private surface-backed C module is gone |
| `ruled.client.completed_with_payload_callback` | `ruled.client.execute` |

#### Theme variables

Gone with the properties that read them: `slider_bar_border_color`, `slider_bar_border_width`, `slider_handle_margins`, `calendar_empty_color`, `checkbox_check_border_color`, `checkbox_check_border_width`, `checkbox_check_shape` and `radialprogressbar_paddings`. Setting one does nothing.

### Widget restrictions

These values produce one warning naming the class, property and resulting behaviour:

| You set | What happens |
| --- | --- |
| `bgimage` to a function | `wibox.drawable: bgimage functions are not drawn`. A surface or a file path still draws, once at its own size in the top-left corner. To cover a bar, prepare the image at the bar's size ([Put a PNG texture on your wibar](../guides/wibar-background-image.md)). |
| a `shape` function that does more than trace a path | only the path is taken. A colour it sets or anything it paints is dropped. `gears.shape.rounded_rect` and the other `gears.shape` functions are fine. |
| a widget tree of more than 4096 nodes in one wibox | the wibox shows nothing and warns once that it is over the output's element budget. |
| a textbox with more than one line under a `rotate` or `mirror` | left out with a warning. Rotated text is one line. |
| a `wibox.container.scroll` under a `rotate` or `mirror`, or a rotate inside a rotate | left out with a warning. |
| a grid with `superpose`, or a row span | a widget added over another is refused. A span occupies its first row and warns. |
| a padding, gap or border width below 0 | it is 0, with a warning. |
| a colour that is not a solid or a gradient (a surface or mesh pattern) | transparent, with a warning naming the property. |

A textbox with `ellipsize = "none"` wraps at words; with it set, the default, it keeps one line per newline and is cut with an ellipsis instead. `wrap = "char"` warns that character wrapping is not applied. `wibox.container.tile` draws one copy of its widget and warns that tiling is not applied.

### Layout, rendering and client behaviour

| Area | 2.1 |
| --- | --- |
| Client shape | Changing `c.shape` emits `property::shape` and arranges the screen. |
| Entrance input | Widgets receive pointer events during their wibox or popup’s entrance animation. |
| Bordered popups | Content larger than the slot is clipped while the popup keeps its slot geometry. |
| Size-hint signals | `property::size_hints` fires when a Wayland client’s committed bounds change. |
| Layout leaves | A leaf placed and sized with grow, fit or percent on one axis is omitted with a warning naming the client. |
| Fractional dimensions | Padding, gaps, offsets and border widths round to the nearest whole pixel. |
| Screenshot overlay | Interactive selection covers the pointer’s screen. |
| Xwayland geometry | Content-size requests pass through the Clay client frame. Geometry replies use the completed solve. |
| Render verification | `render_verify` is removed. The verifier runs only in sanitizer and test builds. |
| Imagebox sizing | An imagebox without a forced size takes its size from an explicit ancestor size, as 2.0's fit did. With none on either axis it declares the image's own size and can overflow a flex or fixed layout. An imagebox forced on one axis scales its image to that axis. |
| Hotkeys help and menubar | They scroll instead of paging. Hotkeys: one column per group, continued every `beautiful.hotkeys_rows` rows (default 20), PgDn and PgUp scroll by one viewport. Menubar: `left_label` and `right_label` show while items lie beyond that side. |
| Grid | A non-homogeneous grid no longer sizes its columns to the widest cell across rows. A homogeneous grid inside a content-sized box takes content-sized cells and warns. Border dashes draw solid and gradient border colours are transparent, both with a warning. |
| Clients under a layout | An ontop, above or below client tiles into its slot, as in AwesomeWM. A client whose protocol minimum exceeds its tiled cell overhangs the cell. The workarea and its neighbours keep their size. A client that draws a size other than the one it was given is drawn at the drawn size, cut at its cell. |
| Max and magnifier | A floating client is above the layout's clients whatever the raise order, and a transient of a max or magnifier client is above every client of that layout. |
| Size hints | `c.size_hints` reports min and max width and height for Wayland clients, from the toplevel's committed bounds. A Wayland client whose min equals max reports `is_fixed` and floats. |
| Border width | A client whose rules set no `border_width` draws no border, as in AwesomeWM. 2.0 applied the theme's width from C. `property::border_color` also fires when the focus recolour changes the drawn border. |
| Overflow scroll signals | `property::scroll_factor` fires once the frame has applied a change, with the applied value, including for the mouse wheel and for a content or viewport change that moves the factor. |
| Gradients | A slider `bar_color` gradient, an arcchart `colors` gradient and a separator `color` gradient are drawn in the bar's, the box's and the line's own box. Upstream used the widget's box or a centred square. A slider `bar_active_color` gradient now draws. |
| Rotate | A widget under a rotate receives press coordinates relative to its rotated box. Text under a rotate or mirror draws as one line. |
| Shapes | `shape_bounding`, `shape_clip` and `shape_input` on a client or a wibox are accepted and never read, and warn by name. A client's corners come from `client.shape` and a wibox's from its `shape`. |
| Align with `expand = "none"` | An outer widget wider than its half pushes the centre widget off centre instead of being cut at the half. |
| Stacking | 2.0 kept six fixed scene layers, background to overlay, and moved each client's and wibox's node between them in C. 2.1 has no layers: order is a band the tree declares ([Scene Graph](../concepts/scene-graph.md#bands)). |
| Layouts | 2.0's `arrange` computed a rectangle per client in Lua. 2.1 declares the layout as a Clay subtree. An `arrange` layout still works, with its numbers marked `legacy` in the dump. |
| Widget sizing | Clay computes widget geometry, replacing the per-widget `fit` and `layout` calls used in 2.0. |
| Client-local properties | `client:set_xproperty` stores scalar values across Lua hot reloads. The 2.0 method did nothing. See [client properties](#x-property-family). |
| Shadows | `clip_directional` is accepted but has no effect. Shadows fade on every side. Remove the setting. See [shadow reference](shadows.md). |
| Layout animation | A client frame declares no transition until something configures animation: `c.animation`, `theme.animation_duration` or any `theme.animation_*_duration` set to a number (0 included), `theme.animation_appear` or `animation_disappear`, or `somewm.animation.layout_duration` above 0. Requiring `somewm.layout_animation` sets that to 0.15 and is deprecated. A client's first frame after that, or after a reload, does not animate unless it has an entrance. |

## Testing compatibility {#testing-implications}

Tests relying on X11 properties or native clients' X11 metadata need a Wayland-specific expectation. Supported key release, keyboard-layout and input-injection APIs can be tested directly. [Nested compositor testing](../guides/testing-with-nested-compositor.md) keeps configuration checks separate from the desktop session.
