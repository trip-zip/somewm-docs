local options = ... or {}
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local target = awful.screen.focused()
if options.output then
    target = nil
    for s in screen do
        for _, output in pairs(s.outputs) do
            if output.name == options.output then target = s end
        end
    end
    assert(target, "Output not found: " .. tostring(options.output))
end
if _G.somewm_frame_figure then _G.somewm_frame_figure.stop() end

local bg = beautiful.bg_normal or "#282828"
local fg = beautiful.fg_normal or "#ebdbb2"
local family = (beautiful.font or "sans 10"):gsub("%s+%d+%.?%d*$", "")
local function label(text, size, color, bold)
    return wibox.widget {
        markup = '<span foreground="' .. (color or fg) .. '">'
            .. gears.string.xml_escape(text) .. '</span>',
        font = family .. (bold and " Bold " or " ") .. size,
        wrap = "word_char",
        widget = wibox.widget.textbox,
    }
end

local stages = {
    { "01  DECLARE", "Lua describes widgets and client layouts.",
      "C assembles one element tree for the output.", "#d79921" },
    { "02  SOLVE", "Clay computes sizes and positions in C.",
      "Widgets, bars and client frames share the layout result.", "#83a598" },
    { "03  RECONCILE", "SomeWM updates the retained scene.",
      "Changed commands update nodes; unchanged nodes are reused.", "#b8bb26" },
    { "04  PRESENT", "wlroots renders the scene to the output.",
      "Applications supply the pixels inside their own surfaces.", "#d5c4a1" },
}

local contents = wibox.layout.fixed.vertical()
contents.spacing = 14
contents:add(label("From state to pixels", 27, fg, true))
contents:add(label("The frame pipeline for one dirty output", 16))

for _, stage in ipairs(stages) do
    local lines = wibox.layout.fixed.vertical()
    lines.spacing = 5
    lines:add(label(stage[1], 14, stage[4], true))
    lines:add(label(stage[2], 20, fg, true))
    lines:add(label(stage[3], 16))
    contents:add(wibox.widget {
        {
            lines,
            margins = 18,
            widget = wibox.container.margin,
        },
        bg = bg,
        fg = fg,
        shape = gears.shape.rounded_rect,
        border_width = 1,
        border_color = stage[4],
        widget = wibox.container.background,
    })
end
contents:add(label("A clean output skips declaration and layout.", 14))

local popup = awful.popup {
    screen = target,
    visible = true,
    ontop = true,
    input_passthrough = true,
    bg = bg,
    fg = fg,
    minimum_width = 940,
    maximum_width = 940,
    placement = awful.placement.centered,
    widget = {
        contents,
        margins = 28,
        widget = wibox.container.margin,
    },
}

local state = { popup = popup, screen = target }
_G.somewm_frame_figure = state
function state.stop()
    popup.visible = false
    if state.timer then state.timer:stop() end
    if _G.somewm_frame_figure == state then _G.somewm_frame_figure = nil end
end
state.timer = gears.timer.start_new(120, function()
    state.stop()
    return false
end)
return "Frame figure opened on screen " .. target.index
