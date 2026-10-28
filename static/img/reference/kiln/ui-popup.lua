local kiln = require("kiln")
local ui, widgets = kiln.ui, kiln.widgets
if kiln_reference_figure then kiln_reference_figure.stop() end

local F = {
  bg = "#282828", fg = "#ebdbb2", panel = "#32302f", slot = "#504945",
  muted = "#bdae93", amber = "#d79921", blue = "#83a598", green = "#b8bb26",
  width = 940, label_width = 300,
}
function F.text(text, cfg)
  cfg = cfg or {}
  cfg.color = cfg.color or F.fg
  cfg.font = cfg.font or "Sans"
  cfg.size = cfg.size or 19
  ui.text(text, cfg)
end
function F.block(text, cfg)
  cfg = cfg or {}
  ui.box({ w = cfg.w or 72, h = cfg.h or 30, color = cfg.color or F.blue,
    radius = 4, align = "center" }, function()
    F.text(text, { color = F.bg, size = 16 })
  end)
end
function F.row(label, draw, opts)
  opts = opts or {}
  return function()
    ui.row({ w = "grow", gap = 20, align = { y = "center" } }, function()
      ui.box({ w = F.label_width }, function()
        F.text(label, { font = "monospace", size = 17, color = F.muted })
      end)
      ui.box({ w = "grow", h = opts.h or 44, pad = opts.pad or 6,
        radius = 8, border = { width = 1, color = F.slot },
        align = { y = "center" } }, draw)
    end)
  end
end
function F.scene(title, subtitle, rows, opts)
  opts = opts or {}
  local s = screen.focused or screen.all()[1]
  assert(s, "a screen is required")
  local popup = ui.popup {
    id = "kiln-reference-figure", screen = s, w = F.width, pad = 28, gap = 12,
    color = F.bg, fit = false, band = opts.band,
    fn = function()
      F.text(title, { size = 36, font = "Sans Bold" })
      F.text(subtitle, { size = 21, color = F.muted })
      ui.box({ h = 6 })
      for _, row in ipairs(rows) do row() end
    end,
  }
  local figure = { popup = popup, screen = s }
  function figure.stop()
    popup:destroy()
    if figure.timer then core.timer_cancel(figure.timer); figure.timer = nil end
    if kiln_reference_figure == figure then kiln_reference_figure = nil end
    if figure.cleanup then figure.cleanup() end
  end
  kiln_reference_figure = figure
  figure.timer = core.timer(120000, figure.stop)
  popup:show(s)
  return figure
end
function F.clients(count)
  local result = {}
  for _, c in ipairs(client.all()) do
    if c.mapped and not c.override_redirect then result[#result + 1] = c end
  end
  assert(#result >= count, "open " .. count .. " clients before running this figure")
  return result
end
function F.client_scene(title, subtitle, rows, opts)
  local previous = kiln.declare_clients
  local replacement = function() end
  kiln.declare_clients = replacement
  local figure = F.scene(title, subtitle, rows, opts)
  figure.cleanup = function()
    if kiln.declare_clients == replacement then kiln.declare_clients = previous end
    kiln.dirty()
  end
  return figure
end

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
