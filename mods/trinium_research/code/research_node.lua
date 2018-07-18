local research = trinium.research
local S = research.S
local M = trinium.materials.materials
local api = trinium.api

minetest.register_node("trinium_research:node_controller", {
	stack_max = 1,
	tiles = {"trinium_research.node.png"},
	description = S"Research Node Controller",
	groups = {cracky = 1, rich_info = 1},
	paramtype2 = "facedir",
	sounds = trinium.sounds.default_stone,
	on_rightclick = function(_, _, player, itemstack)
		local pn = player:get_player_name()
		local item = itemstack:get_name()
		if item == M.paper:get"sheet" then
			research.dp2[pn].paper = research.dp2[pn].paper + itemstack:get_count()
			itemstack:take_item(99)
		elseif item == M.carton:get"sheet" then
			research.dp2[pn].paper = research.dp2[pn].paper + itemstack:get_count() * 4
			itemstack:take_item(99)
		elseif item == M.parchment:get"sheet" then
			research.dp2[pn].paper = research.dp2[pn].paper + itemstack:get_count() * 16
			itemstack:take_item(99)
		elseif item == M.ink:get"cell" then
			research.dp2[pn].ink = research.dp2[pn].ink + itemstack:get_count() * 100
			itemstack:take_item(99)
		elseif item == "trinium_research:charm1" then
			research.random_aspects(pn, 30 * itemstack:get_count(), table.filter(research.aspects, function(a)
				return not a.req1 and not a.req2
			end))
			itemstack:take_item(99)
		elseif item == "trinium_research:charm2" then
			research.random_aspects(pn, 100 * itemstack:get_count())
			itemstack:take_item(99)
		elseif item == "trinium_research:charm3" then
			if itemstack:get_meta():get_string"focus" ~= "" then
				research.random_aspects(pn, 150, {itemstack:get_meta():get_string"focus"})
			end
			itemstack:take_item(1)
		elseif item == "trinium_research:abacus" then
			local label = {}
			for i = 1, #research.aspect_list do
				local an = research.aspect_list[i]
				table.insert(label, S("@1 x@2", api.string_capitalization(an),
						research.dp2[pn].aspects[an] or 0))
			end
			cmsg.push_message_player(player, table.concat(label, "\n"))
		end
	end,

	get_rich_info = function(_, player)
		local pn = player:get_player_name()
		return S("Ink: @1@nPaper: @2@nWarp: @3",
				research.dp2[pn].ink, research.dp2[pn].paper, research.dp2[pn].warp)
	end,
})

local node_mb = {
	width = 3,
	height_d = 1,
	height_u = 1,
	depth_b = 4,
	depth_f = 0,
	controller = "trinium_research:node_controller",
	map = {
		{x = 0, y = -1, z = 0, name = "trinium_research:casing"},
		{x = 0, y = -1, z = 2, name = "trinium_research:casing"},
		{x = 1, y = -1, z = 1, name = "trinium_research:casing"},
		{x = -1, y = -1, z = 1, name = "trinium_research:casing"},
		{x = 0, y = -1, z = 1, name = "trinium_research:chassis"},

		{x = 1, y = -1, z = 2, name = "trinium_research:chassis"},
		{x = -1, y = -1, z = 2, name = "trinium_research:chassis"},
		{x = 1, y = -1, z = 0, name = "trinium_research:chassis"},
		{x = -1, y = -1, z = 0, name = "trinium_research:chassis"},

		{x = 0, y = -1, z = 3, name = "trinium_research:chassis"},
		{x = 0, y = -1, z = 4, name = "trinium_research:chassis"},

		{x = 2, y = -1, z = 1, name = "trinium_research:chassis"},
		{x = 3, y = -1, z = 1, name = "trinium_research:chassis"},
		{x = -2, y = -1, z = 1, name = "trinium_research:chassis"},
		{x = -3, y = -1, z = 1, name = "trinium_research:chassis"},

		{x = -1, y = 0, z = 1, name = "trinium_research:chassis"},
		{x = 1, y = 0, z = 1, name = "trinium_research:chassis"},
		{x = 0, y = 0, z = 2, name = "trinium_research:chassis"},

		{x = -1, y = 1, z = 1, name = "trinium_research:casing"},
		{x = 1, y = 1, z = 1, name = "trinium_research:casing"},
		{x = 0, y = 1, z = 2, name = "trinium_research:casing"},
		{x = 0, y = 1, z = 0, name = "trinium_research:casing"},
		{x = 0, y = 1, z = 1, name = "trinium_research:chassis"}
	},
}

api.register_multiblock("research node", node_mb)
api.multiblock_rename(node_mb)
api.multiblock_rich_info"trinium_research:node_controller"
