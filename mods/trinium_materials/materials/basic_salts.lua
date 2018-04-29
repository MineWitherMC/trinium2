local materials = trinium.materials
local M = materials.materials
local S = materials.S

M.fe2o3 = materials.add("iron_trioxide", {
	formula = {{"iron", 2}, {"oxygen", 3}},
	color = {100, 100, 155},
	types = {"dust", "brick"},
	description = S"Ferric Oxide",
	data = {melting_point = 1839},
}):generate_interactions()

M.cr2o3 = materials.add("chromium_trioxide", {
	formula = {{"chromium", 2}, {"oxygen", 3}},
	color = {100, 160, 100},
	types = {"dust", "brick"},
	description = S"Chromia",
	data = {melting_point = 2708},
}):generate_interactions()

M.al2o3 = materials.add("aluminium_trioxide", {
	formula = {{"aluminium", 2}, {"oxygen", 3}},
	color = {160, 160, 100},
	types = {"dust", "brick", "catalyst"},
	description = S"Aloxide",
	data = {melting_point = 2417},
}):generate_interactions()

M.k2o = materials.add("potassium_oxide", {
	formula = {{"potassium", 2}, {"oxygen", 1}},
	color = {250, 250, 235},
	types = {"dust", "brick"},
	description = S"Potassium Oxide",
	data = {melting_point = 973},
}):generate_interactions()

M.alcl3 = materials.add("aluminium_chloride", {
	formula = {{"aluminium", 1}, {"chlorine", 3}},
	color = {100, 160, 160},
	types = {"dust", "brick", "catalyst"},
	description = S"Aluminium Chloride",
}):generate_interactions()

M.cr2o3al2o3 = materials.add("chromium_aluminium_oxide", {
	formula = {{"chromium_trioxide", 2}, {"aluminium_trioxide", 1}},
	types = {"ingot", "catalyst"},
	description = S"Chromia with Aloxide",
}):generate_data("melting_point"):generate_interactions():generate_recipe("alloysmelting_tower")

M.cr2o3fe2o3 = materials.add("chromium_iron_oxide", {
	formula = {{"chromium_trioxide", 2}, {"iron_trioxide", 1}},
	types = {"ingot", "catalyst"},
	description = S"Chromia with Ferric Oxide",
}):generate_data("melting_point"):generate_interactions():generate_recipe("alloysmelting_tower")

M.fe7k2oal2o3 = materials.add("ipa_compound", {
	formula = {{"iron", 7}, {"potassium_oxide", 1}, {"aluminium_trioxide", 1}},
	types = {"ingot", "catalyst"},
	description = S"IPA Compound",
}):generate_data("melting_point"):generate_interactions():generate_recipe("alloysmelting_tower")