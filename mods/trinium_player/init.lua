local path = minetest.get_modpath"trinium_player"
trinium.bound_inventories = {}

trinium.player_S = minetest.get_translator "trinium_player"

dofile(path.."/creative.lua")
dofile(path.."/utility.lua")
dofile(path.."/inventory.lua")
dofile(path.."/nei.lua")
dofile(path.."/player_model.lua")
dofile(path .. "/integrated_inventory.lua")

trinium.api.send_init_signal()
