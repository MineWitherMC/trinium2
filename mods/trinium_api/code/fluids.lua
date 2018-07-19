local api = trinium.api

function api.register_fluid(src_name, flow_name, src_description, flow_description, color, def)
	def = table.copy(def)
	def.paramtype = "light"
	def.walkable = false
	def.pointable = false
	def.diggable = false
	def.buildable_to = true
	def.is_ground_content = false
	def.drowning = 1
	def.drop = ""
	def.liquid_alternative_flowing = flow_name
	def.liquid_alternative_source = src_name
	def.groups = def.groups or {}
	def.groups.liquid = 3
	def.post_effect_color = { a = 103, r = 30, g = 60, b = 90 }
	def.sounds = def.sounds or trinium.sounds.default_water
	local def2 = table.copy(def)

	def.drawtype = "liquid"
	def.tiles = {
		{
			name = "fluid_source.png^[multiply:#" .. color,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		}
	}
	def.liquidtype = "source"
	def.description = src_description
	minetest.register_node(src_name, def)

	def2.drawtype = "flowingliquid"
	def2.paramtype2 = "flowingliquid"
	def2.groups.not_in_creative_inventory = 1
	def2.tiles = {"fluid_basic.png^[multiply:#" .. color}
	def2.special_tiles = {
		{
			name = "fluid_flowing.png^[multiply:#" .. color,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.8,
			},
			backface_culling = false,
		},
		{
			name = "fluid_flowing.png^[multiply:#" .. color,
			animation = {
				type = "vertical_frames",
				aspect_w = 64,
				aspect_h = 64,
				length = 0.8,
			},
			backface_culling = true,
		},
	}
	def2.liquidtype = "flowing"
	def2.description = flow_description
	minetest.register_node(flow_name, def2)
end
api.register_liquid = api.register_fluid
