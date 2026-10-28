local s = screen.focused or screen.all()[1]
local figure = F.scene("kiln.widgets.layoutlist", "A menu of registered layouts", {
  F.row('widgets.layoutlist(s)', function()
    ui.box({ id = "reference-layout-anchor", w = "grow", h = "grow" })
  end, { h = 360 }),
}, { band = "above" })
local attempts = 0
local function open_menu()
  attempts = attempts + 1
  local box = core.box("reference-layout-anchor")
  if not box then
    if attempts < 20 then figure.menu_timer = core.timer(50, open_menu) end
    return
  end
  widgets.layoutlist(s, { x = box.x, y = box.y })
end
figure.menu_timer = core.timer(50, open_menu)
figure.cleanup = function()
  core.timer_cancel(figure.menu_timer)
  kiln.menu.close()
end
return figure
