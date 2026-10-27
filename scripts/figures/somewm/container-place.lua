-- wibox.container.place: a small block aligned inside a larger box.
local function place(extra)
    local t = { F.block(80, 24, F.blue, "child"), widget = wibox.container.place }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.place", "The child aligned inside the space the container gets", {
    F.row('halign = "center", valign = "center"', place(), { h = 72 }),
    F.row('halign = "left", valign = "top"', place { halign = "left", valign = "top" }, { h = 72 }),
    F.row('halign = "right", valign = "bottom"', place { halign = "right", valign = "bottom" }, { h = 72 }),
    F.row('content_fill_horizontal = true', place { content_fill_horizontal = true }, { h = 72 }),
    F.row('content_fill_vertical = true', place { content_fill_vertical = true }, { h = 72 }),
})
