local path = minetest.get_modpath"trinium_research" .. "/code"

trinium.research = {}
trinium.research.S = minetest.get_translator"trinium_research"

dofile(path .. "/api.lua")
dofile(path .. "/commands.lua")
dofile(path .. "/research_inv.lua")
dofile(path .. "/research_common.lua")
dofile(path .. "/research_node.lua")
dofile(path .. "/research_table.lua")
dofile(path .. "/press_randomizer.lua")
dofile(path .. "/lens_compressor.lua")
dofile(path .. "/sheet_infuser.lua")
dofile(path .. "/research_content.lua")
dofile(path .. "/aspects.lua")

trinium.api.send_init_signal()
