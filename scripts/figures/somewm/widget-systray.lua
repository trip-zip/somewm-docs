-- wibox.widget.systray: the session's tray. There is one instance per
-- session, so one row.
return F.scene("wibox.widget.systray", "The tray icons of running applications, over StatusNotifierItem", {
    F.row('systray(), base_size = 32', { base_size = 32, widget = wibox.widget.systray }, { h = 56 }),
})
