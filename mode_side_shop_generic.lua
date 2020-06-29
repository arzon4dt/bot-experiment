local utils = require(GetScriptDirectory() ..  "/util")
local npcBot = GetBot();

local getop = false;
local closestOutpost = nil;
local closestDist = 10000;
local outposts = {};
local team = GetTeam();
local enemyPids = nil

local towerT2 = {
	TOWER_TOP_2,
	TOWER_MID_2,
	TOWER_BOT_2,
};

local tower2Down = false;

function GetDesire()
	
	if tower2Down == false then
		for i=1,#towerT2 do
			if GetTower(GetOpposingTeam(), towerT2[i]) == nil then
				tower2Down = true;
			end
		end 
	end
	
	if tower2Down == false or DotaTime() < 10*60 
		or ( closestOutpost == nil and npcBot:IsChanneling() ) 
		or npcBot:IsIllusion() 
		or (string.find(GetBot():GetUnitName(), "monkey") and npcBot:IsInvulnerable())
		or IsSuitableToOutpost() == false
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if getop == false then
		local units = GetUnitList(UNIT_LIST_ALL);
		for _,unit in pairs(units) do
			if unit:GetUnitName() == "npc_dota_watch_tower" 
				or unit:GetUnitName() == '#DOTA_OutpostName_North' 
				or unit:GetUnitName() == '#DOTA_OutpostName_South' 
			then
				table.insert(outposts, unit);
			end
		end
		getop = true;
	end
	
	closestOutpost, closestDist = GetClosestOutpost();
	if ( closestOutpost ~= nil and closestDist <= 3500 ) and IsEnemyCloserToOutpostLoc(closestOutpost:GetLocation(), closestDist) == false then
		return RemapValClamped(  GetUnitToUnitDistance(npcBot, closestOutpost), 3500, 0, 0.65, 1.0 );
	end
	
	return BOT_MODE_DESIRE_NONE

end

function OnStart()
	
	
end

function OnEnd()
	closestOutpost = nil;
	closestDist = 10000;
end

function Think()
	if GetUnitToUnitDistance(npcBot,closestOutpost) > 300
	then
		npcBot:Action_MoveToLocation(closestOutpost:GetLocation())
		return
	elseif  npcBot:IsChanneling() then 
		return
	else
		npcBot:Action_AttackUnit(closestOutpost,false)
		return
	end
	
end


function IsNearbyEnemyClosestToLoc(loc)
	local closestDist = GetUnitToLocationDistance(npcBot, loc);
	local closestUnit = npcBot;
	local enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,enemy in pairs(enemies) do
		local dist = GetUnitToLocationDistance(enemy, loc);
		if dist < closestDist then
			return true;
		end
	end
	return false;
end

function GetClosestOutpost()

	local closest = nil;
	local dist = 10000;
	for i=1,2 do
		if outposts[i] ~= nil 
			and outposts[i]:IsNull() == false 
			and outposts[i]:GetTeam() ~= team 
			and GetUnitToUnitDistance(npcBot, outposts[i]) < dist
		then
			closest = outposts[i];
			dist = GetUnitToUnitDistance(npcBot, outposts[i]);
		end
	end
	
	return closest, dist;

end

function IsSuitableToOutpost()
	local mode = npcBot:GetActiveMode();
	if ( ( mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or npcBot:WasRecentlyDamagedByAnyHero(2.5)
		) 
	then
		return false;
	end
	return true;
end

function IsEnemyCloserToOutpostLoc(opLoc, botDist)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 5.0  and utils.GetDistance(dInfo.location, opLoc) <  botDist
			then	
				return true;
			end
		end	
	end
	return false;
end
