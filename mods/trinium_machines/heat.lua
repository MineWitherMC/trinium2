local api = trinium.api
local S = trinium.machines.S

minetest.register_node("trinium_machines:hatch_tempinput", {
	description = S"Temperature Hatch",
	groups = {cracky = 1, greggy_hatch = 1, heat_container = 1, rich_info = 1},
	tiles = {"trinium_machines.casing.png"},
	overlay_tiles = {{name = "trinium_machines.temperature_input_overlay.png", color = "white"}},
	palette = "trinium_api.palette.png",
	place_param2 = 175,
	paramtype2 = "color",
	color = "#646464",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("temperature", 300)
	end,

	ghatch_id = "input.heat",
	ghatch_max = 1,
	get_rich_info = function(pos, player)
		local meta = minetest.get_meta(pos)
		return ("Heat: %sK"):format(meta:get_int"temperature")
	end,
})

local function chg_formspec(temp)
	return ("size[3,3]field[0,1;3,1;force_temp;Set generated temperature;%s]"):format(temp)
end
minetest.register_node("trinium_machines:creative_heat_gen", {
	description = S"Creative Heat Generator",
	groups = {cracky = 1, heat_container = 1, rich_info = 1},
	tiles = {"(trinium_machines.casing.png^[multiply:#FFC200)^trinium_machines.temperature_input_overlay.png"},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("temperature", 300)
		meta:set_int("forced_temp", 300)
		meta:set_string("formspec", chg_formspec(300))
	end,

	get_rich_info = function(pos, player)
		local meta = minetest.get_meta(pos)
		return ("Heat: %sK\nTicking heat: %sK"):format(meta:get_int"temperature", meta:get_int"forced_temp")
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = minetest.get_meta(pos)
		local n = tonumber(fields.force_temp)
		if not n then
			cmsg.push_message_player(player, "Input is invalid: "..tostring(fields.force_temp))
		else
			meta:set_int("forced_temp", n)
			meta:set_string("formspec", chg_formspec(n))
		end
	end,

	on_heat_tick = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("temperature", meta:get_int"forced_temp")
	end,
})

local neighbors = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{y = 1, x = 0, z = 0},
	{y = -1, x = 0, z = 0},
	{z = 1, y = 0, x = 0},
	{z = -1, y = 0, x = 0},
}
minetest.register_abm{
	label = "[TrM] Heat Distribution",
	nodenames = "group:heat_container",
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local temp = meta:get_int"temperature"
		for i = 1, #neighbors do
			local other_meta = minetest.get_meta(vector.add(neighbors[i], pos))
			local other_temp = other_meta:get_int"temperature"
			if other_temp > temp then
				local dt = math.min((other_temp - temp) / 2, 10)
				other_meta:set_int("temperature", other_temp - dt)
				temp = temp + 0.8 * dt
			end
		end
		if temp > 300 then temp = temp - 1 end
		if temp < 300 then temp = temp + 0.5 end
		temp = math.floor(temp)
		meta:set_int("temperature", temp)

		local callback = api.get_field(node.name, "on_heat_tick")
		if callback then
			callback(pos)
		end
	end,
}
