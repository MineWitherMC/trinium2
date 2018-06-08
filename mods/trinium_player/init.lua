local path = minetest.get_modpath"trinium_player"
trinium.bound_inventories = {}

dofile(path.."/creative.lua")
dofile(path.."/utility.lua")
dofile(path.."/inventory.lua")
dofile(path.."/nei.lua")
dofile(path.."/player_model.lua")

trinium.api.send_init_signal()
