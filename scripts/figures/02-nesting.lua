-- Figure 2: nesting. The same card twice, plain and then with every container
-- named by a float pinned to its own corner.
--
-- The badges are floats, so naming a container cannot change how that container
-- was solved: both cards below are laid out identically.

local ui = kiln.ui

local function card(named)
	ui.row({
		id = named and "card-named" or "card-plain",
		w = 340, h = "fit", pad = 14, gap = 12,
		color = F.paper, radius = 10,
		border = { width = 2, color = F.rust },
		align = { y = "center" },
	}, function()
		if named then
			F.badge("ui.row", "above")
		end

		ui.box({
			id = named and "icon-named" or "icon-plain",
			w = 44, h = 44, color = F.orange, radius = 8, align = "center",
		}, function()
			if named then
				F.badge("ui.box", "below", F.orange)
			end
			ui.text("C", { color = F.paper, font = "Sans Bold", size = 22 })
		end)

		ui.column({
			id = named and "col-named" or "col-plain",
			w = "grow", h = "fit", gap = 3,
		}, function()
			if named then
				F.badge("ui.column", "above_right", F.amber)
				F.badge("ui.text", "below_right", F.amber)
			end
			ui.text("Declarative syntax", { color = F.ink, font = "Sans Bold", size = 16 })
			ui.text("one function, called every frame", { color = F.orange, font = "Sans", size = 13 })
		end)
	end)
end

F.canvas({ pad = 34, gap = 26 }, function()
	ui.row({ w = "fit", h = "fit", gap = 34, align = { y = "center" } }, function()
		card(false)
		card(true)
	end)

	F.caption("the same declaration, and the tree it is")
end)
