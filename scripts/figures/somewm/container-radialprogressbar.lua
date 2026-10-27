-- wibox.container.radialprogressbar: a ring filled to a value around the child.
local function ring(extra)
    local t = { { text = "42", font = F.mono, halign = "center", valign = "center", widget = wibox.widget.textbox },
        value = 0.42, forced_width = 56, forced_height = 56, color = F.blue, border_color = F.slot, widget = wibox.container.radialprogressbar }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.radialprogressbar", "A ring filled to a value, around the child", {
    F.row('value = 0.42', ring(), { fit = true }),
    F.row('max_value = 100, value = 80', ring { max_value = 100, value = 80 }, { fit = true }),
    F.row('color = "#d79921"', ring { color = F.amber }, { fit = true }),
    F.row('border_width = 6', ring { border_width = 6 }, { fit = true }),
    F.row('border_color = "#ebdbb2"', ring { border_color = F.fg }, { fit = true }),
})
