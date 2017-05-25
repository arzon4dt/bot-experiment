if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
local hero_roles = role["hero_roles"];
local bot = GetBot();
local minute = 0;
local sec = 0;
local closestRune  = -1;
local mustSaveRune = -1;
local ProxDist = 1200;
local PingTimeGap = 15;
local teamPlayers = nil;

local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}

local DireMustSave = {RUNE_BOUNTY_3,RUNE_BOUNTY_4,RUNE_POWERUP_1,RUNE_POWERUP_2}
local RadiMustSave = {RUNE_BOUNTY_1,RUNE_BOUNTY_2,RUNE_POWERUP_1,RUNE_POWERUP_2}

function GetDesire()
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end

	if bot:IsIllusion() or bot:IsInvulnerable() or not bot:IsHero() or bot:IsUsingAbility() or bot:IsChanneling() 
	   or bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE  then
		return BOT_MODE_DESIRE_NONE;
	end

	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	closestRune = GetClosestRune();
	mustSaveRune = GetClosestMustSave();
	
	for _,r in pairs(ListRune)
	do
		local rLoc = GetRuneSpawnLocation(r);
		if IsHumanPlayerNearby(rLoc) or IsPingedByHumanPlayer(rLoc)  then
			return BOT_MODE_DESIRE_NONE;
		elseif IsThereMidlaner(rLoc) or IsThereCarry(rLoc) then
			return BOT_MODE_DESIRE_NONE;
		elseif r == closestRune and GetRuneStatus( r ) == RUNE_STATUS_AVAILABLE and IsTheClosestOne(rLoc) and GetUnitToLocationDistance( bot , rLoc) < ProxDist / 3 then
			return BOT_MODE_DESIRE_ABSOLUTE;
		elseif r == closestRune and GetRuneStatus( r ) == RUNE_STATUS_AVAILABLE and IsTheClosestOne(rLoc) and IsSuitableToPick() then
			return BOT_MODE_DESIRE_HIGH;
		elseif DotaTime() > 60 and GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN and GetUnitToLocationDistance( bot , rLoc) < ProxDist and IsTheClosestOne(rLoc) then	
			return BOT_MODE_DESIRE_HIGH;
		elseif ( minute % 2 == 1 and sec > 52 ) and GetUnitToLocationDistance( bot , rLoc) < ProxDist and IsTheClosestOne(rLoc) then
			return BOT_MODE_DESIRE_HIGH;
		elseif r == mustSaveRune and DotaTime() > 60 and GetTeam() == TEAM_RADIANT and IsTeamMustSaveRune(r)
			and GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN and IsTheClosestOne(rLoc) and IsSuitableToPick() 
		then
			return BOT_MODE_DESIRE_HIGH;
		elseif r == mustSaveRune and DotaTime() > 60 and GetTeam() == TEAM_DIRE and IsTeamMustSaveRune(r)
			and GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN and IsTheClosestOne(rLoc) and IsSuitableToPick() 
		then
			return BOT_MODE_DESIRE_HIGH;		
		end
	end
	
	if DotaTime() < 0 then 
		return BOT_MODE_DESIRE_MODERATE;	
	end	
	
	return BOT_MODE_DESIRE_NONE;
end

function Think()
	
	for _,rune in pairs(ListRune)
	do
		local rLoc = GetRuneSpawnLocation(rune)
		if rune == closestRune and GetRuneStatus( rune ) == RUNE_STATUS_AVAILABLE and IsTheClosestOne(rLoc) then
			bot:Action_PickUpRune(rune);
			return
		elseif DotaTime() > 60 and GetRuneStatus( rune ) == RUNE_STATUS_UNKNOWN and GetUnitToLocationDistance( bot , rLoc) < ProxDist and IsTheClosestOne(rLoc) then	
			bot:Action_MoveToLocation(rLoc + RandomVector(300));
			return	
		elseif ( minute % 2 == 1 and sec > 50 ) and GetUnitToLocationDistance( bot , rLoc) < ProxDist and IsTheClosestOne(rLoc)	then
			bot:Action_MoveToLocation(rLoc + RandomVector(300));
			return
		elseif rune == mustSaveRune and DotaTime() > 60 and GetTeam() == TEAM_RADIANT and IsTeamMustSaveRune(rune)
			and GetRuneStatus( rune ) == RUNE_STATUS_UNKNOWN and IsTheClosestOne(rLoc) and IsSuitableToPick() 
		then
			bot:Action_MoveToLocation(rLoc);
			return	
		elseif rune == mustSaveRune and DotaTime() > 60 and GetTeam() == TEAM_DIRE and IsTeamMustSaveRune(rune)
			and GetRuneStatus( rune ) == RUNE_STATUS_UNKNOWN and IsTheClosestOne(rLoc) and IsSuitableToPick() 
		then
			bot:Action_MoveToLocation(rLoc);
			return	
		end			
	end
	
	if DotaTime() < 0 then 
		if GetTeam() == TEAM_RADIANT then
			if bot:GetAssignedLane() == LANE_BOT then 
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1) + RandomVector(300));
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2) + RandomVector(300));
				return
			end
		elseif GetTeam() == TEAM_DIRE then
			if bot:GetAssignedLane() == LANE_TOP then 
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3) + RandomVector(300));
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4) + RandomVector(300));
				return
			end
		end
	end	
	
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function IsTeamMustSaveRune(rune)
	if GetTeam() == TEAM_DIRE then
		return rune == RUNE_BOUNTY_3 or rune == RUNE_BOUNTY_4 or rune == RUNE_POWERUP_1 or rune == RUNE_POWERUP_2
	else
		return rune == RUNE_BOUNTY_1 or rune == RUNE_BOUNTY_2 or rune == RUNE_POWERUP_1 or rune == RUNE_POWERUP_2
	end
