local materials = trinium.materials
local M = materials.materials
local S = materials.S

M.antracite = materials.add("antracite", {
	formula = {{"carbon", 4}},
	types = {"dust", "ore", "brick"},
	color = {12, 12, 12},
	description = S"Antracite",
}):generate_interactions()

M.graphite = materials.add("graphite", {
	formula = {{"carbon", 6}},
	types = {"dust", "ore"},
	color = {90, 90, 90},
	description = S"Graphite",
}):generate_interactions()

M.tennantite = materials.add("tennantite", {
	formula = {{"copper", 12}, {"arsenic", 4}, {"sulfur", 13}},
	types = {"dust", "ore"},
	color = {55, 55, 94},
	description = S"Tennantite",
}):generate_interactions()

M.diamond = materials.add("diamond", {
	formula = {{"graphite", 8}},
	types = {"dust", "gem", "ore"},
	color = {200, 255, 255},
	description = S"Diamond",
}):generate_interactions()

M.coal = materials.add("coal", {
	formula = {{"carbon", 2}},
	types = {"dust", "ore"},
	color = {41, 41, 41},
	description = S"Coal",
}):generate_interactions()

M.chalcopyrite = materials.add("chalcopyrite", {
	formula = {{"copper", 1}, {"iron", 1}, {"sulfur", 2}},
	types = {"dust", "ore"},
	color = {100, 85, 10},
	description = S"Chalcopyrite",
}):generate_interactions():generate_recipe"crude_blast_furnace"

M.galena = materials.add("galena", {
	formula = {{"lead", 1}, {"sulfur", 1}},
	types = {"dust", "ore"},
	color = {30, 15, 90},
	description = S"Galena",
}):generate_interactions():generate_recipe"crude_blast_furnace"

M.sphalerite = materials.add("sphalerite", {
	formula = {{"zinc", 1}, {"sulfur", 1}},
	types = {"dust", "ore"},
	color = {230, 230, 230},
	description = S"Sphalerite",
}):generate_interactions():generate_recipe"crude_blast_furnace"
