local path = minetest.get_modpath "trinium_machines" .. "/recipes/"

trinium.machines.recipes = {}
dofile(path .. "chemical_reactor.lua")
dofile(path .. "distillation_tower.lua")
dofile(path .. "metal_press.lua")
