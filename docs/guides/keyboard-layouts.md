---
sidebar_position: 9
title: Keyboard Layout Switching
description: "Set several layouts with awful.input.xkb_layout, switch with a keybinding since grp:* toggle options need an X server, show the current one in the bar, and keep the static XKB options that still work."
---

# Keyboard Layout Switching

```lua
awful.input.xkb_layout = "us,de,ru"
awful.input.xkb_variant = ",nodeadkeys,"        -- one per layout
awful.input.xkb_options = "ctrl:nocaps,compose:ralt"
```

`grp:alt_shift_toggle` and the other `grp:*` options switch nothing on Wayland: the X server used to act on the key, and here it is only a key press. Every Wayland compositor has this limit. Static options (`ctrl:nocaps`, `ctrl:swapcaps`, `compose:ralt`, `caps:escape`) work as before.

## Switch with a key

```lua
awful.key({ "Mod1", "Shift" }, "space", function()
    local layouts = awful.widget.keyboardlayout.get_groups_from_group_names(awesome.xkb_get_group_names())
    local current = awesome.xkb_get_layout_group()
    awesome.xkb_set_layout_group((current + 1) % #layouts)
end, { description = "switch keyboard layout", group = "awesome" })
```

With exactly two layouts, `(current + 1) % 2` is enough.

## Show it in the bar

`awful.widget.keyboardlayout()` is a widget that follows the active layout; put it in a wibar section like any other.

[Input Device Configuration](/docs/guides/input-devices) has the rest of `awful.input`; [awful.input reference](/docs/reference/awful/input) every property.
