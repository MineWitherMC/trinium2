trinium = {}
trinium.api = {}

trinium.DEBUG_MODE = false

local path = minetest.get_modpath"trinium_api" .. "/code"

dofile(path .. "/compat.lua")

-- Change formspecs
trinium.api.set_master_prepend[=[
	bgcolor[#111B;true]
	background[5,5;1,1;trinium_gui_background.png;true]
	listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
]=]

trinium.api.S = minetest.get_translator"trinium_api"

dofile(path .. "/data_pointers.lua")
dofile(path .. "/data_mesh.lua")
dofile(path .. "/stdlib.lua")
dofile(path .. "/random.lua")
dofile(path .. "/algorithm.lua")
dofile(path .. "/inventory.lua")
dofile(path .. "/recipes.lua")
dofile(path .. "/multiblock.lua")
dofile(path .. "/sounds.lua")
dofile(path .. "/fluids.lua")
dofile(path .. "/math.lua")
dofile(path .. "/queueing.lua")

trinium.api.send_init_signal()