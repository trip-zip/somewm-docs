---
sidebar_position: 4
title: Upgrade from 1.4 to 2.0
description: Adapt your SomeWM 1.4 configuration, test it with SomeWM 2.0, and switch sessions.
---

# Upgrade from 1.4 to 2.0

This guide is for an existing SomeWM 1.4 installation. SomeWM 2.0 develops its APIs independently of AwesomeWM and removes deprecated APIs that 1.4 still supports. You can keep your configuration's structure and adapt the affected calls; you do not need to replace it with the new default config.

Back up your configuration, install SomeWM 2.0 through your usual installation method, then check and test your configuration before starting a new session. The commands below use the installed `somewm` and `somewm-client`.

## 1. Preserve your working setup

Record your current version and executable path:

```bash
somewm --version
command -v somewm
command -v somewm-client
```

Keep the package or source revision needed to reinstall that exact 1.4 version. A configuration backup alone cannot restore the compositor and its Lua libraries.

Copy your whole configuration, including local modules and themes, into a backup and a separate working copy. These commands assume `~/.config/somewm`; change `config_source` if you use `~/.config/awesome`, a custom `-c` path, or another location.

```bash
config_source="$HOME/.config/somewm"
upgrade_dir=$(mktemp -d "$HOME/somewm-upgrade-2.0.XXXXXX")
cp -aL "$config_source" "$upgrade_dir/config-1.4"
cp -aL "$upgrade_dir/config-1.4" "$upgrade_dir/config-2.0"
printf 'Upgrade files: %s\n' "$upgrade_dir"
```

Keep this shell open for the following commands, or save the printed path and set `upgrade_dir` to it in a new shell. The copies dereference symlinks so editing a copied file does not edit its original target.

Review hard-coded paths and module search paths in the working copy. A theme or `require()` that still points into your live configuration defeats the separation. Point configuration-specific imports and assets at the working copy, and avoid loading a vendored 1.4 copy of SomeWM's standard libraries.

Before testing, disable autostart commands in the working copy that would launch duplicate background services or change shared desktop settings. A nested compositor isolates its windows and IPC socket; it does not isolate arbitrary commands in your Lua configuration from your user account.

## 2. Install 2.0 and check your configuration

Save your work, then install SomeWM 2.0 using the same method you used for 1.4. If you use a package manager, select its 2.0 package. If you install globally from source, follow [Installation](installation.md) using the `v2.0.0` release tag. Install the matching compositor, Lua libraries, and `somewm-client` together.

Verify that the installed command reports a 2.0 version:

```bash
somewm --version
command -v somewm
command -v somewm-client
```

If it still reports 1.4, check whether an older installation takes precedence on `PATH`. Your session launcher must also use the 2.0 installation.

An already-running 1.4 session continues running its existing executable. Avoid reloading that session after installation: its Lua library files may now belong to 2.0. Use a new nested instance for testing, then log out and start a fresh session when your configuration is ready.

Run the compatibility check on your working copy before making changes:

```bash
somewm --check "$upgrade_dir/config-2.0/rc.lua"
```

Use the report as a starting point: it checks for syntax errors, missing local modules, and X11-related patterns. Fix reported issues and rerun it as you edit. A successful check does not establish that every API call or signal handler works in 2.0, so also review the changes below and test the configuration at runtime.

## 3. Update affected configuration

Review your working copy and third-party modules for the following changes. The release's [changelog](https://github.com/trip-zip/somewm/blob/v2.0.0/CHANGELOG.md) provides the source record for this checklist.

### Notifications

Replace the old notification constructor:

```lua
-- 1.4
naughty.notify { title = "Hello", text = "Ready" }

-- 2.0
naughty.notification { title = "Hello", message = "Ready" }
```

