# Widget reference figures

Every image under `static/img/reference/wibox/` is one scene from this directory, rendered by a real SomeWM session and captured with `grim`. Nothing is drawn by hand, so a figure cannot disagree with the compositor it documents, and re-rendering after a SomeWM change is one command.

```bash
scripts/figures/somewm/generate.sh --check   # headless dry run, catches errors first
scripts/figures/somewm/generate.sh           # capture every scene on the live session
scripts/figures/somewm/generate.sh widget-textbox
```

The check boots a headless test instance from `~/tools/some/build-test` (`SOMEWM_REPO` overrides the path) and loads every scene there. Run it before the live capture: a scene that errors never reaches the live session. The live run places each scene's wibox ontop on the primary screen, captures it, and removes it.

## Writing a scene

A scene is `<kind>-<class>.lua`: `widget-textbox.lua`, `container-background.lua`. `lib.lua` is concatenated ahead of it and defines `F`:

- `F.scene { rows }` builds the canvas and returns its geometry.
- `F.row(label, widget, opts)` is one row: a monospace label naming the property value, then the widget in an outlined slot. `opts.w` and `opts.h` size the slot, `opts.fit = true` lets it take the widget's own size, `opts.pad` is the margin inside the outline (default 6).
- `F.label(text, extra)` is a textbox in the figure font; `F.block(w, h, color, text)` is a solid sized block.
- `F.bg`, `F.panel`, `F.slot`, `F.text`, `F.muted`, `F.accent`, `F.accent2`, `F.accent3` are the palette, taken from the docs site's dark theme. `F.font` and `F.label_font` are the fonts.

Rows set every color and font they show. A scene never reads the user's theme, so the figures look the same on any session.

Captures are taken at the primary output's scale. The shipped set was captured at scale 1.5, so a 720 px canvas is a 1080 px PNG. Capture the whole set on one output so the images match.
