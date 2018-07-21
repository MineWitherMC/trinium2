local materials = trinium.materials
local M = materials.materials
local S = materials.S

M.pyrocatalyst = materials.add("pyrocatalyst", {
	formula = {{"carbon", 2}, {"naquadah", 1}, {"extrium", 1}},
	types = {"dust"},
	color = {255, 110, 35},
	description = S"Pyrolysis Catalyst",
})

M.bifrost = materials.add("bifrost", {
	formula = {{"extrium", 5}, {"iodine_acid_ion", 6}},
	types = {"dust"},
	color = {50, 0, 95},
	description = S"Bifrost",
})

M.xpcatalyst = materials.add("experience_catalyst", {
	formula = {{"extrium", 1}, {"phosphoric_acid_ion", 2}},
	types = {"dust"},
	color = {70, 250, 85},
	description = S"Experience Catalyst",
})

M.forcillium = materials.add("forcillium", {
	formula = {{"iron", 1}, {"extrium", 1}, {"caesium", 2}, {"fluorine", 1}},
	types = {"ingot", "gem", "dust"},
	color = {220, 239, 4},
	description = S"Forcillium",
	data = {melting_point = 2963},
}):generate_interactions()

M.imbued_forcillium = materials.add("imbued_forcillium", {
	formula = {{"forcillium_induced_ion", 4}, {"naquadah", 1}},
	types = {"ingot", "gem", "dust"},
	color = {240, 175, 0},
	description = S"Imbued Forcillium",
	data = {melting_point = 4107},
}):generate_interactions()

M.endium = materials.add("endium", {
	formula = {{"extrium", 4}, {"naquadah", 3}},
	types = {"ingot", "dust", "plate"},
	color = {40, 185, 250},
	description = S"Endium",
	data = {melting_point = 2884, press_time = 12, press_pressure = 5.4},
}):generate_interactions()

M.pulsating_alloy = materials.add("pulsating_alloy", {
	formula = {{"silver_alloy", 5}, {"forcillium", 6}, {"platinum", 3}, {"iron", 2}},
	types = {"ingot", "dust", "plate", "rod"},
	description = S"Pulsating Alloy",
	data = {press_time = 40, press_pressure = 12.25},
}):generate_data("melting_point"):generate_interactions():generate_recipe("smelting_tower")
