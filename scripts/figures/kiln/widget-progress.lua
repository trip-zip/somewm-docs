return F.scene("kiln.widgets.progress", "A horizontal fill from 0 to 1", {
  F.row('value = 0.6', function()
    widgets.progress { value = 0.6, h = 16, color = F.blue, track = F.slot }
  end),
  F.row('value = 0.2', function()
    widgets.progress { value = 0.2, h = 16, color = F.blue, track = F.slot }
  end),
  F.row('color = "#d79921"', function()
    widgets.progress { value = 0.6, h = 16, color = F.amber, track = F.slot }
  end),
  F.row('radius = 8', function()
    widgets.progress { value = 0.6, h = 16, radius = 8, color = F.blue, track = F.slot }
  end),
  F.row('h = 4', function()
    widgets.progress { value = 0.6, h = 4, color = F.blue, track = F.slot }
  end),
  F.row('value = 2 (clamped)', function()
    widgets.progress { value = 2, h = 16, color = F.blue, track = F.slot }
  end),
})
