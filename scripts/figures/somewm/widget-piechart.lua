-- wibox.widget.piechart: three values, with and without labels and borders.
local function pie(extra)
    local t = { data_list = { { "L", 50 }, { "M", 30 }, { "S", 20 } }, forced_width = 200, forced_height = 110,
        colors = { F.blue, F.amber, F.green }, widget = wibox.widget.piechart }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.piechart", "Named values as slices of a circle", {
    F.row('data_list = {{"L",50},{"M",30},{"S",20}}', pie(), { fit = true }),
    F.row('display_labels = false', pie { display_labels = false }, { fit = true }),
    F.row('border_width = 3, border_color = "#ebdbb2"', pie { border_width = 3, border_color = F.fg }, { fit = true }),
    F.row('colors = { "#d79921" }', pie { colors = { F.amber } }, { fit = true }),
})
