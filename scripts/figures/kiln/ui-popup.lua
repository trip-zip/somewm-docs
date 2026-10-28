local panel
local figure = F.scene("kiln.ui.popup", "Content positioned below a named element", {
  F.row('under = "status-button"', function()
    ui.box({ w = "grow", h = "grow" }, function()
      ui.box({ id = "status-button", w = 160, h = 36, color = F.blue,
        align = "center", radius = 6, on_press = function() panel:toggle() end }, function()
        F.text("Status", { color = F.bg })
      end)
    end)
  end, { h = 200 }),
})
panel = ui.popup {
  id = "reference-child-popup", under = "status-button", fit = false,
  w = 260, pad = 12, gap = 8, color = F.panel, radius = 8,
  border = { width = 1, color = F.blue },
  fn = function() F.text("Status"); F.text("Connected", { color = F.green }) end,
}
panel:show(figure.screen)
figure.cleanup = function() panel:destroy() end
return figure
