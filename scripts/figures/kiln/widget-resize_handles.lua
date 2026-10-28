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
