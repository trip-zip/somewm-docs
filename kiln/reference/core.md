---
title: core
description: The raw C boundary, 54 functions across core.*, core.client.*, core.input.*, and core.output.*.
sidebar_position: 15
---

# core

`core` is the raw C surface of the compositor: 54 functions across `core.*`, `core.client.*`, `core.input.*`, and `core.output.*`. Everything the stdlib does (layout, chrome, focus, rules) is built by calling these.

:::note
`core.*` is the raw C boundary the stdlib is built on. Configs should prefer the object model (`client`, `tag`, `screen`, `layer`, `notification`) and `some.*`, but everything here is reachable from config code and over IPC.
:::

```lua
-- readback over IPC: where did the element named "bar" land?
local b = core.box("bar")
print(b.x, b.y, b.width, b.height)
```

## core.*

### Declare

These four build the Clay element tree and error outside a frame or lock handler ("declare primitives are only callable inside the frame handler"). Normally only the stdlib's frame handler calls them; `some.ui` nodes compile down to these.

| Function | Description |
|---|---|
| `core.open(decl)` | Open a Clay element. `decl` is a raw Clay declaration table: `id`, `layout` (`sizing`, `padding`, `childGap`, `childAlignment`, `layoutDirection`), `backgroundColor`, `cornerRadius`, `aspectRatio`, `image`, `floating`, `clip`, `border`. Must be balanced by `core.close()`. |
| `core.close()` | Close the innermost open element. Errors without a matching `core.open`. |
| `core.text(str, cfg)` | Declare a text leaf. `cfg` fields: `textColor`, `fontId` (accepted but currently ignored, one font), `fontSize` (default 16), `letterSpacing`, `lineHeight`, `wrapMode`, `textAlignment`. |
| `core.surface(handle, decl?)` | Place a client surface as a self-closing leaf. Without `decl` it grows in both axes. The element id derives from the handle, so the key is stable across frames. Declaring the same handle twice in one frame is an error. |

### Readback

