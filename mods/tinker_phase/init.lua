local path = minetest.get_modpath"tinker_phase" .. "/code"
tinker = {}
tinker.S = minetest.get_translator"tinker_phase"

dofile(path .. "/api.lua")
dofile(path .. "/materials.lua")
dofile(path .. "/patterns.lua")
dofile(path .. "/part_builder.lua")
dofile(path .. "/modifiers.lua")
dofile(path .. "/tools.lua")
dofile(path .. "/tool_station.lua")

trinium.api.send_init_signal()
