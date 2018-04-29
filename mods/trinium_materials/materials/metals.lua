local materials = trinium.materials
local V = materials.vanilla_elements
local M = materials.materials
local S = materials.S

--[[ Elements ]]--
M.titanium = V.titanium:register_material({
	description = S"Titanium",
	types = {"ingot", "dust", "plate"},
})

M.iron = V.iron:register_material({
	description = S"Iron",
	types = {"ingot", "dust"},
})

M.nickel = V.nickel:register_material({
	description = S"Nickel",
	types = {"ingot", "dust"},
})

M.copper = V.copper:register_material({
	description = S"Copper",
	types = {"ingot", "dust", "rod"},
})

M.silver = V.silver:register_material({
	description = S"Silver",
	types = {"ingot", "dust", "plate"},
})

M.tin = V.tin:register_material({
	description = S"Tin",
	types = {"ingot", "dust"},
})

M.rhenium = V.rhenium:register_material({
	description = S"Rhenium",
	types = {"ingot", "dust"},
})

M.platinum = V.platinum:register_material({
	description = S"Platinum",
	types = {"ingot", "dust", "catalyst"},
})

--[[ Compounds ]]--
-- Rhenium Alloy
M.rhenium_alloy = materials.add("rhenium_alloy", {
	formula = {{"titanium", 11}, {"rhenium", 2}, {"platinum", 5}},
	types = {"ingot", "dust", "rod"},
	description = S"Rhenium Alloy"
}):generate_data("melting_point"):generate_interactions():generate_recipe("alloysmelting_tower")

-- Cupronickel
M.cupronickel = materials.add("cupronickel", {
	formula = {{"copper", 3}, {"nickel", 2}},
	types = {"ingot", "dust"},
	description = S"Constantan"
}):generate_data("melting_point"):generate_interactions():generate_recipe("alloysmelting_tower")
	:generate_recipe("trinium:crude_alloyer")

-- Silver Alloy
M.silver_alloy = materials.add("silver_alloy", {
	formula = {{"silver", 2}, {"tennantite", 5}},
	types = {"ingot", "dust", "wire"},
	description = S"Conductant Silver",
	data = {melting_point = 1563},
}):generate_interactions():generate_recipe("alloysmelting_tower"):generate_recipe("crude_alloyer")

-- Bronze
M.bronze = materials.add("bronze", {
	formula = {{"copper", 4}, {"tin", 1}},
	types = {"ingot", "dust"},
	description = S"Bronze",
}):generate_data("melting_point"):generate_interactions()
		:generate_recipe("alloysmelting_tower"):generate_recipe("crude_alloyer")
