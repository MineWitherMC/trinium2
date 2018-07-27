trinium = {}
trinium.api = {}
api = trinium.api

trinium.DEBUG_MODE = false

local path = minetest.get_modpath"trinium_api" .. "/code"

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