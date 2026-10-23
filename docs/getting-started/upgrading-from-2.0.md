---
sidebar_position: 4
title: Upgrading from 2.0 to 2.1
description: Identify affected widgets, replace removed APIs, and check a SomeWM 2.0 configuration after upgrading.
---

# Upgrading from 2.0 to 2.1

Custom widgets are still supported. In 2.1, widgets describe their content and sizing, Clay calculates layout, and SomeWM renders the resulting tree.

We removed per-widget `fit`, `layout` and `draw` callbacks so Clay is the single authority for layout. This keeps a single flow, **define state → compute layout → render**, with the renderer using the sizes and positions Clay calculated.

## Check your widgets

| Your configuration uses | What to do |
| --- | --- |
| Built-in widgets, or custom compositions of them | Check [removed properties](#removed-names) and [visual changes](#what-you-will-see). |
| Widgets with `fit`, `layout`, `draw`, `before_draw_children` or `after_draw_children` | [Port the implementation](#port-a-custom-widget). Otherwise the widget and its children are omitted, with a warning. |
| Third-party widget libraries | Check for 2.1 support if they implement those methods or call removed APIs. |
| Custom **client layouts** with `arrange` | No port needed. `arrange` is separate from widget layout. |

This applies to widgets in wibars, titlebars, popups and notifications.

<span id="layout-and-drawing-in-21" />
<span id="the-same-widget-before-and-after" />

## Port a custom widget

Keep its data collection, state and input handling. Replace drawing and sizing methods with [built-in components](../guides/custom-widgets.md#compose-built-in-widgets), a [Clay description (before-and-after example)](../guides/custom-widgets.md#register-a-clay-description), or an [image surface](../guides/custom-widgets.md#draw-to-an-image-surface). Remove the old methods, including those copied from a class table, even after registering a description.

## Removed names

<span id="widget-methods-and-drawing" />
<span id="classes-and-properties" />
<span id="theme-variables" />

Check the [removed APIs and their replacements](../reference/deviations.md#removed-apis-and-properties) against your configuration and widget libraries. The list covers drawing helpers, widget properties, theme variables and animation APIs.

## Check visual changes {#what-you-will-see}

<span id="a-widget-that-paints-itself-is-left-out" />
<span id="a-translucent-wibox-looks-denser-where-fills-overlap" />
<span id="a-few-things-the-tree-cannot-hold-warn-and-change" />

| If you use | Check or change |
| --- | --- |
| Translucent wibars or popups | Opacity applies to each fill, so overlapping backgrounds can look denser. Apply alpha to the backgrounds you want translucent. |
| `bgimage` functions | Replace them with a file or image surface. See [wibar backgrounds](../guides/wibar-background-image.md). |
| Custom `shape` functions | Only their paths are used. Move painting into widget properties or an image surface. |
| Imageboxes without a size limit | Without a size bound from an ancestor, they use their natural image size. |
| Grids, rotated text, scroll or tile containers | Check the [widget restrictions](../reference/deviations.md#widget-restrictions). Some combinations are omitted or draw differently. |
| Client borders | Set `border_width` in rules if you want borders. A client with no rule setting now has no border. |
| `shape_bounding`, `shape_clip` or `shape_input` | Use `client.shape` or `wibox.shape`. The old mask properties are ignored and warn. |

<span id="behaviour-that-changed" />

See [other behaviour changes](../reference/deviations.md#layout-rendering-and-client-behaviour) for sizing, stacking and signals.

## Check warnings after reloading {#how-to-read-a-warning}

Reload your configuration and check the log. With `somewm-session`:

```bash
journalctl --user -u somewm.service -f
```

If started from a terminal, read standard error there. Warnings identify omitted widgets and ignored or adjusted properties.

Test widget updates and pointer input. To diagnose sizing or positioning, [inspect the layout](../concepts/reading-the-tree.md).

## Building 2.1

- SomeWM builds wlroots 0.20.2. Remove `-Dwlroots_version` and update dependencies using [Installation](installation.md).
- XWayland is always built in. Remove `-Dxwayland` from build commands and install xcb, xcb-icccm and Xwayland.
- `make install` replaces the installed Lua tree, removing obsolete modules.

## Further reading {#new-in-21}

<span id="seeing-the-tree" />
<span id="clients" />
<span id="animation" />
<span id="widgets-and-popups" />
<span id="lock-screen" />
<span id="see-also" />

See the [2.1 release notes](/blog/somewm-2.1.0) for new features, [How SomeWM draws](../concepts/how-somewm-draws.md) for the rendering model, and [Theme Variables](../reference/beautiful/theme-variables.md) for new settings.
