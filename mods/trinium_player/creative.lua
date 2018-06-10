trinium.creative_mode = minetest.settings:get_bool"creative_mode"

local speed = 100
local caps = {times = {speed, speed, speed}, uses = 0, maxlevel = 456}
if trinium.creative_mode then
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x = 1, y = 1, z = 2.5},
		groups = {hidden_from_nei = 1},
		tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level = 456,
			groupcaps = {
				cracky = caps,
				choppy = caps,
				snappy = caps,
				crumbly = caps,
				dig_immediate = caps,
				oddly_breakable_by_hand = caps,
			},
			damage_groups = {fleshy = 10},
		}
	})
	minetest.register_on_joinplayer(function(player)
		local privs = minetest.get_player_privs(player:get_player_name())
		privs.fly = 1
		minetest.set_player_privs(player:get_player_name(), privs)
	end)
else
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x = 1, y = 1, z = 2.5},
		tool_capabilities = {
			full_punch_interval = 0.9,
			max_drop_level = 0,
			groupcaps = {
				crumbly = {times = {[2] = 3.00, [3] = 0.70}, uses = 0, maxlevel = 1},
				snappy = {times = {[3] = 0.40}, uses = 0, maxlevel = 1},
				oddly_breakable_by_hand = {times = {3.50, 2.00, 0.70}, uses = 0},
			},
			damage_groups = {fleshy = 1},
		}
	})
end

local old_handle_node_drops = minetest.handle_node_drops
function minetest.handle_node_drops(pos, drops, digger)
	return digger and digger:is_player() and (trinium.creative_mode or old_handle_node_drops(pos, drops, digger))
end
minetest.register_on_placenode(function()
	return trinium.creative_mode
end)
