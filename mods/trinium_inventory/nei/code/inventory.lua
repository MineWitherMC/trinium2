local bi = trinium.bound_inventories
local api = trinium.api
local S = trinium.nei.S
local recipes = trinium.recipes

recipes.add_method("crafting", {
	input_amount = 9,
	output_amount = 1,
	get_input_coords = recipes.coord_getter(3, 0, 0),
	get_output_coords = recipes.coord_getter(1, 4.5, 1),
	formspec_width = 7.5,
	formspec_height = 5,
	formspec_name = S"Crafting Table",

	process = function(inputs, b, data)
		if data.shapeless then
			return inputs, b, data
		end

		data.possible_inputs = {}

		local max, max_mod3 = 0, 0
		local min, min_mod3 = 10, 4
		for k in pairs(inputs) do
			if max < k then max = k end
			if min > k then min = k end
			local mod = math.modulate(k, 3)
			if max_mod3 < mod then max_mod3 = mod end
			if min_mod3 > mod then min_mod3 = mod end
		end

		while min > 3 do
			min = min - 3
			max = max - 3
			local new_inputs = {}
			for k, v in pairs(inputs) do
				new_inputs[k - 3] = v
			end
			inputs = new_inputs
		end

		while min_mod3 > 1 do
			min_mod3 = min_mod3 - 1
			max_mod3 = max_mod3 - 1
			local new_inputs = {}
			for k, v in pairs(inputs) do
				new_inputs[k - 1] = v
			end
			inputs = new_inputs
		end

		for dw = 0, 3 - max_mod3 do
			for dh = 0, 9 - max, 3 do
				local new_inputs = {}
				for k, v in pairs(inputs) do
					new_inputs[k + dw + dh] = v
				end
				data.possible_inputs[recipes.stringify(9, new_inputs)] = 1

				if data.hmirror then
					new_inputs = {}
					for k, v in pairs(inputs) do
						local key = k + dw + dh
						if key % 3 == 0 then
							key = key - 2
						elseif key % 3 == 1 then
							key = key + 2
						end
						new_inputs[key] = v
					end
					data.possible_inputs[recipes.stringify(9, new_inputs)] = 1
				end

				if data.vmirror then
					new_inputs = {}
					for k, v in pairs(inputs) do
						local key = k + dw + dh
						if key > 6 then
							key = key - 6
						elseif key < 4 then
							key = key + 6
						end
						new_inputs[key] = v
					end
					data.possible_inputs[recipes.stringify(9, new_inputs)] = 1
				end
			end
		end

		return inputs, b, data
	end,
})

function api.try_craft(player)
	local pn = player:get_player_name()
	local inv = bi[pn]
	local list = inv:get_list"crafting"
	for i = 1, 9 do
		list[i] = list[i]:get_name()
	end

	local counts2 = {}
	for i = 1, #list do
		counts2[list[i]] = (counts2[list[i]] or 0) + 1
	end

	list = recipes.stringify(9, list)
	local rr = recipes.recipe_registry
	local rbm = recipes.recipes_by_method.crafting

	local recipe = table.exists(rbm, function(k)
		local v = recipes.recipe_registry[k]
		if v.data.shapeless then
			local counts = {}
			for i = 1, #v.inputs do
				counts[v.inputs[i]] = (counts[v.inputs[i]] or 0) + 1
			end

			return table.every(counts, function(v1, k1) return counts2[k1] == v1 end) and
					table.sum(counts) == table.sum(counts2)
		else
			return v.data.possible_inputs[list]
		end
	end)

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
		local desc = api.get_description(str)
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
				listring[detached:bound~%s;crafting]
				listring[current_player;main]
				listring[detached:bound~%s;trash]
				tooltip[inventory~craft;%s]
			]]):format(pn, str, pn, pn, desc), false, false, true)
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
							api.save_inventory(pn)
						end
					end
				end
			end
		end
	end,
})
