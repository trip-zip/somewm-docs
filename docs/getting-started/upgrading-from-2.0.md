---
sidebar_position: 4
title: Upgrading from 2.0 to 2.1
description: What changes when you move an rc.lua from SomeWM 2.0 to 2.1, what you will see, and what to do about each warning.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Upgrading from 2.0 to 2.1

SomeWM 2.1 declares everything on an output as [one Clay tree per frame](../concepts/how-somewm-draws.md). Stock widgets retain their configuration interfaces where supported; custom painters and the removed names below require configuration changes. A config notices 2.1 in three places: a widget that painted itself, a translucent bar, and a few properties the tree cannot hold. Compose custom widgets from supported stock classes; some removed features have no equivalent.

## What you will see

### A widget that paints itself is left out

A widget with its own `fit`, `layout` or `draw` is [left out of the tree](../concepts/widgets-in-the-tree.md) with everything inside it, once per class in the log:

```
W: awesome: wibox.clay: badge draws itself (:draw, :fit) and is left out of the tree
```

The symptom is a gap where the widget was; the wibox's background still shows. Compose the look from stock widgets instead: a `wibox.container.background` with `bg`, `shape` and `border_width` replaces most hand-drawn boxes ([example](../concepts/widgets-in-the-tree.md#the-same-look-without-a-painter)). Third-party widget libraries are where this hits, and a library widget that draws with cairo needs the library's update.

### A translucent wibox looks denser where fills overlap

A wibox with `opacity` below 1 blends each fill at that opacity, so overlapping fills add up: a blue container on a blue wibox at 0.5 is denser than either alone. 2.0 blended the finished wibox once; the 2.1 renderer draws each fill as its own rect. Lower the inner containers' opacity, or give only the outermost one an alpha.

### A few things the tree cannot hold warn and change

Each is one line in the log, once, naming the class, the property and what happens instead:

| You set | What happens |
| --- | --- |
| `bgimage` to a function | `wibox.drawable: bgimage functions are not drawn`. A surface or a file path still draws, once at its own size in the top-left corner. To cover a bar, prepare the image at the bar's size ([Put a PNG texture on your wibar](../guides/wibar-background-image.md)). |
| a `shape` function that does more than trace a path | only the path is taken; a colour it sets or anything it paints is dropped. `gears.shape.rounded_rect` and the other `gears.shape` functions are fine. |
| a widget tree of more than 4096 nodes in one wibox | the wibox shows nothing and warns once that it is over the output's element budget. |
| a textbox with more than one line under a `rotate` or `mirror` | left out with a warning; rotated text is one line. |
| a `wibox.container.scroll` under a `rotate` or `mirror`, or a rotate inside a rotate | left out with a warning. |
| a grid with `superpose`, or a row span | a widget added over another is refused; a span occupies its first row and warns. |
| a padding, gap or border width below 0 | it is 0, with a warning. |
| a colour that is not a solid or a gradient (a surface or mesh pattern) | transparent, with a warning naming the property. |

Textboxes wrap at words; `wrap = "char"` warns that character wrapping is not applied. `wibox.container.tile` draws one copy of its widget and warns that tiling is not applied.

## How to read a warning

Warnings go to the compositor's standard error. Under the `somewm-session` wrapper that is the user journal:

```bash
journalctl --user -u somewm.service -f
```

A SomeWM started from a terminal prints them there. The three forms are:

- `wibox.clay: <class> draws itself (...) and is left out of the tree`, or `has no describer and is left out of the tree`: the widget and its subtree are not drawn.
- `wibox.clay: <class> <property> <what happens>`: the value was changed to one the tree can hold, and the rest of the widget is drawn.
- `wibox.clay: <class> <property> is ignored`: a property the class no longer has; nothing changes.

To see what was drawn instead, print the tree or open the inspector:

```bash
somewm-client clay tree
```

```lua
screen.primary.inspector = true
```

[Reading the tree](../concepts/reading-the-tree.md) walks the output. A widget that was left out is simply absent from it.

## Behaviour that changed

Without any change to `rc.lua`:

