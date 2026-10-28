local function slider(label, cfg)
  local value = cfg.value or 0.6
  cfg.changed = function(v) value = v end
  return F.row(label, function() cfg.value = value; widgets.slider(cfg) end)
end
return F.scene("kiln.widgets.slider", "Press or drag to change a value from 0 to 1", {
  slider('w = 120 (default)', { id = "slider-default" }),
  slider('w = "grow"', { id = "slider-grow", w = "grow" }),
  slider('value = 0.25', { id = "slider-quarter", value = 0.25, w = "grow" }),
  slider('color = "#d79921"', { id = "slider-amber", color = F.amber, w = "grow" }),
  slider('h = 8, radius = 4', { id = "slider-thin", h = 8, radius = 4, w = "grow" }),
})
