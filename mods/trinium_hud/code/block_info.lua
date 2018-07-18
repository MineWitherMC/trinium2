local block_descriptions = {}
local huds = {}
local api = trinium.api
local huds_data = api.get_data_pointers"hud_block_info"
local hud = trinium.hud

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	huds[pn] = {}

	huds_data[pn].bg = huds_data[pn].bg or {
		hud_elem_type = "image",
		text = "",
		scale = {x = -40, y = -15},
		alignment = {x = 0, y = 0},
		position = {x = 0.5, y = 0.1},
	}

	huds_data[pn].bg_info = huds_data[pn].bg_info or {
		hud_elem_type = "image",
		text = "",
		scale = {x = -20, y = -30},
		alignment = {x = 0, y = 0},
		position = {x = 0.125, y = 0.5},
	}

	huds_data[pn].node = huds_data[pn].node or {
		hud_elem_type = "text",
		text = "",
		number = 0xffffff,
		alignment = {x = 1, y = 0},
		position = {x = 0.3, y = 0.1},
		offset = {x = 48, y = -12},
	}

	huds_data[pn].rich = huds_data[pn].rich or {
		hud_elem_type = "text",
		text = "",
		number = 0xffffff,
		alignment = {x = 0, y = 0},
		position = {x = 0.125, y = 0.5},
	}

	huds_data[pn].mod = huds_data[pn].mod or {
		hud_elem_type = "text",
		text = "",
		number = 0x003267,
		alignment = {x = 1, y = 0},
		position = {x = 0.3, y = 0.1},
		offset = {x = 48, y = 12},
	}

	huds_data[pn].image = huds_data[pn].image or {
		hud_elem_type = "image",
		text = "",
		scale = {x = 1, y = 1},
		alignment = 0,
		position = {x = 0.7, y = 0.1},
		offset = {x = -56, y = 0},
	}

	huds[pn].bg = player:hud_add(huds_data[pn].bg)
	huds[pn].bg_info = player:hud_add(huds_data[pn].bg_info)
	huds[pn].node = player:hud_add(huds_data[pn].node)
	huds[pn].rich = player:hud_add(huds_data[pn].rich)
	huds[pn].mod = player:hud_add(huds_data[pn].mod)
	huds[pn].image = player:hud_add(huds_data[pn].image)

	block_descriptions[pn] = ""
end)

local prohibited = {
	torchlike = 1, signlike = 1,
	airlike = 1, liquid = 1, flowingliquid = 1,
	plantlike = 1, fencelike = 1, firelike = 1, raillike = 1, plantlike_rooted = 1,
	nodebox = 1, mesh = 1,
}
local function generate_inv_cube(node)
	if prohibited[node.drawtype] then return "" end

	local tiles = node.tiles
	local overlay_tiles = node.overlay_tiles
	if not tiles then return "" end
	if #tiles == 0 then return "" end

	for i = 1, 6 do
		if not tiles[i] then
			if type(tiles[i - 1]) ~= "table" then
				tiles[i] = tiles[i - 1]
			else
				tiles[i] = table.copy(tiles[i - 1])
			end
		end
		if overlay_tiles and not overlay_tiles[i] then overlay_tiles[i] = overlay_tiles[i - 1] end

		for _, v in pairs{tiles, overlay_tiles} do
			if v and type(v[i]) == "table" then
				if v[i].name and v[i].color and v[i].color ~= "white" then
					v[i] = ("(%s)^[multiply:%s"):format(v[i].name, v[i].color)
				elseif v[i].name then
					v[i] = v[i].name
				end
			end
		end
	end

	if overlay_tiles then
		tiles = table.map(tiles, function(v, k)
			local q = overlay_tiles[k]
			if q.name and q.color then
				q = ("(%s)^[multiply:%s"):format(q.name, q.color)
			elseif q.name then
				q = q.name
			end
			return q ~= "" and ("(%s)^(%s)"):format(v, q) or v
		end)
	end

	if #tiles == 1 then
		-- Whole block
		return minetest.inventorycube(tiles[1], tiles[1], tiles[1])
	elseif #tiles == 2 then
		-- Top differs
		return minetest.inventorycube(tiles[1], tiles[2], tiles[2])
	elseif #tiles == 3 then
		-- Top and Bottom differ
		return minetest.inventorycube(tiles[1], tiles[3], tiles[3])
	elseif #tiles == 6 then
		-- All sides
		return minetest.inventorycube(tiles[1], tiles[6], tiles[5])
	else
		return ""
	end
end

local function get_pointed_node(player)
	local dir = vector.multiply(player:get_look_dir(), 5)
	local begin = vector.add(player:get_pos(), {x = 0, y = 13 / 8, z = 0})
	local rc = Raycast(begin, vector.add(begin, dir))
	for i in rc do
		if i.type == "node" and minetest.get_node(i.under).name ~= "air" then
			return i.under
		end
	end
end

