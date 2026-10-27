-- wibox.container.margin: space around a child, shown with a filled child.
local function mg(extra)
    local t = { { F.label("content"), bg = F.panel, widget = wibox.container.background }, widget = wibox.container.margin }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.margin", "Space around the child, empty or colored", {
    F.row('margins = 0', mg(), { h = 56 }),
    F.row('margins = 10', mg { margins = 10 }, { h = 56 }),
    F.row('left = 40, top = 4', mg { left = 40, top = 4 }, { h = 56 }),
    F.row('margins = { left = 20, right = 60 }', mg { margins = { left = 20, right = 60 } }, { h = 56 }),
    F.row('margins = 8, color = "#d79921"', mg { margins = 8, color = F.amber }, { h = 56 }),
})
