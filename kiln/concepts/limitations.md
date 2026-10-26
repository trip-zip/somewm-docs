---
title: Limitations
description: What kiln cannot do today, what it will not do by design, and the workarounds that exist.
sidebar_position: 7
---

# Limitations

Kiln runs the maintainer's desktop on its own DRM backend, logind session,
libinput and renderer, but the API is still experimental.

## What is tested and what is not {#current-evidence-and-accepted-defects}

The maintainer runs the Odin implementation daily on one AMD GPU with a
laptop panel and one external display: keyboard and pointer input, tags,
layouts and focus, fullscreen and maximise, reload, the inspector, the
native lock, screenshots, XWayland clients and the clipboard. Physical
hotplug, VT switching under load, DPMS, VRR and gamma on hardware, external
lockers and mixed-scale setups are tested less often or not at all.

Accepted limits of the backends:

- Hardware access goes through logind only; seatd is not supported, and a
  GPU without atomic mode setting is refused. One GPU is driven.
- The cursor is composited in software, so animated cursors show their
  first frame and every cursor move is a frame. Fullscreen clients are
  composited too, never scanned out directly.
- `core.output.set_mode` accepts only timings the display advertises; there
  is no mode generator.
- After a GPU reset kiln exits cleanly instead of recreating its renderer.
- Screencopy offers no dmabuf targets and always includes the cursor.
- A nested kiln needs a Wayland parent (no X11 host) and does not import the
  parent's Caps Lock or Num Lock state.
- `WAYLAND_DEBUG` accepts `1` and `server` only.

Known bugs:

- Clay hit testing misses a visible child in a horizontal-only clip and accepts
  a hit outside a nested outer clip.
- `core.inspector` accepts only `enabled` and `width`; any palette key raises
  an error. If a frame fails, the inspector's selected row can still change,
  and a toggle made in that frame is lost; toggle again.
- Incoming X11-to-Wayland drag-and-drop is unsupported.
- A slow incoming X11 INCR transfer can truncate on EAGAIN.
- Incoming INCR owner death can leave no EOF and retain one pipe FD.

Tests confirm these three against XWayland 24.1.14.

## The drawing vocabulary

kiln draws rectangles, rounded corners, borders, images, text, and color. That is the complete list, and it is deliberate: the vocabulary is what Clay declares and the retained renderer reconciles, with no escape hatch into arbitrary painting.

Not available as drawing primitives: gradients, arcs, rings, and circles (so no radial progress bars or pie charts), rotation and mirroring, drop shadows, shapes beyond the rounded rectangle, and per-window opacity. There is no Lua canvas and no cairo access; a config cannot paint pixels, only declare nodes. The escape hatch is an image: `kiln.asset` renders SVG (including [`kiln.asset.gradient`](/kiln/reference/kiln)) to cached PNGs, which is how the default desktop gets its gradient wallpaper and its glyphs. If your aesthetic depends on painting at declare time, kiln cannot draw it today.

## Current gaps

These are unbuilt, not refused:

- **No pointer warp.** A config cannot move the cursor, so focus-follows policies that warp the pointer to the focused client are not expressible.
- **Floating clients do not honor size hints.** Min, max, and increment size hints are not read: a floating terminal resizes freely instead of in cell steps, a dialog can be squeezed below its minimum, and the only floor is the uniform `theme.min_size`.
- **Only edge bars reserve workarea.** A bar declared as a float (a floating pill) reserves none. See [A bar from scratch](/kiln/tutorials/a-bar-from-scratch).

## Protocol support for external tools

What works, today, with stock tools:

- **Screen capture**: screencopy (wlr-screencopy) and `core.screenshot` work. Portal-based recorders are untested. See [Screenshots](/kiln/guides/screenshots).
- **Colour temperature**: the gamma control protocol is implemented; untested on real hardware.
- **Session locking**: both the native lock and ext-session-lock work; external lockers are untested on hardware. See [Lockscreen and idle](/kiln/guides/lockscreen-and-idle).
- **Layer-shell** (panels, launchers, OSDs), **xdg-activation** (focus handoff), and **foreign-toplevel** (taskbars, window switchers).

What does not:

- **No wlr-output-management.** kanshi, wdisplays, and similar display configurators cannot talk to kiln. Output configuration is done from your config with `core.output` instead; see [Multi-monitor](/kiln/guides/multi-monitor).
- **No output power management.** wlopm and dpms-style tools have no protocol to use. Disabling an output from config via `core.output.set_enabled` is the available lever.
- **No virtual keyboard or pointer.** wtype, ydotool's Wayland path, and remote-input tools cannot inject input.

## Input configuration is global

`kiln.input` settings (acceleration, natural scrolling, tap-to-click, and the rest) apply to every device. There are no per-device settings, so a laptop with an external mouse cannot give the touchpad and the mouse different acceleration profiles. Single-pointer setups lose nothing. See [Input devices](/kiln/guides/input-devices).

## External widget libraries

Widget libraries written for other compositors will never load in kiln: the imperative drawing machinery they are built against does not exist here, by design, and no compatibility layer is planned. Their outcomes are often reachable anyway: the standard forms (progress bars, sliders, toggles) ship on [`kiln.widgets`](/kiln/reference/widgets), and the rest usually reduce to a poll plus a declaration; see [Data widgets](/kiln/guides/data-widgets) for both paths. For what carries over from AwesomeWM and what does not, see [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm).

## See also

- [Kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm)
- [The Clay Bet](/kiln/concepts/the-clay-bet)
- [FAQ](/kiln/faq)
