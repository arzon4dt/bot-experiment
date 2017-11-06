local U = {};

function U.IsInTeamFight(bot)
	local num_fight_allies = 0;
	if bot.data.allies ~= nil and #bot.data.allies > 0 then
		for i=1,#bot.data.allies do
			if bot.data.allies[i] ~= nil and bot.data.allies[i]:CanBeSeen() and bot.data.allies[i]:GetActiveMode() == BOT_MODE_ATTACK  then
				num_fight_allies = num_fight_allies + 1;
			end
		end
	end
	return num_fight_allies >= 2;
end

return U;