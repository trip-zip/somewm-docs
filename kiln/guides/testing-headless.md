---
title: Testing Headless
description: Start a private Kiln instance, query it, capture it and shut down only that instance.
sidebar_position: 20
---

# Testing Headless

Use a private instance to check config declarations and composed pixels without
changing the live desktop. Headless selects virtual outputs; it does not imply
a particular renderer. Set `WLR_RENDERER=pixman` when software rendering is the
workload you intend to measure.

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
  KILN_SOCK="$kiln_test/eval.sock" WLR_BACKENDS=headless \
  WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman \
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
command spelling is `kiln-client`. A config's local `kiln` is not global;
use `require("kiln")` in an eval. Spawn into this instance using its child
environment instead of guessing a display name:

```sh
./build/kiln-client -s "$kiln_test/eval.sock" exec foot
```

Calling a Lua handler checks policy, not physical input. The compatibility
suite has separate native input checks using private backends. Neither proves
DRM scanout, hotplug, physical gamma or real authentication.

## Seeing what it drew

```sh
./build/kiln-client -s "$kiln_test/eval.sock" screenshot "$kiln_test/desktop.png"
```

Inspect the PNG before claiming a visual result. State mutations may require
`core.dirty()` and another frame before capture; multiple mutations in one eval
can coalesce. A composed PNG does not establish physical scanout correctness.

## Shutting down

```sh
./build/kiln-client -s "$kiln_test/eval.sock" quit
wait "$kiln_test_pid"
```

Confirm the private socket disappears. Keep the log and image for review. On
failure, stop only the owned process after checking its identity; never kill by
compositor name. The source repository's compatibility harness automates owned
PID cleanup and socket checks for longer tests.

## A minimal smoke test

The sequence above is a manual smoke test. For automated runs use the existing
`make compat-test` harness, which waits for readiness, asserts results and
cleans up on failures. It also retains the historical C comparison checkout;
see the source repository's `TRANSITION.md` for baseline provenance.

## See also

- [Environment and IPC](/kiln/reference/environment-and-ipc)
- [Reload and debugging](/kiln/guides/reload-and-debugging)
- [Limitations](/kiln/concepts/limitations)
