local function toggle(label, cfg)
  local on = cfg.on or false
  cfg.track = F.slot
  cfg.press = function() on = not on; kiln.dirty() end
  return F.row(label, function() cfg.on = on; widgets.toggle(cfg) end)
end
return F.scene("kiln.widgets.toggle", "A switch controlled by a boolean", {
  toggle('on = false', { id = "toggle-off" }),
  toggle('on = true', { id = "toggle-on", on = true }),
  toggle('w = 64, h = 28', { id = "toggle-large", on = true, w = 64, h = 28 }),
  toggle('color = "#d79921"', { id = "toggle-amber", on = true, color = F.amber }),
  toggle('pad = 5', { id = "toggle-pad", on = true, w = 64, h = 28, pad = 5 }),
  toggle('radius = 0', { id = "toggle-square", on = true, radius = 0 }),
})
