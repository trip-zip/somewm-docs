<!--
Hand-curated prelude for theme-variables.md. Survives regeneration.
Edits to this file are picked up on the next `npm run generate:reference`.
-->

## Quick-Start Variables

The handful of variables every theme sets. Each is also listed in its module section below.

| Variable | Type | Description |
| --- | --- | --- |
| `bg_normal` | `color` | Default background |
| `fg_normal` | `color` | Default text |
| `bg_focus` | `color` | Background when focused |
| `fg_focus` | `color` | Text when focused |
| `bg_urgent` | `color` | Background for urgent items |
| `fg_urgent` | `color` | Text for urgent items |
| `font` | `string` | Default Pango font, e.g. `"sans 10"` |
| `border_width` | `number` | Window border thickness in pixels |
| `border_color_normal` | `color` | Unfocused window border |
| `border_color_active` | `color` | Focused window border |
| `useless_gap` | `number` | Gap between tiled windows |
| `wallpaper` | `string` | Path to wallpaper image |

## Cursors

Standard X cursor names like `"left_ptr"`, `"fleur"`, `"cross"`, `"watch"` are accepted.

:::tip Cursor theme
Set the cursor theme via environment variables before launching:

```bash
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE="24"
somewm
```

Or change it at runtime (SomeWM-only):

```lua
root.cursor_theme("Adwaita")
root.cursor_size(32)
```

See [Input Devices: Cursor Theming](/docs/guides/input-devices#cursor-theming).
:::

---
