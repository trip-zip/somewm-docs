---
sidebar_position: 4
title: Upgrade from 1.4 to 2.0
description: Adapt your SomeWM 1.4 configuration, test it with SomeWM 2.0, and switch sessions.
---

# Upgrade from 1.4 to 2.0

SomeWM 2.0 removes deprecated APIs and queues some compositor-generated signals. Keep your configuration's structure and update the affected calls, including those in third-party modules.

## 1. Preserve your working setup

Record the installed version and paths, and keep the package or source revision needed to reinstall it:

```bash
somewm --version
command -v somewm
command -v somewm-client
```

Copy your whole configuration, including modules and themes. Change `config_source` if you use another path:

```bash
config_source="${XDG_CONFIG_HOME:-$HOME/.config}/somewm"
upgrade_dir=$(mktemp -d "$HOME/somewm-upgrade-2.0.XXXXXX")
cp -aL "$config_source" "$upgrade_dir/config-1.4"
cp -aL "$upgrade_dir/config-1.4" "$upgrade_dir/config-2.0"
printf 'Upgrade files: %s\n' "$upgrade_dir"
```

Keep this shell open or save the printed path. `cp -aL` copies symlink targets so edits do not change the originals.

In the working copy, update hard-coded theme and module paths and remove vendored 1.4 standard libraries. Disable autostart commands that would duplicate services or change shared settings. A nested session shares your user account and files.

## 2. Install 2.0 and check your configuration

Save your work and install the matching compositor, Lua libraries and `somewm-client` together. Use your package manager's 2.0 package or the release tag in [Installation](installation.md).

Check `somewm --version` and the executable paths again. If they still select 1.4, fix `PATH` and your session launcher.

An existing 1.4 process keeps running its old executable. Avoid reloading it after replacing its installed Lua libraries. Test in a new nested instance, then start a fresh session.

```bash
somewm --check "$upgrade_dir/config-2.0/rc.lua"
```

The check finds syntax errors, missing modules and known compatibility patterns. It does not prove API or signal compatibility. Review the changes below and test at runtime.

## 3. Update affected configuration

Check these uses in both your config and its imported modules.

### Notifications

Use `naughty.notification` and the `message` property:

```lua
-- 1.4
naughty.notify { title = "Hello", text = "Ready" }

-- 2.0
naughty.notification { title = "Hello", message = "Ready" }
```

