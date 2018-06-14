local api = trinium.api
local S = api.S
local recipes = trinium.recipes

trinium.nei = {}
local nei = trinium.nei
nei.player_stuff = {}

local S1 = {S"Recipe", S"Usage", S"Cheat"}

local function get_formspec_array(search_string, mode)
	local ss, items = search_string:lower()
	local formspec, lengthPerPage, i, j = {}, 56, 0, 1
	items = table.filter(minetest.registered_items, function(v)
		return (
			v.mod_origin ~= "*builtin*" and
			not (v.groups or {}).hidden_from_nei and
			not (v.groups or {}).hidden_from_irp and
			((v.description and v.description:lower():find(ss)) or v.name:lower():find(ss) or v.mod_origin:lower():find(ss))
		)
	end)
	local x, y
	local page_amount = math.max(math.ceil(table.count(items) / lengthPerPage), 1)
	local pa = math.ceil(table.count(items) / lengthPerPage)
	for j = 1, page_amount do
		formspec[j] = ([=[
			field[0.25,8.8;6,0;search;;%s]
			field_close_on_enter[search;false]
			button[6,8.1;1,1;search_use;>>]
			button[7,8.1;1,1;search_clear;X]
			label[1,0.2;%s]
			button[0,0.2;1,0.5;page_open~-1;<]
			button[7,0.2;1,0.5;page_open~+1;>]
			button[5,0.2;2,0.5;change_mode;%s]
			tooltip[change_mode;%s]
		]=]):format(search_string, S("Page @1 of @2", math.min(j, pa), pa), S "Change Mode",
			S("Current mode: @1", S1[mode]))
	end
	j = 1
	local tbl = {}
	for _, z in pairs(items) do
		tbl[#tbl + 1] = z
	end
	table.sort(tbl, api.sort_by_param"name")
	for _,v in ipairs(tbl) do
		if v.type ~= "none" then
			x = i % 8
			y = (i - x) / 8
			formspec[j] = formspec[j]..([=[
				item_image_button[%s,%s;1,1;%s;view_recipe~%s;]
				tooltip[view_recipe~%s;%s]
			]=]):format(x, y + 1, v.name, v.name, v.name, api.get_field(v.name, "description")..
					"\n"..minetest.colorize("#4d82d7", api.string_superseparation(api.get_field(v.name, "mod_origin"))))
			i = i + 1
			if i >= lengthPerPage then
				i = 0
				j = j + 1
			end
		end
	end

	if i == 0 then j = j - 1 end
	return formspec, j
end

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	nei.player_stuff[pn] = {}
	nei.player_stuff[pn].page = 1
	nei.player_stuff[pn].search = ""
	nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount = get_formspec_array("", 1)
end)

local item_panel = { description = S "NeverEnoughItems" }

function item_panel.getter(player, context)
	local pn = player:get_player_name()
	return sfinv.make_formspec(player, context, nei.player_stuff[pn].formspecs_array[nei.player_stuff[pn].page], false)
end

function nei.absolute_draw_recipe(l_recipes, rec_id)
	local id = rec_id
	local max = #recipes.recipe_registry
	if l_recipes then
		max = #l_recipes
		if max == 0 then return "", 0, 0, 0 end
		id = math.modulate(rec_id or 1, max)
	end
	local recipe = l_recipes and recipes.recipe_registry[l_recipes[id]] or recipes.recipe_registry[id]
	local method = recipes.methods[recipe.type]

	local formspec = ("%s label[0,0;%s]"):format(method.formspec_begin(recipe.data), method.formspec_name)
	
	local it, ot = recipe.data.input_tooltips, recipe.data.output_tooltips
	local item_name, amount, x, y, arr, chance
	for i = 1, method.input_amount do
		amount = nil
		if recipe.inputs[i] then
			arr = recipe.inputs[i]:split" "
			item_name, amount = unpack(arr)
		else
			item_name = ""
		end
		x, y = method.get_input_coords(i)
		formspec = formspec..("item_image_button[%s,%s;1,1;%s;view_recipe~%s~i%s;%s]box[%s,%s;0.925,0.95;#0000FF]")
				:format(x, y, item_name, item_name, i, amount ~= "1" and amount or "", x - 1 / 20, y - 1 / 20)

		if it and it[i] then
			formspec = formspec .. ("tooltip[view_recipe~%s~i%s;%s]"):format(item_name, i, it[i])
		end
	end

	for i = 1, method.output_amount do
		chance, amount = nil, nil
		if recipe.outputs[i] then
			arr = recipe.outputs[i]:split" "
			item_name, amount, chance = unpack(arr)
		else
			item_name = ""
		end
		x, y = method.get_output_coords(i)
		formspec = formspec..("item_image_button[%s,%s;1,1;%s;view_recipe~%s~o%s;%s]box[%s,%s;0.925,0.95;#FFA500]")
				:format(x, y, item_name, item_name, i, table.f_concat(
					{amount ~= "1" and amount or nil, chance and chance.." %"}, "\n"), x - 1/20, y - 1/20)

		if ot and ot[i] then
			formspec = formspec .. ("tooltip[view_recipe~%s~o%s;%s]"):format(item_name, i, ot[i])
		end
	end

	return formspec, method.formspec_width, method.formspec_height, max, id
