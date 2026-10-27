-- wibox.container.rotate: the child turned.
local function rot(extra)
    local t = { { F.label("Rotate"), bg = F.panel, widget = wibox.container.background }, widget = wibox.container.rotate }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.rotate", "The child turned by a quarter, half or three quarters", {
    F.row('direction = "north"', rot(), { fit = true }),
    F.row('direction = "east"', rot { direction = "east" }, { fit = true }),
    F.row('direction = "south"', rot { direction = "south" }, { fit = true }),
    F.row('direction = "west"', rot { direction = "west" }, { fit = true }),
})
