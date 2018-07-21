local api = trinium.api
local recipes = trinium.recipes

local nei = trinium.nei
local S = nei.S
nei.player_stuff = {}

local function satisfies_search(search_string)
	local expansion = api.search(search_string, api.functions.identity, function(z)
		local tbl = {}
		local i = z:match("%(([^()]+)%)")
		if i then
			local tbl2 = i:split"|"
			for j = 1, #tbl2 do
				local k = tbl2[j]
				local str = z:gsub("%(([^()]+)%)", k, 1)
				tbl[str] = 1
			end
		end
		return tbl
	end):push(search_string):map(function(q)
		return q:gsub("%*", ".*")
	end):filter(function(z) return not z:find"%(" end)

	local exp2 = api.DataMesh:new()
	expansion:forEach(function(q)
		for _,i in pairs(q:split"|") do
			exp2:push(i:split" ")
		end
	end)
	exp2:filter(function(q) return q ~= "" end)

	return function(v)
		if v.mod_origin == "*builtin*" then return false end
		if v.groups and v.groups.not_in_creative_inventory then return false end
		if not v.description then return false end
		if search_string == "" then return true end
		local desc, name = v.description:lower(), v.name:lower()
		return exp2:exists(function(z)
			return table.every(z, function(z2)
				if z2:sub(1, 1) == "@" then
					return name:find(z2:sub(2))
				else
					return desc:find(z2)
				end
			end)
		end)
	end
end

