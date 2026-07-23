---
title: IPC and Scripting
description: "Drive a running kiln from the shell: the socket protocol, kiln-eval one-liners, and scripting patterns."
sidebar_position: 17
---

import YouWillLearn from '@site/src/components/YouWillLearn';

# IPC and Scripting

<YouWillLearn>

- The kiln socket as a live Lua REPL into the running compositor
- One-liners with `kiln-eval`: inspecting clients, switching tags, tweaking the theme
- Expressions versus statements, and the reply size cap
- Targeting a nested dev instance with `KILN_SOCK`
- Getting events out despite the request-reply-only protocol

</YouWillLearn>

Every running kiln listens on a unix socket and evaluates whatever Lua you send it, in the same VM your config runs in. Anything your config can do, a shell script can do: the entire API surface is drivable from outside.

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
The reply is capped at 4096 bytes. For big dumps, return compact strings, or write to a file from inside the chunk and read that.
:::

## 3. One-liners

The six config globals (`client`, `screen`, `tag`, `layer`, `notification`, `core`) are available directly; the `some` module is one `require` away.

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
scripts/kiln-eval 'require("somewm").theme.accent = "#ff8800" core.dirty()'
```

Raise a notification:

```bash
scripts/kiln-eval 'require("somewm").notify { title = "build", message = "done" }'
```

Reload the config:

```bash
scripts/kiln-eval 'require("somewm").reload()'
```

## 4. Target a nested dev instance

Each kiln instance owns one socket. Your daily session uses the default path; a nested test instance started with `make dev` picks a private socket (like `/tmp/kiln-dev-1.sock`) and prints it at startup, so scripts target it explicitly:

```bash
KILN_SOCK=/tmp/kiln-dev-1.sock scripts/kiln-eval 'return #screen.all()'
```

See [Reload and Debugging](/kiln/guides/reload-and-debugging) for the nested-instance workflow, and [Testing Headless](/kiln/guides/testing-headless) for driving an invisible instance in tests.

## 5. Request-reply only: getting events out

The socket has no subscription mechanism: you cannot ask it to stream events. When something outside kiln needs to hear about changes, invert the flow: a signal listener inside the config pushes out with `some.spawn`:

```lua
-- In your config: tell an external script whenever focus changes.
client.on("focus", function(c)
	some.spawn({ "/home/me/bin/on-focus-change", c.app_id or "" })
end)
```

Polling over IPC is the other option and is fine for status bars, since a query is one cheap socket round trip.

## 6. Scripting examples

A layout cycler, bindable in any external tool:

```bash
#!/bin/sh
# kiln-next-layout: cycle the focused tag's layout
exec scripts/kiln-eval '
local some = require("somewm")
local t = screen.focused.selected_tag
if t ~= nil then
	t.layout = some.layout.next(t.layout)
end
return some.layout.name(t.layout) or "custom"'
```

A focused-window query for a status bar:

```bash
#!/bin/sh
# focused-title: print the focused window, empty when none
exec scripts/kiln-eval \
	'return client.focus and (client.focus.title or client.focus.app_id) or ""'
```

Both are plain request-reply, so they compose with watch loops, status bar exec modules, and cron alike.

## See also

- [Environment and IPC reference](/kiln/reference/environment-and-ipc)
- [Reload and Debugging](/kiln/guides/reload-and-debugging)
- [Testing Headless](/kiln/guides/testing-headless)
- [Spawn Lifecycle](/kiln/guides/spawn-lifecycle)