| Function | Description |
|---|---|
| `core.hits(screen, x, y)` | Element ids under a layout point, innermost first, as `{ { name, index }, ... }` (max 32), from the last solve. The liveness test: only elements the live tree put under the point answer. |
| `core.box(id)` | The solved box of an element as `{ x, y, width, height }`, half-up-rounded integers. `id` is a string or `{ name, index }`. Callable any time: inside the frame handler it reads the previous solve (boxes are only rewritten when the solve ends). Clay's element map is persistent, so an id that left the tree keeps answering with its final box; `nil` only for an id never declared, or before the first solve. Not a liveness test, use `core.hits` for that. |
| `core.screenshot(screen, path?)` | Read the screen's composed scene into the image cache and return the cache key (usable as an image source). With `path`, also write a PNG there. `nil` on a stale screen name or failed readback. |
| `core.output.list()` | Output enumeration, see [core.output.*](#coreoutput) below. |

### Handlers

One of each; setting again replaces. The stdlib owns all three, so a config never calls these unless it is replacing stdlib behavior wholesale.

| Function | Description |
|---|---|
| `core.set_frame_handler(fn(screen, w, h))` | The declare pass: called per dirty screen, builds that screen's tree with the declare primitives. |
| `core.set_event_handler(fn(ev))` | Receives every [origin event](/kiln/reference/events). |
| `core.set_lock_handler(fn(screen, w, h))` | The declare pass for the native lockscreen while locked. |

### Control

| Function | Description |
|---|---|
| `core.dirty(screen?)` | Mark one screen (by name) or every screen dirty, scheduling a re-solve. |
| `core.tick(screen, on)` | Arm or disarm that output's frame clock. While on, C keeps a frame scheduled and delivers `frame::tick` with the true delta each cycle; easing and delta clamping are Lua's job. |
| `core.set_key_bindings(chords)` | Replace the whole consume set: `{ { mods = {"alt"}, key = "Return" }, ... }`. Mod names: `shift`, `ctrl`, `alt`, `super`. C consumes exactly these chords; every other key forwards to the focused client. Locked modifiers (NumLock, CapsLock) are ignored in the match. Errors on an unknown key name. |
| `core.timer(ms, fn)` | One-shot timer; returns a numeric id. `ms <= 0` fires on the next loop turn. |
| `core.timer_cancel(id)` | Disarm a pending timer. A fired or unknown id no-ops. |
| `core.quit()` | Terminate the compositor. Deferred to the event loop, so it works even at config load time. |
| `core.replay()` | Re-emit the map fact for every live client. The reload verb: after Lua drops its client model, the compositor is the only one that still knows what is on screen. |
| `core.set_idle_timeout(ms)` | Arm the idle timer for `ms` of no input (delivers `idle` events); `nil` or 0 disarms. |
| `core.image_reload(path)` | Drop the cached decode so the next declare re-reads the file. The only image invalidation; marking dirty afterwards is the caller's job. |

### Spawn

| Function | Description |
|---|---|
| `core.spawn(cmd)` | Fork and exec. `cmd` is an argv table (via execvp) or a string (via `sh -c`); anything else errors. |
| `core.spawn_with_token(cmd)` | Like `spawn`, but mints an xdg-activation token first and hands it to the child via `XDG_ACTIVATION_TOKEN`, so the launched client can raise itself as user-initiated. |
| `core.spawn_pipe(cmd)` | Spawn with stdout and stderr piped back. Returns an id; each raw chunk arrives as a `spawn::out` event (`fd` 1 or 2), then one `spawn::exit` after both streams hit EOF and the child is reaped (`code` is the exit status, or 128 plus the signal). Line framing is Lua's job. |

### Lock

| Function | Description |
|---|---|
| `core.lock()` | Engage the native lockscreen. Returns false if a lock (native or external) is already active. |
| `core.unlock()` | Disengage the native lockscreen. Refused (returns false) unless a prior `core.authenticate` succeeded; the gate is enforced in C, so Lua cannot unlock without a verified password. |
| `core.authenticate(password)` | Verify via PAM, synchronously. Returns whether it matched; success opens the C unlock gate. |

### Notify, tray, and layer plumbing

| Function | Description |
|---|---|
| `core.notify_closed(id, reason)` | Send `NotificationClosed` on the bus. `reason` is the protocol integer; C does not check whether the id ever named anything. |
| `core.notify_action(id, key)` | Send `ActionInvoked` for a pressed notification action. Whether the notification then closes is Lua's call, made with `notify_closed`. |
| `core.tray_activate(service, kind, a?, b?)` | Forward one method call to a tray item (activate, scroll, and so on). |
| `core.layer_configure(handle, w, h)` | Answer a `layer::map` or `layer::commit` fact with a size. The only configure path a layer surface has. |

## core.client.*

All eleven take the numeric client handle (the `handle` field from client events).

| Function | Description |
|---|---|
| `core.client.focus(handle?)` | Give keyboard focus; `nil` defocuses everything. |
| `core.client.configure(handle, w, h)` | Send a size to the client. |
| `core.client.close(handle)` | Polite close request (the client may ignore it). |
| `core.client.kill(handle)` | Force kill the client's process. |
| `core.client.set_activated(handle, on)` | Set the activated (focused-look) state. |
| `core.client.set_fullscreen_hint(handle, on)` | Tell the client it is fullscreen. Presentation only; geometry stays Lua's. |
| `core.client.set_maximized_hint(handle, on)` | Tell the client it is maximized. |
| `core.client.set_tiled_hint(handle, edges)` | Set the tiled-edges hint (bitmask). |
| `core.client.set_suspended(handle, on)` | Tell the client it is not visible, so it can stop drawing. |
| `core.client.set_minimized_hint(handle, on)` | Tell the client it is minimized. |
| `core.client.set_output_mirror(handle, name?)` | Restrict the client's wl_output presence to one named output; `nil` leaves it on every output. |

## core.input.*

| Function | Description |
|---|---|
| `core.input.grab_pointer(on)` | Hand the cursor to Lua policy, or return it. While on, pointer events keep flowing to the event handler and none reach clients. |
| `core.input.grab_keyboard(on)` | While on, keys keep entering the event queue and none reaches a client, so a Lua grabber reads them ahead of bindings. C tracks no grabber and no stack; the claim is Lua's. |
| `core.input.set_cursor(name)` | Set the cursor image by xcursor name. |
| `core.input.set_cursor_theme(name?, size?)` | Swap the xcursor theme. `nil` name restores the environment default; `size` defaults to 24. |
| `core.input.set_keymap{rules, model, layout, variant, options}` | One whole-keymap replacement applied to every keyboard, no readback. The compose table is built from the locale, not the keymap, so it survives untouched. |
| `core.input.set_repeat(rate, delay)` | Key repeat rate (per second) and delay (ms) on every keyboard. |
| `core.input.set_numlock(on)` | Set the locked NumLock modifier on every keyboard (Wayland starts with it cold). |
| `core.input.set_pointer{tap_to_click, natural_scrolling, left_handed, accel_speed, accel_profile, scroll_method, click_method}` | libinput config over every pointer device. A `nil` field is left untouched; a device that does not support a field ignores it. No per-device targeting. |

## core.output.*

| Function | Description |
|---|---|
| `core.output.list()` | Enumerate outputs (max 16). Returns `{ { name, width, height, refresh, scale, x, y, enabled, modes = { { width, height, refresh }, ... } }, ... }`. Enumeration is discovery; runtime changes arrive as `output` events, not from re-reading this. |
| `core.output.set_mode(name, w, h, refresh?)` | Set the output mode. `refresh` omitted or 0 picks a matching advertised mode, or sets a custom one at whatever rate the backend gives. |
| `core.output.set_scale(name, f)` | Set the output scale factor. |
| `core.output.set_position(name, x, y)` | Move the output in the global layout. |
| `core.output.set_enabled(name, on)` | Enable or disable the output. |
| `core.output.set_adaptive_sync(name, on)` | Toggle adaptive sync (VRR). |

## See also

- [Origin events](/kiln/reference/events): everything C pushes into the event handler
- [Environment and IPC](/kiln/reference/environment-and-ipc): drive all of this from a shell
- [The C/Lua boundary](/kiln/concepts/c-lua-boundary): why the split falls where it does
- [Frames and dirty](/kiln/concepts/frames-and-dirty): when the frame handler runs
- [ui](/kiln/reference/ui): the node tree that compiles to the declare primitives
