local path = minetest.get_modpath"pulse_network" .. "/code"
pulse_network = {}
pulse_network.S = minetest.get_translator"pulse_network"
pulse_network.recipes = {}

dofile(path .. "/crafting.lua")
dofile(path .. "/controller_api.lua")
dofile(path .. "/controller.lua")
dofile(path .. "/combinator.lua")
dofile(path .. "/storage_cells.lua")
dofile(path .. "/terminal.lua")
dofile(path .. "/pattern_encoder.lua")
dofile(path .. "/interface.lua")
dofile(path .. "/crafting_core.lua")

trinium.api.send_init_signal()
