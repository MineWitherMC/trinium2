local path = minetest.get_modpath"trinium_materials"

trinium.materials = {}
trinium.materials.S = minetest.get_translator"trinium_materials"

dofile(path .. "/api.lua")
dofile(path .. "/material_types.lua")
dofile(path .. "/combinations.lua")
dofile(path .. "/generators.lua")
assert(loadfile(path .. "/materials/init.lua"))(path .. "/materials")

trinium.api.send_init_signal()
