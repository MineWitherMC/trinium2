local hud = trinium.hud
local cfgs = hud.configurators

local configurator = { description = hud.S"HUD Configuration" }
function configurator.getter(player, context)
	local fs_base = ""

	if not context.selected_tab then
		for k, v in pairs(cfgs) do
			fs_base = fs_base .. ("button[%s,%s;4,1;open_hud_tab~%s;%s]"):format(v.x * 4, v.y, k, v.desc)
		end
	else
		fs_base = ("button[6,7.6;2,1;return_hud_tab;%s]"):format(trinium.api.S"Back")
		local tab_def = cfgs[context.selected_tab]
		for k, v in pairs(tab_def.fields) do
			fs_base = fs_base .. ([=[
				label[0,%s;%s]
				field[6,%s;2,1;internal~%s~%s;;]
				field_close_on_enter[internal~%s~%s;false]
			]=]):format(v.y, v.label, v.y, context.selected_tab, k, context.selected_tab, k)
		end
	end

	return betterinv.generate_formspec(player, fs_base)
end

function configurator.processor(player, context, fields)
	if fields.quit then return end
	for k, v in pairs(fields) do
		local k_split = k:split"~"
		local a = k_split[1]
		if a == "open_hud_tab" then
			context.selected_tab = k_split[2]
		elseif a == "return_hud_tab" then
			context.selected_tab = nil
		elseif a == "internal" and k_split[2] == context.selected_tab then
			cfgs[context.selected_tab].fields[k_split[3]].func(player, v)
		end
	end
end

betterinv.register_tab("hudconf", configurator)