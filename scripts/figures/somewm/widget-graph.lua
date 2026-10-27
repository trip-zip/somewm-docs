-- wibox.widget.graph: the same values in a few styles.
local function graph(extra, groups)
    local t = { forced_width = 320, color = F.blue, background_color = F.panel, widget = wibox.widget.graph }
    for k, v in pairs(extra or {}) do t[k] = v end
    local w = wibox.widget(t)
    for i = 1, 60 do
        local v = 0.5 + 0.45 * math.sin(i / 5)
        if groups then w:add_value(v, 1); w:add_value(0.3 + 0.2 * math.cos(i / 7), 2) else w:add_value(v) end
    end
    return w
end
return F.scene("wibox.widget.graph", "Values added over time, drawn as bars from the right", {
    F.row('add_value(v) 60 times', graph()),
    F.row('color = "#d79921", background_color = ...', graph { color = F.amber, background_color = F.slot }),
    F.row('step_width = 6, step_spacing = 2', graph { step_width = 6, step_spacing = 2 }),
    F.row('step_shape = rounded_rect', graph { step_width = 8, step_spacing = 2, step_shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 3) end }),
    F.row('max_value = 2', graph { max_value = 2 }),
    F.row('stack = true, group_colors = {...}', graph({ stack = true, group_colors = { F.blue, F.amber } }, true)),
    F.row('border_width = 2, border_color = "#d79921"', graph { border_width = 2, border_color = F.amber }),
})
