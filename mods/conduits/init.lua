local path = minetest.get_modpath"conduits" .. "/code"
conduits = {}
conduits.S = minetest.get_translator"conduits"
conduits.recipes = {}

conduits.neighbours = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{y = 1, x = 0, z = 0},
	{y = -1, x = 0, z = 0},
	{z = 1, x = 0, y = 0},
	{z = -1, x = 0, y = 0},
}
conduits.strings = {
	conduits.S"Never active",
	conduits.S"With signal",
	conduits.S"Without signal",
	conduits.S"Always active"
}

dofile(path .. "/signal_cable.lua")
dofile(path .. "/item_conduit.lua")
dofile(path .. "/temporal_controller.lua")
dofile(path .. "/lua_controller.lua")

trinium.api.send_init_signal()
