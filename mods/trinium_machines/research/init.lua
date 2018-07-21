local path = minetest.get_modpath"trinium_machines" .. "/research/"
local M = trinium.materials.materials
local research = trinium.research
local S = research.S

research.add_chapter("Chemistry2", {
	texture = M.abs:get"ingot",
	x = 1,
	y = 1,
	name = S"Advanced Chemistry",
	tier = 2
})

dofile(path .. "chemical_reactor.lua")
dofile(path .. "distillation_tower.lua")
