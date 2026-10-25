---
title: IPC and Scripting
description: "Drive a running kiln from the shell: the socket protocol, kiln-eval one-liners, and scripting patterns."
sidebar_position: 18
---

# IPC and Scripting

Every running kiln listens on a unix socket and evaluates whatever Lua you send it, in the same VM your config runs in.

## 1. The socket and the protocol

The socket is `$XDG_RUNTIME_DIR/kiln.sock` (owner-only, mode 0600), or wherever `KILN_SOCK` pointed when the compositor started. The protocol is minimal: connect, write Lua source, half-close, read one reply. The `kiln-eval` script in the kiln repo wraps that with `nc`:

```bash
scripts/kiln-eval 'return 1 + 1'
# 2

echo 'core.dirty()' | scripts/kiln-eval
```

An argument is sent as-is; with no argument, stdin is sent. Because the socket evaluates arbitrary Lua in your session, it is deliberately restricted to your own user.

## 2. Expressions and statements

The evaluator tries your input as an expression first, then as a statement block:

- An expression replies with its value: `'client.focus.title'` answers the title directly, no `return` needed.
- Statements run and reply empty: `'screen.focused.tags[2]:view()'`.
- A multi-statement chunk that should answer something needs an explicit `return` at the end.

Multiple return values come back tab-joined; each value goes through `tostring`, so tables print as `table: 0x...` (format what you want to see):

```bash
scripts/kiln-eval 'return #client.all(), #screen.all()'
# 5	2
```

Errors come back prefixed `ERROR:` with the Lua message.

:::note
The CLI `kiln-client eval` takes a Lua statement chunk, so use an explicit
`return` when asking it for a value. `scripts/kiln-eval` uses the raw
expression-or-statement evaluator.
:::

## 3. One-liners

The seven config globals (`client`, `screen`, `tag`, `layer`, `notification`, `drag`, `core`) are available directly. Over the socket, `kiln` is not a global: use `require("kiln")`. The `local kiln` in your config file is private to that file.

List every client:

```bash
scripts/kiln-eval 'local out = {}
for _, c in ipairs(client.all()) do
	out[#out + 1] = (c.app_id or c.class or "?") .. " [" .. (c.title or "") .. "]"
end
return table.concat(out, "\n")'
```

Switch to tag 2 on the focused screen:

```bash
scripts/kiln-eval 'screen.focused.tags[2]:view()'
```

Tweak the theme live:

```bash
scripts/kiln-eval 'require("kiln").theme.accent = "#ff8800" core.dirty()'
```

Raise a notification:

```bash
scripts/kiln-eval 'require("kiln").notify { title = "build", message = "done" }'
```

Reload the config:

```bash
scripts/kiln-eval 'require("kiln").reload()'
```

Most one-liners like these have a `kiln-client` verb that spares you the
Lua: `kiln-client client list`, `kiln-client tag view 2`, `kiln-client theme
set accent "#ff8800"`, `kiln-client notify --title build done`,
`kiln-client reload`. It speaks the same socket, adds `--json` for scripts,
and ships shell completions; see the
[kiln-client reference](/kiln/reference/kiln-client). Use `eval` for anything
without a verb.

## 4. Target a nested dev instance

Each Kiln instance owns one socket. Give a nested test a private path as in
[First launch](/kiln/getting-started/first-launch), then target that path
explicitly from the same shell:

```bash
KILN_SOCK="$kiln_demo/eval.sock" scripts/kiln-eval 'return #screen.all()'
```

See [Reload and Debugging](/kiln/guides/reload-and-debugging) for the nested-instance workflow, and [Testing Headless](/kiln/guides/testing-headless) for driving an invisible instance in tests.

## 5. Request-reply only: getting events out

The socket has no subscription mechanism: you cannot ask it to stream events. When something outside kiln needs to hear about changes, invert the flow: a signal listener inside the config pushes out with `kiln.spawn`:

```lua
-- In your config: tell an external script whenever focus changes.
client.on("focus", function(c)
	kiln.spawn({ "/home/me/bin/on-focus-change", c.app_id or "" })
end)
```

Polling over IPC is the other option and is fine for status bars, since a query is one cheap socket round trip.

## 6. Scripting examples

A layout cycler, bindable in any external tool:

```bash
#!/bin/sh
# kiln-next-layout: cycle the focused tag's layout
exec kiln-client eval '
local kiln = require("kiln")
local t = screen.focused.selected_tag
if t == nil then
	return ""
end
t.layout = kiln.layout.next(t.layout)
return kiln.layout.name(t.layout) or "custom"'
```

A focused-window query for a status bar:

```bash
#!/bin/sh
# focused-title: print the focused window, empty when none
exec kiln-client eval \
	'return client.focus and (client.focus.title or client.focus.app_id) or ""'
```

## See also

- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
- [kiln-client reference](/kiln/reference/kiln-client)
- [Reload and Debugging](/kiln/guides/reload-and-debugging)
- [Testing Headless](/kiln/guides/testing-headless)
- [Spawn Lifecycle](/kiln/guides/spawn-lifecycle)
