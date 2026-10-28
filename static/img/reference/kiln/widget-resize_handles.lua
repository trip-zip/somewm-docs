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

local c = F.clients(1)[1]
local old_float = c.float
c.float = { x = 0, y = 0, width = 500, height = 240 }
local edges = { "n", "s", "w", "e", "nw", "ne", "sw", "se" }
local figure = F.client_scene("kiln.widgets.resize_handles", "Outlines show the normally invisible pointer targets", {
  F.row('resize_handles(c, 5010)', function()
    ui.box({ w = 500, h = 240, color = F.panel }, function()
      ui.surface(c)
      widgets.resize_handles(c, 5010)
    end)
    for _, edge in ipairs(edges) do
      local b = core.box({ "resize_" .. edge, c.handle })
      if b then
        ui.box({
          float = { to = "root", offset = { x = b.x, y = b.y }, z = 5012, passthrough = true },
          w = b.width, h = b.height, color = "#d7992140",
          border = { width = 1, color = F.amber },
        })
      end
    end
  end, { h = 264, pad = 12 }),
})
local restore = figure.cleanup
figure.cleanup = function()
  core.timer_cancel(figure.redraw)
  c.float = old_float
  restore()
end
figure.redraw = core.timer(100, function() kiln.dirty() end)
return figure
