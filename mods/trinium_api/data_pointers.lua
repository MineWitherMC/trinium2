local api = trinium.api
local secret_api = ...

local datas = {}
--[[function api.get_data_pointer(player, file)
	local x = {}
	datas[player] = datas[player] or {}
	datas[player][file] = x

	local dir1 = minetest.get_worldpath().."/data/"
	secret_api.mkdir(dir1)

	local dir2 = dir1..player
	secret_api.mkdir(dir2)

	local filename = dir2.."/"..file..".data"
	local handler = io.open(filename, "a+")
	if not handler then
		handler = assert(io.open(filename, "w"))
	end

	x._filename = filename
	x._strings = assert(minetest.deserialize("local p = {\n"..handler:read("*all").."\n}\nreturn p"))
	handler:close()

	function x:save()
		local handler = io.open(self._filename, "w")
		for k,v in pairs(self._strings) do
			handler:write("['"..k.."'] = "..minetest.serialize(v):sub(8)..",\n")
		end
		handler:close()
	end

	setmetatable(x, {__newindex = function(t,k,v) t._strings[k] = v end, __index = x._strings})
	return x
end]]--
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

	setmetatable(x, {__newindex = function(t,k,v) t._strings[k] = v end, __index = x._strings})
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
		for k,v in pairs(datas[pn]) do
			v:save()
		end
	end
end)

minetest.register_on_shutdown(function()
	for k,v in pairs(datas) do
		for k2,v2 in pairs(v) do
			v2:save()
		end
	end
end)
