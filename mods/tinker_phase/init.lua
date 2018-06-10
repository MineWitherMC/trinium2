tinker = {}
tinker.S = minetest.get_translator"tinker_phase"
local S = tinker.S
local api = trinium.api
local path = minetest.get_modpath"tinker_phase"

tinker.materials = {}
function tinker.add_material(name, def)
	def.multiplier = def.multiplier or 1
	assert(minetest.registered_items[name])
	local groups = table.copy(minetest.registered_items[name].groups)
	groups._tinkerphase_tool_material = 1
	tinker.materials[name] = def
	minetest.override_item(name, {groups = groups})
end

function tinker.add_system_material(data, def)
	local item = data
	if type(data) == "table" then
		item = data:get"ingot"
		if not item then item = data:get"gem" end
		assert(item, "Material "..data.name.." must either have ingot or gem!")
	end
	if not def.color then
		def.color = api.cstring(data.color)
	end
	tinker.add_material(item, def)
end
dofile(path.."/materials.lua")

tinker.patterns = {}
function tinker.add_pattern(name, def)
	tinker.patterns[name] = def
	tinker.patterns[name].name = name
	minetest.register_craftitem("tinker_phase:part_"..name, {
		inventory_image = "tinker_phase.part."..name..".png",
		groups = {hidden_from_irp = 1, _tinkerphase_part = 1},
	})
	minetest.register_craftitem("tinker_phase:pattern_"..name, {
		description = S("Pattern - @1", def.description:sub(4)).."\n"..
				minetest.colorize("#CCC", S("Material Cost: @1", def.cost)),
		inventory_image = "tinker_phase.pattern_base.png^(tinker_phase.part."..name..".png^[colorize:#4D3C22)",
		groups = {_tinkerphase_pattern = 1},
		stack_max = 1,
	})
end
dofile(path.."/patterns.lua")
dofile(path.."/part_builder.lua")

tinker.modifiers, tinker.add_modifier = api.adder()
dofile(path.."/modifiers.lua")

tinker.tools = {}
function tinker.add_tool(name, def)
	tinker.tools[name] = def
	minetest.register_tool("tinker_phase:tool_"..name, api.set_defaults({
		inventory_image = "tinker_phase.colorer."..name..".png",
		inventory_overlay = "tinker_phase.base."..name..".png",
		groups = {hidden_from_irp = 1, _tinkerphase_tool = 1},
		after_use = function(itemstack, player, node) -- todo: wait until they expose position and rewrite this
			local meta = itemstack:get_meta()
			table.walk(meta:get_string"modifiers":data() or {}, function(v, k)
				if tinker.modifiers[k] and tinker.modifiers[k].after_use then
					tinker.modifiers[k].after_use(player, itemstack, v, node)
				end
			end)
			local durability = meta:get_int"current_durability"
			meta:set_int("current_durability", durability - 1)
			if durability == 0 then
				return ""
			else
				meta:set_string("description", def.update_description(itemstack))
			end
		end,
	}, def.overrides))
end

function tinker.get_color(num)
	if num <= 0.075 then
		return "#6D2400"
	elseif num <= 0.2 then
		return "#DB0000"
	elseif num <= 0.4 then
		return "#FF4900"
	elseif num <= 0.55 then
		return "#FF9200"
	elseif num <= 0.7 then
		return "#FFFF00"
	elseif num <= 0.8 then
		return "#92B600"
	elseif num <= 0.9 then
		return "#499200"
	else
		return "#00B600"
	end
end

local MAX_VERSION = 1
function tinker.wrap_description(version, def)
	assert(version <= MAX_VERSION)
	local description = ""

	-- API v1
	description = description..def.base
	description = description.."\n"..minetest.colorize(tinker.get_color(def.current_durability / def.max_durability),
			S("Durability: @1/@2", def.current_durability, def.max_durability))
	local modifiers = def.modifiers or {}
	table.walk(modifiers, function(k, v)
		local num = k == 1 and "" or " "..api.roman_number(k)
		if tinker.modifiers[v] and tinker.modifiers[v].description then
			description = description.."\n"..tinker.modifiers[v].description..num
		else
			description = description.."\n"..api.string_superseparation(v)..num
		end
	end)
	-- END API v1

	if version == 1 then return description end
	return ""
end

dofile(path.."/tools.lua")

tinker.base = {
	cracky = {20, 8, 4},
	crumbly = {7, 5, 2},
	choppy = {11, 7, 5},
	snappy = {12, 6, 2},
}

dofile(path.."/tool_station.lua")

api.send_init_signal()
