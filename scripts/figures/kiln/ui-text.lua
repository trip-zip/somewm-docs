return F.scene("kiln.ui.text", "Font, colour, wrapping and truncation", {
  F.row('size = 18', function() ui.text("Handgloves 0123456789", { size = 18 }) end),
  F.row('font = "Sans Bold"', function() ui.text("Handgloves 0123456789", { font = "Sans Bold", size = 18 }) end),
  F.row('font = "Serif Italic"', function() ui.text("Handgloves 0123456789", { font = "Serif Italic", size = 18 }) end),
  F.row('color = "#d79921"', function() ui.text("Handgloves 0123456789", { color = F.amber, size = 18 }) end),
  F.row('wrap = "words", w = 240', function()
    ui.box({ w = 240 }, function() ui.text("Text wraps at word boundaries inside this box.", { size = 18 }) end)
  end, { h = 82 }),
  F.row('clip + ellipsize = true', function()
    ui.box({ w = 240, clip = { horizontal = true } }, function()
      ui.text("A title longer than its container", { size = 18, ellipsize = true })
    end)
  end),
})
