-- wibox.container.background: fill, text color, shape, border.
local function bg(extra)
    local t = { F.label("content"), widget = wibox.container.background }
    for k, v in pairs(extra) do t[k] = v end
    return t
end
return F.scene("wibox.container.background", "A fill, text color, shape and border around one widget", {
    F.row('bg = "#83a598"', bg { bg = F.blue, fg = F.bg }),
    F.row('fg = "#d79921"', bg { fg = F.amber }),
    F.row('shape = rounded_rect', bg { bg = F.blue, fg = F.bg, shape = F.rounded }),
    F.row('border_width = 2', bg { border_width = 2, border_color = F.amber }),
    F.row('shape + border', bg { bg = F.panel, border_width = 2, border_color = F.blue, shape = F.rounded }),
    F.row('border_strategy = "inner"', bg { bg = F.blue, fg = F.bg, border_width = 6, border_color = F.amber, border_strategy = "inner" }),
    F.row('border_strategy = "none"', bg { bg = F.blue, fg = F.bg, border_width = 6, border_color = F.amber }),
})
