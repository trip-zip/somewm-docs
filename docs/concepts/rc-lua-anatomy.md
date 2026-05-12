---
sidebar_position: 3.5
title: Anatomy of rc.lua
description: Section-by-section map of the default SomeWM config
---

import YouWillLearn from '@site/src/components/YouWillLearn';
import SomewmOnly from '@site/src/components/SomewmOnly';

# Anatomy of `rc.lua`

<YouWillLearn>

- How the default config is organized
- Which section to edit to change a specific behavior
- Which sections are SomeWM-specific vs. upstream-compatible

</YouWillLearn>

The default config ships as `somewmrc.lua` (1118 lines), installed to `/usr/share/somewm/somewmrc.lua`. Copy it to `~/.config/somewm/rc.lua` to customize. This page maps each section to its purpose and the line you'd edit for a given goal.

## At a glance

| # | Section | Lines | Edit this to... |
|---|---------|-------|------------------|
| 1 | [Error handling](#1-error-handling) | 21-55 | Change error UI or X11 fallback behavior |
| 2 | [Theme system](#2-theme-system) | 57-81 | Change the default theme or theme switcher behavior |
| 3 | [Custom "s" logo](#3-custom-s-logo) | 83-112 | Customize the menu/launcher icon |
| 4 | [Lockscreen and defaults](#4-lockscreen-and-defaults) | 114-122 | Change terminal, editor, modkey |
| 5 | [User customization examples](#5-user-customization-examples) | 124-172 | Uncomment options you want enabled |
| 6 | [Menu](#6-menu) | 174-199 | Customize the right-click menu or theme submenu |
| 7 | [Layouts](#7-layouts) | 201-221 | Add, remove, or reorder window layouts |
| 8 | [Wallpaper](#8-wallpaper) | 223-278 | Change wallpaper rendering or fallback |
| 9 | [Tag persistence](#9-tag-persistence) | 280-284 | Disable monitor-hotplug tag restore |
| 10 | [Wibar](#10-wibar) | 286-438 | Customize the top bar, tag names, and widgets |
| 11 | [Root mouse bindings](#11-root-mouse-bindings) | 440-445 | Change desktop-background mouse buttons |
| 12 | [Global key bindings](#12-global-key-bindings) | 447-898 | Add or change keyboard shortcuts |
| 13 | [Client mouse and key bindings](#13-client-mouse-and-key-bindings) | 900-1008 | Change per-window shortcuts |
| 14 | [Rules](#14-rules) | 1010-1051 | Auto-tag, float, or place specific apps |
| 15 | [Titlebars](#15-titlebars) | 1053-1086 | Customize per-window titlebar widgets |
| 16 | [Notifications](#16-notifications) | 1088-1113 | Change notification display and rules |
| 17 | [Sloppy focus](#17-sloppy-focus) | 1115-1118 | Disable focus-follows-mouse |

## 1. Error handling

**Lines:** 21-55
**Purpose:** Notify the user when SomeWM hits a runtime error, plus a SomeWM-specific notification when the user's config contains X11-only patterns and gets skipped.
**Modules:** `naughty`, `gears.timer`
**SomeWM-specific** <SomewmOnly />**:** The `awesome.x11_fallback_info` block (L31-55). When SomeWM's compatibility layer detects an X11 API in your config, it loads the system fallback and surfaces the offending file, line number, and pattern via notification.
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

## 2. Theme system

**Lines:** 57-81
**Purpose:** Persist the user's theme choice across reloads and provide a `switch_theme()` helper for runtime swapping. Reads from `$XDG_CONFIG_HOME/somewm/theme` (defaults to `gruvbox`), then passes the chosen name to `beautiful.init()`.
**Modules:** `beautiful`, `gears.filesystem`
**SomeWM-specific** <SomewmOnly />**:** The persisted theme name and the `switch_theme()` helper are SomeWM additions, not part of AwesomeWM. They're wired into the menu (section 6) so the user can swap themes via right-click.
**Common edits:**

- **L59** Default theme name — change `"gruvbox"` to `"catppuccin"`, `"nord"`, or any theme dir under `gears.filesystem.get_themes_dir()`
- Replace `switch_theme()` with a fancier handler (e.g., reload only `beautiful` instead of restarting the whole compositor)
- See the [Theme tutorial](/docs/tutorials/theme) for writing custom themes

```lua
local theme_file = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/somewm/theme"
local theme_name = "gruvbox"
-- ...read theme_file if it exists...

local function switch_theme(name)
    -- write name to theme_file and restart
end

beautiful.init(gears.filesystem.get_themes_dir() .. theme_name .. "/theme.lua")
```

## 3. Custom "s" logo

**Lines:** 83-112
**Purpose:** Generate a square SomeWM "s" wordmark logo via Cairo and assign it to `beautiful.awesome_icon`. The result is used as the launcher menu icon in the wibar.
**Modules:** `lgi.cairo`, `beautiful`, `gears.color`
**SomeWM-specific** <SomewmOnly />**:** This block replaces AwesomeWM's `theme_assets.gen_awesome_name()` "a" wordmark with an "s" cut from a filled square.
**Common edits:**

- **L91-92** Change `fg`/`bg` to override the colors (otherwise pulls from `beautiful.wallpaper_logo_color` and `beautiful.wibar_bg`)
- Replace the entire block with `beautiful.awesome_icon = "/path/to/your/logo.png"` for a custom icon

```lua
local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
local cr  = cairo.Context(img)
-- draw filled square, then cut two horizontal stripes to shape an "s"
beautiful.awesome_icon = img
```

## 4. Lockscreen and defaults

**Lines:** 114-122
**Purpose:** Initialize the SomeWM lockscreen module, then define the globals used throughout the rest of the file: `terminal`, `editor`, `editor_cmd`, `modkey`.
**Modules:** `lockscreen` (SomeWM-only)
**SomeWM-specific** <SomewmOnly />**:** `require("lockscreen").init()` on L115 — SomeWM ships a native Wayland lockscreen. See [Lockscreen](/docs/concepts/lockscreen).
**Common edits:**

- **L119** `terminal = "foot"` — change to your terminal of choice (`alacritty`, `kitty`, `wezterm`, etc.)
- **L120** `editor` — falls back to `$EDITOR` or `nano`; override here
- **L122** `modkey = "Mod4"` — change to `"Mod1"` (Alt) if you don't have a Super key

```lua
require("lockscreen").init()

local terminal   = "foot"
local editor     = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor
local modkey     = "Mod4"
```

## 5. User customization examples

**Lines:** 124-172
**Purpose:** Commented-out template snippets showing the most common opt-in customizations. Nothing here runs by default — uncomment what you want.
**SomeWM-specific** <SomewmOnly />**:** Several of these reference SomeWM-only APIs:

- `awful.input.*` — keyboard layouts and pointer/touchpad config (compositor-side, no `setxkbmap` / `libinput-gestures`)
- `output.connect_signal("added", ...)` — per-monitor fractional scaling
- `awesome.set_idle_timeout()` and `awesome.idle_inhibit` — idle/inhibitor APIs
- `somewm.layout_animation` — animated tile transitions
- `awful.ipc.register()` — custom IPC commands callable via `somewm-client`

**Common edits:** Uncomment the snippet you want. Typical first uncomments:

- Keyboard layout (`xkb_layout`, `xkb_options = "caps:escape"`)
- Touchpad behavior (`tap_to_click`, `natural_scrolling`)
- Autostart entries (`awful.spawn.once("nm-applet")`)
- Auto-lock idle timer

```lua
-- awful.input.xkb_layout  = "us"
-- awful.input.xkb_options = "caps:escape"
-- awful.input.tap_to_click      = 1
-- awful.spawn.once("nm-applet")
-- awesome.set_idle_timeout("auto-lock", 600, function() awesome.lock() end)
```

See the [Input Devices guide](/docs/guides/input-devices), [Autostart guide](/docs/guides/autostart), and [Fractional Scaling guide](/docs/guides/fractional-scaling) for full coverage.

## 6. Menu

**Lines:** 174-199
**Purpose:** Define the theme submenu (gruvbox/catppuccin/nord), the main right-click menu (`mymainmenu`), and the launcher widget that anchors the menu in the wibar.
**Modules:** `awful.menu`, `awful.widget.launcher`, `menubar`
**Common edits:**

- **L175-179** Add more themes to the `theme_menu` (any directory under `gears.filesystem.get_themes_dir()`)
- **L181-189** Top-level entries in `menu_items` (add screenshot, file manager, etc.)
- **L199** Terminal that `menubar` uses to launch text apps

```lua
local theme_menu = {
    { "gruvbox",    function() switch_theme("gruvbox") end },
    { "catppuccin", function() switch_theme("catppuccin") end },
    { "nord",       function() switch_theme("nord") end },
}

local menu_items = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "terminal", function() awful.spawn(terminal) end },
   { "theme", theme_menu },
   -- ...
}
```

## 7. Layouts

**Lines:** 201-221
**Purpose:** Register the layouts available in the cycle order. The first layout in the list is the default for new tags.
**Modules:** `awful.layout.suit.*`
**SomeWM-specific** <SomewmOnly />**:** `awful.layout.suit.carousel` (L210) — SomeWM's scrollable tiling layout. See the [Carousel tutorial](/docs/tutorials/carousel).
**Common edits:**

- Reorder or remove layouts in the `append_default_layouts` call
- `tile` is the default — swap it with `floating` on L206 to default to floating instead

```lua
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        -- ...
        awful.layout.suit.carousel,
        -- ...10 more
    })
end)
```

## 8. Wallpaper

**Lines:** 223-278
**Purpose:** Render the wallpaper for each screen via `awful.wallpaper` when SomeWM emits `request::wallpaper`. Three branches:

1. If `beautiful.wallpaper_colors` is set, render a gradient with the theme logo placed in the center
2. Else if `beautiful.wallpaper` is set, render that image
3. Else fall back to a solid color

**Modules:** `awful.wallpaper`, `wibox.widget.imagebox`, `wibox.container.place`, `wibox.container.tile`, `gears.color`
**Common edits:**

- Make the gradient/logo branch unconditional, ignoring `beautiful.wallpaper_colors`
- Branch on `s.index` for per-screen wallpapers
- Replace the inner `imagebox` with a custom widget (animation, slideshow, procedural)

See [Wallpaper Caching](/docs/concepts/wallpaper-caching) for SomeWM's wallpaper memory handling.

```lua
screen.connect_signal("request::wallpaper", function(s)
    local colors = beautiful.wallpaper_colors
    if colors then
        awful.wallpaper {
            screen = s,
            bg     = { type = "linear", stops = { { 0, colors[1] }, { 1, colors[2] } } },
            widget = logo_widget,
        }
    elseif beautiful.wallpaper then
        -- ...image branch...
    else
        awful.wallpaper { screen = s, bg = beautiful.bg_normal or "#222222" }
    end
end)
```

## 9. Tag persistence

**Lines:** 280-284
**Purpose:** Comment-only stub documenting how to opt out of tag persistence.
**SomeWM-specific** <SomewmOnly />**:** SomeWM persists tags across monitor disconnect/reconnect by default — the save handler lives in `awful.permissions.tag_screen` and stores state in `awful.permissions.saved_tags`. The restore happens inline in the wibar section (next).
**Common edits:** To disable, add the disconnect call:

```lua
tag.disconnect_signal("request::screen", awful.permissions.tag_screen)
```

See [Tag Persistence](/docs/concepts/tag-persistence) for the full mechanism.

## 10. Wibar

**Lines:** 286-438 (the largest section)
**Purpose:** Build the top bar for each screen. Creates a rounded-background clock widget globally, then for each screen builds promptbox, layoutbox, taglist, tasklist (with a custom `widget_template` for icon + text + margins), and the final wibar with `wibox.layout.stack` so the clock can float dead-center over the underlying align layout.
**Modules:** `awful.widget.prompt`, `awful.widget.layoutbox`, `awful.widget.taglist`, `awful.widget.tasklist`, `awful.widget.clienticon`, `awful.wibar`, `wibox.widget.systray`, `wibox.widget.textclock`, `wibox.container.background`, `gears.shape`
**SomeWM-specific** <SomewmOnly />**:** L307-333 — the restore branch. When `request::desktop_decoration` fires for a screen that was previously removed (and whose tags were saved), it rebuilds the tags and moves the saved clients back.
**Common edits:** See the full [Wibar tutorial](/docs/tutorials/wibar). Quick hits:

- **L335** Tag names — default is `{ "dev", "web", "chat", "files", "media" }`. Change to whatever you want (`{ "1", "2", ..., "9" }` to mirror AwesomeWM's defaults)
- **L288-301** Clock styling — change format, background, rounded-corner radius
- **L410-437** Wibar layout — reorder widgets in left/right sections, change `wibox.layout.stack` to a simple align layout if you don't want the centered clock

```lua
-- Default tags
awful.tag({ "dev", "web", "chat", "files", "media" }, s, awful.layout.layouts[1])
```

## 11. Root mouse bindings

**Lines:** 440-445
**Purpose:** Global mouse buttons on the root (desktop background) surface.
**Modules:** `awful.mouse.append_global_mousebindings`
**Common edits:**

- **L442** Right-click default opens the main menu
- **L443-444** Scroll on the desktop cycles tags by default

```lua
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),
})
```

## 12. Global key bindings

**Lines:** 447-898 (second largest section)
**Purpose:** Global keybindings, organized into named groups. Each group is registered with its own `append_global_keybindings` call so the hotkeys popup categorizes them. Uses the new `awful.key { ... }` declarative form everywhere.
**Modules:** `awful.keyboard`, `awful.key`, `hotkeys_popup`, `awful.prompt`
**Groups and their line ranges:**

| Group | Lines | Notable bindings |
|-------|-------|------------------|
| **somewm** | 449-515 | Mod+s help, Mod+w menu, Mod+Ctrl+r reload, Mod+Shift+q quit, Mod+Shift+Esc lock, Mod+x lua prompt, **Mod+Shift+d do-not-disturb** |
| **launcher** | 517-540 | Mod+Return terminal, Mod+r run prompt, Mod+p menubar |
| **tag** | 542-584 | Mod+Left/Right, Mod+Esc history, **Mod+Shift+r rename current tag** |
| **client** | 586-647 | Mod+j/k focus, Mod+Shift+j/k swap, Mod+u urgent, Mod+Ctrl+n restore minimized |
| **screen** | 649-665 | Mod+Ctrl+j/k focus next/prev screen |
| **audio** | 667-697 | XF86Audio* via `wpctl` (volume, mute, mic mute) |
| **brightness** | 699-715 | XF86MonBrightness* via `brightnessctl` |
| **screenshot** | 717-758 | Print full-screen via `grim`, Shift+Print region via `slurp`+`grim`, Mod+Ctrl+p interactive `awful.screenshot` |
| **layout** | 760-818 | Mod+l/h mwfact, Mod+Shift+l/h nmaster, Mod+Ctrl+l/h ncol, Mod+Space cycle |
| **tag (numrow)** | 820-882 | Mod+1-9, +Ctrl/Shift/Ctrl+Shift variants (view-only, toggle, move, toggle-on) |
| **layout (numpad)** | 884-898 | Mod+Numpad picks a layout directly |

**Common edits:** See the [Keybindings tutorial](/docs/tutorials/keybindings). To add or remove a binding, edit the appropriate group's `append_global_keybindings` call.

```lua
-- somewm group sample
awful.key {
    modifiers   = { modkey, "Shift" },
    key         = "d",
    on_press    = function() naughty.suspended = not naughty.suspended end,
    description = "toggle do-not-disturb",
    group       = "somewm",
}
```

## 13. Client mouse and key bindings

**Lines:** 900-1008
**Purpose:** Per-client bindings registered via the `request::default_mousebindings` and `request::default_keybindings` signals. Using signals (not direct registration) means user code can append more later.
**Modules:** `awful.mouse`, `awful.keyboard`, `awful.button`, `awful.key`
**Client mouse bindings (L900-914):** Left-click activates, Mod+Left-click moves, Mod+Right-click resizes.
**Client keybindings (L916-1008):** Mod+f fullscreen, Mod+Shift+c close, Mod+Ctrl+Space float toggle, Mod+Ctrl+Return move to master, Mod+o move to screen, Mod+t toggle ontop, **Mod+, toggle sticky**, Mod+n minimize, Mod+m maximize (with Ctrl/Shift variants for vertical/horizontal).
**Common edits:**

- Add a binding for `c.maximized_vertical` / `c.minimized` toggles
- Bind a custom key to move the client between tags by name
- Remove sticky if you don't use it

```lua
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key {
            modifiers   = { modkey },
            key         = "f",
            on_press    = function(c) c.fullscreen = not c.fullscreen; c:raise() end,
            description = "toggle fullscreen",
            group       = "client",
        },
        -- ...
    })
end)
```

## 14. Rules

**Lines:** 1010-1051
**Purpose:** Match newly-spawned clients and apply properties (focus policy, screen placement, floating, titlebars, tag assignment).
**Modules:** `ruled.client`, `awful.client.focus.filter`, `awful.placement`
**Common edits:**

- **L1015-1024** Global rule — applies to every client
- **L1027-1035** Floating rule — add app class/instance/role names to force-float
- **L1039-1043** Tag-route rule — example tags nested wlroots compositor windows to the `"media"` tag; use the same pattern to route a specific app to a specific tag

```lua
ruled.client.append_rule {
    id         = "wlroots-tests",
    rule       = { class = "wlroots" },
    properties = { tag = "media", switchtotag = false, focus = false },
}
```

See the [Client Rules guide](/docs/guides/client-rules) for the matcher reference.

## 15. Titlebars

**Lines:** 1053-1086
**Purpose:** When a client emits `request::titlebars`, build its titlebar widget: icon on the left, title in the middle, control buttons on the right (floating/maximized/close — no sticky or ontop by default).
**Modules:** `awful.titlebar`, `awful.button`, `wibox.layout.*`
**SomeWM-specific** <SomewmOnly />**:** Titlebars on Wayland use client-side decoration (CSD). The widget structure matches AwesomeWM, but the draw pipeline runs through wlroots.
**Common edits:**

- Add `stickybutton` / `ontopbutton` to the right section if you want them visible
- To disable titlebars globally, set `titlebars_enabled = false` in Section 14's `titlebars` rule

```lua
client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c).widget = {
        { awful.titlebar.widget.iconwidget(c), layout = wibox.layout.fixed.horizontal },
        { { halign = "center", widget = awful.titlebar.widget.titlewidget(c) }, layout = wibox.layout.flex.horizontal },
        {
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
```

## 16. Notifications

**Lines:** 1088-1113
**Purpose:** Apply a default rule to every notification (5-second timeout, route to preferred screen), and render notifications via `naughty.layout.box` when the daemon emits `request::display`. Includes commented examples for per-app routing (ignore Spotify, raise Slack mentions to critical).
**Modules:** `ruled.notification`, `naughty.layout.box`
**Common edits:**

- **L1092-1098** Default notification properties — change timeout, screen, or layered urgency styling
- **L1101-1108** Uncomment and adapt the per-app routing examples
- Swap `naughty.layout.box` for a custom widget to fully replace the notification UI

```lua
ruled.notification.append_rule {
    rule       = { app_name = "Slack", title = "@you" },
    properties = { urgency = "critical" },
}
```

See the [Notifications guide](/docs/guides/notifications) for more.

## 17. Sloppy focus

**Lines:** 1115-1118
**Purpose:** Focus follows the mouse — when the pointer enters a client window, that client gets focus without raising.
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
- [Signals](/docs/concepts/signals) — the `request::*` pattern used in sections 1, 7, 8, 10, 13, 14, 15, 16
- [Keybindings tutorial](/docs/tutorials/keybindings) — detailed customization of section 12
- [Wibar tutorial](/docs/tutorials/wibar) — detailed customization of section 10
- [Theme tutorial](/docs/tutorials/theme) — detailed customization of `beautiful.init()` in section 2
- [Carousel tutorial](/docs/tutorials/carousel) — the SomeWM-specific layout enabled by default in section 7
- [Basics tutorial](/docs/tutorials/basics) — first run, copying the default config
