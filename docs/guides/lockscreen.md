---
sidebar_position: 9
title: Lockscreen
description: Enable the bundled lockscreen, theme it, pick the screen it draws on, add idle timeouts and DPMS, inhibit idle, lock on suspend, build a custom lock UI on the raw API, or use swaylock.
---

import SomewmOnly from '@site/src/components/SomewmOnly';

# Lockscreen <SomewmOnly />

```lua
require("lockscreen").init()     -- after beautiful.init()
```

Mod4 + Shift + Escape locks; the password and Return unlock. `somewm-client lock` locks from a shell once `init()` has registered the surface.

## Appearance and placement

`theme.lockscreen_*` variables style it: `bg_color`, `fg_color`, `input_bg`, `border_color`, `error_color`, `font`, `font_large`, `wallpaper`, `wallpaper_overlay`. The `init` table overrides them and adds the formats and the screen:

```lua
require("lockscreen").init({
    bg_color = "#1e1e2e", fg_color = "#cdd6f4", error_color = "#f38ba8",
    wallpaper = "/home/you/wallpapers/spaceman.jpg", wallpaper_overlay = "#00000080",
    clock_format = "%I:%M %p", date_format = "%a, %b %d",
    lock_screen = function() return awful.screen.focused() end,   -- or screen[1]; default screen.primary
})
```

The image is letterboxed and centred the way `awful.wallpaper` does it, so a 16:9 picture on a 3:2 panel leaves `bg_color` above and below. Other screens get the same image, dimmed, or a plain `bg_color` cover.

## Idle, DPMS, suspend

```lua
awesome.set_idle_timeout("dpms", 180, function() awesome.dpms_off() end)
awesome.set_idle_timeout("lock", 300, function() awesome.lock() end)
awesome.clear_idle_timeout("dpms")        -- or clear_all_idle_timeouts()

awesome.connect_signal("logind::prepare_sleep", function(going_to_sleep)
    if going_to_sleep then awesome.lock() end
end)

awful.key({ modkey }, "F7", awesome.dpms_off, { description = "displays off", group = "screen" })
```

Each named timeout fires once per idle period and resets on input; displays wake on input.

`awesome.idle_inhibit = true` suppresses the timeouts from Lua. It is OR-ed with protocol inhibitors from clients such as video players, and `awesome.idle_inhibited` is the combined state, with `property::idle_inhibited` on change and `awesome.inhibitors` listing the clients:

```lua
client.connect_signal("property::fullscreen", function()
    local any = false
    for _, c in ipairs(client.get()) do
        if c.fullscreen then any = true; break end     -- add `and c.class == "firefox"` to narrow it
    end
    awesome.idle_inhibit = any
end)

awful.key({ modkey }, "F8", function() awesome.idle_inhibit = not awesome.idle_inhibit end,
    { description = "toggle idle inhibition", group = "screen" })

local idle_widget = wibox.widget.textbox()
local function update()
    local i = awesome.inhibitors
    idle_widget.text = awesome.idle_inhibited and ("  " .. (i[1] and i[1].client and i[1].client.class or "")) or " "
end
update()
awesome.connect_signal("property::idle_inhibited", update)
```

## A custom lock UI

The raw API: one lock surface, a cover per other screen, and two signals.

```lua
local lock_wb = wibox { visible = false, ontop = true, type = "desktop" }
awesome.set_lock_surface(lock_wb)

for s in screen do
    if s ~= screen.primary then
        awesome.add_lock_cover(wibox {
            screen = s, visible = false, ontop = true, bg = "#000000",
            x = s.geometry.x, y = s.geometry.y, width = s.geometry.width, height = s.geometry.height,
        })
    end
end

awesome.connect_signal("lock::activate", function()
    lock_wb.visible = true
    local password = ""
    awful.keygrabber {
        autostart = true,
        keypressed_callback = function(_, _, key)
            if key == "Return" then
                awesome.authenticate(password)
                awesome.unlock()
                password = ""
            elseif key == "BackSpace" then
                password = password:sub(1, -2)
            elseif #key == 1 then
                password = password .. key
            end
        end,
    }
end)

awesome.connect_signal("lock::deactivate", function() lock_wb.visible = false end)
```

`awesome.unlock()` only succeeds after `awesome.authenticate()` passed PAM, which uses the `login` service.

An external locker works through `ext-session-lock-v1`: `swaylock -c 000000`. While one is active, `awesome.lock()` is refused.

## When it does not lock

`awesome.lock()` returns false with no surface registered, when already locked, or while an ext-session-lock client holds the session: `somewm-client eval "return awesome.locked, awesome.lock_mechanism"`. For idle: `awesome.idle_inhibit`, `awesome.idle_inhibited` and `awesome.idle_timeouts` are all readable the same way, and `awesome.dpms_state` for displays that stay dark.

[Lock, Idle, and DPMS](/docs/reference/lock) is the API; [Lockscreen module](/docs/reference/lockscreen) the bundled UI's options; [Session Locking](/docs/concepts/lockscreen) what C enforces.
