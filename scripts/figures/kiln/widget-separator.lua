return F.scene("kiln.widgets.separator", "A horizontal or vertical line", {
  F.row('thickness = 1', function() widgets.separator() end),
  F.row('thickness = 4', function() widgets.separator { thickness = 4 } end),
  F.row('length = 160', function() widgets.separator { length = 160, thickness = 2 } end),
  F.row('color = "#83a598"', function() widgets.separator { color = F.blue, thickness = 2 } end),
  F.row('vertical = true', function()
    ui.row({ gap = 20, h = 30, align = { y = "center" } }, function()
      F.text("Left")
      widgets.separator { vertical = true, length = "grow", color = F.blue }
      F.text("Right")
    end)
  end),
})
