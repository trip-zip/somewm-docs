-- wibox.widget.checkbox: checked state, colors and shapes, at a forced size.
local function box(extra)
    local t = { forced_width = 28, forced_height = 28, color = F.fg, widget = wibox.widget.checkbox }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.checkbox", "A box that is checked or not, drawn at the size you give it", {
    F.row('checked = false', box()),
    F.row('checked = true', box { checked = true }),
    F.row('color = "#83a598"', box { checked = true, color = F.blue }),
    F.row('check_color = "#d79921"', box { checked = true, check_color = F.amber }),
    F.row('shape = gears.shape.circle', box { checked = true, shape = gears.shape.circle }),
    F.row('border_width = 3, border_color = "#d79921"', box { checked = true, border_width = 3, border_color = F.amber }),
    F.row('paddings = 6', box { checked = true, paddings = 6 }),
    F.row('bg = "#504945"', box { bg = F.slot }),
})
