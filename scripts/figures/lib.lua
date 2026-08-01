-- Shared palette and canvas helper for the Clay Bet figures.
--
-- This file is concatenated ahead of each figure config by generate.sh, so it
-- defines the global F rather than returning a module: there is no package.path
-- to require through when kiln loads an rc from an arbitrary path.

local kiln = require("kiln")
local ui = kiln.ui

F = {}

-- Clay's own palette, sampled from screenshots of nicbarker.com/clay so the
-- primer figures read as "this is Clay" rather than "this is kiln".
F.paper  = "#f4ebe6"
F.pale   = "#f3c370"
F.amber  = "#ecab57"
F.orange = "#da812f"
F.rust   = "#a8421c"
F.panel  = "#3c3a37"

F.ink    = "#a8421c" -- text on paper
F.on_ink = "#f4ebe6" -- text on orange or rust

F.bold = "Sans Bold"
F.mono = "JetBrains Mono"

-- A labelled cell: solid fill with its sizing rule printed inside, so the
-- figure's caption is rendered by Clay at the width Clay actually solved.
function F.cell(cfg, label, sub)
	ui.box({
		id = cfg.id,
		w = cfg.w, h = cfg.h or "grow",
		color = cfg.color, radius = 6,
		align = "center", pad = 8, gap = 2,
	}, function()
		ui.column({ w = "fit", h = "fit", align = "center", gap = 2 }, function()
			ui.text(label, { color = cfg.fg or F.on_ink, font = F.mono, size = 15 })
			if sub then
				ui.text(sub, { color = cfg.fg or F.on_ink, font = "Sans", size = 12 })
			end
		end)
	end)
end

-- A caption under a figure, centred across its full width.
function F.caption(text)
	ui.box({ w = "grow", h = "fit", align = "center" }, function()
		ui.text(text, { color = F.ink, font = "Sans", size = 14 })
	end)
end

-- Where a badge hangs off its parent. Each entry is the Clay attach-point pair
-- plus the nudge that clears the parent's edge.
F.placements = {
	above       = { parent = "left_top",     element = "left_bottom",  x = 8,  y = -3 },
	above_right = { parent = "right_top",    element = "right_bottom", x = -8, y = -3 },
	below       = { parent = "left_bottom",  element = "left_top",     x = 8,  y = 3 },
	below_right = { parent = "right_bottom", element = "right_top",    x = -8, y = 3 },
	right       = { parent = "right_top",    element = "left_top",     x = 6,  y = 0 },
}

-- A name tag pinned to one of its parent's corners. It is a float, so naming a
-- container does not make the badge one of that container's children for layout
-- purposes: the annotation cannot change the thing it annotates.
function F.badge(name, where, tone)
	local p = F.placements[where or "above"]
	ui.box({
		id = "badge:" .. name,
		float = {
			to = "parent",
			anchor = { parent = p.parent, element = p.element },
			offset = { x = p.x, y = p.y },
			band = "above",
		},
		w = "fit", h = "fit", pad = { x = 6, y = 1 },
		color = tone or F.rust, radius = 4,
	}, function()
		ui.text(name, { color = F.paper, font = F.mono, size = 12 })
	end)
end

-- Register a figure on the screen: a flat paper backdrop with `declare`
-- centred on it. The centred element is id "figure", which generate.sh reads
-- back with core.box to crop the capture to exactly the figure's solved box.
function F.canvas(cfg, declare)
	cfg = cfg or {}
	screen.on("added", function(s)
		ui.bar(s, { height = 0, color = "#00000000" }, function()
			ui.box({
				id = "backdrop",
				float = { to = "root", anchor = "center", band = "background", passthrough = true },
				w = s.width, h = s.height, color = cfg.bg or F.paper,
			})
			-- A column, not a box: ui.box has no layout direction of its own, so
			-- a caption under the figure would otherwise be laid out beside it.
			ui.column({
				id = "figure",
				float = { to = "root", anchor = "center", band = "normal" },
				w = cfg.w or "fit", h = cfg.h or "fit",
				pad = cfg.pad or 28, gap = cfg.gap or 16,
				color = cfg.bg or F.paper,
			}, declare)
		end)
	end)
end
