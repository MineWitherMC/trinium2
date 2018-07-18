default = {}
default.S = minetest.get_translator"default"

local path = minetest.get_modpath"default" .. "/code"
dofile(path .. "/nodes.lua")
dofile(path .. "/aliases.lua")
dofile(path .. "/sounds.lua")
dofile(path .. "/random_compat.lua")

trinium.api.send_init_signal()