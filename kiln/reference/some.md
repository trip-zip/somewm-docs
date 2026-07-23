---
title: some
description: The some module, the root of kiln's config API, with its fields, functions, submodules, and input settings.
sidebar_position: 7
---

# some

`some` is the root of kiln's configuration API: everything a config does goes through this table or one of its submodules. Load it once at the top of your `rc.lua`:

```lua
local some = require("somewm")

some.modkey = "super"
some.spawn("foot")
```

## Fields and submodules

| Field | Description |
|---|---|
| `some.theme` | The live theme table. See [theme variables](/kiln/reference/theme-variables). |
| `some.modkey` | The modifier that `"mod"` resolves to in key and button specs. Default `"alt"`. Read at binding time, so set it before your `some.key{}` calls. |
| `some.defaults` | The 10 replaceable policy functions. See [some.defaults](/kiln/reference/defaults). |
| `some.input` | Input device settings as plain read-write properties. See [some.input](#someinput) below. |
| `some.ui` | The declarative node tree: boxes, text, bars, floats. See [some.ui](/kiln/reference/ui). |
| `some.layout` | The tiling layouts and the layout registry. See [some.layout](/kiln/reference/layout). |
| `some.animation` | Frame-clock easing: `get` and `start`. See [some.animation](#someanimation) below. |
| `some.lockscreen` | The built-in lockscreen. `configure{}` overrides its colors and formats. See [Lockscreen and idle](/kiln/guides/lockscreen-and-idle). |
| `some.prompt` | The inline text prompt: `run{}` and `completion`. See [some.prompt](#someprompt) below. |
| `some.menu` | Popup menus: `show`, `close`, `client_list`. See [Menus](/kiln/guides/menus). |
| `some.tooltip` | `attach(text)` returns an `on_hover` handler. See [some.tooltip](#sometooltip) below. |
| `some.placement` | 14 float-placement helpers. See [some.placement](/kiln/reference/placement). |
| `some.icon` | Application icon lookup: `path(name)` and `client(c)`. See [some.icon](#someicon) below. |
| `some.object` | The class factory and handle registry (`attach`, `detach`, `lookup`). See [the object model](/kiln/concepts/object-model). |

Key bindings, mouse buttons, and client rules (`some.key`, `some.button`, `some.rule`, `some.focused`) have their own page: [Keys, Buttons, and Rules](/kiln/reference/keybindings-and-rules).

## Spawning

| Function | Description |
|---|---|
| `some.spawn(cmd)` | Fire and forget. `cmd` is an argv table or a shell string. |
| `some.spawn.pipe(cmd, cbs)` | Async spawn with output callbacks. Returns an id. `cbs` may carry `on_line(line)` (stdout, one call per complete line, trailing unterminated line flushed at exit), `on_err(chunk)` (stderr, raw chunk, not line-split), and `on_exit(code)`. |
| `some.spawn.watch(cmd, interval, cb)` | Run `cmd`, feed each stdout line to `cb`, and re-run it `interval` seconds after each exit. Returns a handle; `handle:stop()` cancels the re-arm. |
| `some.spawn_with_token(cmd)` | Like `spawn`, but the child gets an `XDG_ACTIVATION_TOKEN` in its environment, so its activation request arbitrates as user-initiated. |

See [Spawn lifecycle](/kiln/guides/spawn-lifecycle) for how pipes and watches behave across reload.

## Housekeeping

| Function | Description |
|---|---|
| `some.timer(ms, fn)` | One-shot timer. Returns an id; cancel with `core.timer_cancel(id)`. |
| `some.quit()` | Exit the compositor. |
| `some.dirty(screen_name?)` | Force a re-declare of the named screen, or of every screen when called with no argument. |
| `some.image_reload(path)` | Drop the cached decode of an image file, so the next frame re-reads it from disk. |
| `some.reload()` | Re-run the config file in the live process. |

:::note
`some.reload()` re-runs your `rc.lua`, not the library: it does NOT re-require stdlib modules, so edits to kiln's own Lua need a restart. A reload drops everything the config built (bindings, rules, listeners, grabs, watches) and keeps everything the compositor owns (screens, layer surfaces, notifications, running children, input settings). Clients survive as clients but are re-tagged by the new config's rules, and a client minimized from the config side comes back unminimized. A broken config leaves a live compositor; the error surfaces through `some.on("error")`.
:::

## Signals

| Function | Description |
|---|---|
| `some.on(name, fn)` | Subscribe on the global bus. |

| Signal | Payload | Emitted when |
|---|---|---|
| `error` | `signal, err` | Any config callback raised an error (they are pcall-isolated). |
| `idle::start` | | The armed idle timeout elapsed with no input. |
| `idle::stop` | | Input resumed after idle. |
| `idle::inhibit` | `on` | An idle inhibitor (a video player, for example) engaged or released. |

## Session lock and idle

| Function | Description |
|---|---|
| `some.lock()` | Engage the native session lock. From the instant it returns, no binding is reachable and no client sees input. |
| `some.unlock()` | Release the lock. Refused by C unless a prior `core.authenticate` succeeded, so a config cannot bypass authentication. |
| `some.set_idle_timeout(ms)` | Arm the idle timer for `ms` of no input; the `idle::*` signals above fire from it. `nil` or `0` disarms. |

Wire idle to the lock in a few lines; see [Lockscreen and idle](/kiln/guides/lockscreen-and-idle).

## Grabs

A grab is an exclusive claim on an input device: while it holds, the grabber outranks every binding and no client sees the device. One claim per device, no stack: starting a grab while another holds stops the old one first. A grabber whose callback errors is released before the error surfaces.

| Function | Description |
|---|---|
| `some.keygrabber{ key = fn(ev), stopped = fn }` | Claim the keyboard. `ev` is the ordinary key origin event, `utf8` field included, so composed text arrives resolved. Returns a handle; `handle:stop()` releases. |
| `some.mousegrabber{ motion = fn, button = fn, axis = fn, stopped = fn }` | Claim the pointer. Each handler takes the matching input event. The claim consumes every pointer event even when it has no handler for it. Returns a handle; `handle:stop()` releases. |

## some.input

Input device settings as plain read-write properties:

```lua
some.input.repeat_rate = 40
some.input.keymap = { layout = "us", variant = "colemak" }
some.input.tap_to_click = true
```

Writes forward to C immediately; reads return the last written value (there is no readback from C by design, so the store is the record of what was asked for). Every setting applies to every device of its kind: there is no per-device configuration.

| Property | Type | Default | Description |
|---|---|---|---|
| `keymap` | table | unset | XKB keymap: `{rules, model, layout, variant, options}`. |
| `repeat_rate` | number | `25` | Key repeats per second. |
| `repeat_delay` | number | `600` | Milliseconds before repeat starts. |
| `numlock` | boolean | unset | Numlock state at startup. |
| `tap_to_click` | boolean | unset | Touchpad tap registers as a click. |
| `natural_scrolling` | boolean | unset | Invert scroll direction. |
| `left_handed` | boolean | unset | Swap primary and secondary buttons. |
| `accel_speed` | number | unset | Pointer acceleration speed. |
| `accel_profile` | string | unset | Pointer acceleration profile: `"flat"`, anything else means adaptive. |
| `scroll_method` | string | unset | How scrolling is generated: `"two_finger"`, `"edge"`, or `"button"`; anything else disables. |
| `click_method` | string | unset | How touchpad clicks are generated: `"button_areas"` or `"clickfinger"`. |

See [Input devices](/kiln/guides/input-devices) for worked examples.

## some.animation

Easing over the true frame delta. While any key on a screen animates, that screen re-solves at panel rate; when the last animation finishes the screen goes idle again.

| Function | Description |
|---|---|
| `some.animation.get(key, dflt)` | The eased value for `key` right now. Mid-animation it interpolates; idle it returns (and remembers) `dflt`, so the next start eases from where the display sits. |
| `some.animation.start(screen, key, target, dur, from)` | Ease `key` on the named screen (`screen` is the screen name string) toward `target` over `dur` seconds (default 0.15). `from` defaults to the last value `get` saw; pass it explicitly to restart from a fixed point. |

## some.lockscreen

`some.lockscreen.configure(cfg)` overrides the built-in lockscreen's appearance. Keys and their defaults:

| Key | Default |
|---|---|
| `bg` | `"#101014"` |
| `fg` | `"#dcdce6"` |
| `error` | `"#c05068"` |
| `clock_size` | `48` |
| `date_size` | `16` |
| `dots_size` | `22` |
| `status_size` | `14` |
| `clock_format` | `"%H:%M"` |
| `date_format` | `"%A, %B %d"` |
| `prompt` | `"Enter password to unlock"` |
| `fail` | `"Authentication failed"` |

## some.prompt

`some.prompt.run(spec)` opens an inline text prompt. It holds the keyboard for its lifetime (it is a keygrabber underneath); starting one while another runs stops the first. Returns the prompt object; `:stop()` closes it with no callback.

| Spec field | Description |
|---|---|
| `screen` | Screen to show on. Default `screen.focused`. |
| `label` | Text before the input, for example `"Run: "`. Default `""`. |
| `text` | Initial content; the cursor lands at its end. Default `""`. |
| `done(text)` | Called on Return with the final text. |
| `cancelled()` | Called on Escape. |
| `changed(text)` | Called on every edit. |
| `completion(text, cursor)` | Called on Tab. Returns the new `text, cursor`, or `nil` to no-op. |
| `history` | A history list to cycle with the arrow keys. Default: the shared `prompt.history`. |

`some.prompt.completion(candidates)` builds a Tab-cycling completion function in that shape: `candidates(prefix)` returns a list of words, the cycler keeps the prefix matches and advances through them on repeated Tab, and any manual edit resets the cycle. See [App launcher](/kiln/guides/app-launcher) for a full run prompt.

## some.tooltip

`some.tooltip.attach(text)` returns an `on_hover` handler for the element it describes; `ui.tooltip` is the same function. `text` is a string or a function read at declare time, so a live tooltip needs no update path:

```lua
ui.box({ id = "clock", on_hover = ui.tooltip(function()
    return os.date("%A %d %B")
end) }, function()
    ui.text(os.date("%H:%M"))
end)
```

The tooltip opens above or below the element depending on which half of the screen it sits in, and never captures clicks.

## some.icon

| Function | Description |
|---|---|
| `some.icon.path(name)` | Resolve an application name to an icon file path, or `nil`. Consults the app's `.desktop` `Icon=` line, then the icon theme and pixmaps directories. Memoized, misses included. |
| `some.icon.client(c)` | The best icon for a client: `c.icon` if C already holds one (X11 pixel data), else the lookup on `c.app_id`, else on `c.class` and its lowercase form. |

## See also

- [Keys, Buttons, and Rules](/kiln/reference/keybindings-and-rules)
- [some.defaults](/kiln/reference/defaults)
- [some.ui](/kiln/reference/ui)
- [some.layout](/kiln/reference/layout)
- [Signals index](/kiln/reference/signals)
- [Reload and debugging](/kiln/guides/reload-and-debugging)
- [Input devices](/kiln/guides/input-devices)