hud.register_globalstep("block_info", {
	period = 0.1,
	consistent = true,
	callback = function()
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			local pn, pos = player:get_player_name(), get_pointed_node(player)
			if pos then
				local def = minetest.registered_items[minetest.get_node(pos).name] or {groups = {}}
				if def.description ~= block_descriptions[pn] or def.groups.rich_info == 1 then
					if block_descriptions[pn] == "" then
						player:hud_change(huds[pn].bg, "text", "trinium_hud.background.png")
					end
					block_descriptions[pn] = def.description
					player:hud_change(huds[pn].node, "text", (def.description or "???"):split"\n"[1])
					player:hud_change(huds[pn].mod, "text", api.string_superseparation(def.mod_origin or "???"))
					player:hud_change(huds[pn].image, "text", generate_inv_cube(def))

					local rich_info = def.groups.rich_info == 1 and def.get_rich_info(pos, player)
					-- todo: refactor rich info to only change when needed and use less time/memory/CPU
					if rich_info then
						player:hud_change(huds[pn].bg_info, "text", "trinium_hud.background.png")
						player:hud_change(huds[pn].rich, "text", rich_info)
					else
						player:hud_change(huds[pn].bg_info, "text", "")
						player:hud_change(huds[pn].rich, "text", "")
					end
				end
			else
				player:hud_change(huds[pn].bg, "text", "")
				player:hud_change(huds[pn].node, "text", "")
				player:hud_change(huds[pn].mod, "text", "")
				player:hud_change(huds[pn].image, "text", "")
				player:hud_change(huds[pn].bg_info, "text", "")
				player:hud_change(huds[pn].rich, "text", "")
				block_descriptions[pn] = ""
			end
		end
	end,
})

local S = hud.S
local conf = hud.configurator("block_info", 0, 0, S"Block Info")

local function update_position_x(player, v)
	local pn = player:get_player_name()
	huds_data[pn].node.position.x = huds_data[pn].bg.position.x - v / 200
	player:hud_change(huds[pn].node, "position",
			{x = huds_data[pn].bg.position.x - v / 200, y = huds_data[pn].node.position.y})
	huds_data[pn].mod.position.x = huds_data[pn].bg.position.x - v / 200
	player:hud_change(huds[pn].mod, "position",
			{x = huds_data[pn].bg.position.x - v / 200, y = huds_data[pn].mod.position.y})
	huds_data[pn].image.position.x = huds_data[pn].bg.position.x + v / 200
	player:hud_change(huds[pn].image, "position",
			{x = huds_data[pn].bg.position.x + v / 200, y = huds_data[pn].image.position.y})
end
local function update_rich_position(player)
	local pn = player:get_player_name()
	huds_data[pn].rich.position = huds_data[pn].bg_info.position
	player:hud_change(huds[pn].rich, "position",
			{x = huds_data[pn].rich.position.x, y = huds_data[pn].rich.position.y})
end

local function update_position_y(player)
	local pn = player:get_player_name()
	huds_data[pn].node.position.y = huds_data[pn].bg.position.y
	player:hud_change(huds[pn].node, "position",
			{y = huds_data[pn].bg.position.y, x = huds_data[pn].node.position.x})
	huds_data[pn].mod.position.y = huds_data[pn].bg.position.y
	player:hud_change(huds[pn].mod, "position",
			{y = huds_data[pn].bg.position.y, x = huds_data[pn].mod.position.x})
	huds_data[pn].image.position.y = huds_data[pn].bg.position.y
	player:hud_change(huds[pn].image, "position",
			{y = huds_data[pn].bg.position.y, x = huds_data[pn].image.position.x})
end

conf:add("size_hor", {
	y = 0,
	label = S"Block Info Window Width",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg.scale.x = -v
		player:hud_change(huds[pn].bg, "scale", {x = -v, y = huds_data[pn].bg.scale.y})

		update_position_x(player, v)
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return -huds_data[pn].bg.scale.x
	end,
})

conf:add("pos_hor", {
	y = 1,
	label = S"Block Info Horizontal Position",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg.position.x = v
		player:hud_change(huds[pn].bg, "position", {x = v, y = huds_data[pn].bg.position.y})

		update_position_x(player, v)
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return huds_data[pn].bg.position.x
	end,
})

conf:add("pos_ver", {
	y = 2,
	label = S"Block Info Vertical Position",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg.position.y = v
		player:hud_change(huds[pn].bg, "position", {y = v, x = huds_data[pn].bg.position.x})

		update_position_y(player)
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return huds_data[pn].bg.position.y
	end,
})

conf:add("rich_size_hor", {
	y = 3,
	label = S"Rich Info Width",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg_info.scale.x = -v
		player:hud_change(huds[pn].bg_info, "scale", {x = -v, y = huds_data[pn].bg_info.scale.y})
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return -huds_data[pn].bg_info.scale.x
	end,
})

conf:add("rich_size_ver", {
	y = 4,
	label = S"Rich Info Height",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg_info.scale.y = -v
		player:hud_change(huds[pn].bg_info, "scale", {y = -v, x = huds_data[pn].bg_info.scale.x})
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return -huds_data[pn].bg_info.scale.y
	end,
})

conf:add("rich_pos_hor", {
	y = 5,
	label = S"Rich Info Horizontal Position",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg_info.position.x = v
		player:hud_change(huds[pn].bg_info, "position", {x = v, y = huds_data[pn].bg_info.position.y})

		update_rich_position(player)
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return huds_data[pn].bg_info.position.x
	end,
})

conf:add("rich_pos_ver", {
	y = 6,
	label = S"Rich Info Vertical Position",
	func = function(player, v)
		local pn = player:get_player_name()
		if not tonumber(v) then
			cmsg.push_message_player(player, trinium.api.S("Couldn't parse number: @1", v))
			return
		end

		v = tonumber(v)
		huds_data[pn].bg_info.position.y = v
		player:hud_change(huds[pn].bg_info, "position", {y = v, x = huds_data[pn].bg_info.position.x})

		update_rich_position(player)
	end,
	get_current = function(player)
		local pn = player:get_player_name()
		return huds_data[pn].bg_info.position.y
	end,
})