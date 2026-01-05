---
sidebar_position: 4
title: Autostart Applications
description: Start apps automatically when SomeWM launches
---

# Autostart Applications

Most setups need background services started automatically: clipboard managers, notification daemons, authentication agents. SomeWM provides several ways to autostart applications.

## Basic Autostart

Add spawn calls at the end of your `rc.lua`:

```lua
-- Start applications when SomeWM launches
awful.spawn("nm-applet")
awful.spawn("blueman-applet")
awful.spawn("pasystray")
```

**Problem:** These run every time you reload your config, spawning duplicates.

## spawn.once - Run Once Per Session

Use `awful.spawn.once` to only run on initial startup, not on config reload:

```lua
-- Only starts once, ignores config reloads
awful.spawn.once("nm-applet")
awful.spawn.once("blueman-applet")
awful.spawn.once("pasystray")
```

`spawn.once` tracks commands by their command string. If you reload config, it won't spawn duplicates.

## spawn.single_instance - Check for Existing Process

`spawn.single_instance` checks if the process is already running:

```lua
-- Checks if already running before spawning
awful.spawn.single_instance("picom")
awful.spawn.single_instance("dunst")
```

The difference from `spawn.once`:
- `spawn.once` - tracks what was spawned this session
- `spawn.single_instance` - checks actual running processes

Use `single_instance` for apps you might restart manually, or that might crash and need re-launching.

## spawn.with_shell - For Complex Commands

Some commands need shell features (pipes, redirects, `&&`, `||`):

```lua
-- Commands that need shell interpretation
awful.spawn.with_shell("sleep 2 && picom")
awful.spawn.with_shell("xdg-user-dirs-update && nitrogen --restore")

-- Redirect output to a log file
awful.spawn.with_shell("my-app > ~/.cache/my-app.log 2>&1")
```

Combine with once for one-time shell commands:

```lua
-- Only run once, with shell
awful.util.spawn_with_shell("sleep 3 && nitrogen --restore")
```

## Delayed Startup

Some apps need the compositor fully running before they start:

```lua
-- Wait for SomeWM to be ready
gears.timer.start_new(2, function()
    awful.spawn.once("polybar")
    return false  -- Don't repeat
end)

-- Or use spawn.with_shell with sleep
awful.spawn.with_shell("sleep 2 && polybar")
```

## Complete Autostart Pattern

Here's a robust autostart section for your `rc.lua`:

```lua
-- Autostart applications
-- Place this at the end of rc.lua

-- Immediate starts (no shell needed)
awful.spawn.once("nm-applet")
awful.spawn.once("blueman-applet")
awful.spawn.once("dunst")  -- Or let naughty handle notifications

-- Apps that need shell or delay
awful.spawn.with_shell("sleep 1 && nitrogen --restore")

-- Single-instance apps (restart-friendly)
awful.spawn.single_instance("picom", { silent = true })

-- Authentication agent (one of these)
awful.spawn.once("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
-- or: awful.spawn.once("lxpolkit")

-- SSH/GPG agent (if not started by your session)
awful.spawn.with_shell("eval $(ssh-agent) && ssh-add")
```

## Environment Variables

Set environment variables before spawning apps:

```lua
-- Set environment variable
os.execute("export MY_VAR=value")

-- Or use spawn.with_shell
awful.spawn.with_shell("export GTK_THEME=Adwaita:dark && my-gtk-app")
```

For system-wide variables, use `~/.profile` or `~/.pam_environment` instead.

## Systemd User Services Alternative

For more complex scenarios, consider systemd user services:

### When to Use systemd

- Apps that need restart-on-crash
- Apps with dependencies on other services
- Apps that should start before or after SomeWM
- When you want `systemctl` control

### Creating a User Service

Create `~/.config/systemd/user/my-app.service`:

```ini
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

Enable and start:

```bash
systemctl --user enable my-app.service
systemctl --user start my-app.service
```

### Controlling Services from rc.lua

```lua
-- Start a systemd user service
awful.spawn("systemctl --user start my-app.service")

-- Restart on config reload
awful.spawn("systemctl --user restart my-app.service")
```

## Common Autostart Apps

### System Tray Apps

```lua
awful.spawn.once("nm-applet")           -- Network
awful.spawn.once("blueman-applet")      -- Bluetooth
awful.spawn.once("pasystray")           -- PulseAudio/PipeWire
awful.spawn.once("cbatticon")           -- Battery
```

### Desktop Utilities

```lua
awful.spawn.once("dunst")               -- Notifications (if not using naughty)
awful.spawn.once("clipit")              -- Clipboard manager
awful.spawn.once("flameshot")           -- Screenshots
awful.spawn.single_instance("picom")    -- Compositor effects
```

### Authentication

```lua
-- Polkit agent (pick one)
awful.spawn.once("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
awful.spawn.once("/usr/lib/polkit-kde-authentication-agent-1")
awful.spawn.once("lxpolkit")

-- Keyring
awful.spawn.once("gnome-keyring-daemon --start --components=secrets")
```

### Wallpaper

```lua
-- Using nitrogen
awful.spawn.with_shell("sleep 1 && nitrogen --restore")

-- Using feh
awful.spawn.with_shell("feh --bg-fill ~/.wallpaper.jpg")

-- Using swaybg (Wayland-native)
awful.spawn.once("swaybg -i ~/.wallpaper.jpg -m fill")
```

## Troubleshooting

### App Starts Multiple Times

Use `spawn.once` or `spawn.single_instance` instead of plain `spawn`:

```lua
-- Wrong: starts on every reload
awful.spawn("my-app")

-- Right: only once per session
awful.spawn.once("my-app")
```

### App Doesn't Start

Check if the binary exists and is executable:

```bash
which my-app
my-app  # Try running manually
```

Check SomeWM logs:

```bash
journalctl --user -f
# Or check: ~/.local/share/somewm/somewm.log
```

### Spawned App Can't Find Display

Ensure the app supports Wayland or is running through XWayland:

```lua
-- For X11 apps that need DISPLAY
awful.spawn.with_shell("export DISPLAY=:0 && my-x11-app")

-- For Wayland-native apps
awful.spawn.once("my-wayland-app")
```

## See Also

- **[CLI Control](/guides/cli-control)** - Control SomeWM from scripts
- **[AwesomeWM Spawn Docs](https://awesomewm.org/doc/api/libraries/awful.spawn.html)** - Full spawn API
