local path = minetest.get_modpath "trinium_machines" .. DIR_DELIM .. "recipes" .. DIR_DELIM

trinium.machines.recipes = {}
dofile(path .. "chemical_reactor.lua")
dofile(path .. "distillation_tower.lua")
