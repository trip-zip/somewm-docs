---
title: Keys, Buttons, and Rules
description: Full reference for kiln.key, kiln.button, kiln.rule, and kiln.focused, kiln's binding and client-rule specs.
sidebar_position: 11
---

# Keys, Buttons, and Rules

Bindings and rules are declared as spec tables passed to `kiln.key{}`, `kiln.button{}`, and `kiln.rule{}`. All three are registries a config fills at load time and a reload clears and refills.

```lua
local kiln = require("kiln")

kiln.key { mods = { "mod" }, key = "Return", desc = "terminal", group = "apps",
           press = function() kiln.spawn("foot") end }

kiln.rule { match_any = { app = { "pinentry" } },
            props = { floating = true } }
```

## kiln.key

`kiln.key{spec}` registers a keyboard chord.

| Spec field | Description |
|---|---|
| `mods` | List of modifiers: `"ctrl"`, `"alt"`, `"shift"`, `"super"`, or `"mod"`, which resolves through `kiln.modkey` at binding time. |
| `key` | A key name (`"Return"`, `"j"`, `"F1"`), or a range (below). |
| `press` | `function()` called on the press edge. For a range, `function(v)` receives the value. |
| `release` | `function()` called on the release edge. |
| `desc` | One-line description, consumed by the hotkeys popup. |
| `group` | Group name, consumed by the hotkeys popup. |

A spec's modifiers must match the held set exactly, so `mod+j` and `mod+shift+j` are different bindings. Binding the same chord again replaces the previous handler. A bound chord is consumed on the press edge and its matching release is swallowed, so nothing leaks to the focused client, even for a release-only binding.

**Ranges.** A `key` of the form `"1-9"` (digit to digit) or `"a-z"` (letter to letter) expands to one binding per key in the range. The handler receives the pressed value: digits arrive as numbers, letters as one-character strings.

```lua
kiln.key { mods = { "mod" }, key = "1-9", desc = "view tag", group = "tags",
           press = function(i)
               local t = screen.focused.tags[i]
               if t then t:view() end
           end }
```

The registry keeps one entry per `key{}` call, ranges intact, so a hotkeys popup shows one row reading `1-9 view tag`, not nine rows.

| Function | Description |
|---|---|
| `kiln.key{spec}` | Register a binding (callable table). |
| `kiln.key.all()` | A copy of the registry in declaration order, each entry `{mods, key, desc, group}` with ranges as written. For cheat sheets and the [hotkeys popup](/kiln/guides/hotkeys-popup). |
| `kiln.key.clear()` | Drop every binding (the reload path). |

## kiln.button

`kiln.button{spec}` registers a mouse binding.

| Spec field | Description |
|---|---|
| `mods` | Modifier list, same resolution as `kiln.key` (exact match against the held set). |
| `button` | The button number (integer): 1 left, 2 middle, 3 right. |
| `on` | Where the press must land: `"client"` (a client surface, the default) or `"root"` (empty workarea). |
| `press` | `function(c)` on the press edge. `c` is the clicked client, or `nil` for `on = "root"`. |
| `release` | `function(c)` on the release edge. |

Dispatch order for a press: a client surface checks the `on = "client"` specs first and falls back to click-to-focus if none fires; elsewhere, chrome elements get first claim, and only a press no element handled reaches the `on = "root"` specs.

| Function | Description |
|---|---|
| `kiln.button{spec}` | Register a mouse binding. |
| `kiln.button.clear()` | Drop all mouse bindings. |

## kiln.rule

`kiln.rule{spec}` registers a client rule. Rules apply in declaration order on map, before the client takes focus; when several rules match, a later rule's props override an earlier one's.

| Spec field | Description |
|---|---|
| `match` | A clause; every present field must hit. |
| `match_any` | A clause; any one present field hitting is enough. |
| `except` | A veto clause; if every present field hits, the rule does not apply. |
| `except_any` | A veto clause; any one field hitting vetoes. |
| `props` | Table of properties to apply (below). |
| `on` | `function(c)` called after props are applied. |

A spec with no selector at all matches nothing, not everything.

### Clause fields

| Field | Type | Matches against |
|---|---|---|
| `app` | pattern | `c.app_id` (the Wayland app id). |
| `class` | pattern | `c.class` (X11 `WM_CLASS`, for clients with no app id). |
| `instance` | pattern | `c.instance` (X11 `WM_CLASS` instance). |
| `title` | pattern | `c.title`. |
| `role` | pattern | `c.role` (X11 `WM_WINDOW_ROLE`). |
| `dialog` | boolean | Whether the client has a parent. |
| `fn` | function | `fn(c)` predicate; the general escape into plain Lua. It reads the same public client object every other field does. |

String values are Lua patterns, and each field takes a single value or a list (a list means any-of).

:::note
Because values are Lua patterns, magic characters need escaping: match a literal dash with `role = "pop%-up"`.
:::

### Props semantics

Three keys are special and applied first:

- `tag`: the client's home tag, by name or by tag object.
- `screen`: by name or by screen object. With `tag` it scopes the name lookup; alone, the client goes to that screen's selected tag.
- `focus = false`: blocks activation, so the client maps without taking focus.

Everything else is a plain property write (`c[k] = v`): `floating = true`, `fullscreen = true`, `ontop = true`, `titlebar = false`, and any other [client property](/kiln/reference/client). The writes are order-independent by construction.

The `on(c)` callback runs after props, which is where a [placement helper](/kiln/reference/placement) slots in directly:

```lua
kiln.rule { match = { app = "mpv" },
            props = { floating = true },
            on = kiln.placement.centered }
```

| Function | Description |
|---|---|
| `kiln.rule{spec}` | Register a rule. |
| `kiln.rule.clear()` | Drop all rules. |

## kiln.focused

`kiln.focused(fn)` wraps `fn` into a handler that runs `fn(client.focus, ...)` when a client has focus and does nothing otherwise. Keybinding sugar:

```lua
kiln.key { mods = { "mod" }, key = "q", desc = "close", group = "clients",
           press = kiln.focused(function(c) c:close() end) }
```

## See also

- [Keybindings tutorial](/kiln/tutorials/keybindings)
- [Client rules guide](/kiln/guides/client-rules)
- [Hotkeys popup](/kiln/guides/hotkeys-popup)
- [kiln.placement](/kiln/reference/placement)
- [client reference](/kiln/reference/client)
