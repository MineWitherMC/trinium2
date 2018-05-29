local S = trinium.machines.S
local api = trinium.api
minetest.register_node("trinium_machines:casing_chemical", {
	description = S"Chemical Casing",
	groups = {cracky = 1},
	tiles = {"trinium_machines.casing.png"},
	palette = "trinium_api.palette.png",
	place_param2 = 179,
	paramtype2 = "color",
	color = "#5575ff",
})

local input_bus_fs = "size[8,8.5]list[context;input;2,0;4,4]list[current_player;main;0,4.5;8,4]"
local output_bus_fs = "size[8,8.5]list[context;output;2,0;4,4]list[current_player;main;0,4.5;8,4]"

minetest.register_node("trinium_machines:hatch_inputbus", {
	description = S"Input Bus",
	groups = {cracky = 1, greggy_hatch = 1},
	tiles = {"trinium_machines.casing.png"},
	overlay_tiles = {{name = "trinium_machines.input_bus_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 175,
	paramtype2 = "color",
	color = "#646464",
	after_place_node = api.initializer{input = 16, formspec = input_bus_fs},
	ghatch_id = "input",
	ghatch_max = 1,
})

minetest.register_node("trinium_machines:hatch_outputbus", {
	description = S"Output Bus",
	groups = {cracky = 1, greggy_hatch = 1},
	tiles = {"trinium_machines.casing.png"},
	overlay_tiles = {{name = "trinium_machines.output_bus_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 175,
	paramtype2 = "color",
	color = "#646464",
	after_place_node = api.initializer{output = 16, formspec = output_bus_fs},
	ghatch_id = "output",
	allow_metadata_inventory_put = function() return 0 end,
})
