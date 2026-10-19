local options = ... or {}
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local target = awful.screen.focused()
if options.output then
    target = assert(output.get_by_name(options.output), "Output not found").screen
end
if _G.somewm_signal_figure then _G.somewm_signal_figure.stop() end

local bg = beautiful.bg_normal or "#282828"
local fg = beautiful.fg_normal or "#ebdbb2"
local muted = "#bdae93"
local amber, blue, green = "#d79921", "#83a598", "#b8bb26"
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
local function card(heading, action, detail, color)
    return wibox.widget {
        {
            {
                label(heading, 14, color, true),
                label(action, 21, fg, true),
                label(detail, 16, muted),
                spacing = 10,
                layout = wibox.layout.fixed.vertical,
            },
            margins = 18,
            widget = wibox.container.margin,
        },
        forced_width = 260,
        bg = bg,
        shape = gears.shape.rounded_rect,
        border_width = 1,
        border_color = color,
        widget = wibox.container.background,
    }
end
local function arrow()
    return wibox.widget {
        label("→", 27, muted),
        halign = "center",
        valign = "center",
        forced_width = 56,
        widget = wibox.container.place,
    }
end

local contents = wibox.layout.fixed.vertical()
contents.spacing = 22
contents:add(label("C → Lua, in batches", 27, fg, true))
contents:add(label("Notifications are delivered at a defined point in the main loop.", 16, muted))
contents:add(wibox.widget {
    card("C EVENTS", "Record", "Signal, target, arguments", amber),
    arrow(),
    card("QUEUE", "Take a snapshot", "The current batch", blue),
    arrow(),
    card("LUA HANDLERS", "Deliver", "At main-loop refresh", green),
    layout = wibox.layout.fixed.horizontal,
})
contents:add(wibox.widget {
    { forced_width = 316, widget = wibox.container.background },
    {
        label("NEXT BATCH", 14, blue, true),
        label("Notifications queued while handlers run\nwait until the next drain.", 16),
        spacing = 6,
        layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.horizontal,
})
contents:add(wibox.widget {
    {
        {
            label("C ⇄ Lua    Immediate answers", 18, amber, true),
            label("Requests whose results C needs now remain synchronous.", 16, muted),
            spacing = 8,
            layout = wibox.layout.fixed.vertical,
        },
        margins = 18,
        widget = wibox.container.margin,
    },
    bg = "#32302f",
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
})

local popup = awful.popup {
    screen = target,
    visible = true,
    ontop = true,
    input_passthrough = true,
    bg = bg,
    fg = fg,
    minimum_width = 948,
    maximum_width = 948,
    placement = awful.placement.centered,
    widget = { contents, margins = 28, widget = wibox.container.margin },
}
local state = { popup = popup, screen = target }
_G.somewm_signal_figure = state
function state.stop()
    popup.visible = false
    if state.timer then state.timer:stop() end
    if _G.somewm_signal_figure == state then _G.somewm_signal_figure = nil end
end
state.timer = gears.timer.start_new(120, function() state.stop(); return false end)
return "Signal figure opened on screen " .. target.index
