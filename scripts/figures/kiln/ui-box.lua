local function children()
  F.block("A"); F.block("B", { color = F.amber }); F.block("C", { color = F.green })
end
return F.scene("kiln.ui.box, row and column", "Sizing, direction, spacing and alignment", {
  F.row('row, gap = 8', function() ui.row({ gap = 8 }, children) end),
  F.row('column, gap = 8', function() ui.column({ gap = 8 }, children) end, { h = 130 }),
  F.row('w = "grow", spacer()', function()
    ui.row({ w = "grow" }, function() F.block("A"); ui.spacer(); F.block("B", { color = F.amber }) end)
  end),
  F.row('align = "center"', function() ui.row({ w = "grow", align = "center", gap = 8 }, children) end),
  F.row('pad = 12, border = 1', function()
    ui.row({ pad = 12, gap = 8, border = { width = 1, color = F.blue }, radius = 6 }, children)
  end, { h = 72 }),
})