local function get_formspec_array(search_string, mode)
	local ss = search_string:lower()
	local formspec, width, height, cell_size, i = {}, 8, nei.integrate and 9 or 7, 1, 0
	local length_per_page = width * height
	local items = table.filter(minetest.registered_items, satisfies_search(ss))
	local x, y
	local page_amount = math.max(math.ceil(table.count(items) / length_per_page), 1)
	local pa = math.ceil(table.count(items) / length_per_page)
	for j = 1, page_amount do
		formspec[j] = ([=[
			field[0.25,${height_search};${width_search},1;search;;${search}]
			field_close_on_enter[search;false]
			button[${width_search},${height_search_buttons};1,1;search_use;>>]
			button[${width_search2},${height_search_buttons};1,1;search_clear;X]
			label[1,0.2;${page_number}]
			button[0,0.2;1,0.5;page_open~-1;<]
			button[${width_search2},0.2;1,0.5;page_open~+1;>]
		]=]):from_table{
			height_search = height * cell_size + 1.3,
			height_search_buttons = height * cell_size + 1,
			width_search = width * cell_size - 2,
			width_search2 = width * cell_size - 1,
			search = search_string,
			page_number = S("Page @1 of @2", math.min(j, pa), pa),
		}

		if trinium.creative_mode then
			formspec[j] = formspec[j] .. ([=[
				button[${change_mode_coord},0.2;3,0.5;change_mode;${change_mode_text}]
				tooltip[change_mode;${current_mode}]
			]=]):from_table{
				change_mode_coord = width * cell_size - 4,
				change_mode_text = S"Change Mode",
				current_mode = S("Current mode: @1", mode == 0 and S"Recipes" or S"Cheat"),
			}
		end
	end
	local j = 1
	local tbl = {}
	for _, z in pairs(items) do
		tbl[#tbl + 1] = z
	end
	table.sort(tbl, api.sort_by_param"name")
	for _, v in ipairs(tbl) do
		if v.type ~= "none" then
			x = i % width
			y = (i - x) / width
			formspec[j] = formspec[j] .. ([=[
				item_image_button[${cell_x},${cell_y};${cell_size},${cell_size};${item_id};${current_mode}~${item_id};]
				tooltip[${current_mode}~${item_id};${description}]=] .. "\n${mod_origin}]"):from_table{
				cell_x = x * cell_size,
				cell_y = y * cell_size + 1,
				cell_size = cell_size,
				item_id = v.name,
				current_mode = mode == 1 and "give" or "view_recipe",
				description = api.get_description(v.name),
				mod_origin = minetest.colorize("#4d82d7", api.string_superseparation(api.get_field(v.name, "mod_origin"))),
			}
			i = i + 1
			if i >= length_per_page then
				i = 0
				j = j + 1
			end
		end
	end

	if i == 0 then j = j - 1 end
	return formspec, j, {x = width * cell_size, y = height * cell_size + 1.6}
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

local item_panel = {description = S"NeverEnoughItems"}

function item_panel.getter(player)
	local pn = player:get_player_name()
	local ps = nei.player_stuff[pn]
	return betterinv.generate_formspec(player, ps.formspecs_array[math.min(ps.page, ps.page_amount)],
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
			arr = recipe.inputs[i]:split" "
			item_name, amount = unpack(arr)
		else
			item_name = ""
		end
		x, y = method.get_input_coords(i)
		formspec = formspec .. ([=[
			item_image_button[${width},${height};1,1;${id};view_recipe~${id}~1~1~i${number};${amount}]
			box[${box_x},${box_y};0.9375,0.95;#0000FF]
		]=]):from_table{
			width = x,
			height = y,
			id = item_name,
			number = i,
			amount = amount ~= "1" and amount or "",
			box_x = x - 1 / 20,
			box_y = y - 1 / 20,
		}

		if it and it[i] then
			formspec = formspec .. ("tooltip[view_recipe~%s~1~1~i%s;%s]"):format(item_name, i, it[i])
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
		formspec = formspec .. ([=[
			item_image_button[${width},${height};1,1;${id};view_recipe~${id}~1~1~o${number};${amount}]
			box[${box_x},${box_y};0.9375,0.95;#FFA500]
		]=]):from_table{
			width = x,
			height = y,
			id = item_name,
			number = i,
			amount = table.f_concat({amount ~= "1" and amount or nil, chance and chance .. " %"}, "\n"),
			box_x = x - 1 / 20,
			box_y = y - 1 / 20,
		}

		if ot and ot[i] then
			formspec = formspec .. ("tooltip[view_recipe~%s~1~1~o%s;%s]"):format(item_name, i, ot[i])
		end
	end

	return {form = formspec, w = method.formspec_width, h = method.formspec_height}
end

function nei.draw_recipe_wrapped(item, player, id, r_type)
	local tbl
	if r_type == 1 then
		tbl = recipes.recipes[item]
	elseif r_type == 2 then
		tbl = recipes.usages[item]
	elseif r_type == 3 then
		tbl = table.merge({}, unpack(recipes.implementing_objects[item] or {}))
	end
	tbl = tbl or {}

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
		local message = ""
		if r_type == 1 then
			message = S"recipes"
		elseif r_type == 2 then
			message = S"usages"
		elseif r_type == 3 then
			message = S"implements"
		end

		fs_base = {
			w = 6,
			h = 4,
			form = ([=[
				label[0,0.5;%s]
				item_image[2,1.5;2,2;%s]
			]=]):format(S("No @1 found for this item.", message), item),
		}
	end

	local actual_formspec = {
		("size[%s,%s]"):format(fs_base.w, fs_base.h + 1),
		("tabheader[0,0;change_nei_mode~${item};${rec},${use},${impl};${current};true;false]"):from_table{
			item = item,
			current = r_type,
			rec = S"Recipes",
			use = S"Usages",
			impl = S"Implements",
		},
		fs_base.form,
		("label[1,%s;%s]"):format(fs_base.h + 0.5, S("Recipe @1 of @2", id, #tbl)),
		("button[0,%s;1,1;view_recipe~%s~%s~%s;<]"):format(fs_base.h + 0.3, item, id - 1, r_type),
		("button[%s,%s;1,1;view_recipe~%s~%s~%s;>]"):format(fs_base.w - 1, fs_base.h + 0.3, item, id + 1, r_type),
	}

	return table.concat(actual_formspec), {x = fs_base.w, y = fs_base.h + 1}, id ~= 0 and tbl[id] or 0
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
		local k_split = k:split"~" -- Module, action, parameters
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
