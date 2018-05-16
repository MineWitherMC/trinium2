local api = trinium.api
local S = api.S
local recipes = trinium.recipes

trinium.nei = {}
local nei = trinium.nei
nei.player_stuff = {}

local S1 = {S"Recipe", S"Usage", S"Cheat"}

local function get_formspec_array(searchstring, mode)
	local ss, items = searchstring:lower()
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
			button[0,0.2;1,0.5;pageopen~-1;<]
			button[7,0.2;1,0.5;pageopen~+1;>]
			button[5,0.2;2,0.5;changemode;%s]
			tooltip[changemode;%s]
		]=]):format(searchstring, S("Page @1 of @2", math.min(j, pa), pa), S"Change Mode",
			S("Current mode: @1", S1[mode]))
	end
	j = 1
	local tbl = {}
	for _,iter in pairs(items) do
		tbl[#tbl+1] = iter
	end
	table.sort(tbl, api.sort_by_param"name")
	for k,v in ipairs(tbl) do
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

local itempanel = {title = S"NeverEnoughItems"}

function itempanel:get(player, context)
	local pn = player:get_player_name()
	return sfinv.make_formspec(player, context, nei.player_stuff[pn].formspecs_array[nei.player_stuff[pn].page], false)
end

function nei.absolute_draw_recipe(lrecipes, rec_id)
	local max = #lrecipes
	if max == 0 then return "", 0, 0, 0 end
	local id = math.modulate(rec_id or 1, max)
	local recipe = recipes.recipe_registry[lrecipes[id]]
	local method = recipes.methods[recipe.type]

	local formspec = ("%slabel[0,0;%s]"):format(method.formspec_begin(recipe.data), method.formspec_name)
	local itemname, amount, x, y, arr, chance
	for i = 1, method.input_amount do
		amount = nil
		if recipe.inputs[i] then
			arr = recipe.inputs[i]:split" "
			itemname, amount = unpack(arr)
		else
			itemname = ""
		end
		x, y = method.get_input_coords(i)
		formspec = formspec..("item_image_button[%s,%s;1,1;%s;view_recipe~%s;%s]"):format(x, y,
				itemname, itemname, amount ~= 1 and amount ~= "1" and amount or "" or "")
	end
	for i = 1, method.output_amount do
		chance, amount = nil, nil
		if recipe.outputs[i] then
			arr = recipe.outputs[i]:split" "
			itemname, amount, chance = unpack(arr)
		else
			itemname = ""
		end
		x, y = method.get_output_coords(i)
		formspec = formspec..("item_image_button[%s,%s;1,1;%s;view_recipe~%s;%s]"):format(x, y, itemname, itemname,
				table.fconcat({amount ~= 1 and amount ~= "1" and amount or nil, chance and chance.." %" or nil}, "\n"))
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

local R = recipes.recipes
function nei.draw_research_recipe(item, num)
	local x = {nei.absolute_draw_recipe(R[item], num or 1)}
	return {form = x[1], w = x[2], h = x[3]}
end

local function get_formspec(player, id, item, mode)
	if mode < 3 then
		local formspec, width, height, number, new_id =
				nei.draw_recipe(item, player, tonumber(id), mode == 1 and recipes.recipes or recipes.usages)
		if not formspec or width == 0 or height == 0 then return end
		formspec = ([=[
			size[%s,%s]
			%s
			label[0,%s;%s]
		]=]):format(width + 0.5, height + 0.5,
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
		local pn = player
		local player = minetest.get_player_by_name(pn)
		player:get_inventory():add_item("main", item.." "..stack)
		cmsg.push_message_player(player, S("Given @1 @2 to @3", stack, item, pn))
	end
end

function itempanel:on_player_receive_fields(player, context, fields)
	if fields.quit then return end
	if fields.key_enter then
		fields.search_use = 1
	end
	context.neimode = context.neimode or 1
	local pn = player:get_player_name()
	for k,v in pairs(fields) do
		local ksplit = k:split("~") -- Module, action, parameters
		local a = ksplit[1]
		if a == "search_use" then
			nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount =
					get_formspec_array(fields.search, context.neimode)
		elseif a == "search_clear" then
			nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount =
					get_formspec_array("", context.neimode)
		elseif a == "pageopen" then
			nei.player_stuff[pn].page =
					math.modulate(nei.player_stuff[pn].page + tonumber(ksplit[2]), nei.player_stuff[pn].page_amount)
		elseif a == "changemode" then
			context.neimode = context.neimode % (trinium.creative_mode and 3 or 2) + 1
			nei.player_stuff[pn].formspecs_array, nei.player_stuff[pn].page_amount =
					get_formspec_array(fields.search, context.neimode)
		elseif a == "view_recipe" then
			local fs = get_formspec(pn, ksplit[3] or 1, ksplit[2], context.neimode)
			if not fs then return end
			minetest.show_formspec(pn, "trinium:nei:recipe_view", fs)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "" then return end
	local pn = player:get_player_name()
	for k,v in pairs(fields) do
		local ksplit = k:split"~" -- Module, action, parameters
		local a = ksplit[1]
		if a == "view_recipe" then
			local fs = get_formspec(pn, ksplit[3] or 1, ksplit[2], betterinv.contexts[pn]["trinium:itempanel"].neimode)
			if not fs then return end
			minetest.show_formspec(pn, "trinium:nei:recipe_view", fs)
		end
	end
end)

sfinv.register_page("trinium:itempanel", itempanel)
