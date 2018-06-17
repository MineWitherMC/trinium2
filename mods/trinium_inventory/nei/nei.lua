local api = trinium.api
local recipes = trinium.recipes

local nei = trinium.nei
local S = nei.S
nei.player_stuff = {}

local function get_formspec_array(search_string, mode)
	local ss, items = search_string:lower()
	local formspec, width, height, cell_size, i, j = {}, 8, nei.integrate and 9 or 7, 1, 0, 1
	local length_per_page = width * height
	items = table.filter(minetest.registered_items, function(v)
		return (
				v.mod_origin ~= "*builtin*" and
						not (v.groups or {}).hidden_from_nei and
						not (v.groups or {}).hidden_from_irp and
						((v.description and v.description:lower():find(ss)) or v.name:lower():find(ss) or v.mod_origin:lower():find(ss))
		)
	end)
	local x, y
	local page_amount = math.max(math.ceil(table.count(items) / length_per_page), 1)
	local pa = math.ceil(table.count(items) / length_per_page)
	for j = 1, page_amount do
		formspec[j] = ([=[
			field[0.25,%s;%s,1;search;;%s]
			field_close_on_enter[search;false]
			button[%s,%s;1,1;search_use;>>]
			button[%s,%s;1,1;search_clear;X]
			label[1,0.2;%s]
			button[0,0.2;1,0.5;page_open~-1;<]
			button[%s,0.2;1,0.5;page_open~+1;>]
		]=]):format(height * cell_size + 1.3, width * cell_size - 2, search_string,
				width * cell_size - 2, height * cell_size + 1, width * cell_size - 1, height * cell_size + 1,
				S("Page @1 of @2", math.min(j, pa), pa), width * cell_size - 1)

		if trinium.creative_mode then
			formspec[j] = formspec[j] .. ([=[
				button[%s,0.2;3,0.5;change_mode;%s]
				tooltip[change_mode;%s]
			]=]):format(width * cell_size - 4, S "Change Mode", S("Current mode: @1", mode == 0 and S "Recipes" or S "Cheat"))
		end
	end
	j = 1
	local tbl = {}
	for _, z in pairs(items) do
		tbl[#tbl + 1] = z
	end
	table.sort(tbl, api.sort_by_param "name")
	for _, v in ipairs(tbl) do
		if v.type ~= "none" then
			x = i % width
			y = (i - x) / width
			formspec[j] = formspec[j] .. ([=[
				item_image_button[%s,%s;%s,%s;%s;%s~%s;]
				tooltip[view_recipe~%s;%s]
			]=]):format(x * cell_size, y * cell_size + 1, cell_size, cell_size, v.name,
					mode == 1 and "give" or "view_recipe", v.name, v.name,
					api.get_field(v.name, "description") .. "\n" ..
							minetest.colorize("#4d82d7", api.string_superseparation(api.get_field(v.name, "mod_origin"))))
			i = i + 1
			if i >= length_per_page then
				i = 0
				j = j + 1
			end
		end
	end

	if i == 0 then j = j - 1 end
	return formspec, j, { x = width * cell_size, y = height * cell_size + 1.6 }
end

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	nei.player_stuff[pn] = {}
	local ps = nei.player_stuff[pn]
	ps.page = 1
	ps.search = ""
	ps.formspecs_array, ps.page_amount, ps.size = get_formspec_array("", 0)
	ps.mode = 0
end)

local item_panel = { description = S "NeverEnoughItems" }

function item_panel.getter(player)
	local pn = player:get_player_name()
	local ps = nei.player_stuff[pn]
	return betterinv.generate_formspec(player, ps.formspecs_array[ps.page],
			ps.size, false, false)
end

