---
title: FAQ
description: Short answers to common kiln questions, with links to the full pages.
sidebar_position: 99
---

# FAQ

## Is kiln compatible with AwesomeWM configs or widgets?

No, by design. kiln has no compatibility layer, and AwesomeWM widget libraries (vicious, lain, bling, and the rest) are built on wibox and cairo, an imperative machinery kiln deliberately does not have. The concepts carry over; the code does not. See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm).

## How is kiln related to SomeWM?

kiln began as a SomeWM fork that tests whether Clay can do a compositor's layout, widgets and hit testing. It keeps SomeWM's desktop concepts (clients, tags, layouts, rules) but replaces the API with its own declarative one, with no compat layer in either direction. See [kiln vs SomeWM](/kiln/concepts/kiln-vs-somewm) and [One tree per screen](/kiln/concepts/one-tree).

## Can I draw gradients, arcs, or custom shapes?

Not as drawing primitives. The paint vocabulary is rectangles, corner radius, borders, images, text, and color (with alpha). There is no cairo drawing API. For anything else, render an SVG to a PNG with `kiln.asset` (`kiln.asset.gradient` for ramps) and declare it as an image; that is how the default desktop draws its wallpaper and glyphs. See [Limitations](/kiln/concepts/limitations).

## How do I script or query kiln from the shell?

kiln listens on a unix socket (`$XDG_RUNTIME_DIR/kiln.sock`, overridable with `KILN_SOCK`). The socket evaluates the Lua you send in the running config's Lua state and returns the result. The installed `kiln-client` command handles the socket protocol:

```bash
kiln-client eval 'require("kiln").notify{title = "hello", message = "from the shell"}'
```

See [IPC and Scripting](/kiln/guides/ipc-and-scripting).

## Do screen sharing, screenshots, and recording work?

Kiln implements wlr-screencopy, so grim works. It implements wlr-gamma-control
(wlsunset, gammastep). Screen sharing through xdg-desktop-portal-wlr is
untested. See [Screenshots](/kiln/guides/screenshots) and [Limitations](/kiln/concepts/limitations).

## Do display-configuration GUIs like wdisplays work?

No. kiln does not implement the wlr-output-management protocol, so external tools like wdisplays, kanshi, and nwg-displays cannot configure outputs. Output configuration lives in your config instead, through `core.output`: list outputs, set mode, scale, position, and enabled state from Lua. See [Multi-Monitor](/kiln/guides/multi-monitor).

## How do I make a client always float on a specific tag?

With a rule. Rules match clients on map and apply properties:

```lua
kiln.rule{
  match = { app = "mpv" },
  props = { tag = "media", floating = true },
}
```

`tag` is a tag name; the default config's tags are `dev`, `web`, `chat`, `files` and `media`. [Client Rules](/kiln/guides/client-rules) covers what clauses can match and how rules stack.

## Why does my bar or widget not update?

kiln only redraws a screen when something marks it dirty. Most stdlib property writes do that for you, but a plain value changing inside your widget function does not: the frame that would show it never happens. Declare what your widget depends on with `ui.widget{watch = {"client::focus"}, every = 30, fn}` so a listed signal or the timer marks the screen dirty and your function runs again, or call `kiln.dirty()` to force a frame. See [Frames and Dirty](/kiln/concepts/frames-and-dirty).

## Can I log into kiln from a display manager?

Yes. `make install` puts `kiln.desktop` in `$(datadir)/wayland-sessions`.
Display managers scan `/usr/share` and usually `/usr/local/share`, not
`~/.local/share`. Kiln also runs from a free TTY or nested inside an existing
desktop. See [First Launch](/kiln/getting-started/first-launch).

## Where is the config file?

`~/.config/kiln/rc.lua`, falling back to the installed default; `KILN_RC` overrides both ([full search order](/kiln/reference/environment-and-ipc#config-search-order)). Copy the installed default to `~/.config/kiln/rc.lua` to start customizing. See [Anatomy of rc.lua](/kiln/getting-started/rc-anatomy).

## How do I reload the config without restarting?

Call `kiln.reload()`. It re-runs your config in the live compositor. Clients and screens survive. Tags are recreated by your config, and clients are re-sorted onto them. Bind it to a key, or trigger it over IPC:

```bash
kiln-client eval 'require("kiln").reload()'
```

Over the socket, use `require("kiln")`, as [IPC and Scripting](/kiln/guides/ipc-and-scripting) explains. Reload re-runs the config file only;
stdlib modules are not re-required. See [Reload and Debugging](/kiln/guides/reload-and-debugging).

## What is the difference between c:close() and c:kill()?

`c:close()` is the polite close: it sends the client a close request and lets it exit cleanly. `c:kill()` is force: SIGKILL for Wayland clients, `xcb_kill_client` for X11 ones.

:::warning
If you come from AwesomeWM: there, `c:kill()` is the polite close. In kiln the polite verb is `c:close()`, and `c:kill()` really kills. Rebind your close key accordingly.
:::

See the [client reference](/kiln/reference/client).

## Is there a hotkeys cheat sheet?

Yes. Every `kiln.key` binding can carry `desc` and `group` fields, and the hotkeys popup renders them as an on-screen cheat sheet. `kiln.key.all()` returns the binding registry if you want to build your own. See [Hotkeys Popup](/kiln/guides/hotkeys-popup).
