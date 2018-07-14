local bi = trinium.bound_inventories
local api = trinium.api
local S = trinium.player_S
local recipes = trinium.recipes

function api.try_craft(player)
	local pn = player:get_player_name()
	local inv = bi[pn]
	local list = inv:get_list"crafting"
	for i = 1, 9 do
		list[i] = list[i]:get_name()
	end
	list = recipes.stringify(9, list)
	local rr = recipes.recipe_registry
	local rbm = recipes.recipes_by_method.crafting
	if not rbm then return end

	local recipe = table.exists(rbm, function(v) return rr[v].inputs_string == list end)
	local output = recipe and rr[rbm[recipe]].outputs[1] or ""
	inv:set_stack("output", 1, output)
	betterinv.redraw_for_player(player)
end

-- Crafting
betterinv.register_tab("inventory", {
	description = S"Crafting",
	getter = function(player)
		local pn = player:get_player_name()
		local inv2 = bi[pn]
		local str = inv2 and inv2:get_stack("output", 1):to_string() or ""
		return betterinv.generate_formspec(player, ([[
				list[detached:bound~%s;crafting;1.75,0.5;3,3;]
				item_image_button[5.75,1.5;1,1;%s;inventory~craft;]
				image[4.75,1.5;1,1;trinium_gui.arrow.png]
				image[0,4.75;1,1;trinium_gui_hb_bg.png]
				image[1,4.75;1,1;trinium_gui_hb_bg.png]
				image[2,4.75;1,1;trinium_gui_hb_bg.png]
				image[3,4.75;1,1;trinium_gui_hb_bg.png]
				image[4,4.75;1,1;trinium_gui_hb_bg.png]
				image[5,4.75;1,1;trinium_gui_hb_bg.png]
				image[6,4.75;1,1;trinium_gui_hb_bg.png]
				image[7,4.75;1,1;trinium_gui_hb_bg.png]
				listring[current_player;main]listring[detached:bound~%s;crafting]
			]]):format(pn, str, pn), false, false, true)
	end,
	processor = function(player, _, fields)
		if fields.quit then return end
		local pn = player:get_player_name()
		local inv1, inv2 = player:get_inventory(), bi[pn]
		for k in pairs(fields) do
			local k_split = k:split"~" -- Module, action, parameters
			if k_split[1] == "inventory" then
				local a = k_split[2]
				if a == "craft" then
					local s = inv2:get_stack("output", 1):to_string()
					if s ~= "" then
						if not inv1:room_for_item("main", s) then
							cmsg.push_message_player(player, S"Inventory is full!")
						else
							inv1:add_item("main", s)
							for i = 1, 9 do
								local s1 = inv2:get_stack("crafting", i)
								s1:take_item()
								inv2:set_stack("crafting", i, s1)
							end
							api.try_craft(player)
						end
					end
				end
			end
		end
	end,
})