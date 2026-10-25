---
title: Testing Headless
description: Start a private Kiln instance, query it, capture it and shut down only that instance.
sidebar_position: 20
---

# Testing Headless

Use a private instance to check config declarations and composed pixels without
changing the live desktop. `KILN_BACKEND=headless` selects one virtual output,
`HEADLESS-1`, 1280x720 at 60 Hz, drawn by the same GLES renderer as the
desktop on the GPU's render node; `KILN_HEADLESS_OUTPUTS=n` creates more. No
input device is attached; input reaches a headless instance only through
the Lua API.

## Booting headless

From a built Kiln checkout, this creates private runtime, config, data, cache
and IPC paths and loads the stock config explicitly:

```sh
kiln_test=$(mktemp -d /tmp/kiln-doc-test.XXXXXX)
mkdir -m 700 "$kiln_test/runtime"
mkdir -p "$kiln_test/home" "$kiln_test/config" "$kiln_test/data" "$kiln_test/cache"
env -u DISPLAY -u WAYLAND_DISPLAY -u WAYLAND_SOCKET \
  HOME="$kiln_test/home" XDG_RUNTIME_DIR="$kiln_test/runtime" \
  XDG_CONFIG_HOME="$kiln_test/config" XDG_DATA_HOME="$kiln_test/data" \
  XDG_CACHE_HOME="$kiln_test/cache" KILN_RC="$PWD/kilnrc.lua" \
  KILN_SOCK="$kiln_test/eval.sock" KILN_BACKEND=headless \
  dbus-run-session -- ./build/kiln >"$kiln_test/server.log" 2>&1 &
kiln_test_pid=$!
```

Keep this shell open for the following commands. Wait for the socket and check
`server.log` if startup fails. Kiln refuses to bind an occupied socket rather than
unlinking it; a unique private path is still necessary to address the right
instance.

## Driving it over IPC

```sh
./build/kiln-client -s "$kiln_test/eval.sock" ping
./build/kiln-client -s "$kiln_test/eval.sock" eval 'return #screen.all()'
./build/kiln-client -s "$kiln_test/eval.sock" eval 'return #screen.all()[1].tags'
```

With the stock config and one output, expect `pong`, `1` and `5`. The installed
command spelling is `kiln-client`. In an eval, `kiln` is reached through
`require("kiln")` (see [IPC and Scripting](/kiln/guides/ipc-and-scripting#3-one-liners)).
Spawn into this instance using its child environment instead of guessing a
display name:

```sh
./build/kiln-client -s "$kiln_test/eval.sock" exec foot
```

Headless runs do not exercise DRM output, hotplug, gamma or PAM.

## Seeing what it drew

```sh
./build/kiln-client -s "$kiln_test/eval.sock" screenshot "$kiln_test/desktop.png"
```

State mutations may require `core.dirty()` and another frame before capture;
multiple mutations in one eval can coalesce.

## Shutting down

```sh
./build/kiln-client -s "$kiln_test/eval.sock" quit
wait "$kiln_test_pid"
```

After `quit`, `$kiln_test/eval.sock` should be gone. If it hangs,
`kill "$kiln_test_pid"`; never `pkill kiln`, which also kills your desktop
session.

## A minimal smoke test

The sequence above is a manual smoke test. `make test` runs the automated
version: the `tests` package boots `build/kiln` headless, waits for
readiness, drives it over IPC, and stops only the instances it started.
`make test-nested` runs the same tests as a window in the current desktop.

## See also

- [Environment and IPC](/kiln/reference/environment-and-ipc)
- [Reload and debugging](/kiln/guides/reload-and-debugging)
- [Limitations](/kiln/concepts/limitations)