The [notification reference](../reference/naughty/index.md#removed-functions) lists the functional helpers replaced by object methods and the `naughty.suspended` property.

The constructor still accepts `text` as an alias, but assigning `n.text` does not update the message.

### Client lifecycle handlers

Replace connections to `manage` and `unmanage` with `request::manage` and `request::unmanage`:

```lua
client.connect_signal("request::manage", function(c, context, hints)
    -- Your existing new-client logic goes here.
end)
```

Connections to the old names warn and never run. Check scratchpads, placement, titlebars and cleanup handlers. See [client lifecycle](../guides/react-to-client-lifecycle.md) for rule timing.

### Wallpapers, modules, and helper functions

| If your configuration uses… | Change it to… |
|---|---|
| `gears.wallpaper` | `awful.wallpaper`, adapting the arguments to its API |
| `awful.rules` | `ruled.client`. See [client rules](../guides/client-rules.md) for rule registration |
| `awful.util` | The specific function in `gears.*` or `awful.*`. See replacements below |
| `awful.wibox` | `awful.wibar` |
| `awful.ewmh` | `awful.permissions` |
| `awful.widget.graph`, `awful.widget.progressbar`, `awful.widget.textclock` | The corresponding `wibox.widget.*` modules |
| `wibox.widget.background` | `wibox.container.background` |
| `wibox.layout.margin`, `constraint`, `scroll`, `mirror`, `rotate` | The corresponding `wibox.container.*` modules |
| Functional tag/client wrappers such as `awful.tag.setmwfact`, `awful.tag.viewonly`, or `awful.client.floating.toggle` | Object properties and methods such as `t.master_width_factor`, `t:view_only()`, or `c.floating = not c.floating` |

Common `awful.util` replacements:

| Removed | Replacement |
| --- | --- |
| `table.join` | `gears.table.join` |
| `get_cache_dir` | `gears.filesystem.get_cache_dir` |
| `eval` | `function(s) return assert((loadstring or load)(s))() end` as the prompt's `exe_callback` |
| `escape`, `unescape` | `gears.string.xml_escape`, `gears.string.xml_unescape` |
| `mkdir` | `gears.filesystem.make_directories` |
| `get_rectangle_in_direction` | `gears.geometry.rectangle.get_in_direction` |
| `getdir("config")`, `getdir("cache")` | `gears.filesystem.get_xdg_config_home() .. "somewm/"`, `gears.filesystem.get_cache_dir()` |
| `restart` | `awesome.restart()` |
| `geticonpath` | `menubar.utils.lookup_icon`, with its supported arguments |
| `checkfile`, `shell` | No equivalent interface |

### API levels and less common aliases

`awesome.api_level` is gone. Reading it returns `nil`, so numerical comparisons fail. Remove API-level selection and adapt code to 2.0's supported APIs. It cannot be used to select 1.4 behaviour in 2.0.

The behaviours formerly selected by API level are fixed at level 4: `awful.autofocus` loads without a warning, `awful.permissions` does not automatically connect `mouse::enter` to `request::autoactivate`, and `wibox.widget.base.make_widget` defaults `enable_properties` to `false`. If you relied on another level, review focus-follows-mouse and custom widget construction explicitly.

#### Other removed APIs {#other-removed-apis}

| Removed | Action |
| --- | --- |
| `<class>.add_signal`, `gears.object.add_signal` | Remove declarations. Connect handlers directly |
| The `.data` alias on C API objects | Use `._private` for the same per-object table. Leave unrelated application fields named `data` alone |
| `_key`, `_timer` | Use `awful.key` and `gears.timer` |
| `awful.ipc.remove_subscriber` | Remove the call. The compositor owns subscriber connections |
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

Compositor-generated focus, geometry and pointer notifications can now be queued. A handler may not have run by the next line after an operation, and consecutive pointer moves can be combined. Review code that relies on handlers updating cached state immediately.

Lua-emitted signals and requests such as `request::manage`, `request::unmanage` and `request::geometry` stay synchronous. See [Signals](../concepts/signals.md#dispatch-model) for the distinction.

The default desktop also changed. Your config does not need to adopt its appearance or bindings. If you see an unexpected desktop, check the log for a config error and fallback.

## 4. Test your working copy

Start a named nested instance with the installed 2.0 commands:

```bash
somewm --check "$upgrade_dir/config-2.0/rc.lua"
somewm-client test start \
    --name upgrade-2-0 --config "$upgrade_dir/config-2.0/rc.lua"
somewm-client test logs --name upgrade-2-0
somewm-client test eval --name upgrade-2-0 'return awesome.conffile'
somewm-client test run --name upgrade-2-0 -- foot
```

Add `--host x11` when testing from X11. Replace `foot` with your terminal. Confirm the config path, your expected bars and tags, and the absence of config-load errors or removed-API warnings.

Test rules, placement, titlebars and scratchpads by opening and closing clients. Exercise tags, layouts, focus, notifications, widget updates and shortcuts. After editing, reload only the test instance and repeat:

```bash
somewm-client test reload --name upgrade-2-0
```

See [nested testing](../guides/testing-with-nested-compositor.md) if the host intercepts shortcuts. Physical outputs, suspend/resume and locking need a real session on your hardware.

Save logs before stopping, which removes the instance directory:

```bash
somewm-client test logs --name upgrade-2-0 > "$upgrade_dir/test-2.0.log"
somewm-client test stop --name upgrade-2-0
```

## 5. Switch sessions

Save your work. Put the tested config at your [session's config path](first-launch.md#configuration-locations), preserving the original for rollback. Update paths into the temporary copy and restore the autostart commands you disabled.

Log out and start a fresh SomeWM session. Lua reload does not replace the 1.4 executable. Check the active version with `somewm-client version`, then verify monitors, input, locking and suspend/resume.

## If you need to return to 1.4

Keep the 2.0 config and logs. From a TTY or another desktop:

1. Reinstall your recorded 1.4 package or source revision, including its matching Lua libraries, using the original installation method.
2. Restore the original configuration directory or dotfiles revision from step 1. Keep the 2.0 working copy separately.
3. Verify the executable path and version, then start a fresh SomeWM session.

Restoring only the old `rc.lua` while leaving 2.0 installed can reintroduce calls to removed APIs. Restore the compositor and configuration together.
