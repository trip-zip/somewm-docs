local c = F.clients(1)[1]
return F.client_scene("kiln.ui.surface", "The client's buffer inside a solved UI box", {
  F.row('ui.surface(c)', function()
    ui.surface(c, { w = "grow", h = "grow" })
  end, { h = 260 }),
})
