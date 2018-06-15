local path = minetest.get_modpath "trinium_mapgen"

trinium.mapgen = {}
trinium.mapgen.S = minetest.get_translator "trinium_mapgen"

dofile(path .. "/nodes.lua")
dofile(path .. "/biomes.lua")
dofile(path .. "/ore_generator.lua")
dofile(path .. "/ores.lua")
dofile(path .. "/trees.lua")
dofile(path .. "/rocks.lua")

trinium.api.send_init_signal()
