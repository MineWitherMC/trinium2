local api = trinium.api
local machines = trinium.machines
local S = machines.S

local def, destruct = machines.parse_multiblock{
	controller = "trinium_machines:controller_chemicalreactor",
	casing = "trinium_machines:casing_chemical",
	size = {front = 0, back = 2, up = 1, down = 1, sides = 1},
	min_casings = 23,
	air_positions = {{x = 0, z = 1, y = 0}},
	color = 179,
}

minetest.register_node("trinium_machines:controller_chemicalreactor", {
	description = S"Chemical Reactor",
	groups = {cracky = 1},
	tiles = {
		{name = "trinium_machines.casing.png", color = "#5575ff"},
		{name = "trinium_machines.casing.png", color = "#5575ff"},
		{name = "trinium_machines.casing.png", color = "#5575ff"},
		{name = "trinium_machines.casing.png", color = "#5575ff"},
		{name = "trinium_machines.casing.png", color = "#5575ff"},
		{name = "trinium_machines.casing.png", color = "#5575ff"},
	},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.chemical_reactor_overlay.png"},
	palette = "trinium_api.palette8.png",
	paramtype2 = "colorfacedir",
	color = "white",
	on_destruct = destruct,
})

api.register_multiblock("chemical reactor", def)
