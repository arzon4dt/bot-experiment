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
local RCStackTime = {54,55,55,55,55,54,55,55,55,54,55,55,55,55,55,55,55,55}
local RCStackLoc = {
	Vector(-642.000000,  -4132.000000, 0.000000),
	Vector(-1871.000000, -2936.000000, 0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(-3481.000000, -1122.000000, 0.000000),
	Vector(5773.000000,  -3071.000000, 0.000000),
	Vector(3570.000000,  -5963.000000, 0.000000),
	Vector(-1872.000000, 1141.000000,  0.000000),
	Vector(586.000000,   4456.000000,  0.000000),
	Vector(-3457.000000, 6297.000000,  0.000000),
	Vector(-955.000000,  5121.000000,  0.000000),
	Vector(-3050.000000, 3434.000000,  0.000000),
	Vector(3473.000000,  1870.000000,  0.000000),
	Vector(2474.000000,  5051.000000,  0.000000),
	Vector(3036.000000,  -1168.000000, 0.000000),
	Vector(-5374.000000, 446.000000,   0.000000),
	Vector(957.000000,   2295.000000,  0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(4071.000000,  -2013.000000, 0.000000)
}
local DCStackTime = {55,55,54,55,55,55,55,55,55,55,55,54,55,55,55,55,54,55}
local DCStackLoc = {
	Vector(586.000000,   4456.000000,  0.000000),
	Vector(-3457.000000, 6297.000000,  0.000000),
	Vector(-955.000000,  5121.000000,  0.000000),
	Vector(-3050.000000, 3434.000000,  0.000000),
	Vector(3473.000000,  1870.000000,  0.000000),
	Vector(2474.000000,  5051.000000,  0.000000),
	Vector(3036.000000,  -1168.000000, 0.000000),
	Vector(-5374.000000, 446.000000,   0.000000),
	Vector(957.000000,   2295.000000,  0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(4071.000000,  -2013.000000, 0.000000),
	Vector(-642.000000,  -4132.000000, 0.000000),
	Vector(-1871.000000, -2936.000000, 0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(-3481.000000, -1122.000000, 0.000000),
	Vector(5773.000000,  -3071.000000, 0.000000),
	Vector(3570.000000,  -5963.000000, 0.000000),
	Vector(-1872.000000, 1141.000000,  0.000000)
}

function GetDesire()
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	--[[for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and not IsPlayerBot(v) and member:IsAlive() then
			local ping = member:GetMostRecentPing();
			if GameTime() - ping.time < 1 then
				print(tostring(ping.location));
			end
		end
	end]]--
	
	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	
	
	local EnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	local Towers = bot:GetNearbyTowers(1000, true);
	
	if #EnemyHeroes > 0 or #Towers > 0  then
			return BOT_MODE_DESIRE_NONE;
	end		
	
	if not bot:IsAlive() or bot:IsChanneling() or bot:GetCurrentActionType() == 1 or bot:GetNextItemPurchaseValue() == 0 
	   or bot:WasRecentlyDamagedByAnyHero(3.0) or #EnemyHeroes >= 1 
	   or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
	   or bot.SecretShop
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
	if bot:GetLevel() >= 6 and IsStrongJungler()
	then
		LaneCreeps = bot:GetNearbyLaneCreeps(1600, true);
		if LaneCreeps ~= nil and #LaneCreeps > 0 then
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

function NotEnemyOrAncientCamp(camp)
	if team == TEAM_RADIANT then
		return camp.name == "basic_enemy_7" or not string.find(camp.name, "ancient") and not string.find(camp.name, "enemy");  
	else
		return camp.name ~= "basic_7" and not string.find(camp.name, "ancient") and not string.find(camp.name, "enemy")  
	end
end

function RefreshCamp()
	local camps = GetNeutralSpawners();
	AvailableCamp = {};
	for k,camp in pairs(camps) do
		if bot:GetLevel() < 10 then
			if NotEnemyOrAncientCamp(camp)
			then
				table.insert(AvailableCamp, {idx=k, cattr=camp});
			end
		else
			table.insert(AvailableCamp, {idx=k, cattr=camp});
		end
	end
	--print(tostring(team)..tostring(#AvailableCamp))
	numCamp = #AvailableCamp;
end

function Think()
	
	if bot:IsUsingAbility() then 
		return
	end
	
	if LaneCreeps ~= nil and #LaneCreeps > 0 then
		local farmTarget = FindFarmedTarget(LaneCreeps)
		if farmTarget ~= nil then
			bot:Action_AttackUnit(farmTarget, true);
			return
		end
	end
		
	if preferedCamp ~= nil then
		local cDist = GetUnitToLocationDistance(bot, preferedCamp.cattr.location);
		local stackMove = GetCampMoveToStack(preferedCamp.idx);
		local stackTime = GetCampStackTime(preferedCamp.idx);
		if cDist > 300 and farmState == 0 then
			bot:Action_MoveToLocation(preferedCamp.cattr.location);
			return
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(800);
			local farmTarget = FindFarmedTarget(neutralCreeps)
			if farmTarget ~= nil then
				farmState = 1;
				if sec >= stackTime then
					bot:Action_MoveToLocation(stackMove);
					return
				else
					bot:Action_AttackUnit(farmTarget, true);
					return
				end
			else
				farmState = 0;
				UpdateAvailableCamp();
			end
		end	
	end
	
	
end

function GetCampMoveToStack(id)
	if team == TEAM_RADIANT then
		return RCStackLoc[id];
	else
		return DCStackLoc[id];
	end
end

function GetCampStackTime(id)
	if team == TEAM_RADIANT then
		return RCStackTime[id];
	else
		return DCStackTime[id];
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
			if AvailableCamp[i].cattr.location == preferedCamp.cattr.location or GetUnitToLocationDistance(bot,  AvailableCamp[i].cattr.location) < 300 then
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
	for _,camp in pairs(AvailableCamp)
	do
	   local dist = GetUnitToLocationDistance(bot, camp.cattr.location);
	   if IsTheClosestOne(dist, camp.cattr.location) and dist < minDist then
			minDist = dist;
			pCamp = camp;
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
TEAM_RADIANT wait move time
[VScript] 2basic_0 --Large Camp Near Bot Shrine (-763.000000 -3267.000000 0.000000) (-642.000000 -4132.000000 0.000000) 55
[VScript] 2basic_1 --Medium Camp Closest To Base (-1822.000000 -4123.000000 0.000000) (-1871.000000 -2936.000000 0.000000) 55
[VScript] 2basic_2 --Medium Camp In Front Bot Ancient (595.000000 -4392.000000 0.000000) (801.000000 -3146.000000 0.000000) 55
[VScript] 2basic_3 --Large Camp Near Top Shrine (-4615.000000 -337.000000 0.000000) (-3481.000000 -1122.000000 0.000000) 55
[VScript] 2basic_4 --Large Camp Near Bot Side Shop (4818.000000 -4135.000000 0.000000) (5773.000000 -3071.000000 0.000000) 55
[VScript] 2basic_5 --Small Camp (3250.000000 -4575.000000 0.000000) (3570.000000 -5963.000000 0.000000) 54
[VScript] 2ancient_0 --Ancient Near Roshan (-2753.000000 -124.000000 0.000000) (-1872.000000 1141.000000 0.000000) 55
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
TEAM_DIRE wait move time
[VScript] 3basic_0 --Large Camp Near Top Shrine (-357.000000 3535.000000 0.000000) (586.000000 4456.000000 0.000000) 55
[VScript] 3basic_1 --Small Camp (-3030.000000 5023.000000 0.000000) (-3457.000000 6297.000000 0.000000) 55
[VScript] 3basic_2 --Medium Camp Near Small Camp (-1601.000000 4160.000000 0.000000) (-955.000000 5121.000000 0.000000) 54
[VScript] 3basic_3 --Large Camp Near Top Side Shop (-4284.000000 3782.000000 0.000000) (-3050.000000 3434.000000 0.000000) 55
[VScript] 3basic_4 --Large Camp Near Bot Shrine (4138.000000 845.000000 0.000000) (3473.000000 1870.000000 0.000000) 55
[VScript] 3basic_5 --Medium Camp Closest To Base (1352.000000 3574.000000 0.000000) (2474.000000 5051.000000 0.000000) 55
[VScript] 3basic_6 --Medium Camp Near Bot Shrine (2885.000000 27.000000 0.000000) (3036.000000 -1168.000000 0.000000) 55
[VScript] 3basic_7 --Radiant Medium Camp Near Radiant Top Shrine ** (-3953.000000 721.000000 0.000000) (-5374.000000 446.000000 0.000000) 55
[VScript] 3ancient_0 --Ancient Near Roshan (-543.000000 2350.000000 0.000000) (957.000000 2295.000000 0.000000) 55
[VScript] 3ancient_1 --Radiant Ancient Near Radiant Bot Shrine ** (376.000000 -2122.000000 0.000000) (801.000000 -3146.000000 0.000000) 55
[VScript] 3ancient_2 --Ancient Near Bot Shrine (3784.000000 -876.000000 0.000000) (4071.000000 -2013.000000 0.000000) 55
[VScript] 3basic_enemy_0
[VScript] 3basic_enemy_1
[VScript] 3basic_enemy_2
[VScript] 3basic_enemy_3
[VScript] 3basic_enemy_4
[VScript] 3basic_enemy_5
[VScript] 3ancient_enemy_0
]]--
