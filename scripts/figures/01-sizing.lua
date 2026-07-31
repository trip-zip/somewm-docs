-- Figure 1: the three sizing modes, solved at their real widths.
--
-- The point of the picture is that each cell's label states its own rule and
-- the cell is drawn at whatever width that rule produced. Nothing here is
-- annotated afterwards.

local ui = kiln.ui

F.canvas({ w = 760 }, function()
	ui.row({ w = "grow", h = 108, gap = 10 }, function()
		F.cell({ id = "c-fixed", w = 180, color = F.rust }, "w = 180", "fixed pixels")
		F.cell({ id = "c-grow", w = "grow", color = F.orange }, 'w = "grow"', "takes what is left")
		F.cell({ id = "c-pct", w = "25%", color = F.amber, fg = F.rust }, 'w = "25%"', "of the parent")
	end)

	ui.text("one row, three children, no arithmetic", {
		color = F.ink, font = "Sans", size = 14, align = "center",
	})
end)
