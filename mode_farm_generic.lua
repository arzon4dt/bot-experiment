local role = require(GetScriptDirectory() .. "/RoleUtility");
local utils = require(GetScriptDirectory() ..  "/util")
local bot = GetBot()
local team = GetTeam()
local minute = 0;
local sec = 0;
local preferedCamp = nil;
local AvailableCamp = {};
local LaneCreeps = {};
local numCamp = 18;
local farmState = 0;
local teamPlayers = nil;

function GetDesire()
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	local EnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if not bot:IsAlive() or bot:IsChanneling() or bot:GetCurrentActionType() == 1 or bot:GetNextItemPurchaseValue() == 0 
	   or bot:WasRecentlyDamagedByAnyHero(3.0) or #EnemyHeroes >= 1 or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if #AvailableCamp < numCamp and ( ( DotaTime() > 30 and DotaTime() < 60 and sec > 30 and sec < 31 ) 
	   or ( DotaTime() > 30 and  sec > 0 and sec < 1 ) ) 
	then
		RefreshCamp();
		--print("Refresh Camp "..bot:GetUnitName()..":"..tostring(#AvailableCamp))
	end

	--if not IsSuitableToFarm() then return  BOT_MODE_DESIRE_NONE; end 
	
	--[[if string.find(bot:GetUnitName(), "storm") then
	for _,c in pairs(AvailableCamp)
	do
		--print(c.name)
		if string.find(c.name, "ancient") and not string.find(c.name, "enemy") and string.find(c.name, "1")  then 
			bot:ActionImmediate_Ping(c.location.x, c.location.y, true);
		end
	end
	end]]--
	
	--if ( ( string.find(bot:GetUnitName(), "bloodseeker") and bot:GetLevel() >= 3 ) or ( string.find(bot:GetUnitName(), "life_stealer") and bot:GetLevel() >= 6 ) )
	--if DotaTime() > 10*60 and #AvailableCamp > 0 and role.CanBeSafeLaneCarry(bot:GetUnitName()) and  
	   --((team == TEAM_DIRE and bot:GetAssignedLane() == LANE_TOP) or (team == TEAM_RADIANT and bot:GetAssignedLane() == LANE_BOT)) 
	if bot:GetLevel() >= 3 and IsStrongJungler()
	then
		LaneCreeps = bot:GetNearbyLaneCreeps(1600, true);
		local Towers = bot:GetNearbyTowers(800, true);
		if (( EnemyHeroes == nil or #EnemyHeroes == 0 ) or ( Towers == nil or #Towers == 0 )) and LaneCreeps ~= nil and #LaneCreeps > 0 then
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp == nil then preferedCamp = GetClosestNeutralSpwan() end
			if preferedCamp ~= nil then
				if bot:GetHealth() / bot:GetMaxHealth() <= 0.15 then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_LOW;
				elseif farmState == 1 then 
					return BOT_MODE_DESIRE_ABSOLUTE;
				elseif not IsSuitableToFarm() then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_NONE;
				else
					return BOT_MODE_DESIRE_VERYHIGH;
				end
			end
		end
	end
	
	return 0.0
end

function OnEnd()
	preferedCamp = nil;
	farmState = 0;
end

function RefreshCamp()
	local camps = GetNeutralSpawners();
	AvailableCamp = {};
	for _,camp in pairs(camps) do
		if bot:GetLevel() < 10 then
			if ( team == TEAM_RADIANT and camp.name == "basic_enemy_7" ) or ( team == TEAM_DIRE and not camp.name == "basic_7" ) or
			   not string.find(camp.name, "ancient") and not string.find(camp.name, "enemy")  
			then
				table.insert(AvailableCamp, camp);
			end
		else
			table.insert(AvailableCamp, camp);
		end
	end
	print(tostring(team)..tostring(#AvailableCamp))
	numCamp = #AvailableCamp;
end

function Think()
	
	if LaneCreeps ~= nil and #LaneCreeps > 0 then
		local farmTarget = FindFarmedTarget(LaneCreeps)
		if farmTarget ~= nil then
			bot:Action_AttackUnit(farmTarget, true);
			return
		end
	end
		
	if preferedCamp ~= nil then
		local cDist = GetUnitToLocationDistance(bot, preferedCamp);
		if cDist > 300 then
			bot:Action_MoveToLocation(preferedCamp);
			return
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(800);
			local farmTarget = FindFarmedTarget(neutralCreeps)
			if farmTarget ~= nil then
				farmState = 1;
				bot:Action_AttackUnit(farmTarget, true);
				return
			else
				farmState = 0;
				UpdateAvailableCamp();
			end
		end	
	end
	
	
end

function IsStrongJungler()
	local name = bot:GetUnitName();
	return string.find(name, "bloodseeker") or string.find(name, "life_stealer") or string.find(name, "legion") or string.find(name, "skeleton")
			or string.find(name, "ursa") or ( string.find(name, "alchemist") and bot:GetLevel() >= 6 ) 
end

function UpdateAvailableCamp()
	if preferedCamp ~= nil then
		for i = 1, #AvailableCamp
		do
			if AvailableCamp[i].location == preferedCamp or GetUnitToLocationDistance(bot,  AvailableCamp[i].location) < 300 then
				table.remove(AvailableCamp, i);
				--print("Updating available camp : "..tostring(#AvailableCamp))
				preferedCamp = nil;	
				return
			end
		end
	end
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function FindFarmedTarget(Creeps)
	local minHP = 10000;
	local target = nil;
	for _,creep in pairs(Creeps)
	do
		local hp = creep:GetHealth(); 
		if hp < minHP then
			minHP = hp;
			target = creep;
		end
	end
	return target
end

function GetClosestNeutralSpwan()
	local minDist = 10000;
	local pCamp = nil;
	local neutralSpawn  = GetNeutralSpawners();
	for _,camp in pairs(AvailableCamp)
	do
	   local dist = GetUnitToLocationDistance(bot, camp.location);
	   if IsTheClosestOne(dist, camp.location) and dist < minDist then
			minDist = dist;
			pCamp = camp.location;
	   end
	end
	return pCamp
end

function IsTheClosestOne(bDis, loc)
	local dis = bDis;
	local closest = bot;
	for k,v in pairs(teamPlayers)
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() and member:GetActiveMode() == BOT_MODE_FARM then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist < dis then
				minDist = dist;
				closest = member;
			end
		end
	end
	return closest:GetUnitName() == bot:GetUnitName();
end

function IsSuitableToFarm()
	local mode = bot:GetActiveMode();
	if mode == BOT_MODE_RUNE
	   or mode == BOT_MODE_SECRET_SHOP
	   or mode == BOT_MODE_DEFEND_TOWER_TOP
	   or mode == BOT_MODE_DEFEND_TOWER_MID
	   or mode == BOT_MODE_DEFEND_TOWER_BOT
	   or mode == BOT_MODE_ATTACK
	then
		return false;
	end
	return true;
end

--[[ CAMP LIST
TEAM_RADIANT
[VScript] 2basic_0 --Large Camp Near Bot Shrine
[VScript] 2basic_1 --Medium Camp Closest To Base
[VScript] 2basic_2 --Medium Camp In Front Bot Ancient
[VScript] 2basic_3 --Large Camp Near Top Shrine
[VScript] 2basic_4 --Large Camp Near Bot Side Shop
[VScript] 2basic_5 --Small Camp Top
[VScript] 2ancient_0 --Ancient Near Roshan 
[VScript] 2basic_enemy_0
[VScript] 2basic_enemy_1
[VScript] 2basic_enemy_2
[VScript] 2basic_enemy_3
[VScript] 2basic_enemy_4
[VScript] 2basic_enemy_5
[VScript] 2basic_enemy_6
[VScript] 2basic_enemy_7
[VScript] 2ancient_enemy_0
[VScript] 2ancient_enemy_1
[VScript] 2ancient_enemy_2
TEAM_DIRE
[VScript] 3basic_0 --Large Camp Near Top Shrine
[VScript] 3basic_1 --Small Camp 
[VScript] 3basic_2 --Medium Camp Near Small Camp
[VScript] 3basic_3 --Large Camp Near Top Side Shop
[VScript] 3basic_4 --Large Camp Near Bot Shrine
[VScript] 3basic_5 --Medium Camp Closest To Base
[VScript] 3basic_6 --Medium Camp Near Bot Shrine
[VScript] 3basic_7 --Radiant Medium Camp Near Radiant Top Shrine **
[VScript] 3ancient_0 --Ancient Near Roshan 
[VScript] 3ancient_1 --Radiant Ancient Near Radiant Bot Shrine **
[VScript] 3ancient_2 --Ancient Near Bot Roshan 
[VScript] 3basic_enemy_0
[VScript] 3basic_enemy_1
[VScript] 3basic_enemy_2
[VScript] 3basic_enemy_3
[VScript] 3basic_enemy_4
[VScript] 3basic_enemy_5
[VScript] 3ancient_enemy_0
]]--