local path = assert(kiln.asset.svg("reference-image", 128, 128, [[
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
<rect x="4" y="4" width="56" height="56" rx="10" fill="#83a598"/>
<path d="M18 20l12 12-12 12M34 44h14" fill="none" stroke="#282828" stroke-width="5"/>
</svg>]]), "rsvg-convert is required")
return F.scene("kiln.ui.image", "Explicit size, aspect ratio and recolouring", {
  F.row('w = 32, h = 32', function() ui.image(path, { w = 32, h = 32 }) end),
  F.row('w = 64, aspect = 1', function() ui.image(path, { w = 64, aspect = 1 }) end, { h = 80 }),
  F.row('w = 96, h = 48', function() ui.image(path, { w = 96, h = 48 }) end, { h = 64 }),
  F.row('recolor = "#d79921"', function() ui.image(path, { w = 48, h = 48, recolor = F.amber }) end, { h = 64 }),
})
