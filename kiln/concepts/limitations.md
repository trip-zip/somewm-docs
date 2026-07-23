---
title: Limitations
description: What kiln cannot do today, what it will not do by design, and the workarounds that exist.
sidebar_position: 7
---

# Limitations

kiln is a proof of concept, and this page is the honest inventory: what the model excludes on purpose, what is simply not built yet, and what external tools can and cannot expect. Where a workaround exists, it is linked.

## The drawing vocabulary

kiln draws rectangles, rounded corners, borders, images, text, and color. That is the complete list, and it is deliberate: the vocabulary is what Clay declares and the C renderer reconciles, with no escape hatch into arbitrary painting.

Not available: gradients, arcs, rings, and circles (so no radial progress bars or pie charts), rotation and mirroring, drop shadows, shapes beyond the rounded rectangle, and per-window opacity. There is no Lua canvas and no cairo access; a config cannot paint pixels, only declare nodes. A surprising amount of chrome fits the vocabulary (the default desktop, including its launcher glyph, is composed entirely from it), but if your aesthetic depends on arcs and gradients, kiln cannot draw it today.

## Current gaps

These are unbuilt, not refused:

- **No pointer warp.** A config cannot move the cursor, so focus-follows policies that warp the pointer to the focused client are not expressible.
- **Menus are pointer-only.** No arrow-key navigation, enter to select, or escape to close in [menus](/kiln/guides/menus), and the same applies to the [hotkeys popup](/kiln/guides/hotkeys-popup) and the layout picker, which are built on the same machinery.
- **Floating clients do not honor size hints.** Min, max, and increment size hints are not read: a floating terminal resizes freely instead of in cell steps, a dialog can be squeezed below its minimum, and the only floor is the uniform `theme.min_size`.
- **Bars are full-width top or bottom struts.** No vertical bars, no floating pill bars, no margins or partial width. A pill can be declared as a float, but a float reserves no workarea. See [A bar from scratch](/kiln/tutorials/a-bar-from-scratch) for what bars can do.

## Protocol support for external tools

What works, today, with stock tools:

- **Screen capture**: screencopy is implemented, so grim, slurp, wf-recorder, and OBS's wlroots capture all work. See [Screenshots](/kiln/guides/screenshots).
- **Color temperature**: gamma control is implemented; wlsunset and gammastep work.
- **Session locking**: external lockers work via the session lock protocol, alongside kiln's native lock. See [Lockscreen and idle](/kiln/guides/lockscreen-and-idle).
- **Layer-shell** (panels, launchers, OSDs), **xdg-activation** (focus handoff), and **foreign-toplevel** (taskbars, window switchers).

What does not:

- **No wlr-output-management.** kanshi, wdisplays, and similar display configurators cannot talk to kiln. Output configuration is done from your config with `core.output` instead, which covers a static setup well; see [Multi-monitor](/kiln/guides/multi-monitor).
- **No output power management.** wlopm and dpms-style tools have no protocol to use. Disabling an output from config via `core.output.set_enabled` is the available lever.
- **No virtual keyboard or pointer.** wtype, ydotool's Wayland path, and remote-input tools cannot inject input.

## Input configuration is global

`some.input` settings (acceleration, natural scrolling, tap-to-click, and the rest) apply to every device. There are no per-device settings, so a laptop with an external mouse cannot give the touchpad and the mouse different acceleration profiles. Single-pointer setups lose nothing. See [Input devices](/kiln/guides/input-devices).

## The AwesomeWM ecosystem

AwesomeWM widget libraries (vicious, lain, bling, awesome-wm-widgets) are wibox and cairo code, and cannot be ported: the machinery they are written against does not exist in kiln, by design. Their outcomes are often reachable anyway, since most data widgets reduce to a poll plus a declaration; see [Data widgets](/kiln/guides/data-widgets) for the kiln way to build them. But the libraries themselves will never load, and no compatibility layer is planned.

## See also

- [Kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm)
- [The Clay Thesis](/kiln/concepts/the-clay-thesis)
- [FAQ](/kiln/faq)
