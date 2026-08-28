---
sidebar_position: 12
title: Wayland Protocols
description: Wayland protocols somewm advertises to clients
---

# Wayland Protocols

Wayland protocols somewm advertises in its registry. Versions are the maximum announced; clients negotiate down as needed.

## Core

| Protocol | Version |
|----------|---------|
| `wl_compositor` | 6 |
| `wl_subcompositor` | |
| `wl_seat` | |
| `wl_output` | |
| `wl_data_device_manager` | |

## Shells and decorations

| Protocol | Version | Purpose |
|----------|---------|---------|
| `xdg_shell` | 6 | Application windows and popups |
| `zwlr_layer_shell_v1` | 3 | Bars, docks, wallpapers, notifications |
| `xdg_activation_v1` | | Focus and urgency requests |
| `zwlr_foreign_toplevel_management_v1` | | External window list and control |
| `ext_session_lock_manager_v1` | | Lockscreens |
| `zxdg_decoration_manager_v1` | | Client/server decoration negotiation |
| `org_kde_kwin_server_decoration` | | Legacy decoration fallback |

## Clipboard and capture

| Protocol | Version | Purpose |
|----------|---------|---------|
| `zwlr_data_control_manager_v1` | | Clipboard without focus |
| `zwp_primary_selection_device_manager_v1` | | Middle-click paste |
| `zwlr_screencopy_manager_v1` | | Pixel screen capture |
| `zwlr_export_dmabuf_manager_v1` | | GPU-buffer screen capture |

## Input

| Protocol | Version | Purpose |
|----------|---------|---------|
| `wp_cursor_shape_v1` | 1 | Named cursors |
| `zwp_pointer_gestures_v1` | | Touchpad swipe, pinch, hold |
| `zwp_pointer_constraints_v1` | | Lock or confine pointer |
| `zwp_relative_pointer_manager_v1` | | Relative motion deltas |
| `zwp_virtual_keyboard_manager_v1` | | Virtual keyboard input |
| `zwlr_virtual_pointer_manager_v1` | | Virtual pointer input |

## Output

| Protocol | Version | Purpose |
|----------|---------|---------|
| `zxdg_output_manager_v1` | | Logical output geometry |
| `zwlr_output_manager_v1` | | Output config (`kanshi`, `wlr-randr`) |
| `zwlr_output_power_management_v1` | | DPMS |
| `zwlr_gamma_control_manager_v1` | | Gamma ramps (`gammastep`, `wlsunset`) |

## Rendering and buffers

| Protocol | Version | Purpose |
|----------|---------|---------|
| `zwp_linux_dmabuf_v1` | 5 | GPU buffer sharing |
| `wp_linux_drm_syncobj_manager_v1` | 1 | Explicit GPU sync |
| `wp_viewporter` | | Surface crop and scale |
| `wp_single_pixel_buffer_manager_v1` | | Solid-color buffers |
| `wp_fractional_scale_manager_v1` | 1 | Non-integer HiDPI scaling |
| `wp_alpha_modifier_v1` | | Per-surface alpha |
| `wp_presentation` | | Frame timestamps |
| `wl_drm` | | Legacy, superseded by `zwp_linux_dmabuf_v1` |

## Idle

| Protocol | Version | Purpose |
|----------|---------|---------|
| `ext_idle_notifier_v1` | | Idle-timeout notifications |
| `zwp_idle_inhibit_manager_v1` | | Idle inhibition |

## XWayland

Included by default, started on demand for the first X11 client. Disable with `meson setup -Dxwayland=disabled`.
