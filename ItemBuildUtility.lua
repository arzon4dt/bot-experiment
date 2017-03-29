local X = {}

function X.FillTalenTable(npcBot)
	local skills = {};
	for i = 0, 23 
	do
		local ability = npcBot:GetAbilityInSlot(i);
		if ability ~= nil and ability:IsTalent() then
			table.insert(skills, ability:GetName());
		end
	end
	return skills
end

return X;