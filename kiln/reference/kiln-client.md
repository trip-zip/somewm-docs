---
title: kiln-client
description: The command-line client, every verb by namespace, selectors, reflection, JSON output, and shell completions.
sidebar_position: 19
---

# kiln-client

`kiln-client` is the CLI over kiln's IPC socket: a fixed verb surface plus a
reflection layer over the object classes, so scripts and keybind-external
tools reach the config API without writing Lua. It speaks the same socket as
`kiln-eval`; commands travel wrapped in `kiln_ipc(...)` so a verb and a Lua
chunk stay distinct on the wire.

```bash
kiln-client tag view web
kiln-client client list
kiln-client --json screen list
# {"result":[{"focus":"*","height":720,"name":"HEADLESS-1","scale":1,...}],"status":"ok"}
```

## Invocation

```
kiln-client [OPTIONS] COMMAND [ARGS...]
```

| Option | Meaning |
|---|---|
| `--json` | Machine-readable output: `{"status":"ok","result":...}` on success, `{"status":"error","error":"..."}` on failure. |
| `-s`, `--socket PATH` | Socket path. Default: `$KILN_SOCK`, else `$XDG_RUNTIME_DIR/kiln.sock`. |
| `-h`, `--help` | Usage. |

Any other `--long` word is treated as the verb's own flag (`notify --urgency
critical ...`) and stops option parsing. Errors print `ERROR ...` and exit
nonzero.

The tool documents itself against the running compositor, so the output below
can never be more current than what your build answers:

```bash
kiln-client commands        # every verb, one per line
kiln-client help            # every verb with its arguments
kiln-client help tag view   # one verb, or one namespace: help tag
kiln-client reflect client  # every method, getter, setter a class carries
```

## Verbs

74 verbs in the current build. Arguments in `<angles>` are required,
`[brackets]` optional; a `[client]`, `[tag]`, or `[screen]` argument is a
[selector](#selectors) and defaults to the focused one.

### Session

| Verb | Does |
|---|---|
| `ping` | Answer, so a caller can tell a live socket from a dead one |
| `commands`, `help [verb...]` | Self-documentation |
| `complete <index> [word...]` | Completion candidates (what the shell completions call) |
| `eval <lua...>` | Run Lua in the compositor, the one door to everything the fixed verbs refuse |
| `exec <command...>` | Spawn a command |
| `notify [message...]` | Post a notification; `--title`/`--timeout`/`--urgency` anywhere in it |
| `dirty` | Mark every screen for a re-declare |
| `screenshot <path> [screen]` | Write a screen's pixels to a file |
| `inspector [screen]` | Toggle the Clay debug inspector |
| `idle <ms\|off>` | Set or clear the idle timeout |
| `lock`, `unlock` | Session lock |
| `reload` | Re-run the config, keeping the session up if it raises |
| `quit` | End the session |
| `input [setting] [value]` | List every input setting, or read or write one |
| `theme get [key]`, `theme set <key> <value>` | Theme readback and live writes |
| `key list` | Every key the config bound, as written |
| `rule list` | Every client rule the config declared, in order |

### client

| Verb | Does |
|---|---|
| `client list` / `client visible` | Every client / only those on a selected tag, unminimized |
| `client info [client]` | Every property one client carries |
| `client focus [client]` | Focus; also `next` or `prev` around the list |
| `client close [client]` / `client kill [client]` | Polite close / SIGKILL |
| `client raise` / `client lower [client]` | Restack within the band |
| `client swap <client> <other>` | Swap layout positions |
| `client movetotag <tag> [client] [screen]` | Replace a client's tags with one |
| `client toggletag <tag> [client] [screen]` | Add or remove one tag, keeping the rest |
| `client movetoscreen [screen] [client]` | Move to another screen's selected tag |
| `client geometry [client]` | The solved box |
| `client floating` / `fullscreen` / `maximized` / `minimized` / `sticky` / `urgent [client] [on\|off\|toggle]` | Read or write each state flag |

### tag

| Verb | Does |
|---|---|
| `tag list [screen]` / `tag current [screen]` | Every tag / the selected ones |
| `tag view <tag> [screen]` / `tag toggle <tag> [screen]` | Exclusive / additive selection |
| `tag add <name> [screen]` / `tag delete <tag> [screen]` / `tag rename <tag> <new> [screen]` | Lifecycle |
| `tag screen <tag> [screen]` | Which screen a tag lives on |
| `tag gap` / `mwfact` / `master_count` / `column_count` / `carousel_width <tag> [value] [screen]` | Layout parameters, read or written |

### layout

| Verb | Does |
|---|---|
| `layout list` | Every layout name, families flattened into their variants |
| `layout get [tag] [screen]` | The layout a tag is using |
| `layout set <name> [tag] [screen]` | Set by name (`tile.left`, `max`, ...) |
| `layout next` / `layout prev [tag] [screen]` | Step around the ring |

### screen and output

| Verb | Does |
|---|---|
| `screen list` / `screen count` / `screen focused` | Enumeration and focus state |
| `screen focus [screen]` | Focus; also `next` or `prev` |
| `screen clients [screen]` | Every client homed to a screen |
| `screen scale [screen] [factor]` | Scale, read or written |
| `screen workarea [screen]` | The box left after bars and layer reservations |
| `output list` | Every output as the hardware reports it |
| `output mode <output> <w> <h> [hz]` / `position <output> <x> <y>` / `scale <output> <factor>` / `enabled <output> <on\|off>` / `adaptive_sync <output> <on\|off>` | Output configuration |

### Reflection

The four reflection verbs reach anything the fixed verbs do not name, across
the five classes (`client`, `screen`, `tag`, `layer`, `notification`):

```bash
kiln-client get client app_id:firefox title
kiln-client set tag focused gap 0
kiln-client call client focused raise
kiln-client reflect tag
```

| Verb | Does |
|---|---|
| `get <class> <selector> <property>` | Read a property off every object the selector resolves to |
| `set <class> <selector> <property> <value>` | Write a property on every one |
| `call <class> <selector> <method> [arg...]` | Invoke a method on every one |
| `reflect [class]` | Every method, getter, setter, and property a class carries |

## Selectors

Wherever a verb takes an object, the selector is one of:

| Form | Resolves to |
|---|---|
| *(omitted)* | The focused one, for verbs with an optional selector |
| `all` | Every object of the class |
| `focused` | The focused client / screen / selected tag |
| `previous` (or `mru`) | Clients only: the previously focused client |
| `selected` | Tags only: every selected tag |
| a number | The object with that `handle` |
| a name | The object whose `name` matches exactly (tags, screens) |
| `<field>:<pattern>` | Every object whose field matches the Lua pattern, e.g. `app_id:firefox`, `title:%d+`. A field holding an object compares by its name, so `tag:web` reads the way it looks. |

Argument values get the same treatment in reverse: `true`/`false` and numbers
convert, a quoted word stays a string (the only way to set a title of
`"42"`), and a leading `@` resolves an object inline, which is how a method
taking one stays reachable:

```bash
kiln-client call client focused swap @client:app_id:foot
```

## Shell completions

Bash, zsh, and fish completions ship with the install (`kiln-client.bash`,
`_kiln-client`, `kiln-client.fish`). All three query the running compositor
through the `complete` verb, so they complete live verb names, tag names, and
property names and never go stale against your build.

## See also

- [Environment and IPC](/kiln/reference/environment-and-ipc) for the socket
  and the raw `kiln-eval` path
- [IPC and scripting](/kiln/guides/ipc-and-scripting) for recipes
- [core](/kiln/reference/core) for what `eval` can ultimately reach
