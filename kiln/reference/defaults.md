---
title: some.defaults
description: The 10 replaceable policy functions that decide focus succession, activation, layer-shell answers, state requests, and the notification display.
sidebar_position: 11
---

# some.defaults

`some.defaults` holds kiln's policy decisions as 10 plain Lua functions. There is no permissions framework and no hook API: each policy is an ordinary field on the table, and a config changes the policy wholesale by replacing the function.

```lua
local some = require("somewm")

-- Refuse fullscreen requests entirely.
client.off("request::fullscreen", some.defaults.fullscreen)
```

## The model

The `request::*` client signals route to these functions, and the runtime consults them at decision points. There are two replacement shapes, both spelled out per policy below:

- **Read at call time** (`successor`, `notify_display`): the runtime reads the field every time it needs the policy, so assigning a new function to the field is the whole replacement.
- **Registered on a bus** (`activate`, `fullscreen`, `maximize`, `minimize`, `close` on client signals; `layer`, `layer_keyboard`, `layer_release` on layer signals): the stock function is subscribed at boot. To replace one, take the stock function off the bus and put yours on:

```lua
client.off("request::activate", some.defaults.activate)
client.on("request::activate", function(c, ctx)
    c:focus()  -- honor every ask, valid token or not
end)
```

Removing a handler without adding a replacement is itself a policy: a request nobody acts on leaves the client exactly where it is, because nothing in C acts on requests.

## The 10 policies

| Policy | Decides |
|---|---|
| `successor(gone)` | Which client gets focus when one goes away. |
| `activate(c, ctx)` | What a `request::activate` does. |
| `layer(l)` | How a layer-shell surface is sized and answered. |
| `layer_keyboard(l)` | Whether a layer surface gets the keyboard. |
| `layer_release(l)` | Cleanup when a layer surface unmaps or is destroyed. |
| `notify_display(s)` | The whole notification UI. |
| `fullscreen(c, on)` | What a fullscreen request does. |
| `maximize(c, on)` | What a maximize request does. |
| `minimize(c, on)` | What a minimize request does. |
| `close(c)` | What a `request::close` does. |

### successor(gone)

Called when the focused client unmaps or minimizes; returns the client to focus next, or `nil` to clear focus. Read at call time.

Stock behavior: walk the focus history most-recent first and return the first client that is not `gone`, is mapped, is not minimized, and sits on a visible tag of the same screen (a selected tag, or any tag if the client is sticky). Policy over the focus history, not tag order.

### activate(c, ctx)

Handles `request::activate` (a client asked to be raised). Registered on the client bus.

Stock behavior: if `ctx.valid` (the request carries a seat-backed activation token, so it is user-initiated), `c:focus()`; otherwise mark the client urgent instead of letting it steal focus.

### layer(l)

Answers a mapped or changed layer-shell surface with a size. Registered on the layer bus for both `map` and `commit`, so it runs on every surface change. See [layer reference](/kiln/reference/layer).

Stock behavior: standard protocol sizing. A desired axis of zero that is anchored to both opposite edges stretches between them minus margins; everything else is honored as asked. Writes `l.w`/`l.h`, sends the configure, and re-declares the screen. A replacement that answers nothing leaves the surface visibly absent; C never synthesizes a configure.

### layer_keyboard(l)

Keyboard-interactivity arbitration for layer surfaces, on `map` and `commit`.

Stock behavior: `"exclusive"` takes the seat immediately and holds it; a surface stepping down from exclusive returns the seat to the focused client (or clears it). `"on_demand"` stays inert: pointer input already reaches the surface, and granting focus on click is config policy.

### layer_release(l)

Cleanup on layer `unmap` and `destroy`.

Stock behavior: if the surface held the keyboard, return the seat to the focused client, or clear it.

### notify_display(s)

The entire notification presentation. Not a listener: it is a declare, called at the tail of each screen's declare pass, and read at call time. Replace it with your own declare function to redraw notifications from scratch, or set it to `nil` to draw nothing at all.

Stock behavior: the built-in notification stack. See [notification reference](/kiln/reference/notification) and the [notifications guide](/kiln/guides/notifications).

### fullscreen(c, on), maximize(c, on), minimize(c, on)

Handle `request::fullscreen`, `request::maximize`, `request::minimize`. Registered on the client bus.

Stock behavior: honor the ask with the matching property write, which is the whole verb: `c.fullscreen = on`, `c.maximized = on`, `c.minimized = on`.

### close(c)

Handles `request::close`: a foreign-toplevel client (a taskbar's close button) asked to close this window. Registered on the client bus.

Stock behavior: `c:close()`, the polite close. A config that wants a confirm dialog swaps this off the bus.

## See also

- [Replace default policies](/kiln/guides/replace-default-policies)
- [client reference](/kiln/reference/client)
- [layer reference](/kiln/reference/layer)
- [notification reference](/kiln/reference/notification)
- [Signals index](/kiln/reference/signals)
