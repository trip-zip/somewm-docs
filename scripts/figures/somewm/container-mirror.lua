-- wibox.container.mirror: the child flipped.
local function mirror(extra)
    local t = { F.label("Mirror"), widget = wibox.container.mirror }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.mirror", "The child flipped horizontally, vertically or both", {
    F.row('(no reflection)', mirror()),
    F.row('reflection = { horizontal = true }', mirror { reflection = { horizontal = true } }),
    F.row('reflection = { vertical = true }', mirror { reflection = { vertical = true } }),
    F.row('reflection = { horizontal = true, vertical = true }', mirror { reflection = { horizontal = true, vertical = true } }),
})
