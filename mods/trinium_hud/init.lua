local path = minetest.get_modpath"trinium_hud"
trinium.hud = {}

dofile(path.."/api.lua")
dofile(path.."/block_info.lua")
dofile(path.."/wield.lua")

trinium.api.send_init_signal()
