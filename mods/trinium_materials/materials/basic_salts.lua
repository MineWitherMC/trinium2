local materials = trinium.materials
local M = materials.materials
local S = materials.S

M.fe2o3 = materials.add("iron_trioxide", {
	formula = { { "iron", 2 }, { "oxygen", 3 } },
	color = { 100, 100, 155 },
	types = { "dust", "brick", "catalyst" },
	description = S "Ferric Oxide",
	data = { melting_point = 1839 },
})                 :generate_interactions()

M.cr2o3 = materials.add("chromium_trioxide", {
	formula = { { "chromium", 2 }, { "oxygen", 3 } },
	color = { 100, 160, 100 },
	types = { "dust", "brick", "catalyst" },
	description = S "Chromia",
	data = { melting_point = 2708 },
})                 :generate_interactions()
