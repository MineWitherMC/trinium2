-- Change formspecs
minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend [=[
		bgcolor[#111B;true]
		background[5,5;1,1;trinium_gui_background.png;true]
		listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
	]=]
end)

trinium = {}
trinium.api = {}

trinium.DEBUG_MODE = false

local path = minetest.get_modpath"trinium_api"
trinium.api.S = minetest.get_translator"trinium_api"

dofile(path .. "/data_pointers.lua")
dofile(path .. "/data_mesh.lua")
dofile(path .. "/stdlib.lua")
dofile(path .. "/random.lua")
dofile(path .. "/recipes.lua")
dofile(path .. "/multiblock.lua")
dofile(path .. "/sounds.lua")
dofile(path .. "/fluids.lua")
dofile(path .. "/math.lua")
dofile(path .. "/queueing.lua")
