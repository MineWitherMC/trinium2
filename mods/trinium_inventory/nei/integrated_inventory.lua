local nei = trinium.nei

local integrator = { description = trinium.nei.S"Integrated Inventory" }
function integrator.getter(player)
	local pn = player:get_player_name()
	local ps = nei.player_stuff[pn]

	local w_i, h_i, w_n, h_n = 9, 8.6, ps.size.x, ps.size.y
	local dx_i, dy_i, dx_n, dy_n = 0, math.max(0, 1 / 2 * (h_n - h_i)), w_i, math.max(0, 1 / 2 * (h_i - h_n))

	local fs_inv = betterinv.extract_formspec(betterinv.tabs.inventory.getter(player))
	local fs_nei = betterinv.extract_formspec(betterinv.tabs.item_panel.getter(player))

	local fs_base = ([=[
		container[${dx_inventory},${dy_inventory}]
		${fs_inventory}
		list[detached:bound~${player};trash;0,1;1,1]
		image[0,2;1,1;trinium_gui.trash.png]
		container_end[]

		container[${dx_nei},${dy_nei}]
		${fs_nei}
		container_end[]
	]=]):from_table{
		dx_inventory = dx_i,
		dy_inventory = dy_i,
		fs_inventory = fs_inv,
		player = pn,
		dx_nei = dx_n,
		dy_nei = dy_n,
		fs_nei = fs_nei,
	}

	return betterinv.generate_formspec(player, fs_base, { x = w_i + w_n, y = math.max(h_i, h_n) }, false, false)
end

function integrator.processor(player, context, fields)
	betterinv.tabs.inventory.processor(player, context, fields)
	betterinv.tabs.item_panel.processor(player, context, fields)
end

betterinv.register_tab("default", integrator)
betterinv.disable_tab"inventory"
betterinv.disable_tab"item_panel"
betterinv.disable_tab"utilities"