end

function nei.draw_recipe(item, player, rec_id, tbl1, rec_method)
	local recipes1 = tbl1[item]
	if not recipes1 then return "", 0, 0, 0 end
	recipes1 = table.remap(table.filter(recipes1, function(v1)
		local v = recipes.recipe_registry[v1]
		return v.type == (rec_method or v.type) and recipes.methods[v.type].can_perform(player, v.data)
	end))
	return nei.absolute_draw_recipe(recipes1, rec_id)
end

function nei.draw_research_recipe(recipe_id)
	local x = { nei.absolute_draw_recipe(false, recipe_id) }
	return {form = x[1], w = x[2], h = x[3]}
end

local function get_formspec(pn, id, item, mode)
	if mode < 3 then
		local formspec, width, height, number, new_id = nei.draw_recipe(item, pn, tonumber(id), mode == 1 and recipes.recipes or recipes.usages)
		if not formspec or width == 0 or height == 0 then return end
		formspec = ([=[
			size[%s,%s]
			%s
			label[0,%s;%s]
		]=]):format(width, height + 0.5,
				formspec, height + 0.2, S("@1 @2 of @3", S1[mode], new_id, number))

		if number > 1 then
			formspec = formspec..([=[
				button[%s,0;1,0.5;view_recipe~%s~%s;<]
				button[%s,0;1,0.5;view_recipe~%s~%s;>]
			]=]):format(width - 2, item, new_id - 1, width - 1, item, new_id + 1)
		end

		return formspec
	else
		local stack = minetest.registered_items[item].stack_max
		local player = minetest.get_player_by_name(pn)
		player:get_inventory():add_item("main", item.." "..stack)
		cmsg.push_message_player(player, S("Given @1 @2 to @3", stack, item, pn))
	end
end

function item_panel.processor(player, context, fields)
	if fields.quit then return end
	if fields.key_enter then
		fields.search_use = 1
	end
	context.nei_mode = context.nei_mode or 1
	local pn = player:get_player_name()
	for k in pairs(fields) do
		local k_split = k:split("~") -- Module, action, parameters
		local a = k_split[1]
		if a == "search_use" then
			nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount = get_formspec_array(fields.search, context.nei_mode)
		elseif a == "search_clear" then
			nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount = get_formspec_array("", context.nei_mode)
		elseif a == "page_open" then
			nei.player_stuff[pn].page = math.modulate(nei.player_stuff[pn].page + tonumber(k_split[2]), nei.player_stuff[pn].page_amount)
		elseif a == "change_mode" then
			context.nei_mode = context.nei_mode % (trinium.creative_mode and 3 or 2) + 1
			nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount = get_formspec_array(fields.search, context.nei_mode)
		elseif a == "view_recipe" then
			local fs = get_formspec(pn, k_split[3] or 1, k_split[2], context.nei_mode)
			if not fs then return end
			minetest.show_formspec(pn, "trinium:nei:recipe_view", fs)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, form_name, fields)
	if form_name == "" then
		return
	end
	local pn = player:get_player_name()
	for k in pairs(fields) do
		local k_split = k:split "~" -- Module, action, parameters
		local a = k_split[1]
		if a == "view_recipe" then
			local fs = get_formspec(pn, k_split[3] or 1, k_split[2], betterinv.contexts[pn].item_panel.nei_mode)
			if not fs then return end
			minetest.show_formspec(pn, "trinium:nei:recipe_view", fs)
		end
	end
end)

betterinv.register_tab("item_panel", item_panel)
