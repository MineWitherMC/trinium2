local S = trinium.machines.S
local api = trinium.api
local sdh = trinium.machines.set_default_hatch

minetest.register_node("trinium_machines:casing_chemical", {
	description = S"Chemical Casing",
	groups = {cracky = 1},
	tiles = {"trinium_machines.casing.png"},
	palette = "trinium_api.palette.png",
	place_param2 = 179,
	paramtype2 = "color",
	color = "#5575ff",
})
minetest.register_node("trinium_machines:casing_distillation", {
	description = S"Distillation Grate",
	groups = {cracky = 1},
	tiles = {"trinium_machines.casing.png"},
	overlay_tiles = {{name = "trinium_machines.distillation_grate_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 135,
	paramtype2 = "color",
	color = "#9a00ff",
})
minetest.register_node("trinium_machines:casing_heatbrick", {
	description = S"Heat-Proof Brick Block",
	groups = {cracky = 2},
	tiles = {"trinium_machines.brick.png"},
	palette = "trinium_api.palette.png",
	place_param2 = 100,
	paramtype2 = "color",
	color = "#c7b671",
})

local input_bus_fs = "size[8,8.5]list[context;input;2,0;4,4]list[current_player;main;0,4.5;8,4]listring[]"
local crude_input_bus_fs = "size[8,5.5]list[context;input;2.5,0;3,1]list[current_player;main;0,1.5;8,4]"
local output_bus_fs = "size[8,8.5]list[context;output;2,0;4,4]list[current_player;main;0,4.5;8,4]listring[]"
local crude_output_bus_fs = "size[8,5.5]list[context;output;2.5,0;3,1]list[current_player;main;0,1.5;8,4]"

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
	ghatch_id = "input.item",
	ghatch_max = 1,
})
sdh("input.item", "trinium_machines:hatch_inputbus")

minetest.register_node("trinium_machines:hatch_crudeinputbus", {
	description = S"Crude Input Bus",
	groups = {cracky = 1, greggy_hatch = 1},
	tiles = {"trinium_machines.brick.png"},
	overlay_tiles = {{name = "trinium_machines.input_bus_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 191,
	paramtype2 = "color",
	color = "#808080",
	after_place_node = api.initializer{input = 3, formspec = crude_input_bus_fs},
	ghatch_id = "input.item",
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
	ghatch_id = "output.item",
	allow_metadata_inventory_put = function() return 0 end,
})
sdh("output.item", "trinium_machines:hatch_outputbus")

minetest.register_node("trinium_machines:hatch_crudeoutputbus", {
	description = S"Crude Output Bus",
	groups = {cracky = 1, greggy_hatch = 1},
	tiles = {"trinium_machines.brick.png"},
	overlay_tiles = {{name = "trinium_machines.output_bus_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 191,
	paramtype2 = "color",
	color = "#808080",
	after_place_node = api.initializer{output = 3, formspec = crude_output_bus_fs},
	ghatch_id = "output.item",
	allow_metadata_inventory_put = function() return 0 end,
})

minetest.register_node("trinium_machines:hatch_pressureinput", {
	description = S"Pressure Input Hatch",
	groups = {cracky = 1, greggy_hatch = 1, pressure_container = 1, rich_info = 1},
	tiles = {"trinium_machines.casing.png"},
	overlay_tiles = {{name = "trinium_machines.pressure_input_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 175,
	paramtype2 = "color",
	color = "#646464",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("pressure", 1000)
	end,

	ghatch_id = "input.pressure",
	ghatch_max = 1,
	get_rich_info = function(pos)
		local meta = minetest.get_meta(pos)
		return S("Pressure: @1 kPa", meta:get_int"pressure" / 10)
	end,
})
sdh("input.pressure", "trinium_machines:hatch_pressureinput")
