local function entries()
  for i = 1, 12 do
    ui.box({ h = 28, w = "grow", color = i % 2 == 0 and F.panel or nil, pad = { x = 8 } }, function()
      F.text("Entry " .. i, { size = 18 })
    end)
  end
end
return F.scene("kiln.ui.scroll", "The viewport clips a taller column; wheel input changes its offset", {
  F.row('h = 84, 12 entries', function()
    ui.scroll({ id = "scroll-short", w = "grow", h = 84, step = 28 }, entries)
  end, { h = 100 }),
  F.row('h = 168, 12 entries', function()
    ui.scroll({ id = "scroll-tall", w = "grow", h = 168, step = 28 }, entries)
  end, { h = 184 }),
})
