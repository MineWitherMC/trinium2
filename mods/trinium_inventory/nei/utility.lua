local api = trinium.api
local bi = trinium.bound_inventories
local S = trinium.player_S

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	local dp = api.get_data_pointer(pn, "bound_inventories")
	bi[pn] = minetest.create_detached_inventory("bound~" .. pn, {
		allow_move = function(_, from_list, _, to_list, _, count)
			return from_list ~= "trash" and count or 0
		end,

		allow_take = function(_, _, _, stack)
			return stack:get_count()
		end,

		on_move = function(inv, from_list, from_index, to_list, to_index, _, player)
			dp[from_list] = dp[from_list] or {}
			dp[to_list] = dp[to_list] or {}

			if to_list == "crafting" then
				api.try_craft(player)
			elseif to_list == "trash" then
				inv:set_stack("trash", 1, "")
			end

			dp[from_list][from_index] = inv:get_stack(from_list, from_index):to_string()
			dp[to_list][to_index] = inv:get_stack(to_list, to_index):to_string()
		end,

		on_put = function(inv, list_name, index, _, player)
			dp[list_name] = dp[list_name] or {}

			if list_name == "trash" then
				inv:set_stack("trash", 1, "")
			elseif list_name == "crafting" then
				api.try_craft(player)
			end

			dp[list_name][index] = inv:get_stack(list_name, index):to_string()
		end,

		on_take = function(inv, list_name, index, _, player)
			if not dp[list_name] then
				dp[list_name] = {}
			end
			dp[list_name][index] = inv:get_stack(list_name, index):to_string()
			if list_name == "crafting" then
				api.try_craft(player)
			end
		end,
	})
	api.initialize_inventory(bi[pn], { trash = 1, crafting = 9, output = 1 })
	for k, v in pairs(dp._strings) do
		for k1, v1 in pairs(v) do
			bi[pn]:set_stack(k, k1, v1)
		end
	end
end)

-- Utility
betterinv.register_tab("utilities", {
	description = S "Utility",
	getter = function(player, context)
		local pn = player:get_player_name()
		return betterinv.generate_formspec(player, ([[
				list[detached:bound~%s;trash;0.5,0.5;1,1]
				image[0.5,1.5;1,1;trinium_gui.trash.png]
				image[0,4.75;1,1;trinium_gui_hb_bg.png]
				image[1,4.75;1,1;trinium_gui_hb_bg.png]
				image[2,4.75;1,1;trinium_gui_hb_bg.png]
				image[3,4.75;1,1;trinium_gui_hb_bg.png]
				image[4,4.75;1,1;trinium_gui_hb_bg.png]
				image[5,4.75;1,1;trinium_gui_hb_bg.png]
				image[6,4.75;1,1;trinium_gui_hb_bg.png]
				image[7,4.75;1,1;trinium_gui_hb_bg.png]
				listring[current_player;main]listring[detached:bound~%s;trash]
			]]):format(pn, pn), false, false, true)
	end
})
