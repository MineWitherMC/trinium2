local path = minetest.get_modpath "nei"
trinium.bound_inventories = {}

trinium.nei = {}
trinium.nei.S = minetest.get_translator "nei"
trinium.nei.integrate = minetest.settings:get_bool("trinium.integrated_inventory", true)

dofile(path .. "/utility.lua")
dofile(path .. "/inventory.lua")
dofile(path .. "/nei.lua")

if trinium.nei.integrate then
	dofile(path .. "/integrated_inventory.lua")
end

trinium.api.send_init_signal()
