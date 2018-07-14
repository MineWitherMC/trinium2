local api = trinium.api

local datas = {}
local storage = minetest.get_mod_storage()
function api.get_data_pointer(player, file)
	if not datas[player] then datas[player] = {} end
	datas[player][file] = {}
	local x = datas[player][file]
	x._key = ("playerdata:%s:%s"):format(player, file)
	x._strings = storage:get_string(x._key):data() or {}

	function x:save()
		storage:set_string(self._key, minetest.serialize(self._strings))
	end

	setmetatable(x, {__newindex = function(t, k, v) t._strings[k] = v end, __index = x._strings})
	return x
end

function api.get_data_pointers(id)
	local dps = {}
	setmetatable(dps, {__index = function(t, k)
		t[k] = api.get_data_pointer(k, id)
		return t[k]
	end})
	return dps
end

minetest.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if datas[pn] then
		for _, v in pairs(datas[pn]) do
			v:save()
		end
	end
end)

minetest.register_on_shutdown(function()
	for _, v in pairs(datas) do
		for _, v2 in pairs(v) do
			v2:save()
		end
	end
end)
