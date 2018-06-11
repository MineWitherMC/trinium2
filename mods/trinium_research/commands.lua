local research = trinium.research
minetest.register_privilege("research_grant", {
	description = "Can use /research and /research_me commands",
	give_to_singleplayer = false,
})

minetest.register_chatcommand("research_me", {
	params = "<research>",
	description = "Give research to activator",
	privs = { research_grant = 1 },
	func = function(name, param)
		if research.researches[param] then
			research.force_grant(name, param)
		else
			minetest.chat_send_player(pn, S("Unknown research: @1", param))
		end
	end,
})
