# textbox-ellipsize figure

`static/img/concepts/textbox-ellipsize.png`, used by `concepts/widgets-in-the-tree.md` (next and 2.1). The same title in a 260 px box twice: the default `ellipsize` cuts it with an ellipsis, `"none"` wraps it.

Captured from a live SomeWM 2.1 session (commit 330d6c262 or later), the user's own theme and font, output scale 1.5, so the PNG is 1040x180 device pixels. Needs `grim`.

```bash
geo=$(somewm-client eval "return dofile('$PWD/scripts/figures/somewm-textbox-ellipsize/scene.lua')" | tail -1)
WAYLAND_DISPLAY=wayland-0 grim -l 0 -g "$geo" static/img/concepts/textbox-ellipsize.png
somewm-client eval 'if _G.docs_ellipsize_scene then _G.docs_ellipsize_scene() end'
```

The scene places a wibox on the primary screen's current tag and returns its geometry. The last line removes it. Look at the PNG: two rows, the first on one line ending in an ellipsis, the second on two lines, nothing cut.
