local utils = require(GetScriptDirectory() ..  "/util")
local bot = GetBot();
local team = GetTeam();
local opptTeam = GetOpposingTeam();
local pingTime = -60;
local assgLane = -1;

function GetDesire()

	assgLane = bot:GetAssignedLane();
	
	if DotaTime() > -60 and string.find(bot:GetUnitName(), "life") and DotaTime() > pingTime + 5 then
		local eFLoc = GetLaneFrontLocation(opptTeam, LANE_TOP, 100);
		--local eFLoc =  GetLocationAlongLane( LANE_TOP, GetLaneFrontAmount( team, LANE_TOP, true ) )
		--local camps = GetNeutralSpawners()
		--local loc = camps[17].max;
		local loc = eFLoc;
		--bot:ActionImmediate_Ping( loc.x, loc.y, true );
		--print(tostring(GetLaneFrontAmount( team, LANE_TOP, true )).."><"..tostring(GetLaneFrontAmount( opptTeam, LANE_TOP, true )))
		
		pingTime = DotaTime();
		--return
	end

    if bot:GetLevel() < 7 then
		return BOT_MODE_DESIRE_LOW; 
	end
	
	return 0.0
	
end
--[[
function Think()
	
	local eCreeps = bot:GetNearbyLaneCreeps(1200, true);
	local tCreeps = bot:GetNearbyLaneCreeps(1200, false);
	
	local tFLoc = GetLaneFrontLocation(team, assgLane, -400)
	local eFLoc = GetLaneFrontLocation(opptTeam, assgLane, -400) 
	
	for _,creep in pairs(eCreeps) do
		if creep:GetHealth() <= bot:GetAttackDamage() then
			bot:Action_AttackUnit(creep, true);
			return
		end
	end
	
	for _,creep in pairs(tCreeps) do
		if creep:GetHealth() / creep:GetMaxHealth() <= 0.25 then
			bot:Action_AttackUnit(creep, true);
			return
		end
	end
	
	if string.find(bot:GetUnitName(),"wisp")  and DotaTime() < 15 then
		if team == TEAM_DIRE then
			tFLoc = GetLaneFrontLocation(team, LANE_TOP, -400)
			bot:Action_MoveToLocation(tFLoc - RandomVector(300));
			return
		else
			tFLoc = GetLaneFrontLocation(team, LANE_BOT, -400)
			bot:Action_MoveToLocation(tFLoc - RandomVector(300));
			return
		end
	elseif string.find(bot:GetUnitName(),"titan") and DotaTime() < 15 then
		if team == TEAM_DIRE then
			tFLoc = GetLaneFrontLocation(team, LANE_BOT, -400)
			bot:Action_MoveToLocation(tFLoc - RandomVector(300));
			return
		else
			tFLoc = GetLaneFrontLocation(team, LANE_TOP, -400)
			bot:Action_MoveToLocation(tFLoc - RandomVector(300));
			return
		end	
	elseif GetUnitToLocationDistance(bot, eFLoc) < 600 then
		bot:Action_MoveToLocation(eFLoc - RandomVector(300));
		return
	else
		bot:Action_MoveToLocation(tFLoc - RandomVector(300));
		return
	end
	
end
]]--