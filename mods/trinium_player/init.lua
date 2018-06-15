local path = minetest.get_modpath"trinium_player"
trinium.bound_inventories = {}

trinium.nei = {}
trinium.player_S = minetest.get_translator "trinium_player"
trinium.nei.integrate = minetest.settings:get_bool "trinium.integrated_inventory"

dofile(path.."/creative.lua")
dofile(path.."/utility.lua")
dofile(path.."/inventory.lua")
dofile(path.."/nei.lua")
dofile(path.."/player_model.lua")

if trinium.nei.integrate then
	dofile(path .. "/integrated_inventory.lua")
end

trinium.api.send_init_signal()