The [notification reference](../reference/naughty/index.md#removed-functions) lists the functional helpers replaced by object methods and the `naughty.suspended` property.

The `text` constructor argument still works as an alias for `message`; assigning `n.text` is not how to update a notification. Use `n.message`.

### Client lifecycle handlers

Replace connections to `manage` and `unmanage` with `request::manage` and `request::unmanage`:

```lua
client.connect_signal("request::manage", function(c, context, hints)
    -- Your existing new-client logic goes here.
end)
```

Connections to the old names warn and never run. Check scratchpads, placement, titlebars, and cleanup handlers as well as your main `rc.lua`. The [client lifecycle guide](../guides/react-to-client-lifecycle.md) explains when the supported handlers run relative to client rules.

### Wallpapers, modules, and helper functions

| If your configuration uses… | Change it to… |
|---|---|
| `gears.wallpaper` | `awful.wallpaper`; adapt the call to its API, rather than only changing the module name |
| `awful.rules` | `ruled.client`; see [client rules](../guides/client-rules.md) for rule registration |
| `awful.util` | The specific function in `gears.*` or `awful.*`; see examples below |
| `awful.wibox` | `awful.wibar` |
| `awful.ewmh` | `awful.permissions` |
| `awful.widget.graph`, `awful.widget.progressbar`, `awful.widget.textclock` | The corresponding `wibox.widget.*` modules |
| `wibox.widget.background` | `wibox.container.background` |
| `wibox.layout.margin`, `constraint`, `scroll`, `mirror`, `rotate` | The corresponding `wibox.container.*` modules |
| Functional tag/client wrappers such as `awful.tag.setmwfact`, `awful.tag.viewonly`, or `awful.client.floating.toggle` | Object properties and methods such as `t.master_width_factor`, `t:view_only()`, or `c.floating = not c.floating` |

Common `awful.util` replacements include:

```lua
local gtable = require("gears.table")
local gfilesystem = require("gears.filesystem")
local gstring = require("gears.string")

-- awful.util.table.join(...) -> gtable.join(...)
-- awful.util.get_cache_dir() -> gfilesystem.get_cache_dir()
-- awful.util.mkdir(path) -> gfilesystem.make_directories(path)
-- awful.util.escape(text) -> gstring.xml_escape(text)
```

For a Lua evaluation prompt using `awful.util.eval`, replace its callback with:

```lua
exe_callback = function(s)
    return assert((loadstring or load)(s))()
end,
```

This belongs in your prompt options table. Other `awful.util` members do not all have direct replacements; review the replacements below for any remaining calls.

Additional `awful.util` replacements:

| Removed | Replacement |
| --- | --- |
| `escape`, `unescape` | `gears.string.xml_escape`, `gears.string.xml_unescape` |
| `mkdir` | `gears.filesystem.make_directories` |
| `get_rectangle_in_direction` | `gears.geometry.rectangle.get_in_direction` |
| `getdir("config")`, `getdir("cache")` | `gears.filesystem.get_xdg_config_home() .. "somewm/"`, `gears.filesystem.get_cache_dir()` |
| `restart` | `awesome.restart()` |
| `geticonpath` | `menubar.utils.lookup_icon`; check the supported arguments in the module |
| `checkfile`, `shell` | No replacement with the same interface; remove the dependency on these fields |

### API levels and less common aliases

`awesome.api_level` is gone. Reading it returns `nil`, so numerical comparisons fail. Remove API-level selection and adapt code to 2.0's supported APIs. It cannot be used to select 1.4 behaviour in 2.0.

The behaviours formerly selected by API level are fixed at level 4: `awful.autofocus` loads without a warning, `awful.permissions` does not automatically connect `mouse::enter` to `request::autoactivate`, and `wibox.widget.base.make_widget` defaults `enable_properties` to `false`. If you relied on another level, review focus-follows-mouse and custom widget construction explicitly.

#### Other removed APIs {#other-removed-apis}

| Removed | Action |
| --- | --- |
| `<class>.add_signal`, `gears.object.add_signal` | Remove declarations; signals do not need declaring before connecting handlers |
| The `.data` alias on C API objects | Use `._private` for the same per-object table; leave unrelated application fields named `data` alone |
| `_key`, `_timer` | Use `awful.key` and `gears.timer` |
| `awful.ipc.remove_subscriber` | Remove the call; the compositor owns subscriber connections |
| `gears.debug.deprecate_class` | Remove API-level proxy logic |

`gears.debug.deprecate` prints a warning without consulting `args.deprecated_in`, emitting `debug::deprecation`, or routing deprecations through `debug::error`. Real Lua errors still use `debug::error`.

#### Removed deprecated aliases {#removed-deprecated-aliases}

| Removed | Replacement |
| --- | --- |
| `awful.screen.getdistance_sq(s, x, y)` | `s:get_square_distance(x, y)` |
| `awful.screen.padding(s, p)` | The `screen.padding` property |
| `awful.mouse.client.dragtotag.border(c)` | Set `awful.mouse.snap.drag_to_tag_enabled`, then use `awful.mouse.client.move(c)` |
| `awful.mouse.client.corner(c, corner)` | `awful.placement.closest_corner` |
| `awful.mouse.client_under_pointer()` | `mouse.current_client` |
| `awful.key.execute(modifiers, key)` | `awful.keyboard.emulate_key_combination(modifiers, key)` |
| `menubar.get(s)` and calling `menubar(s)` | `menubar.refresh(s)` |
| `beautiful.theme_assets.recolor_titlebar_normal(t, c)`, `recolor_titlebar_focus(t, c)` | `beautiful.theme_assets.recolor_titlebar(t, c, "normal")` or `"focus"` |
| `gears.filesystem.mkdir(dir)` | `gears.filesystem.make_directories(dir)` |
| `gears.filesystem.get_dir("config")`, `get_dir("cache")` | `gears.filesystem.get_xdg_config_home() .. "somewm/"`, `gears.filesystem.get_cache_dir()` |
| `wibox.layout.ratio:ajust_ratio`, `:ajust_widget_ratio` | `:adjust_ratio`, `:adjust_widget_ratio` |
| `wibox.layout.grid:get_dimension()` | The `row_count` and `column_count` properties |
| `naughty.notification.run` and `.destroy` properties | Connect to `invoked` and `destroyed` signals |
| Client `marked`, `unmarked` signals | Connect to `property::marked` and inspect the property |
| Textbox `property::align` signal | Connect to `property::halign` |
| `naughty.notificationClosedReason` | `naughty.notification_closed_reason` |
| `notification_closed_reason.dismissedByUser`, `.dismissedByCommand` | `.dismissed_by_user`, `.dismissed_by_command` |

Some deprecated names were already inert. Assignments to old grid properties such as `forced_num_rows`, `min_cols_size` and `horizontal_spacing`, background `shape_border_width` and `shape_border_color`, notification `text`, or textbox `align` do not update the corresponding live properties. Use the current API names. The notification constructor still accepts `text` as an argument, as described above.

Deprecation does not always mean removal: `beautiful.xresources.get_dpi`, `wibox.container.background.bgimage`, `wibox.layout.grid:add_widget_at`, `menubar.icon_theme` and `menubar.index_theme` remain available in 2.0.

### Signal timing and the default config

Some C-generated signals, including geometry and focus notifications, are now queued before delivery to Lua. Pointer motion can coalesce into one event per object per delivery. Code that assumes a handler has already updated cached state immediately after an operation needs review. The [signal reference](../reference/signals.md) describes which signals are queued and which remain synchronous; `request::manage`, `request::unmanage`, and `request::geometry` remain synchronous.

Test custom focus history, geometry-dependent widgets, mouse handlers, and layouts in particular. Avoid blanket changes to every signal handler: investigate the operations that depend on immediate delivery.

The shipped default configuration also changed. Your adapted 1.4 configuration does not need to adopt its layout or bindings. If you unexpectedly see a different desktop, check which configuration loaded and whether an error caused fallback to the default.

## 4. Test your working copy

After updating the configuration, rerun the check and start a named nested instance with the installed 2.0 commands:

```bash
somewm --check "$upgrade_dir/config-2.0/rc.lua"
somewm-client test start \
    --name upgrade-2-0 --config "$upgrade_dir/config-2.0/rc.lua"
```

The nested instance lets you exercise runtime calls and signal handlers in a window inside your current desktop. If you are testing from an X11 session, add `--host x11` to the start command.

Confirm the config path in the startup output, then inspect the log and open a terminal:

```bash
somewm-client test logs --name upgrade-2-0
somewm-client test eval --name upgrade-2-0 'return awesome.conffile'
somewm-client test run --name upgrade-2-0 -- alacritty
```

Replace `alacritty` with your terminal. Confirm that your own bars, tags, and bindings appear and that the log contains no config-load failure or removed-API warnings. An IPC response alone does not prove your config loaded successfully.

Exercise the parts of your desktop you use:

- Open and close clients; verify rules, placement, titlebars, and scratchpad cleanup.
- Switch tags and layouts; check focus cycling, floating toggles, and geometry-dependent widgets.
- Trigger notifications, then dismiss them and toggle suspension if configured.
- Check wallpapers, widget updates, theme assets, and keyboard/mouse bindings.
- Reload the working config and repeat the operations that register handlers or timers.

After editing the working copy, reload only the named test instance:

```bash
somewm-client test reload --name upgrade-2-0
```

See [nested compositor testing](../guides/testing-with-nested-compositor.md) if the outer compositor intercepts your shortcuts. Physical output configuration, suspend/resume, and session locking need verification in a real 2.0 session; nesting does not establish that they work on your hardware.

Save any logs you need before stopping, because stopping removes the instance's state directory:

```bash
somewm-client test logs --name upgrade-2-0 > "$upgrade_dir/test-2.0.log"
somewm-client test stop --name upgrade-2-0
```

## 5. Switch sessions

Once the working config behaves as expected, save your work in the current session.

Put the tested configuration at the path your session loads, preserving the original directory or dotfiles revision for rollback. Update any paths that pointed into the temporary working copy, and restore the autostart commands you disabled for testing. See [configuration search order](first-launch.md#configuration-locations) if you need to check which path will be used.

Log out and start a new SomeWM session. A Lua reload through `awesome.restart()` does not replace the running 1.4 executable with 2.0. Verify the active compositor with `somewm-client version`, then check your monitors, input devices, locking, and suspend/resume in the real session.

## If you need to return to 1.4

Save the failing 2.0 config and logs for diagnosis. From a TTY or another desktop session:

1. Reinstall your recorded 1.4 package or source revision, including its matching Lua libraries, using the original installation method.
2. Restore the original configuration directory or dotfiles revision from step 1. Keep the 2.0 working copy separately.
3. Verify the executable path and version, then start a fresh SomeWM session.

Restoring only the old `rc.lua` while leaving 2.0 installed can reintroduce calls to removed APIs. Restore the compositor and configuration together.
