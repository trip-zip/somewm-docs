-- Docs figure: a textbox's ellipsize picks cutting or wrapping.
-- Run on a live SomeWM 2.1 session:
--   somewm-client eval 'return dofile("<this file>")'
-- Shows a wibox on the primary screen's current tag with the same text in a
-- 260 px box twice: the default ellipsize cuts it, "none" wraps it. Returns
-- the wibox geometry for the capture. Remove it with:
--   somewm-client eval 'if _G.docs_ellipsize_scene then _G.docs_ellipsize_scene() end'
local wibox = require("wibox")
local beautiful = require("beautiful")

local s = screen.primary
local text = "Window three: yet another very long window title to fill up the bar"

local function row(label, ellipsize)
    return {
        {
            text = label,
            forced_width = 190,
            font = "monospace 10",
            widget = wibox.widget.textbox,
        },
        {
            {
                text = text,
                ellipsize = ellipsize,
                widget = wibox.widget.textbox,
            },
            forced_width = 260,
            bg = beautiful.bg_focus,
            widget = wibox.container.background,
        },
        spacing = 16,
        layout = wibox.layout.fixed.horizontal,
    }
end

local box = wibox {
    screen = s,
    width = 520,
    height = 90,
    x = s.geometry.x + math.floor((s.geometry.width - 520) / 2),
    y = s.geometry.y + 200,
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
    ontop = true,
    visible = true,
    widget = {
        {
            row('ellipsize = "end"', "end"),
            row('ellipsize = "none"', "none"),
            spacing = 12,
            layout = wibox.layout.fixed.vertical,
        },
        margins = 12,
        widget = wibox.container.margin,
    },
}

_G.docs_ellipsize_scene = function()
    box.visible = false
    _G.docs_ellipsize_scene = nil
end

return string.format("%d,%d %dx%d", box.x, box.y, box.width, box.height)
