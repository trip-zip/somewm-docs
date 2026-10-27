-- wibox.widget.separator: a line between things, in several forms.
local function sep(extra)
    local t = { color = F.muted, widget = wibox.widget.separator }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.separator", "A line, or any shape, between other widgets", {
    F.row('orientation = "auto" (wide box)', sep()),
    F.row('orientation = "vertical"', sep { orientation = "vertical" }, { w = 60, h = 60 }),
    F.row('thickness = 4', sep { thickness = 4 }),
    F.row('span_ratio = 0.5', sep { span_ratio = 0.5 }),
    F.row('color = "#d79921"', sep { color = F.amber }),
    F.row('shape = gears.shape.circle', sep { shape = gears.shape.circle, color = F.blue }, { w = 60, h = 60 }),
    F.row('border_width = 2, border_color = "#d79921"', sep { thickness = 8, border_width = 2, border_color = F.amber }),
})
