-- wibox.widget.progressbar: a bar filled to a value, in a few shapes.
local function bar(extra)
    local t = { value = 0.6, forced_width = 300, forced_height = 16, color = F.blue, background_color = F.slot, widget = wibox.widget.progressbar }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.progressbar", "A horizontal bar filled to a value", {
    F.row('value = 0.6', bar()),
    F.row('max_value = 10, value = 2', bar { max_value = 10, value = 2 }),
    F.row('color = "#d79921"', bar { color = F.amber }),
    F.row('shape = rounded_bar', bar { shape = gears.shape.rounded_bar }),
    F.row('bar_shape = rounded_bar', bar { shape = gears.shape.rounded_bar, bar_shape = gears.shape.rounded_bar }),
    F.row('border_width = 2, border_color = "#ebdbb2"', bar { border_width = 2, border_color = F.fg }),
    F.row('margins = 4, paddings = 3', bar { margins = 4, paddings = 3, forced_height = 24, border_width = 1, border_color = F.fg }),
    F.row('ticks = true, ticks_size = 6', bar { ticks = true, ticks_size = 6 }),
})
