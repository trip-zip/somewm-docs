local c = F.clients(1)[1]
return F.client_scene("kiln.widgets.client", "Border, titlebar and client content", {
  F.row('widgets.client(c)', function()
    widgets.client(c, { w = "grow", h = "grow" })
  end, { h = 260 }),
})
