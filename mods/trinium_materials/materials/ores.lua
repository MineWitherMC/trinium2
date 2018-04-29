local materials = trinium.materials
local M = materials.materials
local S = materials.S

M.antracite = materials.add("antracite", {
	formula = {{"carbon", 4}},
	types = {"dust", "gem", "ore", "brick"},
	color = {9, 9, 9},
	description = S"Antracite",
}):generate_interactions()

M.graphite = materials.add("graphite", {
	formula = {{"carbon", 6}},
	types = {"dust", "ore"},
	color = {50, 50, 50},
	description = S"Graphite",
}):generate_interactions()

M.tennantite = materials.add("tennantite", {
	formula = {{"copper", 12}, {"arsenic", 4}, {"sulfur", 13}},
	types = {"dust", "gem", "ore"},
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
	types = {"dust", "gem", "ore"},
	color = {21, 21, 21},
	description = S"Coal",
}):generate_interactions()