end

function GetClosestRune()
	local closestD = 10000;	
	local closestR = -1;	
	for _,r in pairs(ListRune)
	do
		if GetRuneStatus( r ) == RUNE_STATUS_AVAILABLE then
			local runeD = GetUnitToLocationDistance( bot , GetRuneSpawnLocation(r));
			if runeD <= closestD then
				closestD = runeD;
				closestR = r;
			end
		end
	end
	return closestR;
end

function GetClosestMustSave()
	local closestD = 10000;	
	local closestR = -1;
	local Runes = RadiMustSave;
	if GetTeam() == TEAM_DIRE then Runes = DireMustSave end
	for _,r in pairs(Runes)
	do
		if GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN then
			local runeD = GetUnitToLocationDistance( bot , GetRuneSpawnLocation(r));
			if runeD <= closestD then
				closestD = runeD;
				closestR = r;
			end
		end
	end
	return closestR;
end

function IsHumanPlayerNearby(runeLoc)
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and not IsPlayerBot(v) and member:IsAlive() then
			local dist1 = GetUnitToLocationDistance(member, runeLoc);
			local dist2 = GetUnitToLocationDistance(bot, runeLoc);
			if dist2 < 1200 and dist1 < 1200 then
				return true;
			end
		end
	end
	return false;
end

function IsPingedByHumanPlayer(runeLoc)
	local listPings = {};
	local dist2 = GetUnitToLocationDistance(bot, runeLoc);
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and not IsPlayerBot(v) and member:IsAlive() then
			local ping = member:GetMostRecentPing();
			table.insert(listPings, ping);
		end
	end
	for _,p in pairs(listPings)
	do
		if p ~= nil and GetDistance(p.location, runeLoc) < 1200 and dist2 < 1200 and GameTime() - p.time < PingTimeGap then
			return true;
		end
	end
	return false;
end

function IsTheClosestOne(r)
	local minDist = GetUnitToLocationDistance(bot, r);
	local closest = bot;
	for k,v in pairs(teamPlayers)
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() then
			local dist = GetUnitToLocationDistance(member, r);
			if dist < minDist then
				minDist = dist;
				closest = member;
			end
		end
	end
	return closest:GetUnitName() == bot:GetUnitName();
end

function IsThereMidlaner(runeLoc)
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and member:IsAlive() and member:GetAssignedLane() == LANE_MID then
			local dist1 = GetUnitToLocationDistance(member, runeLoc);
			local dist2 = GetUnitToLocationDistance(bot, runeLoc);
			if dist2 < 1200 and dist1 < 1200 and bot:GetUnitName() ~= member:GetUnitName() then
				return true;
			end
		end
	end
	return false;
end

function IsThereCarry(runeLoc)
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and member:IsAlive() and role.CanBeSafeLaneCarry(member:GetUnitName()) 
		   and ( (GetTeam()==TEAM_DIRE and member:GetAssignedLane()==LANE_TOP) or (GetTeam()==TEAM_RADIANT and member:GetAssignedLane()==LANE_BOT)  )	
		then
			local dist1 = GetUnitToLocationDistance(member, runeLoc);
			local dist2 = GetUnitToLocationDistance(bot, runeLoc);
			if dist2 < 1200 and dist1 < 1200 and bot:GetUnitName() ~= member:GetUnitName() then
				return true;
			end
		end
	end
	return false;
end

function IsSuitableToPick()
	local mode = bot:GetActiveMode();
	local Enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	if ( ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or ( ( Enemies ~= nil or #Enemies >= 1 ) and bot:WasRecentlyDamagedByAnyHero(2.0) )
		) 
	then
		return false;
	end
	return true;
end