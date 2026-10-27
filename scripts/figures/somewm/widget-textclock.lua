-- wibox.widget.textclock: the time in a few formats and zones.
local function clock(extra)
    local t = { font = F.font, widget = wibox.widget.textclock }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end
return F.scene("wibox.widget.textclock", "The time, as a textbox that updates itself", {
    F.row('textclock()', clock()),
    F.row('format = "%H:%M:%S", refresh = 1', clock { format = "%H:%M:%S", refresh = 1 }),
    F.row('format = "<b>%A</b> %d %B"', clock { format = "<b>%A</b> %d %B" }),
    F.row('timezone = "Z"', clock { format = "%H:%M UTC", timezone = "Z" }),
    F.row('timezone = "Asia/Tokyo"', clock { format = "%H:%M Tokyo", timezone = "Asia/Tokyo" }),
})
