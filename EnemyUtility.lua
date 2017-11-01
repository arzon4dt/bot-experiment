local U = {}

local utils = require(GetScriptDirectory() ..  "/util")

local opposing_team = GetOpposingTeam();
local enemyIds = GetTeamPlayers(opposing_team); 

function U.GetNumEnemyAlive()
	local tIds = {};
	for i,id in pairs(enemyIds) do
		if IsHeroAlive(id) then
			table.insert(alive, id);
		end	
	end	
	return tIds;
end

function U.IsEnemyNearLoc(vLoc, nRadius, fTime)
	for i,id in pairs(enemyIds) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and utils.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < fTime then
					return true;
				end
			end
		end
	end
	return false;
end

function U.GetEnemyTower()
	
end

return U