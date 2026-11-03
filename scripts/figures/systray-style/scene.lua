local token = ...
local beautiful = require("beautiful")
local gears = require("gears")
local tray = require("wibox.widget.systray")()

assert(not _G.docs_systray_style, "A systray capture is already running")

local state = { token = token, saved = {}, applied = {} }
_G.docs_systray_style = state

local function set_theme(key, value)
    if not state.saved[key] then state.saved[key] = { value = beautiful[key] } end
    state.applied[key] = value
    beautiful[key] = value
end

-- base_size has a setter but no getter in the captured release.
for i = 1, 20 do
    local name, value = debug.getupvalue(tray.set_base_size, i)
    if not name then break end
    if name == "base_size" then
        state.base_size = value
        state.found_base_size = true
        break
    end
end
assert(state.found_base_size, "Cannot save the tray's icon size")

function state.stop()
    if state.timer then state.timer:stop() end
    if state.hovered then
        state.hovered._private.is_hovered = state.was_hovered
        state.hovered:emit_signal("widget::redraw_needed")
    end
    for key, value in pairs(state.saved) do
        if beautiful[key] == state.applied[key] then
            beautiful[key] = value.value
        end
    end
    tray:set_base_size(state.base_size)
    _G.docs_systray_style = nil
end

state.timer = gears.timer.start_new(60, function() state.stop(); return false end)
set_theme("bg_systray", "#282828")
set_theme("systray_icon_spacing", 4)
set_theme("systray_paddings", 2)
set_theme("systray_hover_bg", "#458588")
tray:set_base_size(16)

function state.hover(id)
    for _, widget in ipairs(tray:get_children()) do
        if widget.get_item and widget:get_item().id == id then
            state.hovered = widget
            state.was_hovered = widget._private.is_hovered
            -- Render the hover state without moving the user's pointer or opening a tooltip.
            widget._private.is_hovered = true
            widget:emit_signal("widget::redraw_needed")
            return
        end
    end
    error("Tray item not found: " .. id)
end

function state.attention()
    set_theme("systray_urgent_bg", "#cc241d")
    tray:emit_signal("widget::redraw_needed")
end

return "ready"
