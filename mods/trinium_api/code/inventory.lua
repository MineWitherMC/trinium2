local api = trinium.api
local DataMesh = api.DataMesh

function api.initialize_inventory(inv, def)
	for k, v in pairs(def) do
		inv:set_size(k, v)
	end
end

function api.initializer(def0)
	return function(pos)
		local def = table.copy(def0)
		local meta = minetest.get_meta(pos)
		if def.formspec then
			meta:set_string("formspec", def.formspec)
			def.formspec = nil
		end
		api.initialize_inventory(meta:get_inventory(), def)
	end
end

function api.inv_to_itemmap(...)
	local map, inv = {}, {...}
	for _, v in pairs(inv) do
		for _, v1 in pairs(v) do
			local name, count = v1:get_name(), v1:get_count()
			if not map[name] then map[name] = 0 end
			map[name] = map[name] + count
		end
	end
	map[""] = nil
	return map
end

function api.get_item_identifier(stack)
	local s = stack:to_string():split(" ")
	return s[1] .. (s[3] and " " .. table.concat(table.multi_tail(s, 2), " ") or "")
end

function api.count_stacks(inv, list, disallow_multi_stacks)
	local dm = DataMesh:new():data(inv:get_list(list)):filter(function(v)
		return not v:is_empty()
	end)
	if not disallow_multi_stacks then
		dm = dm:map(function(v)
			return v:get_name()
		end):unique()
	end
	return dm:count()
end

function api.formspec_escape_reverse(text)
	text = text:gsub("\\%[", "["):gsub("\\%]", "]"):gsub("\\\\", "\\"):gsub("\\,", ","):gsub("\\;", ";")
	return text
end