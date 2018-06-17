local path = minetest.get_modpath "trinium_hud"
trinium.hud = {}
trinium.hud.S = minetest.get_translator "trinium_hud"

dofile(path .. "/api.lua")
dofile(path .. "/block_info.lua")
dofile(path .. "/wield.lua")
dofile(path .. "/configurator.lua")

trinium.api.send_init_signal()
