# Kiln reference figures

These figures accompany `kiln/reference/widgets/` and `kiln/reference/ui/`.
They use the SomeWM reference palette, 940-pixel canvas, 28-pixel margins,
monospace labels and outlined sample boxes. Kiln renders the figures at scale
1.5. The PNGs are cropped one logical pixel inside the solved canvas bounds.

## Capture

Requires a running SomeWM session, a built Kiln checkout, Python 3, ImageMagick,
`dbus-run-session`, `foot`, `rsvg-convert`, and PyGObject with Gio. The terminal
options use foot 1.28's `colors-dark` section.

From the docs checkout:

```sh
python3 scripts/figures/kiln/capture.py \
  --source /path/to/kiln --out /tmp/kiln-reference-captures
```

The runner starts Kiln as a floating, raised Wayland window on the rightmost host output.
Use `--connector DP-1` to select an output explicitly. It creates private home,
config, data, cache, runtime, IPC and D-Bus paths. Only the nested session uses
the reference theme and transparent cursor. The host pointer is not moved.

Client figures use two `foot` windows displaying the start of `widgets.lua` and
`ui.lua`. `tray.py` exports one StatusNotifierItem on the private bus. The runner
closes its clients, stops the tray service and quits its Kiln instance after
capture. Logs and raw images remain in the temporary directory printed at startup.

To inspect one scene without copying it into the site:

```sh
python3 scripts/figures/kiln/capture.py widget-progress \
  --source /path/to/kiln --out /tmp/kiln-progress-review
```

## Startup limitation

A full 19-figure capture succeeded against the revision in the manifest.
Later runs sometimes opened IPC and mapped the host window without committing
Kiln's first frame. The host window was visible and `core.dirty()` did not
resolve the stall. The cause is not established.

The runner times out when no figure geometry settles. Check the printed
`server.log` for `First frame committed`. A stalled run produces no complete
manifest and cannot replace the reviewed assets through `assets.py`.

## Copy reviewed captures

Inspect every PNG from a full capture run, then copy the set:

```sh
python3 scripts/figures/kiln/assets.py --from /tmp/kiln-reference-captures
python3 scripts/figures/kiln/assets.py --check
npm run build
```

PNGs, runnable Lua and capture metadata go to `static/img/reference/kiln/`.
The same Lua is included through `_lua/*.mdx` partials beside the reference
pages. `assets.py` rejects captures whose Lua differs from the current scene.
The manifest records the Kiln source revision, scale, output and image sizes.

## Scene files

`lib.lua` supplies the canvas and row helpers. Each `widget-*.lua` or `ui-*.lua`
file declares one figure. The runner concatenates the helper and scene into the
downloadable file. Each figure replaces the previous one and closes after two
minutes. The page also gives a command to close it immediately.

Client scenes temporarily replace `kiln.declare_clients` to avoid declaring the
same client's surface or titlebar twice. The taglist scene also does this so its
occupancy markers can draw above a canvas in the background band. Closing the
figure restores the previous policy. The resize scene outlines the actual
solved targets and restores the client's floating rectangle on close.

The layout-menu canvas uses the `above` band so the menu can draw in `overlay`.
The popup scene registers its anchor before its content popup. These ordering
requirements also apply when running the downloaded examples.
