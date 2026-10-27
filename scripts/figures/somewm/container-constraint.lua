-- wibox.container.constraint: a size limit around a child.
local long = "A line of text longer than the limit"
local function con(text, extra)
    local t = { { F.label(text), bg = F.panel, widget = wibox.container.background }, widget = wibox.container.constraint }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.constraint", "A minimum, maximum or exact size for the child", {
    F.row('(no constraint)', con(long), { fit = true }),
    F.row('width = 200 (strategy "max")', con(long, { width = 200 }), { fit = true }),
    F.row('width = 200, strategy = "min"', con("short", { width = 200, strategy = "min" }), { fit = true }),
    F.row('width = 200, strategy = "exact"', con(long, { width = 200, strategy = "exact" }), { fit = true }),
    F.row('height = 70, strategy = "exact"', con("short", { height = 70, strategy = "exact" }), { fit = true }),
})
