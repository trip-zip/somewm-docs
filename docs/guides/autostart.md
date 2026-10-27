---
sidebar_position: 4
title: Start applications at login
description: Start apps automatically when SomeWM launches
---

# Start applications at login

Add startup commands near the end of `rc.lua`. Use `awful.spawn` for an executable and arguments, or `awful.spawn.with_shell` when the command needs shell syntax.

## Basic Autostart

<span id="a-typical-block" />

```lua
local awful = require("awful")
awful.spawn({ "nm-applet" })
```

This runs on every config load, including a Lua reload. For a background service, use its own single-instance support or a service manager to avoid duplicates.

## Avoid Duplicate Services

<span id="systemd-user-services" />

A systemd user service gives a background application one managed process. Create `~/.config/systemd/user/my-app.service`, replacing the executable path:

```ini
[Unit]
Description=My background application

[Service]
ExecStart=/usr/bin/my-app
Restart=on-failure
RestartSec=5
```

Start it from `rc.lua`:

```lua
awful.spawn({ "systemctl", "--user", "start", "my-app.service" })
```

Starting an already active service does not launch another process. GUI services also need the session's display variables in the user manager's environment. If your session launcher does not import them, run this from a terminal inside SomeWM before starting the service:

```bash
systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP
systemctl --user start my-app.service
systemctl --user status my-app.service
journalctl --user -u my-app.service
```

Import only variables set in your session. Tie service shutdown to your session manager if the application should stop on logout.

## Window-Based Spawn Helpers

`awful.spawn.once` and `awful.spawn.single_instance` track application windows through startup notification or a supplied client matcher. They do not search the process table. They are unsuitable as general duplicate guards for tray apps, agents or shell commands.

For a windowed application, supply a matcher using the class reported by `somewm-client client list`:

```lua
awful.spawn.single_instance("firefox", nil, function(c)
    return c.class == "firefox"
end)
```

`once` also records that it launched a command in the current Lua state. That state is rebuilt on reload, so do not assume it prevents a background service from starting again. `single_instance` permits another launch after the matched window closes. Calling it repeatedly before a window appears can still launch duplicates.

## Shell Commands and Delays

Use a shell for redirection, pipes or shell operators:

```lua
awful.spawn.with_shell("my-app > ~/.cache/my-app.log 2>&1")
```

For a one-time delay within each config load:

```lua
local gears = require("gears")
gears.timer.start_new(2, function()
    awful.spawn({ "systemctl", "--user", "start", "my-app.service" })
    return false
end)
```

## Environment Variables

Pass environment variables to the application you launch:

```lua
awful.spawn({ "env", "GTK_THEME=Adwaita:dark", "my-gtk-app" })
```

Running `export` in a separate shell cannot change SomeWM's environment or that of later launches. Set session-wide variables in the launcher that starts SomeWM. Inherit `DISPLAY` and `WAYLAND_DISPLAY` from the session rather than hardcoding display numbers.

## Choose Session Services

- Start one notification provider. The default config already uses `naughty`.
- Use a Wayland clipboard manager, or one that explicitly supports your session.
- Start one Polkit authentication agent at the path supplied by your distribution.
- Let your session manager initialise SSH and keyring agents when available.
- Set wallpapers through SomeWM's [wallpaper API](multi-monitor.md#different-wallpaper-per-screen). X11 root-window tools such as `feh` and `nitrogen` do not set the Wayland desktop background.
- SomeWM renders its own effects. Do not start `picom` for SomeWM windows.

## Troubleshooting

<span id="when-an-app-does-not-start" />

Run the application in a terminal first. Check its output, then the service log or the terminal that launched SomeWM. For duplicate processes, check both `rc.lua` and your session manager's autostart entries.

## See Also

- [CLI Control](cli-control.md)
- [AwesomeWM Spawn API](https://awesomewm.org/doc/api/libraries/awful.spawn.html)
