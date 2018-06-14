local api = trinium.api
local bi = trinium.bound_inventories
local S = trinium.player_S

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	local dp = api.get_data_pointer(pn, "bound_inventories")
	bi[pn] = minetest.create_detached_inventory("bound~"..pn, {
		allow_move = function(_, from_list, _, to_list, _, count)
			return to_list == "crafting" and from_list ~= "trash" and count or 0
		end,

		allow_take = function(_, _, _, stack)
			return stack:get_count()
		end,

		on_move = function(inv, from_list, from_index, to_list, to_index, _, player)
			if not dp[from_list] then dp[from_list] = {} end
			if not dp[to_list] then dp[to_list] = {} end
			dp[from_list][from_index] = inv:get_stack(from_list, from_index):to_string()
			dp[to_list][to_index] = inv:get_stack(to_list, to_index):to_string()
			if to_list == "crafting" then api.try_craft(player)
			end
		end,

		on_put = function(inv, list_name, index, _, player)
			if not dp[list_name] then
				dp[list_name] = {}
			end
			dp[list_name][index] = inv:get_stack(list_name, index):to_string()
			if list_name == "trash" then
				inv:set_stack("trash", 1, "")
				dp.trash = {}
			elseif list_name == "crafting" then
				api.try_craft(player)
			end
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
	api.initialize_inventory(bi[pn], {trash = 1, crafting = 9, output = 1})
	for k,v in pairs(dp._strings) do
		for k1,v1 in pairs(v) do
			bi[pn]:set_stack(k, k1, v1)
		end
	end
end)

-- Utility
betterinv.register_tab("trinium:utility", {
	description = S"Utility",
	getter = function(player, context)
		local pn = player:get_player_name()
		return sfinv.make_formspec(player, context, ([[
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
			]]):format(pn, pn), true)
	end
})
