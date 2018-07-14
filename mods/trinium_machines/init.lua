local path = minetest.get_modpath"trinium_machines"

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

dofile(path .. "/recipes/init.lua")
dofile(path .. "/research/init.lua")

trinium.api.send_init_signal()
