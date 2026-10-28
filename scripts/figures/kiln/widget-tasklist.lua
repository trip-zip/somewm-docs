local s = screen.focused or screen.all()[1]
return F.scene("kiln.widgets.tasklist", "Client titles from the selected tags", {
  F.row('width = 220', function() widgets.tasklist(s, { width = 220 }) end),
})
