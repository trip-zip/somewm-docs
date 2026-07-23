---
title: FAQ
description: Short answers to common kiln questions, with links to the full pages.
sidebar_position: 99
---

# FAQ

Short answers to the questions that come up most. Each one links to the page that covers the topic in depth.

## Is kiln compatible with AwesomeWM configs or widgets?

No, by design. kiln has no compatibility layer, and AwesomeWM widget libraries (vicious, lain, bling, and the rest) are built on wibox and cairo, an imperative machinery kiln deliberately does not have. The concepts carry over; the code does not. See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm).

## How is kiln related to SomeWM?

kiln is SomeWM, an AwesomeWM-style framework for Wayland, re-based on the Clay layout library: an experiment in whether a compositor can use Clay as its base layer for layout, chrome, and hit testing. It keeps SomeWM's desktop concepts (clients, tags, layouts, rules) but replaces the API with its own declarative one, with no compat layer in either direction. See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm) and [The Clay Thesis](/kiln/concepts/the-clay-thesis).

## Can I draw gradients, arcs, or custom shapes?

No. The paint vocabulary is rectangles, corner radius, borders, images, text, and color (with alpha). There are no gradients, arcs, shadows, rotation, or arbitrary shapes, and no cairo escape hatch: everything on screen is composed from that vocabulary. This is a deliberate limit, not a missing feature. See [Limitations](/kiln/concepts/limitations).

## How do I script or query kiln from the shell?

kiln listens on a unix socket (`$XDG_RUNTIME_DIR/kiln.sock`, overridable with `KILN_SOCK`). Send Lua text, get the result back: it is a live REPL into the config VM, so everything in these docs is drivable from a script. The `scripts/kiln-eval` wrapper does the socket dance for you:

```bash
scripts/kiln-eval 'require("somewm").notify{title = "hello", message = "from the shell"}'
```

See [IPC and Scripting](/kiln/guides/ipc-and-scripting).

## Do screen sharing, screenshots, and recording work?

Yes. kiln ships the screencopy protocol, so the standard wlroots tools work: `grim` for screenshots, `slurp` for region selection, `wf-recorder` for recording, and OBS with wlroots capture for streaming. Gamma control is also shipped, so `wlsunset` and `gammastep` work. See [Screenshots](/kiln/guides/screenshots).

## Do display-configuration GUIs like wdisplays work?

No. kiln does not implement the wlr-output-management protocol, so external tools like wdisplays, kanshi, and nwg-displays cannot configure outputs. Output configuration lives in your config instead, through `core.output`: list outputs, set mode, scale, position, and enabled state from Lua. See [Multi-Monitor](/kiln/guides/multi-monitor).

## How do I make a client always float on a specific tag?

With a rule. Rules match clients on map and apply properties:

```lua
some.rule{
  match = { app = "mpv" },
  props = { tag = "3", floating = true },
}
```

`match` clauses take Lua patterns against `app` (the app_id), `class`, `instance`, `title`, and `role`, plus a `dialog` boolean and an `fn(c)` predicate. See [Client Rules](/kiln/guides/client-rules).

## Why does my bar or widget not update?

kiln only redraws a screen when something marks it dirty. Most stdlib property writes do that for you, but a plain value changing inside your widget function does not: the frame that would show it never happens. Declare what your widget depends on with `ui.widget{watch = {"client::focus"}, every = 30, fn}` so signals or a timer re-answer it, or call `some.dirty()` to force a frame. See [Frames and Dirty](/kiln/concepts/frames-and-dirty).

## Can I log into kiln from a display manager?

Nothing is documented for display managers today. The two supported ways to run kiln are from a bare TTY, where it drives DRM directly, or nested inside an existing Wayland or X session, where it opens as a window. Either way, launch it under a session bus so spawned clients have D-Bus:

```bash
dbus-run-session ./build/kiln
```

See [First Launch](/kiln/getting-started/first-launch).

## Where is the config file?

First hit wins:

1. `$KILN_RC`, if set
2. `$XDG_CONFIG_HOME/kiln/rc.lua` (falling back to `~/.config/kiln/rc.lua`)
3. the installed default under `<prefix>/share/kiln/rc.lua`
4. `rc.lua` in the working directory (how kiln runs from the source tree)

Copy the installed default to `~/.config/kiln/rc.lua` to start customizing. See [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy).

## How do I reload the config without restarting?

Call `some.reload()`. It re-runs your config in the live compositor: clients, tags, and screens survive. Bind it to a key, or trigger it over IPC:

```bash
scripts/kiln-eval 'require("somewm").reload()'
```

(Over the socket, use `require("somewm")`: the `some` variable is local to your
config file, not a global.) Note that reload re-runs the config file only;
stdlib modules are not re-required. See [Reload and Debugging](/kiln/guides/reload-and-debugging).

## What is the difference between c:close() and c:kill()?

`c:close()` is the polite close: it sends the client a close request and lets it exit cleanly. `c:kill()` is force: SIGKILL for Wayland clients, `xcb_kill_client` for X11 ones.

:::warning
If you come from AwesomeWM: there, `c:kill()` is the polite close. In kiln the polite verb is `c:close()`, and `c:kill()` really kills. Rebind your close key accordingly.
:::

See the [client reference](/kiln/reference/client).

## Is there a hotkeys cheat sheet?

Yes. Every `some.key` binding can carry `desc` and `group` fields, and the hotkeys popup renders them as an on-screen cheat sheet. `some.key.all()` returns the binding registry if you want to build your own. See [Hotkeys Popup](/kiln/guides/hotkeys-popup).
