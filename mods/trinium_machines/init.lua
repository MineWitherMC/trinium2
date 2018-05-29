local path = minetest.get_modpath"trinium_machines"

trinium.machines = {}
trinium.machines.S = minetest.get_translator"trinium_machines"

dofile(path.."/greggy_api.lua")
dofile(path.."/casings.lua")
dofile(path.."/chemical_reactor.lua")