function nei.draw_recipe_raw(id)
	local recipe = recipes.recipe_registry[math.modulate(id, #recipes.recipe_registry)]
	local method = recipes.methods[recipe.type]

	local formspec = ("%s label[0,0;%s]"):format(method.formspec_begin(recipe.data), method.formspec_name)

	local it, ot = recipe.data.input_tooltips, recipe.data.output_tooltips
	local item_name, amount, x, y, arr, chance
	for i = 1, method.input_amount do
		amount = nil
		if recipe.inputs[i] then
			arr = recipe.inputs[i]:split " "
			item_name, amount = unpack(arr)
		else
			item_name = ""
		end
		x, y = method.get_input_coords(i)
		formspec = formspec .. ("item_image_button[%s,%s;1,1;%s;view_recipe~%s~1~1~i%s;%s]box[%s,%s;0.925,0.95;#0000FF]")
				:format(x, y, item_name, item_name, i, amount ~= "1" and amount or "", x - 1 / 20, y - 1 / 20)

		if it and it[i] then
			formspec = formspec .. ("tooltip[view_recipe~%s~1~1~i%s;%s]"):format(item_name, i, it[i])
		end
	end

	for i = 1, method.output_amount do
		chance, amount = nil, nil
		if recipe.outputs[i] then
			arr = recipe.outputs[i]:split " "
			item_name, amount, chance = unpack(arr)
		else
			item_name = ""
		end
		x, y = method.get_output_coords(i)
		formspec = formspec .. ("item_image_button[%s,%s;1,1;%s;view_recipe~%s~1~1~o%s;%s]box[%s,%s;0.925,0.95;#FFA500]")
				:format(x, y, item_name, item_name, i, table.f_concat(
				{ amount ~= "1" and amount or nil, chance and chance .. " %" }, "\n"), x - 1 / 20, y - 1 / 20)

		if ot and ot[i] then
			formspec = formspec .. ("tooltip[view_recipe~%s~1~1~o%s;%s]"):format(item_name, i, ot[i])
		end
	end

	return { form = formspec, w = method.formspec_width, h = method.formspec_height }
end

function nei.draw_recipe_wrapped(item, player, id, type)
	local tbl = ((type == 1) and recipes.recipes or recipes.usages)[item] or {}
	tbl = table.remap(table.filter(tbl, function(r)
		local v = recipes.recipe_registry[r]
		return recipes.methods[v.type].can_perform(player, v.data)
	end))

	local fs_base

	if #tbl > 0 then
		id = math.modulate(id, #tbl)
		fs_base = nei.draw_recipe_raw(tbl[math.modulate(id, #tbl)])
	else
		id = 0
		fs_base = {
			w = 6,
			h = 4,
			form = ([=[
				label[0,0.5;%s]
				item_image[2,1.5;2,2;%s]
			]=]):format(S("No @1 found for this item.", type == 1 and S "recipes" or S "usages"), item),
		}
	end

	local actual_formspec = {
		("size[%s,%s]"):format(fs_base.w, fs_base.h + 1),
		("tabheader[0,0;change_nei_mode~%s;%s,%s;%s;true;false]"):format(item, S "Recipes", S "Usages", type),
		fs_base.form,
		("label[1,%s;%s]"):format(fs_base.h + 0.5, S("Recipe @1 of @2", id, #tbl)),
		("button[0,%s;1,1;view_recipe~%s~%s~%s;<]"):format(fs_base.h + 0.3, item, id - 1, type),
		("button[%s,%s;1,1;view_recipe~%s~%s~%s;>]"):format(fs_base.w - 1, fs_base.h + 0.3, item, id + 1, type),
	}

	return table.concat(actual_formspec)
end

function item_panel.processor(player, _, fields)
	if fields.quit then return end
	if fields.key_enter then
		fields.search_use = 1
	end
	local pn = player:get_player_name()
	local ps = nei.player_stuff[pn]

	for k in pairs(fields) do
		local k_split = k:split("~") -- Module, action, parameters
		local a = k_split[1]
		if a == "search_use" then
			ps.formspecs_array, ps.page_amount = get_formspec_array(fields.search, ps.mode)
		elseif a == "search_clear" then
			ps.formspecs_array, ps.page_amount = get_formspec_array("", ps.mode)
		elseif a == "page_open" then
			ps.page = math.modulate(ps.page + tonumber(k_split[2]), ps.page_amount)
		elseif a == "change_mode" then
			ps.mode = 1 - ps.mode
			ps.formspecs_array, ps.page_amount = get_formspec_array(fields.search, ps.mode)
		elseif a == "view_recipe" then
			local item, num, type = k_split[2], tonumber(k_split[3]), tonumber(k_split[4])
			local fs = nei.draw_recipe_wrapped(item, player, num or 1, type or 1)
			minetest.show_formspec(pn, "nei:recipe_view", fs)
		elseif a == "give" then
			local item = k_split[2]
			local stack = minetest.registered_items[item].stack_max
			player:get_inventory():add_item("main", item .. " " .. stack)
			cmsg.push_message_player(player, S("Given @1 @2 to @3", stack, item, pn))
		end
	end
end

minetest.register_on_player_receive_fields(function(player, form_name, fields)
	if form_name ~= "nei:recipe_view" then
		return
	end
	local fs = false

	for k, v in pairs(fields) do
		local k_split = k:split "~" -- Module, action, parameters
		local a = k_split[1]
		if a == "change_nei_mode" then
			fs = nei.draw_recipe_wrapped(k_split[2], player, 1, tonumber(v))
		elseif a == "view_recipe" then
			local item, num, type = k_split[2], tonumber(k_split[3]), tonumber(k_split[4])
			fs = nei.draw_recipe_wrapped(item, player, num, type)
		end
	end

	if fs then
		local pn = player:get_player_name()
		minetest.show_formspec(pn, "nei:recipe_view", fs)
	end
end)

betterinv.register_tab("item_panel", item_panel)
