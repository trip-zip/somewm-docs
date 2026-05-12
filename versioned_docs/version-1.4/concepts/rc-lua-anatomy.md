---
sidebar_position: 3.5
title: Anatomy of rc.lua
description: Section-by-section map of the default SomeWM config
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import SomewmOnly from '@site/src/components/SomewmOnly';

# Anatomy of `rc.lua`

<YouWillLearn>

- The 13 sections that make up the default config
- Which section to edit to change a specific behavior
- Which sections are SomeWM-specific vs. upstream-compatible

</YouWillLearn>

The default config ships as `somewmrc.lua` (657 lines), installed to `/usr/share/somewm/somewmrc.lua`. Copy it to `~/.config/somewm/rc.lua` to customize. This page maps each section to its purpose and the line you'd edit for a given goal.

## At a glance

| # | Section | Lines | Edit this to... |
|---|---------|-------|------------------|
| 1 | [Error handling](#1-error-handling) | 25-64 | Change error UI or X11 fallback behavior |
| 2 | [Variable definitions](#2-variable-definitions) | 66-86 | Change terminal, editor, modkey, theme path |
| 3 | [Menu](#3-menu) | 88-109 | Customize the right-click menu and launcher |
| 4 | [Tag layout](#4-tag-layout) | 111-131 | Add, remove, or reorder window layouts |
| 5 | [Wallpaper](#5-wallpaper) | 133-152 | Change wallpaper rendering or fit |
| 6 | [Tag persistence](#6-tag-persistence) | 154-159 | Disable monitor-hotplug tag restore |
| 7 | [Wibar](#7-wibar) | 161-282 | Customize the top bar and its widgets |
| 8 | [Mouse bindings](#8-mouse-bindings) | 286-293 | Change root-window mouse buttons |
| 9 | [Key bindings](#9-key-bindings) | 295-534 | Add or change keyboard shortcuts |
| 10 | [Rules](#10-rules) | 536-592 | Auto-tag, float, or place specific apps |
| 11 | [Titlebars](#11-titlebars) | 594-633 | Customize per-window titlebar widgets |
| 12 | [Notifications](#12-notifications) | 635-652 | Change notification display and rules |
| 13 | [Focus behavior](#13-focus-behavior) | 654-657 | Disable sloppy focus |

## 1. Error handling

**Lines:** 25-64
**Purpose:** Notify the user when SomeWM hits a runtime error, plus a SomeWM-specific notification when the user's config contains X11-only patterns and gets skipped.
**Modules:** `naughty`, `gears.timer`
**SomeWM-specific** <SomewmOnly />**:** The `awesome.x11_fallback_info` block (L37-63). When SomeWM's compatibility layer detects an X11 API in your config, it loads the system fallback and surfaces the offending file, line number, and pattern via notification.
**Common edits:** None for most users. Replace the inner `naughty.notification` call to change urgency, timeout, or to log to a file instead of notifying.

```lua
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
```

## 2. Variable definitions

**Lines:** 66-86
**Purpose:** Load the theme, initialize the lockscreen module, and define the globals used throughout the rest of the file (`terminal`, `editor`, `modkey`).
**Modules:** `beautiful`, `gears.filesystem`, `lockscreen` (SomeWM-only)
**SomeWM-specific** <SomewmOnly />**:** `require("lockscreen").init()` on L72 — SomeWM ships a native Wayland lockscreen. See [Lockscreen](/docs/concepts/lockscreen).
**Common edits:**

- **L76** `terminal = "xterm"` — change to your terminal of choice
- **L77** `editor` — falls back to `$EDITOR` or `nano`; override here
- **L85** `modkey = "Mod4"` — change to `"Mod1"` (Alt) if you don't have a Super key
- **L69** theme path — point to your custom theme (see the [Theme tutorial](/docs/tutorials/theme))

```lua
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
require("lockscreen").init()

terminal = "xterm"
editor   = os.getenv("EDITOR") or "nano"
modkey   = "Mod4"
```

## 3. Menu

**Lines:** 88-109
**Purpose:** Define a SomeWM submenu (`myawesomemenu`), the right-click main menu (`mymainmenu`), and the launcher widget that anchors the menu in the wibar.
**Modules:** `awful.menu`, `awful.widget.launcher`, `menubar`
**Common edits:**

- **L91-97** Entries in `myawesomemenu`
- **L99-102** Top-level entries in `mymainmenu` (e.g., `{ "screenshot", "grim" }`)
- **L108** Terminal that `menubar` uses to launch text apps

```lua
mymainmenu = awful.menu({ items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "open terminal", terminal }
} })
```

## 4. Tag layout

**Lines:** 111-131
**Purpose:** Register the layouts available in the cycle order. The first layout in the list is the default for new tags.
**Modules:** `awful.layout.suit.*`
**Common edits:**

- Reorder or remove layouts in the `append_default_layouts` call
- To make `tile` the default, move it to the top of the list
- To add the carousel, append `awful.layout.suit.carousel` (see the [Carousel tutorial](/docs/tutorials/carousel))

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        -- ...11 more layouts
    })
end)
```

## 5. Wallpaper

**Lines:** 133-152
**Purpose:** Render `beautiful.wallpaper` for each screen via `awful.wallpaper` when SomeWM emits `request::wallpaper`.
**Modules:** `awful.wallpaper`, `wibox.widget.imagebox`, `wibox.container.tile`
**Common edits:**

- Change `valign`, `halign`, or `tiled` to alter fit
- Branch on `s.index` for per-screen wallpapers
- Replace the inner `imagebox` with a custom widget for procedural backgrounds

See [Wallpaper Caching](/docs/concepts/wallpaper-caching) for how SomeWM handles wallpaper memory.

```lua
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            { image = beautiful.wallpaper, widget = wibox.widget.imagebox },
            tiled = false, widget = wibox.container.tile,
        }
    }
end)
```

## 6. Tag persistence

**Lines:** 154-159
**Purpose:** Comment-only stub documenting how to opt out of tag persistence.
**SomeWM-specific** <SomewmOnly />**:** SomeWM persists tags across monitor disconnect/reconnect by default — the save handler lives in `awful.permissions.tag_screen` and stores state in `awful.permissions.saved_tags`. The restore happens inline in the wibar section (next).
**Common edits:** To disable, uncomment line 158:

```lua
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)
```

See [Tag Persistence](/docs/concepts/tag-persistence) for the full mechanism.

## 7. Wibar

**Lines:** 161-282 (the largest section)
**Purpose:** Per-screen desktop decoration. Creates the keyboard layout indicator and textclock globally, then for each screen builds a promptbox, layoutbox, taglist, tasklist, and the top wibar with three-section align layout.
**Modules:** `awful.widget.keyboardlayout`, `awful.widget.prompt`, `awful.widget.layoutbox`, `awful.widget.taglist`, `awful.widget.tasklist`, `awful.wibar`, `wibox.widget.systray`, `wibox.widget.textclock`
**SomeWM-specific** <SomewmOnly />**:** L171-200 — the restore branch. When `request::desktop_decoration` fires for a screen that was previously removed (and whose tags were saved), it rebuilds the tags and moves the saved clients back. Upstream AwesomeWM doesn't do this.
**Common edits:** See the full [Wibar tutorial](/docs/tutorials/wibar). Quick hits:

- **L203** Tag names — change `{ "1", ..., "9" }` to whatever you want (`{ "code", "web", "chat" }`)
- **L266-279** Reorder or remove widgets in left / middle / right sections of the wibar

```lua
screen.connect_signal("request::desktop_decoration", function(s)
    -- ...restore-or-create tags...
    s.mywibox = awful.wibar {
        position = "top",
        screen   = s,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { layout = wibox.layout.fixed.horizontal, mylauncher, s.mytaglist, s.mypromptbox },
            s.mytasklist,
            { layout = wibox.layout.fixed.horizontal, mykeyboardlayout, wibox.widget.systray(), mytextclock, s.mylayoutbox },
        }
    }
end)
```

## 8. Mouse bindings

**Lines:** 286-293
**Purpose:** Global mouse buttons on the root (desktop background) surface.
**Modules:** `awful.mouse.append_global_mousebindings`
**Common edits:**

- **L289** Right-click default opens the main menu. Bind to something else if you want
- **L290-291** Scroll on the desktop cycles tags by default

```lua
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),
})
```

## 9. Key bindings

**Lines:** 295-534 (second largest section)
**Purpose:** Global and client keybindings, grouped by purpose (awesome, launcher, tag, screen, client, layout). Uses the `keygroup = "numrow"` and `"numpad"` patterns to bind 1-9 in one declaration instead of nine.
**Modules:** `awful.keyboard`, `awful.key`, `client.connect_signal`
**Common edits:** Full coverage in the [Keybindings tutorial](/docs/tutorials/keybindings). Hot spots:

- **L299-328** General awesome and launcher bindings (terminal, help, restart, run prompt)
- **L401-470** Numrow / numpad keygroup bindings — change which actions Mod4+1...9 trigger
- **L487-532** Per-client bindings inside the `request::default_keybindings` handler

```lua
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              { description = "open a terminal", group = "launcher" }),
    -- ...
})
```

## 10. Rules

**Lines:** 536-592
**Purpose:** Match newly-spawned clients and apply properties (focus policy, screen placement, floating, titlebars, tag assignment).
**Modules:** `ruled.client`, `awful.client.focus.filter`, `awful.placement`
**Common edits:**

- **L542-551** Global rule — applies to every client
- **L554-575** Floating rule — add app class/instance/role names to force-float
- **L587-590** (currently commented) Template for tagging an app to a specific tag (the Firefox-to-tag-2 example)

```lua
ruled.client.append_rule {
    rule_any = { class = { "Arandr", "Wpa_gui", "veromix" } },
    properties = { floating = true }
}
```

See the [Client Rules guide](/docs/guides/client-rules) for the matcher reference.

## 11. Titlebars

**Lines:** 594-633
**Purpose:** When a client emits `request::titlebars`, build its titlebar widget: icon on the left, title in the middle, control buttons on the right.
**Modules:** `awful.titlebar`, `awful.button`, `wibox.layout.*`
**SomeWM-specific** <SomewmOnly />**:** Titlebars on Wayland use client-side decoration (CSD). The widget structure matches AwesomeWM, but the draw pipeline runs through wlroots.
**Common edits:**

- **L622-628** Reorganize the right-side buttons (drop `stickybutton`, change order)
- To disable titlebars globally, set `titlebars_enabled = false` in Section 10's `titlebars` rule

```lua
client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c).widget = {
        { awful.titlebar.widget.iconwidget(c), layout = wibox.layout.fixed.horizontal },
        { { halign = "center", widget = awful.titlebar.widget.titlewidget(c) }, layout = wibox.layout.flex.horizontal },
        { awful.titlebar.widget.closebutton(c), layout = wibox.layout.fixed.horizontal() },
        layout = wibox.layout.align.horizontal
    }
