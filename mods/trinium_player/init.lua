local path = minetest.get_modpath"trinium_player"
trinium.player_S = minetest.get_translator"trinium_player"

dofile(path.."/creative.lua")
dofile(path.."/player_model.lua")

trinium.api.send_init_signal()
