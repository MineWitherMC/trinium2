local block_descriptions = {}
local huds = {}
local hud = trinium.hud
local api = trinium.api

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	huds[pn] = {}
	huds[pn].bg = player:hud_add{
		hud_elem_type = "image",
		text = "",
		scale = {x = -25, y = -15},
		alignment = {x = 0, y = 0.5},
		position = {x = 0.5, y = 0.1},
	}

	huds[pn].node = player:hud_add{
        hud_elem_type = "text",
        text = "",
        number = 0xffffff,
        alignment = {x = 1, y = 0},
        position = {x = 0.5, y = 0.125},
        offset = {x = -15, y = 0},
    }

    huds[pn].mod = player:hud_add{
        hud_elem_type = "text",
        text = "",
        number = 0x003267,
        alignment = {x = 1, y = 0},
        position = {x = 0.5, y = 0.15},
        offset = {x = -15, y = 0},
    }

	huds[pn].image = player:hud_add{
        hud_elem_type = "image",
        text = "",
        scale = {x = 1, y = 1},
        alignment = 0,
        position = {x = 0.5, y = 0.1375},
        offset = {x = -75, y = 0},
    }

	block_descriptions[pn] = ""
end)

local function generate_inv_cube(node)
    local tiles = node.tiles
    local overlay_tiles = node.overlay_tiles

    if tiles then
        for i,v in pairs(tiles) do
            if type(v) == "table" then
                if tiles[i].name then
                    tiles[i] = tiles[i].name
                else
                    return ""
                end
            end
        end

        if overlay_tiles then
            if #tiles < 6 then
                for i = #tiles + 1, 6 do
                    tiles[i] = tiles[#tiles]
                end
            end
            if #overlay_tiles < 6 then
                for i = #overlay_tiles + 1, 6 do
                    overlay_tiles[i] = overlay_tiles[#overlay_tiles]
                end
            end
            for i = 1, #overlay_tiles do
                if type(overlay_tiles[i]) == "table" then
                    if overlay_tiles[i].name then
                        overlay_tiles[i] = overlay_tiles[i].name
                    else
                        return "aspect_tempus.png"
                    end
                end
                tiles[i] = "("..tiles[i]..")^("..overlay_tiles[i]..")"
            end
        end

        if node.drawtype == "normal" or node.drawtype == "allfaces" or node.drawtype == "allfaces_optional" or
				node.drawtype == "glasslike" or node.drawtype == "glasslike_framed" or
				node.drawtype == "glasslike_framed_optional" then
            if #tiles == 1 then -- Whole block
                return minetest.inventorycube(tiles[1], tiles[1], tiles[1])
			elseif #tiles == 2 then -- Top differs
                return minetest.inventorycube(tiles[1], tiles[2], tiles[2])
            elseif #tiles == 3 then -- Top and Bottom differ
                return minetest.inventorycube(tiles[1], tiles[3], tiles[3])
            elseif #tiles == 6 then -- All sides
                return minetest.inventorycube(tiles[1], tiles[6], tiles[5])
            end
        end
    end

    return ""
end

local function get_pointed_node(player)
	local dir = vector.multiply(player:get_look_dir(), 5)
	local begin = vector.add(player:get_pos(), {x = 0, y = 13/8, z = 0})
	local rc = Raycast(begin, vector.add(begin, dir))
	for i in rc do
		if i.type == "node" and minetest.get_node(i.above).name ~= "air" then
			return i.above
		end
	end
end

hud.register_globalstep("block_info", {
	period = 0.2,
	callback = function()
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local pn, pos = players[i]:get_player_name(), get_pointed_node(players[i])
			if pos then
				local def = minetest.registered_items[minetest.get_node(pos).name] or {}
				if def.description ~= block_descriptions[pn] then
					if block_descriptions[pn] == "" then
						players[i]:hud_change(huds[pn].bg, "text", "trinium_hud.background.png")
					end
					block_descriptions[pn] = def.description
					players[i]:hud_change(huds[pn].node, "text", (def.description or "???"):split"\n"[1])
					players[i]:hud_change(huds[pn].mod, "text", api.string_superseparation(def.mod_origin or "???"))
					players[i]:hud_change(huds[pn].image, "text", generate_inv_cube(def))
				end
			else
				players[i]:hud_change(huds[pn].bg, "text", "")
				players[i]:hud_change(huds[pn].node, "text", "")
				players[i]:hud_change(huds[pn].mod, "text", "")
				players[i]:hud_change(huds[pn].image, "text", "")
				block_descriptions[pn] = ""
			end
		end
	end,
})
