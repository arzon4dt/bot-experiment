local enemyStatus = require(GetScriptDirectory() .."/enemy_status" )
local teamStatus = require(GetScriptDirectory() .."/team_status" )
function GetDesire()
	local npcBot = GetBot()

	for i=0, 5 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			local _item = npcBot:GetItemInSlot(i):GetName()
			if(_item == "item_ward_observer") then
				return BOT_MODE_DESIRE_MODERATE
			end
		end
	end
	return ( 0.0 );
end