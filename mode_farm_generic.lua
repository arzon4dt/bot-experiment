local role = require(GetScriptDirectory() .. "/RoleUtility");
local utils = require(GetScriptDirectory() ..  "/util")
local campUtils = require(GetScriptDirectory() ..  "/CampUtility")
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
local lanes = {LANE_TOP, LANE_MID, LANE_BOT}

function GetDesire()
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	
	--[[for _,l in pairs(lanes)
	do
		local tFA = GetLaneFrontAmount( team, l, true )
		local eFA = GetLaneFrontAmount( GetOpposingTeam(), l, true )
		if tFA + eFA >= 0.9 then
			print(tostring(l)..":"..tostring(tFA).."><"..tostring(eFA))
		end
	end]]--
	
	
	--[[if team == TEAM_RADIANT and string.find(bot:GetUnitName(), "bloodseeker") then
		local fLoc = GetLocationAlongLane( lane, GetLaneFrontAmount( GetOpposingTeam(), lane, true ) )
		bot:ActionImmediate_Ping(fLoc.x, fLoc.y, true)	
	end]]--
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

function IsEnemyCamp(camp)
	return camp.team ~= team;
end

function IsAncientCamp(camp)
	return camp.type == "ancient";
end

function IsSmallCamp(camp)
	return camp.type == "small";
end

function IsMediumCamp(camp)
	return camp.type == "medium";
end

function IsLargeCamp(camp)
	return camp.type == "large";
end

function RefreshCamp()
	local camps = GetNeutralSpawners();
	AvailableCamp = {};
	for k,camp in pairs(camps) do
		if bot:GetLevel() <= 6 then
			if not IsEnemyCamp(camp) and not IsLargeCamp(camp) and not IsAncientCamp(camp)
			then
				table.insert(AvailableCamp, {idx=k, cattr=camp});
			end
		elseif bot:GetLevel() <= 10 then
			if not IsEnemyCamp(camp) and not IsAncientCamp(camp)
			then
				table.insert(AvailableCamp, {idx=k, cattr=camp});
			end
		else
			table.insert(AvailableCamp, {idx=k, cattr=camp});
		end
	end
	print(tostring(team)..tostring(#AvailableCamp))
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
		local stackMove = campUtils.GetCampMoveToStack(preferedCamp.idx);
		local stackTime =  campUtils.GetCampStackTime(preferedCamp.idx);
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
		if creep:IsAlive() and hp < minHP then
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
				dis = dist;
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

