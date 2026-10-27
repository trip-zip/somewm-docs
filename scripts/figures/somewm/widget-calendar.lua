-- wibox.widget.calendar: a month at a fixed date, with the display options.
local date = { year = 2026, month = 10, day = 27 }
local function month(extra)
    local t = { date = date, font = "monospace 11", widget = wibox.widget.calendar.month }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.calendar", "A month or a year, one cell per day, today in bold", {
    F.row('calendar.month, date = {2026, 10, 27}', month(), { w = 320, h = 236 }),
    F.row('week_numbers = true', month { week_numbers = true }, { w = 360, h = 236 }),
    F.row('start_sunday = true', month { start_sunday = true }, { w = 320, h = 236 }),
    F.row('spacing = 12', month { spacing = 12 }, { w = 420, h = 300 }),
})
