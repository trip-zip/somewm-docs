---
sidebar_position: 4
title: Autostart Applications
description: "awful.spawn.once runs a command once per session, spawn.single_instance once per running process, spawn.with_shell when a shell is needed. When to use a systemd user service instead."
---

# Autostart Applications

A plain `awful.spawn("nm-applet")` at the end of `rc.lua` runs again on every reload and leaves duplicates. Three variants fix that:

| Call | Runs | Use for |
| --- | --- | --- |
| `awful.spawn.once(cmd)` | once per session, by command string; a reload skips it | tray applets, agents |
| `awful.spawn.single_instance(cmd)` | only if no client of that command is running | apps you restart by hand or that may crash |
| `awful.spawn.with_shell(cmd)` | through `$SHELL -c` (`/bin/sh` if unset), every time | pipes, `&&`, redirects, `sleep` |

`once` and `single_instance` match the spawned client through startup notification, which a shell does not pass on, so a shell command guards itself:

```lua
awful.spawn.with_shell("pgrep -x swaybg > /dev/null || swaybg -i ~/.wallpaper.jpg -m fill")
```

A command that needs the session fully up waits a moment:

```lua
awful.spawn.with_shell("sleep 2 && waybar")
gears.timer.start_new(2, function() awful.spawn.once("waybar"); return false end)
```

## A typical block

```lua
awful.spawn.once("nm-applet")
awful.spawn.once("blueman-applet")
awful.spawn.once("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")   -- or lxpolkit, polkit-kde
awful.spawn.once("gnome-keyring-daemon --start --components=secrets")
awful.spawn.once("wl-paste --watch cliphist store")
awful.spawn.single_instance("swaybg -i " .. os.getenv("HOME") .. "/.wallpaper.jpg -m fill")
```

Notifications need no daemon: `naughty` is one. Running dunst or mako alongside it takes the D-Bus name away.

Environment variables for a spawned app go in the command, `awful.spawn.with_shell("GTK_THEME=Adwaita:dark my-gtk-app")`. `os.execute("export ...")` sets nothing: it runs in a child shell that exits. Session-wide variables belong in `~/.profile` or `environment.d`.

## systemd user services

For restart on crash, ordering between services, or `systemctl` control, a user unit beats a spawn:

```ini
# ~/.config/systemd/user/my-app.service
[Unit]
Description=My Application
After=graphical-session.target

[Service]
ExecStart=/usr/bin/my-app
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
```

```bash
systemctl --user enable --now my-app.service
```

`awful.spawn("systemctl --user restart my-app.service")` from `rc.lua` restarts it on reload.

## When an app does not start

`which my-app` and running it from a terminal come first. The compositor's log, `journalctl --user -u somewm.service` under `somewm-session`, has the spawn error. An X11 app runs through XWayland and needs no `DISPLAY` set by you; a Wayland app needs `WAYLAND_DISPLAY`, which every spawned process inherits.

[awful.spawn upstream](https://awesomewm.org/doc/api/libraries/awful.spawn.html) has the full API.
