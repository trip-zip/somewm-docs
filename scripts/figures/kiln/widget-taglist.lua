local s = screen.focused or screen.all()[1]
return F.client_scene("kiln.widgets.taglist", "Selected tags and client occupancy", {
  F.row('widgets.taglist(s)', function() widgets.taglist(s) end),
}, { band = "background" })
