# Clay Bet figures

Every image under `static/img/kiln/clay/` is rendered by a real headless kiln
and screenshotted. Nothing is drawn by hand, mocked up, or traced in a vector
editor, so a figure can never quietly disagree with the compositor it documents.

## Run

```bash
npm run generate:figures          # all of them, ~30s
scripts/figures/generate.sh 03    # just one
```

Needs a built kiln (`KILN_REPO`, default `~/tools/kiln`), ImageMagick 7
(`magick`), `nc`, and `foot` for the figures with real windows.

## Safety while kiln is your session

All of this lives in one place, `../lib/kiln-headless.sh`, which both this
generator and `../kiln-verify.sh` source. The generator is built to run while you
are sitting in kiln:

- Each instance boots on a private `KILN_SOCK` under a `mktemp -d` work dir, and
  the script refuses to start if that path ever equals `$XDG_RUNTIME_DIR/kiln.sock`.
- `XDG_CONFIG_HOME` is pinned to an empty directory, because kiln resolves
  `$XDG_CONFIG_HOME/kiln/rc.lua` ahead of `KILN_RC`. Without the pin, figures
  would render from whatever config you happen to have installed.
- Cleanup only kills PIDs the script itself started. No `pkill`, no `killall`,
  nothing matched by process name: a name-based kill would drop you to a TTY.

## The figures

| Output | Source | What it shows |
| --- | --- | --- |
| `01-sizing.png` | `01-sizing.lua` | `fixed` / `grow` / `percent`, each cell drawn at the width Clay solved for it |
| `02-nesting.png` | `02-nesting.lua` | One card twice, plain and with every container named by a badge |
| `03-bar.png` | stock `kilnrc.lua` | The real bar, each cell outlined and labelled with the constructor that made it |
| `04-leaf.png` | stock `kilnrc.lua` | The leaf fork: `ui.titlebar` that Clay draws beside `ui.surface` that the client draws |
| `05-mwfact.png` | stock `kilnrc.lua` | The same layout function at `master_width_factor` 0.4 and 0.75 |

Figures 1 and 2 use **Clay's own palette** (sampled from nicbarker.com/clay:
paper `#f4ebe6`, amber `#ecab57`, orange `#da812f`, rust `#a8421c`). Figures 3
to 5 are kiln's real theme. That split is deliberate page grammar: cream means
"this is Clay the library", dark means "this is kiln the compositor".

## How the geometry stays honest

Two mechanisms, both reading from the live compositor:

- **Primer figures** wrap their content in an element with `id = "figure"`, and
  `crop_el` crops the capture to `core.box("figure")`. A figure that reflows
  still crops to its own edges.
- **Desktop figures** read `core.box` for each element they annotate
  (`taglist:HEADLESS-1`, `{"titlebar", handle}`, and so on) and hand those
  rectangles to `annotate.sh`. Callouts land on Clay's solved boxes, not on
  coordinates measured off a screenshot once and never rechecked.

`annotate.sh` draws an outline, a leader line, and a labelled chip:

```bash
annotate.sh src.png dest.png 'x,y,w,h,side,label'
```

`side` is `above`, `below`, or `center`. A region of `w=0,h=0` is a bare chip at
that point, for captions that do not point at anything.

## When to re-run

- After any kiln change to `ui.*` constructors, the stock `kilnrc.lua` bar, or
  the default theme.
- After a Clay bump that changes solved geometry.
- If `core.box` returns nil for an id the script asks for, that id was renamed
  upstream: fix the script rather than hand-editing the PNG.