| Area | 2.1 |
| --- | --- |
| Imagebox sizing | An imagebox without a forced size takes its size from the told size above it, as 2.0's fit did; with none on either axis it declares the image's own size and can overflow a flex or fixed layout. An imagebox forced on one axis scales its image to that axis. |
| Hotkeys help and menubar | They scroll instead of paging. Hotkeys: one column per group, continued every `beautiful.hotkeys_rows` rows (default 20), PgDn and PgUp scroll by one viewport. Menubar: `left_label` and `right_label` show while items lie beyond that side. |
| Grid | A non-homogeneous grid no longer sizes its columns to the widest cell across rows. A homogeneous grid inside a content-sized box takes content-sized cells and warns. Border dashes draw solid and gradient border colours are transparent, both with a warning. |
| Clients under a layout | An ontop, above or below client tiles into its slot, as in AwesomeWM. A client whose protocol minimum exceeds its tiled cell overhangs the cell; the workarea and its neighbours keep their size. A client that draws a size other than the one it was given is drawn at the drawn size, cut at its cell. |
| Max and magnifier | A floating client is above the layout's clients whatever the raise order, and a transient of a max or magnifier client is above every client of that layout. |
| Size hints | `c.size_hints` reports min and max width and height for Wayland clients, from the toplevel's committed bounds. A Wayland client whose min equals max reports `is_fixed` and floats. |
| Border width | A client whose rules set no `border_width` draws no border, as in AwesomeWM; 2.0 applied the theme's width from C. `property::border_color` also fires when the focus recolour changes the drawn border. |
| Overflow scroll signals | `property::scroll_factor` fires once the frame has applied a change, with the applied value, including for the mouse wheel and for a content or viewport change that moves the factor. |
| Gradients | A slider `bar_color` gradient, an arcchart `colors` gradient and a separator `color` gradient are drawn in the bar's, the box's and the line's own box; upstream used the widget's box or a centred square. A slider `bar_active_color` gradient now draws. |
| Rotate | A widget under a rotate receives press coordinates relative to its rotated box. Text under a rotate or mirror draws as one line. |
| Shapes | `shape_bounding`, `shape_clip` and `shape_input` on a client or a wibox are accepted and never read, and warn by name; a client's corners come from `client.shape` and a wibox's from its `shape`. |
| Align with `expand = "none"` | An outer widget wider than its half pushes the centre widget off centre instead of being cut at the half. |
| Stacking | 2.0 kept six fixed scene layers, background to overlay, and moved each client's and wibox's node between them in C. 2.1 has no layers: order is a band the tree declares ([Scene Graph](../concepts/scene-graph.md#bands)). |
| Layouts | 2.0's `arrange` computed a rectangle per client in Lua. 2.1 declares the layout as a Clay subtree; an `arrange` layout still works, with its numbers marked `legacy` in the dump. |
| Widget sizing | 2.0 asked each widget's `fit` for a size and its `layout` for its children's places, so the same question had many answers. 2.1 has one: Clay's solve. |
| Client-local properties | `client:set_xproperty` stores scalar values across Lua hot reloads; the 2.0 method did nothing. See [client properties](../reference/deviations.md#x-property-family). |
| Shadows | `clip_directional` is accepted but has no effect. Shadows fade on every side; remove the setting. See [shadow reference](../reference/shadows.md). |
| Layout animation | A client frame declares no transition until something configures animation: `c.animation`, `theme.animation_duration` or any `theme.animation_*_duration` set to a number (0 included), `theme.animation_appear` or `animation_disappear`, or `somewm.animation.layout_duration` above 0. Requiring `somewm.layout_animation` sets that to 0.15 and is deprecated. A client's first frame after that, or after a reload, does not animate unless it has an entrance. |

## Removed names

Calling a removed function raises `attempt to call ... (a nil value)`. Setting a removed widget, wallpaper or layout_animation property warns once that it is ignored; setting `surface_scale`, `shape_border` or `carousel.scroll_duration` is silent and does nothing. The right column says what to do.

### Widget methods and drawing

| Gone | Instead |
| --- | --- |
| `fit`, `draw`, `layout`, `before_draw_children`, `after_draw_children` on every stock widget, container and layout class | Compose from stock widgets; nothing measures or paints itself. |
| `wibox.hierarchy` and the `wibox.hierarchy` field: `new`, `count_widget`, `update`, `get_widget`, `get_matrix_to_parent`, `get_matrix_to_device`, `get_matrix_from_parent`, `get_matrix_from_device`, `get_draw_extents`, `get_size`, `get_children`, `get_count`, `draw` | No tree of placed widgets is kept. The solved box of a widget is in the dump and the inspector. |
| `wibox.widget.base.fit_widget`, `layout_widget`, `place_widget_at`, `place_widget_via_matrix`, `rect_to_device_geometry`, and `no_parent_I_know_what_I_am_doing` | The solver places every widget. |
| `wibox.widget.draw_to_cairo_context`, `draw_to_image_surface`, `draw_to_svg_file`, `wibox:to_widget`, `wibox:save_to_svg` | Capture the screen: `root.content()`, `screen.content`, `somewm-client screenshot`. |
| `wibox.widget.textbox:get_preferred_size`, `get_preferred_size_at_dpi`, `get_height_for_width`, `get_height_for_width_at_dpi`, `wibox.widget.textbox.get_markup_geometry`, `menubar.utils.compute_text_width`, `menubar.utils.compute_textbox_width` | The solver measures text. Let the textbox fit, or give it a `forced_width`. |
| the drawable `refresh` method and `surface` property, the drawin `surface_scale` and `shape_border` properties | A drawable holds no surface. The renderer draws a shaped wibox's border from `border_width` and `border_color`. |
| the scroll container's `context`, `first_x`, `first_y`, `fit_width`, `fit_height`, `hierarchy`, `surface_width`, `surface_height` | The container is a scroll element of the tree. |
| the wibox `__tostring` | `tostring(wibox)` prints the table. |

### Classes and properties

| Gone | Instead |
| --- | --- |
| `wibox.container.border` | `wibox.container.background` with `border_width`, `border_color` and `shape`. Loading the old module is an error. |
| `horizontal_offset` (stack) | none; stacked widgets share one box |
| `minimum_column_width`, `superpose` (grid) | none; a widget added over another is refused |
| `inner_fill_strategy` (ratio) | none |
| `stretch_horizontally`, `stretch_vertically` (background) | none; the child fills the container |
| `paddings` (radialprogressbar) | none |
| `horizontal_crop`, `vertical_crop` (tile) | none |
| `auto_dpi`, `source_width` (imagebox) | none; the output's scale applies |
| `ticks_gap` (progressbar) | none |
| `bar_border_color`, `bar_border_width`, `handle_margins` (slider) | none |
| `empty_cell_mode`, `empty_color`, `empty_widget` (calendar) | none |
| `check_border_color`, `check_border_width`, `check_shape` (checkbox) | `shape` draws the check |
| `awful.wallpaper` `uncovered_areas_color`, `dpi`, `get_dpi` | the root wallpaper shows in uncovered areas; the output scale applies |
| `awful.client.shape`: `get_transformed`, `update.all`, `update.bounding`, `update.clip`, `update.input` | `client.shape` |
| `carousel.scroll_duration` | `theme.animation_layout_duration` |
| `somewm.layout_animation.easing` | none; the solver's curve |
| `awesome.systray` | `wibox.widget.systray`; the C painter entry point is gone |
| `_wibox` | `wibox`; the private surface-backed C module is gone |
| `ruled.client.completed_with_payload_callback` | `ruled.client.execute` |

### Theme variables

Gone with the properties that read them: `slider_bar_border_color`, `slider_bar_border_width`, `slider_handle_margins`, `calendar_empty_color`, `checkbox_check_border_color`, `checkbox_check_border_width`, `checkbox_check_shape` and `radialprogressbar_paddings`. Setting one does nothing.

New: `hotkeys_rows`, `calendar_popup_width`, `launcher_width`, and the inspector's `inspector_bg`, `inspector_bg_alt`, `inspector_border`, `inspector_fg`, `inspector_bg_selected`, `inspector_highlight`, `inspector_width` and `inspector_font` ([Theme Variables](../reference/beautiful/theme-variables.md)).

## New in 2.1

Everything a 2.0 config can use that it could not before. Each group links the page that documents it.

### Seeing the tree

- `somewm-client clay tree [screen]` prints what the last frame solved: counters per band, then one line per retained node in draw order ([Reading the tree](../concepts/reading-the-tree.md)).
- `screen.inspector` opens Clay's debug inspector on that screen, with the element tree and the selected element's solved box, and `property::inspector` fires on a change. `somewm.inspector.toggle(s)` flips it and `somewm.inspector.restyle()` re-reads the theme keys `inspector_bg`, `inspector_bg_alt`, `inspector_border`, `inspector_fg`, `inspector_bg_selected`, `inspector_highlight`, `inspector_width` and `inspector_font` ([Screen](../reference/screen.md)).

### Clients

- `client.shape`: nil, a corner radius in pixels, or a `gears.shape` function. A rounded rectangle is read as its radius and drawn through the compositor, on Wayland clients too, and a titlebar takes the corners on its edge. `gears.surface.apply_shape_bounding` sets it as it sets `wibox.shape` ([Rounded corners](../guides/rounded-corners.md)).
- `awesome._active_modifiers` lists the modifiers held right now, from real keys and `root.fake_input` presses alike, as the names `awful.key` uses. `awful.keyboard.emulate_key_combination` reads it to release held modifiers first ([Deviations](../reference/deviations.md#signals)).

### Animation

All of it is new in 2.1. `somewm.layout_animation` is deprecated and `awesome.start_animation` is gone ([Animation](../guides/animation.md)).

- `c.animation = { appear, disappear, tag, focus, maximize, floating }` and the rule property of the same name, with the theme keys `animation_appear`, `animation_disappear` and `animation_tag` for the entrance, one duration key per trigger, and `animation_duration` as the fallback for every trigger, layout included.
- The entrances `grow`, `scale`, `scale_top`, `scale_bottom`, `scale_left`, `scale_right`, `slide_left`, `slide_right`, `slide_up`, `slide_down` and `fade`, alone or in a list that runs together.
- `animation = { visible = { duration, enter, exit } }` on a wibox or `awful.popup`.
- `widget.animation = { property = duration }` for `bg`, `border_color`, `border_width`, `forced_width`, `forced_height` and the progressbar and slider `value`, and `widget:animate{ property = value, duration = d }` for one change.
- `.animation = false` on any of them turns the object and its descendants off, and `somewm.animation.enabled = false` turns everything off.

### Widgets and popups

- `awful.widget.calendar_popup.month` and `.year` take a `width`, defaulting to `beautiful.calendar_popup_width`, and the popup is an `awful.popup` placed inside the workarea; `awful.popup` gains `honor_workarea`.
- `beautiful.launcher_width` sets the menubar launcher's width ahead of `menubar.geometry.width`. Without either the launcher spans the workarea.
- `beautiful.hotkeys_rows` sets the rows in one column of the hotkeys help, default 20. The help and the menubar scroll instead of paging.
- A childless `wibox.container.background` inside `wibox.layout.stack` paints its colour over the layers below it, and a floating `wibox.container.place` keeps its whole allocation.

### Lock screen

- `theme.lockscreen_wallpaper` and `theme.lockscreen_wallpaper_overlay`, or the `wallpaper` and `wallpaper_overlay` options of `lockscreen.init`, show an image letterboxed like the desktop wallpaper and dimmed by the overlay colour ([Lockscreen](../reference/lockscreen.md)).

## Building 2.1

- SomeWM builds its own wlroots 0.20.2 and links it in; an installed wlroots is not used. The wlroots 0.19 path and `-Dwlroots_version` are gone. A distribution whose wayland, libdrm, xkbcommon, pixman or wayland-protocols is older than wlroots 0.20.2 gets that library built alongside it by the same build. See [Installation](installation.md).
- XWayland is always built in; `-Dxwayland` is gone. Building needs xcb, xcb-icccm and Xwayland installed.
- `make install` does not delete files from an earlier install. If you installed 2.0 with `make install`, remove the old Lua tree first, or a config that requires a removed module such as `wibox.hierarchy` loads 2.0's copy and fails further on:

```bash
sudo rm -rf /usr/local/share/somewm/lua
sudo make install
```

## See Also

- [How SomeWM draws](../concepts/how-somewm-draws.md) - the model behind every change on this page
- [AwesomeWM widgets in that model](../concepts/widgets-in-the-tree.md) - what a widget declares, and what happens to one that paints
- [Reading the tree](../concepts/reading-the-tree.md) - the dump and the inspector
- [AwesomeWM compatibility reference](../reference/deviations.md) - supported behaviour and platform limits in 2.1
