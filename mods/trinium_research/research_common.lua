local research = trinium.research
local S = research.S
local ss = trinium.sounds

-- Multiblock components
minetest.register_node("trinium_research:chassis", {
	tiles = { "trinium_research.chassis.png" },
	description = S "Research Chassis",
	groups = { cracky = 3 },
	sounds = ss.default_stone,
})
minetest.register_node("trinium_research:casing", {
	tiles = { "trinium_research.casing.png" },
	description = S "Research Casing",
	groups = { cracky = 2 },
	sounds = ss.default_stone,
})
minetest.register_node("trinium_research:wall", {
	tiles = { "trinium_research.wall.png" },
	description = S "Research Wall",
	groups = { cracky = 1 },
	sounds = ss.default_metal,
})

-- Knowledge Charms
minetest.register_craftitem("trinium_research:charm1", {
	inventory_image = "trinium_research.charm1.png",
	description = S "Knowledge Charm",
	stack_max = 16,
})
minetest.register_craftitem("trinium_research:charm2", {
	inventory_image = "trinium_research.charm2.png",
	description = S "Enriched Knowledge Charm",
	stack_max = 16,
})
minetest.register_craftitem("trinium_research:charm3", {
	inventory_image = "trinium_research.charm3.png",
	description = S "Focused Knowledge Charm",
	stack_max = 16,
})

-- Abacus
minetest.register_craftitem("trinium_research:abacus", {
	stack_max = 1,
	inventory_image = "trinium_research.abacus.png",
	description = S "Abacus",
})

-- Modular things
minetest.register_craftitem("trinium_research:lens", {
	inventory_image = "trinium_research.lens.png",
	description = S "Invalid Research Lens",
	stack_max = 1,
	groups = { hidden_from_irp = 1 },
})
minetest.register_craftitem("trinium_research:press", {
	inventory_image = "trinium_research.press.png",
	description = S "Invalid Research Press",
	stack_max = 1,
	groups = { hidden_from_irp = 1 },
})
minetest.register_craftitem("trinium_research:notes_1", {
	inventory_image = "trinium_research.completed_notes.png",
	description = S "Invalid Discovery",
	stack_max = 1,
	groups = { hidden_from_irp = 1 },
	on_place = function(item, player)
		local meta = item:get_meta()
		local pn = player:get_player_name()
		local name = meta:get_string "research_id"
		if research.grant(pn, name) and research.researches[name] and research.researches[name].warp then
			cmsg.push_message_player(player, S("Given @1 warp!", research.researches[name].warp))
			research.dp2[pn].warp = research.dp2[pn].warp + research.researches[name].warp
		end
		betterinv.redraw_for_player(player)
		return ""
	end,
	on_secondary_use = function(item, player)
		local meta = item:get_meta()
		local pn = player:get_player_name()
		local name = meta:get_string "research_id"
		if research.grant(pn, name) and research.researches[name] and research.researches[name].warp then
			cmsg.push_message_player(player, S("Given @1 warp!", research.researches[name].warp))
			research.dp2[pn].warp = research.dp2[pn].warp + research.researches[name].warp
		end
		betterinv.redraw_for_player(player)
		return ""
	end,
})
minetest.register_craftitem("trinium_research:notes_2", {
	inventory_image = "trinium_research.uncompleted_notes.png",
	description = S "Invalid Research Notes",
	stack_max = 1,
	groups = { hidden_from_irp = 1 },
})
minetest.register_craftitem("trinium_research:notes_3", {
	inventory_image = "trinium_research.undiscovered_notes.png",
	description = S "Invalid Research Map",
	stack_max = 1,
	groups = { hidden_from_irp = 1 },
})

-- Upgrades
minetest.register_craftitem("trinium_research:upgrade1", {
	inventory_image = "trinium_research.upgrade1.png",
	description = S "Basic Lens Upgrade",
	groups = { lens_upgrade = 1 },
	stack_max = 8,
})
minetest.register_craftitem("trinium_research:upgrade2", {
	inventory_image = "trinium_research.upgrade2.png",
	description = S "Improved Lens Upgrade",
	groups = { lens_upgrade = 2 },
	stack_max = 8,
})

-- Knowledge Crystal
minetest.register_craftitem("trinium_research:knowledge_crystal", {
	inventory_image = "trinium_research.knowledge_crystal.png",
	description = S "Knowledge Crystal",
	stack_max = 16,
	on_place = function(item, player)
		item = ItemStack(item)
		local meta = item:get_meta()
		local pn = player:get_player_name()
		meta:set_string("player", pn)
		meta:set_string("description", S "Knowledge Crystal" .. "\n" .. S("Bound to @1", pn))
		cmsg.push_message_player(player, S("Successfully bound to @1", pn))
		return item
	end,
	on_secondary_use = function(item, player)
		item = ItemStack(item)
		local meta = item:get_meta()
		local pn = player:get_player_name()
		meta:set_string("player", pn)
		meta:set_string("description", S "Knowledge Crystal" .. "\n" .. S("Bound to @1", pn))
		cmsg.push_message_player(player, S("Successfully bound to @1", pn))
		return item
	end,
})
