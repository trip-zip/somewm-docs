---
title: Limitations
description: What kiln cannot do today, what it will not do by design, and the workarounds that exist.
sidebar_position: 8
---

# Limitations

Kiln's Odin implementation runs the maintainer's desktop, but the API is still
experimental. Software fixtures, reported physical use and untested hardware
paths have different evidence levels.

## Current evidence and accepted defects

The operator reported a working gruvbox physical desktop with foot and xterm,
keyboard/pointer input, tags/layout/focus cycling, fullscreen/maximise/restore,
reload, inspector selection/scroll/close and VT return. Native lock/unlock was
reported successful after instructions to check coverage, wrong-password
rejection, normal login-password unlock and restored input. Each substep and
every output were not independently instrumented.

Physical hotplug, DPMS, VRR/gamma, external locking and systematic mixed-scale
testing remain pending. Automated authentication uses a fixture and does not
prove physical-seat security. A brief client-placement observation across VT
switching remains unresolved; it is not classified as a proven shared bug.

The implementation retains these documented limits:

- Clay hit testing misses a visible child in a horizontal-only clip and accepts
  a hit outside a nested outer clip. Exact inherited capture/scissor fingerprints
  are retained in the source repository's `scripts/clay-contract-baseline.json`
  and `scripts/clay-live-baseline.json` test fixtures.
- Inspector custom palette styling is deferred. Rejected raster work can advance
  private inspector selection; a rejected toggle needs retry. There is no claim
  of private Clay state rollback.
- Incoming X11-to-Wayland drag-and-drop is unsupported.
- A slow incoming X11 INCR transfer can truncate on EAGAIN.
- Incoming INCR owner death can leave no EOF and retain one pipe FD.

The three XWayland classifications are guarded against wlroots 0.20.2 and
XWayland 24.1.14. Supported-path soak success does not erase them. The source
checkout's `TESTING.md` describes the compatibility suite and strict probes.

## The drawing vocabulary

kiln draws rectangles, rounded corners, borders, images, text, and color. That is the complete list, and it is deliberate: the vocabulary is what Clay declares and the retained renderer reconciles, with no escape hatch into arbitrary painting.

Not available as drawing primitives: gradients, arcs, rings, and circles (so no radial progress bars or pie charts), rotation and mirroring, drop shadows, shapes beyond the rounded rectangle, and per-window opacity. There is no Lua canvas and no cairo access; a config cannot paint pixels, only declare nodes. The escape hatch is an image: `kiln.asset` renders SVG (including [`kiln.asset.gradient`](/kiln/reference/kiln)) to cached PNGs, which is how the default desktop gets its gradient wallpaper and its glyphs. A surprising number of widgets fit the vocabulary directly, but if your aesthetic depends on painting at declare time, kiln cannot draw it today.

## Current gaps

These are unbuilt, not refused:

- **No pointer warp.** A config cannot move the cursor, so focus-follows policies that warp the pointer to the focused client are not expressible.
- **Floating clients do not honor size hints.** Min, max, and increment size hints are not read: a floating terminal resizes freely instead of in cell steps, a dialog can be squeezed below its minimum, and the only floor is the uniform `theme.min_size`.
- **Bars reserve workarea at an output edge.** All four edges are supported. A decorative floating pill can be declared as a float, but a float reserves no workarea. See [A bar from scratch](/kiln/tutorials/a-bar-from-scratch).

## Protocol support for external tools

What works, today, with stock tools:

- **Screen capture**: screencopy and internal screenshots are implemented and tested in isolated runs. This is not a blanket validation of every recorder/portal integration. See [Screenshots](/kiln/guides/screenshots).
- **Colour temperature**: the gamma control protocol is implemented; physical gamma/driver behaviour remains pending.
- **Session locking**: native lock and the external session-lock protocol have software coverage. Physical external-locker coverage remains pending. See [Lockscreen and idle](/kiln/guides/lockscreen-and-idle).
- **Layer-shell** (panels, launchers, OSDs), **xdg-activation** (focus handoff), and **foreign-toplevel** (taskbars, window switchers).

What does not:

- **No wlr-output-management.** kanshi, wdisplays, and similar display configurators cannot talk to kiln. Output configuration is done from your config with `core.output` instead, which covers a static setup well; see [Multi-monitor](/kiln/guides/multi-monitor).
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
