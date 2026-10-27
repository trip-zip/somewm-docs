-- wibox.container.arcchart: values as arcs around a child.
local function arc(extra)
    local t = { { text = "42", font = F.mono, halign = "center", valign = "center", widget = wibox.widget.textbox },
        value = 42, max_value = 100, forced_width = 56, forced_height = 56, colors = { F.blue }, widget = wibox.container.arcchart }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.arcchart", "One or more values drawn as arcs around the child", {
    F.row('value = 42, max_value = 100', arc(), { fit = true }),
    F.row('thickness = 10', arc { thickness = 10 }, { fit = true }),
    F.row('values = {30, 20, 10}, colors = {...}', arc { value = nil, values = { 30, 20, 10 }, colors = { F.blue, F.amber, F.green } }, { fit = true }),
    F.row('rounded_edge = true', arc { rounded_edge = true, thickness = 8 }, { fit = true }),
    F.row('start_angle = 0', arc { start_angle = 0 }, { fit = true }),
    F.row('bg = "#504945"', arc { bg = F.slot }, { fit = true }),
    F.row('border_width = 2, border_color = "#d79921"', arc { border_width = 2, border_color = F.amber }, { fit = true }),
    F.row('paddings = 6', arc { paddings = 6 }, { fit = true }),
})
