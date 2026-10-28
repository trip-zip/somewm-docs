local clients = F.clients(2)
return F.client_scene("kiln.widgets.titlebar", "Client title, maximise and close buttons", {
  F.row('focused = true', function() widgets.titlebar(clients[1], true) end),
  F.row('focused = false', function() widgets.titlebar(clients[2], false) end),
})
