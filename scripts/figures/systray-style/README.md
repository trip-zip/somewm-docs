# Systray spacing and hover

The `customise-systray` guides use `spacing.png` and `hover.png` from
`static/img/guides/systray/`. Both show the existing bar's real application icons.
The pages enlarge the 60×32 pixel crops twice. They identify the capture as
2.1.1, including when showing these shared settings in an older version's guide.

Captured on SomeWM `v2.1.1-11-g8edb69dd0-dirty`, output `DP-3`, 3840×2160,
scale 1. The bar uses the session's theme and font; neither crop contains text.
The manifest records the resolved screen and crop coordinates.

Requires `somewm-client`, `grim`, Python 3 and an application with a tray icon.
Run inside the intended live session. Set `SOMEWM_SOCKET` and `WAYLAND_DISPLAY`
when more than one compositor is running. Discover the output and item first:

```sh
somewm-client output list
somewm-client eval 'local ids = {}; for _, item in ipairs(systray_item.get_items()) do ids[#ids + 1] = item.id end; return table.concat(ids, "\n")'
python3 scripts/figures/systray-style/capture.py \
  --output DP-3 --item discord_status_icon_1 \
  --destination /tmp/systray-style-review
```

The script applies the guide's spacing, padding, size and background values to
the existing tray. It captures the normal state, then sets the selected icon's
hover flag and requests a redraw. It does not move the pointer or open a tooltip.
It polls the solved tray geometry before each crop. The theme changes affect the
shared tray on both monitors during capture.

The `finally` block restores the saved settings and hover state. A 60-second Lua
timer also restores them if the driver exits before cleanup. The script leaves
windows, focus, tags, wallpaper and the bar layout in place.

Inspect both images before copying them to `static/img/guides/systray/` and copy
`capture.json` here. The first image should show four pixels between 16-pixel icons. The
second should show a teal hover background behind the chosen icon. No other
application content should appear.

## Attention highlight

```sh
python3 scripts/figures/systray-style/capture.py \
  --output DP-3 --item docs-systray-example --attention \
  --destination /tmp/systray-attention-review
```

This starts `tray-item.py` on the session bus. It publishes one temporary tray
item and changes its status from `Active` to `NeedsAttention` through the SNI
protocol. The driver captures both states, stops that process, and restores the
tray settings. `attention-capture.json` records the capture. The screenshots
show the real renderer's attention background, not an edited image.

`static/img/guides/systray/custom-chat.svg` is the source for the replacement icon:

```sh
magick -background none static/img/guides/systray/custom-chat.svg \
  static/img/guides/systray/custom-chat.png
```

The PNG preview in the 1.4 and 2.0 guides is the icon asset, not a compositor
screenshot. Those versions support `icon_override`.
