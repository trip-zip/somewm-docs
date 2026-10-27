-- wibox.container.scroll: a long textbox scrolling inside a short box.
local long = "A line of text much longer than the space it scrolls through, repeated as it goes"
local function sc(extra)
    local t = { F.label(long), max_size = 300, speed = 40, layout = wibox.container.scroll.horizontal }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.container.scroll", "A child wider than its box, scrolling through it", {
    F.row('scroll.horizontal, max_size = 300', sc(), { fit = true }),
    F.row('extra_space = 60', sc { extra_space = 60 }, { fit = true }),
    F.row('step_function = waiting_nonlinear_back_and_forth', sc { step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth }, { fit = true }),
    F.row('scroll.vertical, max_size = 40', { F.label("line one\nline two\nline three\nline four", { ellipsize = "none" }), max_size = 40, speed = 20, layout = wibox.container.scroll.vertical }, { fit = true }),
})
