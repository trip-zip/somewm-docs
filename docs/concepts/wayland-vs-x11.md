---
sidebar_position: 2
title: Wayland vs X11
description: On Wayland the compositor owns drawing, input and placement, so some AwesomeWM features change shape or go away. The list, with what SomeWM does instead.
---

# Wayland vs X11

| | X11 | Wayland |
| --- | --- | --- |
| window management | clients set hints, the WM interprets them | the compositor decides everything |
| drawing | server-side or client-side | client-side only; the compositor composes buffers |
| input | any client can see or inject it | per surface; only the compositor injects |
| screenshots | any app can grab the screen | compositor support required |
| tray icons | `_NET_SYSTEMTRAY` embeds windows | StatusNotifierItem over D-Bus |

## What changes in SomeWM

- **Restart.** The compositor is the display server, so it cannot exec itself without dropping every client. `awesome.restart()` rebuilds the Lua state in process instead; Mod4+Ctrl+r in the default config calls it.
- **Systray.** Icons come over StatusNotifierItem. NetworkManager, Bluetooth applets, Discord and Steam work; XEmbed-only apps show nothing.
- **Input injection.** `xdotool` cannot reach other apps. `root.fake_input()` works because the compositor itself injects through `wlr_seat`.
- **Key repeat.** The compositor sends the repeat rate and delay with the keymap, and each application repeats on its own, asking the keymap whether the held key repeats. `keyboard_repeat_rate` and `keyboard_repeat_delay` set the timing; a layout can mark a key non-repeating and no property overrides it ([troubleshooting](../troubleshooting.md#a-key-doesnt-repeat-when-held)).
- **X properties.** No equivalent exists. `awesome.register_xproperty()` and its family are stubs.
- **Borders.** The border is a scene rect around the client geometry. `c:geometry()` excludes it, as in AwesomeWM; titlebars sit inside the geometry and start inside the border.
- **XKB toggle options.** `grp:alt_shift_toggle` and the other `grp:*` options need an X server to act on the key. On any Wayland compositor they do nothing. Bind the switch yourself ([Keyboard Layout Switching](/docs/guides/keyboard-layouts)):

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % 2)
end)
```

Static options such as `ctrl:nocaps` and `compose:ralt` work as on X11.

[AwesomeWM Compatibility](./awesomewm-compat.md) has the compatibility contract; [Tag Persistence](./tag-persistence.md) covers hotplug, which Wayland makes routine.
