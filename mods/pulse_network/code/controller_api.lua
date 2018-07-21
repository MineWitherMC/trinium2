local api = trinium.api
local S = pulse_network.S

function pulse_network.trigger_update(controller_pos)
	local meta = minetest.get_meta(controller_pos)
	local cd = minetest.deserialize(meta:get_string"connected_devices")
	for i = 1, #cd do
		local name1 = minetest.get_node(cd[i]).name
		if minetest.registered_items[name1].on_pulsenet_update then
			minetest.registered_items[name1].on_pulsenet_update(cd[i], controller_pos)
		end
	end
end

function pulse_network.import_to_controller(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local items = meta:get_string"inventory":data()
	local pending_recipes = meta:get_string"pending_recipes":data()
	local s = inv:get_stack("input", 1)
	if not s:is_empty() then
		local name = s:get_name()
		for i = 1, #pending_recipes do
			if s:is_empty() then break end

			local x = pending_recipes[i]
			if x[3][name] then
				local decr = math.min(x[3][name], s:get_count())
				s:take_item(decr)
				inv:set_stack("input", 1, s)
				x[3][name] = x[3][name] - decr
				if x[3][name] == 0 then x[3][name] = nil end
				x[2][name] = (x[2][name] or 0) + decr
				meta:set_string("pending_recipes", minetest.serialize(pending_recipes))
				pulse_network.update_pending_recipe(pos, i)
			end
		end
	end

	if not s:is_empty() then
		local CI, UI, CT, UT = meta:get_int"capacity_items", meta:get_int"used_items",
				meta:get_int"capacity_types", meta:get_int"used_types"
		local max_import = CI - UI
		local id = api.get_item_identifier(s)
		local dec = math.min(max_import, s:get_count())
		if items[id] then
			items[id] = items[id] + dec
			s:take_item(dec)
			inv:set_stack("input", 1, s)
			meta:set_int("used_items", UI + dec)
		elseif CT > UT then
			items[id] = dec
			s:take_item(dec)
			inv:set_stack("input", 1, s)
			meta:set_int("used_items", UI + dec)
			meta:set_int("used_types", UT + 1)
		end

		meta:set_string("inventory", minetest.serialize(items))
	end
	pulse_network.trigger_update(pos)
end

function pulse_network.export_from_controller(pos, id, count)
	local meta = minetest.get_meta(pos)
	local items = meta:get_string"inventory":data()
	if not items[id] then return false end
	count = math.min(count, items[id])
	meta:set_int("used_items", meta:get_int"used_items" - count)

	items[id] = items[id] - count
	if items[id] == 0 then
		items[id] = nil
		meta:set_int("used_types", meta:get_int"used_types" - 1)
	end
	meta:set_string("inventory", minetest.serialize(items))
	pulse_network.import_to_controller(pos)

	local tbl = id:split" "
	local additional_info = table.map(table.tail(tbl), function(z) return " "..z end)
	return tbl[1] .. " " .. count .. table.concat(additional_info)
end

function pulse_network.notify_pattern_change(pos, pattern, referrer)
	local meta = minetest.get_meta(pos)
	local patterns = meta:get_string"patterns":data()
	local pattern_data = pattern:get_meta():get_string"recipe_data":data()
	for _, v in pairs(pattern_data.outputs) do
		if not patterns[v] then
			patterns[v] = {}
		end

		if not patterns[v][referrer] then
			patterns[v][referrer] = pattern_data
		else
			patterns[v][referrer] = nil
			if table.count(patterns[v]) == 0 then
				patterns[v] = nil
			end
		end
	end

	meta:set_string("patterns", minetest.serialize(patterns))
	pulse_network.trigger_update(pos)
end

local function sequence(storage, patterns)
	return function(z, step)
		assert(step <= 10, S"Too complicated pattern sequence!")
		local name, count = unpack(z)
		if storage[name] and storage[name] >= count then
			return {}
		end

		if not patterns[name] then
			error(S("Could not craft @1 of @2!", count, api.get_description(name)))
		end

		assert(table.count(patterns[name]) == 1, S("@1 has >1 recipes!", api.get_description(name)))
		local pattern = table.random(patterns[name])

		local found = 0
		for i = 1, #pattern.outputs do
			local output, output_count = unpack(pattern.outputs[i]:split" ")
			if output == name then
				found = found + (tonumber(output_count) or 1)
			end
		end
		assert(found > 0, S"System error!")

		local recipe_number = math.ceil((count - (storage[name] or 0)) / found)
		local tbl = {}
		for _, x in pairs(pattern.inputs) do
			local input, input_count = unpack(x:split" ")
			tbl[{input, (tonumber(input_count) or 1) * recipe_number}] = 1
		end
		return tbl
	end
end

function pulse_network.request_autocraft(pos, item_id, count)
	local meta = minetest.get_meta(pos)
	if meta:get_int"active_processes" >= meta:get_int"available_processes" then
		return false, S"Insufficient crafting cores!"
	end

	local storage = meta:get_string"inventory":data()
	local patterns = meta:get_string"patterns":data()
	local a, b = pcall(api.advanced_search, {item_id, count}, api.functions.new_object, sequence(storage, patterns))
	if a then
		b:push{{item_id, count}, 1}:sort(api.sort_by_param(2, true))
		local memory = count * #b:data()
		if meta:get_int"used_memory" + memory > meta:get_int"available_memory" then
			return false, S"Insufficient crafting memory!"
		end
		return b, memory
	end
	return a, table.concat(table.tail(b:split": "), ": ")
end

function pulse_network.execute_autocraft(pos, item_id, count)
	local meta = minetest.get_meta(pos)
	local storage = meta:get_string"inventory":data()
	local dm, memory = pulse_network.request_autocraft(pos, item_id, count)
	if not dm then return end
	meta:set_int("used_memory", meta:get_int"used_memory" + memory)
	meta:set_int("active_processes", meta:get_int"active_processes" + 1)

	local CI, CT = meta:get_int"used_items", meta:get_int"used_types"

	local buffer, needed = {}, {}
	dm:forEach(function(z, k)
		local id, countx = unpack(z[1])
		local decr = math.min(countx, storage[id] or 0)

		if countx ~= decr then
			needed[id] = (needed[id] or 0) + countx - decr
		end

		if storage[id] then
			storage[id] = storage[id] - decr
			dm:data()[k][1][2] = dm:data()[k][1][2] - decr
			CI = CI - countx
			if storage[id] == 0 then
				storage[id] = nil
				CT = CT - 1
			end
			if dm:data()[k][1][2] == 0 then
				dm:data()[k] = nil
			end
			buffer[id] = (buffer[id] or 0) + countx
		end
	end):remap()

	meta:set_int("used_items", CI)
	meta:set_int("used_types", CT)
	local active_recipes = meta:get_string"pending_recipes":data()
	table.insert(active_recipes, {dm:data(), buffer, needed, memory})
	meta:set_string("pending_recipes", minetest.serialize(active_recipes))
	meta:set_string("inventory", minetest.serialize(storage))

	pulse_network.trigger_update(pos)
	pulse_network.update_pending_recipe(pos, #active_recipes)
end

function pulse_network.update_pending_recipe(pos, key)
	local meta = minetest.get_meta(pos)
	local active_recipes = meta:get_string"pending_recipes":data()
	local patterns = meta:get_string"patterns":data()
	local recipe = active_recipes[key]
	if not recipe then return end

	local action = false
	table.iwalk(recipe[1], function(v, k)
		local id, count = v[1][1], v[1][2]
		if recipe[2][id] then
			v[1][2] = math.max(v[1][2] - recipe[2][id], 0)
			if v[1][2] == 0 then
				recipe[1][k] = nil
				return
			end
		end
		count = math.min(count, 72)
		local pattern, key2 = table.random(patterns[id] or {})
		if not pattern then return end
		local tbl = key2:split"|"
		local position, index = vector.destringify(tbl[1]), table.concat(table.tail(tbl), "|")
		local inv = minetest.get_meta(position):get_inventory()
		if not inv:is_empty"autocraft_buffer" then return end

		local node_name = minetest.get_node(position).name
		local callback = api.get_field(node_name, "on_autocraft_insert")

		if table.every(pattern.inputs, function(x)
			local name, count_mult = unpack(x:split" ")
			count_mult = (tonumber(count_mult) or 1) * count
			return recipe[2][name] and recipe[2][name] >= count_mult
		end) then
			action = true

			table.walk(pattern.inputs, function(x)
				local name, count_mult = unpack(x:split" ")
				count_mult = (tonumber(count_mult) or 1) * count
				recipe[2][name] = recipe[2][name] - count_mult
				if recipe[2][name] == 0 then
					recipe[2][name] = nil
				end

				inv:add_item("autocraft_buffer", name .. " " .. count_mult)
				if callback then
					callback(position, index)
				end
			end)
		end
	end, function() return action end)
	recipe[1] = table.remap(recipe[1])
	active_recipes[key] = recipe

	if #recipe[1] > 0 then
		local output_name = recipe[1][#recipe[1]][1][1]
		if recipe[2][output_name] then
			local pending_recipe_outputs = meta:get_string"pending_outputs":data()
			table.insert(pending_recipe_outputs, {output_name, recipe[2][output_name]})
			recipe[2][output_name] = nil
			meta:set_string("pending_outputs", minetest.serialize(pending_recipe_outputs))
		end
	else
		local e, k = table.random(recipe[2])
		if e then
			local pending_recipe_outputs = meta:get_string"pending_outputs":data()
			table.insert(pending_recipe_outputs, {k, e})
			meta:set_string("pending_outputs", minetest.serialize(pending_recipe_outputs))
		end
		meta:set_int("used_memory", meta:get_int"used_memory" - recipe[4])
		meta:set_int("active_processes", meta:get_int"active_processes" - 1)
		table.remove(active_recipes, key)
	end

	if action then
		meta:set_string("pending_recipes", minetest.serialize(active_recipes))
	end
end