end)
```

## 12. Notifications

**Lines:** 635-652
**Purpose:** Apply a default rule to every notification (5-second timeout, route to preferred screen), and render notifications via `naughty.layout.box` when the daemon emits `request::display`.
**Modules:** `ruled.notification`, `naughty.layout.box`
**Common edits:**

- **L639-645** Default notification properties — change timeout, screen, or layered urgency styling
- Swap `naughty.layout.box` for a custom widget to fully replace the notification UI

```lua
ruled.notification.append_rule {
    rule       = { },
    properties = { screen = awful.screen.preferred, implicit_timeout = 5 }
}
naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)
```

See the [Notifications guide](/docs/guides/notifications) for more.

## 13. Focus behavior

**Lines:** 654-657
**Purpose:** Sloppy focus — when the mouse enters a client window, that client gets focus without raising.
**Modules:** `client.connect_signal`
**Common edits:**

- Delete the block to disable sloppy focus entirely (click-to-focus only)
- Change `raise = false` to `raise = true` to also bring the window forward on hover

```lua
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)
```

## Related

- [Architecture](/docs/concepts/architecture) — the three-layer model: C core, Lua bindings, your config
- [Signals](/docs/concepts/signals) — the `request::*` pattern used in sections 5, 7, 10, 12
- [Keybindings tutorial](/docs/tutorials/keybindings) — detailed customization of section 9
- [Wibar tutorial](/docs/tutorials/wibar) — detailed customization of section 7
- [Theme tutorial](/docs/tutorials/theme) — detailed customization of `beautiful.init()` in section 2
- [Basics tutorial](/docs/tutorials/basics) — first run, copying the default config
