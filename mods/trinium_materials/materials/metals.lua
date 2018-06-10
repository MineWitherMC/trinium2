local materials = trinium.materials
local V = materials.vanilla_elements
local M = materials.materials
local S = materials.S

--[[ Elements ]]--
M.titanium = V.titanium:register_material{
	description = S"Titanium",
	types = {"ingot", "dust", "plate"},
}

M.iron = V.iron:register_material{
	description = S"Iron",
	types = {"ingot", "dust"},
}

M.nickel = V.nickel:register_material{
	description = S"Nickel",
	types = {"ingot", "dust"},
}

M.copper = V.copper:register_material{
	description = S"Copper",
	types = {"ingot", "dust", "rod"},
}

M.zinc = V.zinc:register_material{
	description = S"Zinc",
	types = {"ingot", "dust"},
}

M.molybdenum = V.molybdenum:register_material{
	description = S"Molybdenum",
	types = {"ingot", "dust"},
}

M.silver = V.silver:register_material{
	description = S"Silver",
	types = {"ingot", "dust", "plate"},
}

M.tin = V.tin:register_material{
	description = S"Tin",
	types = {"ingot", "dust"},
}

M.antimony = V.antimony:register_material{
	description = S"Antimony",
	types = {"ingot", "dust"},
}

M.rhenium = V.rhenium:register_material{
	description = S"Rhenium",
	types = {"ingot", "dust"},
}

M.platinum = V.platinum:register_material{
	description = S"Platinum",
	types = {"ingot", "dust"},
}

M.osmium = V.osmium:register_material{
	description = S"Osmium",
	types = {"ingot", "dust", "catalyst"},
}

M.bismuth = V.bismuth:register_material{
	description = S"Bismuth",
	types = {"ingot", "dust"},
}

M.lead = V.lead:register_material{
	description = S"Lead",
	types = {"ingot", "dust"},
}

--[[ Compounds ]]--
-- Rhenium Alloy
M.rhenium_alloy = materials.add("rhenium_alloy", {
	formula = {{"titanium", 11}, {"rhenium", 2}, {"platinum", 5}},
	types = {"ingot", "dust", "rod"},
	description = S"Rhenium Alloy"
}):generate_data("melting_point"):generate_interactions():generate_recipe("alloysmelting_tower")

-- Silver Alloy
M.silver_alloy = materials.add("silver_alloy", {
	formula = {{"silver", 2}, {"tennantite", 5}},
	types = {"ingot", "dust"},
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

-- Molybdenum-Bismuth
M.bismuth_molybdenum = materials.add("bismuth_molybdenum", {
	formula = {{"bismuth", 1}, {"molybdenum", 2}},
	types = {"ingot", "dust", "catalyst"},
	description = S"Molybdenum-Bismuth",
}):generate_data("melting_point"):generate_interactions()
		:generate_recipe("alloysmelting_tower"):generate_recipe("crude_alloyer")
