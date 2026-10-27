-- wibox.widget.slider: a handle on a bar, in a few styles.
local function slider(extra)
    local t = { value = 40, forced_width = 300, forced_height = 24, bar_color = F.slot, handle_color = F.fg, widget = wibox.widget.slider }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.slider", "A draggable handle on a bar, 0 to 100 by default", {
    F.row('value = 40', slider()),
    F.row('minimum = 0, maximum = 10, value = 8', slider { minimum = 0, maximum = 10, value = 8 }),
    F.row('bar_height = 4', slider { bar_height = 4 }),
    F.row('bar_active_color = "#83a598"', slider { bar_active_color = F.blue }),
    F.row('bar_shape = rounded_bar, bar_height = 10', slider { bar_shape = gears.shape.rounded_bar, bar_height = 10 }),
    F.row('handle_shape = circle, handle_color = "#d79921"', slider { handle_shape = gears.shape.circle, handle_color = F.amber }),
    F.row('handle_width = 30, handle_border_width = 2', slider { handle_width = 30, handle_border_width = 2, handle_border_color = F.amber }),
    F.row('bar_margins = { left = 40, right = 40 }', slider { bar_margins = { left = 40, right = 40 } }),
})
