local s = screen.focused or screen.all()[1]
return F.scene("kiln.widgets.layoutbox", "The selected tag's layout; press to cycle", {
  F.row('widgets.layoutbox(s)', function() widgets.layoutbox(s) end),
})
