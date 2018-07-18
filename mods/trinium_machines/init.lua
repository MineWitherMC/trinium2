local path2 = minetest.get_modpath"trinium_machines"
local path = path2 .. "/code"

trinium.machines = {}
trinium.machines.S = minetest.get_translator"trinium_machines"

dofile(path .. "/greggy_api.lua")

dofile(path .. "/heat.lua")

dofile(path .. "/casings.lua")
dofile(path .. "/chemical_reactor.lua")
dofile(path .. "/precision_assembler.lua")
dofile(path .. "/distillation_layer.lua")
dofile(path .. "/distillation_tower.lua")
dofile(path .. "/blast_furnace.lua")

dofile(path2 .. "/recipes/init.lua")
dofile(path2 .. "/research/init.lua")

trinium.api.send_init_signal()
