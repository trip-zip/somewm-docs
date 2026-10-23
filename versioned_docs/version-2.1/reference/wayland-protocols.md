---
sidebar_position: 12
title: Wayland Protocols
description: Wayland protocols somewm advertises to clients
---

# Wayland Protocols

Interfaces advertised by SomeWM 2.1.0. Versions below were checked with wlroots 0.20.2. Clients can bind an older version. Renderer-dependent interfaces are noted separately.

## Core

| Protocol | Version |
|----------|---------|
| `wl_compositor` | 6 |
| `wl_shm` | 2 |
| `wl_subcompositor` | 1 |
| `wl_seat` | 9 |
| `wl_output` | 4 |
| `wl_data_device_manager` | 3 |

## Shells and decorations

| Protocol | Version | Purpose |
|----------|---------|---------|
| `xdg_wm_base` | 6 | Application windows and popups |
| `zwlr_layer_shell_v1` | 3 | Bars, docks, wallpapers, notifications |
| `xdg_activation_v1` | 1 | Focus and urgency requests |
| `zwlr_foreign_toplevel_manager_v1` | 3 | External window list and control |
| `ext_session_lock_manager_v1` | 1 | Lockscreens |
| `zxdg_decoration_manager_v1` | 1 | Client/server decoration negotiation |
| `org_kde_kwin_server_decoration_manager` | 1 | Legacy decoration fallback |

## Clipboard and capture

| Protocol | Version | Purpose |
|----------|---------|---------|
| `zwlr_data_control_manager_v1` | 2 | Clipboard without focus |
| `zwp_primary_selection_device_manager_v1` | 1 | Middle-click paste |
| `zwlr_screencopy_manager_v1` | 3 | Pixel screen capture |
| `zwlr_export_dmabuf_manager_v1` | 1 | GPU-buffer screen capture |

SomeWM 2.1.0 does not advertise `ext_image_copy_capture_manager_v1` or `ext_output_image_capture_source_manager_v1`. Capture tools must use one of the supported interfaces above.

## Input

| Protocol | Version | Purpose |
|----------|---------|---------|
| `wp_cursor_shape_manager_v1` | 1 | Named cursors |
| `zwp_pointer_gestures_v1` | 3 | Touchpad swipe, pinch, hold |
| `zwp_pointer_constraints_v1` | 1 | Lock or confine pointer |
| `zwp_relative_pointer_manager_v1` | 1 | Relative motion deltas |
| `zwp_virtual_keyboard_manager_v1` | 1 | Virtual keyboard input |
| `zwlr_virtual_pointer_manager_v1` | 2 | Virtual pointer input |
| `zwp_tablet_manager_v2` | 1 | Tablet tools and pads |

## Output

| Protocol | Version | Purpose |
|----------|---------|---------|
| `zxdg_output_manager_v1` | 3 | Logical output geometry |
| `zwlr_output_manager_v1` | 4 | Output config (`kanshi`, `wlr-randr`) |
| `zwlr_output_power_manager_v1` | 1 | DPMS |
| `zwlr_gamma_control_manager_v1` | 1 | Gamma ramps (`gammastep`, `wlsunset`) |

## Rendering and buffers

| Protocol | Version | Purpose |
|----------|---------|---------|
| `zwp_linux_dmabuf_v1` | 5 | GPU buffer sharing |
| `wp_linux_drm_syncobj_manager_v1` | 1 | Explicit GPU sync |
| `wp_viewporter` | 1 | Surface crop and scale |
| `wp_single_pixel_buffer_manager_v1` | 1 | Solid-color buffers |
| `wp_fractional_scale_manager_v1` | 1 | Non-integer HiDPI scaling |
| `wp_alpha_modifier_v1` | 1 | Per-surface alpha |
| `wp_presentation` | 2 | Frame timestamps |
| `wl_drm` | 2 | Legacy, superseded by `zwp_linux_dmabuf_v1` |

`wl_drm` and `zwp_linux_dmabuf_v1` require a renderer with DMA-BUF support. Explicit sync additionally requires a DRM file descriptor and timeline support in both the renderer and backend. These are absent from a Pixman headless session.

## Idle

| Protocol | Version | Purpose |
|----------|---------|---------|
| `ext_idle_notifier_v1` | 2 | Idle-timeout notifications |
| `zwp_idle_inhibit_manager_v1` | 1 | Idle inhibition |

## XWayland

Built when XWayland dependencies are available, then started on demand for the first X11 client. `xwayland_shell_v1` version 1 supports XWayland integration. Disable XWayland with `meson setup build -Dxwayland=disabled`.
