local path = minetest.get_modpath "pulse_network"
pulse_network = {}
pulse_network.S = minetest.get_translator "pulse_network"

dofile(path .. "/controller.lua")
dofile(path .. "/combinator.lua")
dofile(path .. "/storage_cells.lua")
dofile(path .. "/terminal.lua")

trinium.api.send_init_signal()
