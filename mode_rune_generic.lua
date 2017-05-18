if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
local hero_roles = role["hero_roles"];
local bot = GetBot();
local minute = 0;
local sec = 0;
local movementSpeed = 0;
local ProxDist = 1200;
local PingTimeGap = 15;
local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}

function GetDesire()

	--[[local items = GetDroppedItemList();
	for _,item in pairs(items)
	do
		for key,value in pairs(item)
		do
			print(tostring(key)..":"..tostring(value))
		end
	end]]--

	if bot:IsIllusion() or bot:IsInvulnerable() or not bot:IsHero() then
		return BOT_MODE_DESIRE_NONE;
	end

	if bot:GetActiveMode() == BOT_MODE_WARD then
		return ( 0.0 );
	end
	
	for _,r in pairs(ListRune)
	do
		if IsHumanPlayerNearby(bot, r) then
			return ( 0.0 );
		end
	end
	
	for _,rune in pairs(ListRune)
	do
		if not IsPingedByHumanPlayer(rune) and GetUnitToLocationDistance( bot , GetRuneSpawnLocation(rune)) < ProxDist/2 and IsTheClosestOne(bot, rune) and
		   ( GetRuneStatus( rune ) == RUNE_STATUS_AVAILABLE )  
		then
			return BOT_MODE_DESIRE_HIGH;
		end
	end
	
	if not IsSuitableToPick(bot) then
		return ( 0.0 );
	end
	
	movementSpeed = bot:GetBaseMovementSpeed();
	
	if DotaTime() < 0 then 
		return BOT_MODE_DESIRE_MODERATE;	
	elseif DotaTime() > 0 then
		minute = math.floor(DotaTime() / 60)
		sec = DotaTime() % 60
		
		for _,rune in pairs(ListRune)
		do
			if not IsPingedByHumanPlayer(rune) and GetUnitToLocationDistance( bot , GetRuneSpawnLocation(rune)) < ProxDist and IsTheClosestOne(bot, rune) and
			   ( GetRuneStatus( rune ) == RUNE_STATUS_AVAILABLE or ( minute % 2 == 1 and sec > 50 ) )  
			then
				return BOT_MODE_DESIRE_HIGH;
			end
		end
		
		local est_time = GetEstimatedTimeToRune(bot);
		
		if ( minute % 2 == 1 and sec > (60 - est_time) ) and ( IsPureSupport(bot) or bot:GetAssignedLane() == LANE_MID ) then
			return BOT_MODE_DESIRE_HIGH;
		else
			for _,rn in pairs(ListRune)
			do
				if GetRuneStatus( rn ) == RUNE_STATUS_AVAILABLE and not IsPingedByHumanPlayer(rn) and IsTheClosestOne(bot, rn) 
				then
					return BOT_MODE_DESIRE_HIGH;
				end
			end
		end
	end
	
	return ( 0.0 );
end

function Think()
	--local bot = GetBot();

	local PriorityHeroesNearby = false;
	local PriorityHeroes = "";
	
	PriorityHeroesNearby ,PriorityHeroes = PriorityHeroExist(bot);
 	
	for _,rune in pairs(ListRune)
	do
		if GetUnitToLocationDistance( bot , GetRuneSpawnLocation(rune)) < ProxDist and ( GetRuneStatus( rune ) == RUNE_STATUS_AVAILABLE
		   or ( minute % 2 == 1 and sec > 50 ) )
		then
			if ( minute % 2 == 1 and sec > 50 ) then
				if GetRuneStatus( rune ) == RUNE_STATUS_AVAILABLE then
					bot:Action_PickUpRune(rune);
					return
				else
					bot:Action_MoveToLocation(GetRuneSpawnLocation(rune) + RandomVector(300));
					return
				end
			elseif PriorityHeroesNearby and PriorityHeroes ~= "" and bot:GetUnitName() == PriorityHeroes then
				bot:Action_PickUpRune(rune);
				return
			elseif not PriorityHeroesNearby then
				bot:Action_PickUpRune(rune);
				return
			end
		end
	end
	
	if ( bot:IsUsingAbility() or bot:IsChanneling() ) then return end;
	
	if DotaTime() < 0 then 
		if GetTeam() == TEAM_RADIANT then
			if bot:GetAssignedLane() == LANE_BOT then 
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1) + RandomVector(200));
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2) + RandomVector(200));
				return
			end
		elseif GetTeam() == TEAM_DIRE then
			if bot:GetAssignedLane() == LANE_TOP then 
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3) + RandomVector(200));
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4) + RandomVector(200));
				return
			end
		end
	elseif DotaTime() > 0 then
		local est_time = GetEstimatedTimeToRune(bot);
		
		if minute % 2 == 1 and sec > ( 60 - est_time ) then
			local pureSupport = IsPureSupport(bot);
			if bot:GetAssignedLane() == LANE_MID and GetTeam() == TEAM_RADIANT then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_1) + RandomVector(200));
				return
			elseif bot:GetAssignedLane() == LANE_MID and GetTeam() == TEAM_DIRE then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_2) + RandomVector(200));
				return	
			elseif bot:GetAssignedLane() == LANE_TOP and GetTeam() == TEAM_RADIANT and pureSupport then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2) + RandomVector(200));
				return
			elseif bot:GetAssignedLane() == LANE_BOT and GetTeam() == TEAM_RADIANT and pureSupport then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1) + RandomVector(200));
				return	
			elseif bot:GetAssignedLane() == LANE_TOP and GetTeam() == TEAM_DIRE and pureSupport then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3) + RandomVector(200));
				return	
			elseif bot:GetAssignedLane() == LANE_BOT and GetTeam() == TEAM_DIRE and pureSupport then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4) + RandomVector(200));
				return	
			end
		else
			for _,rn in pairs(ListRune)
			do
				if GetRuneStatus( rn ) == RUNE_STATUS_AVAILABLE and IsTheClosestOne(bot, rn) 
				then
					if GetUnitToLocationDistance( bot , GetRuneSpawnLocation(rn)) > 200 then
						bot:Action_MoveToLocation(GetRuneSpawnLocation(rn) + RandomVector(200));
						return
					else
						bot:Action_PickUpRune(rn);
						return
					end
				end
			end
		end
	end
	
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function IsPingedByHumanPlayer(rune)
	local listPings = {};
	local RLoc = GetRuneSpawnLocation(rune);
	local ListUnits = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	for _,unit in pairs(ListUnits)
	do
		if unit ~= nil and not unit:IsIllusion() and not IsPlayerBot(unit:GetPlayerID()) and unit:IsAlive() then
			local ping = unit:GetMostRecentPing();
			table.insert(listPings, ping);
		end
	end
	
	for _,p in pairs(listPings)
	do
		if p ~= nil and GetDistance(p.location, RLoc) < 1000 and GameTime() - p.time < PingTimeGap then
			return true;
		end
	end
	return false;
end

function IsHumanPlayerNearby(bot, cRune)
	local RLoc = GetRuneSpawnLocation(cRune);
	local ListUnits = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	for _,unit in pairs(ListUnits)
	do
		if unit ~= nil and not unit:IsIllusion() and not IsPlayerBot(unit:GetPlayerID()) and unit:IsAlive() then
			local dist1 = GetUnitToLocationDistance(unit, RLoc);
			local dist2 = GetUnitToLocationDistance(bot, RLoc);
			if dist2 < 1200 and dist1 < 1200 then
				return true;
			end
		end
	end
	return false;
end

function IsPureSupport(bot)
	return role.CanBeSupport(bot:GetUnitName()) and bot:GetAssignedLane() ~= LANE_MID
end

function PriorityHeroExist(bot)
	local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
	local exist = false;
	local theHero = "";
	for _,a in pairs(allies)
	do
		if a ~= nil and not a:IsIllusion() and a:GetUnitName() ~= "npc_dota_lone_druid_bear" and a:IsHero() and
		  ( HasBottle(a) or a:GetAssignedLane() == LANE_MID or role.CanBeMidlaner(a:GetUnitName()) or role.CanBeSafeLaneCarry(a:GetUnitName()) ) 
		then
			exist = true;
			theHero = a:GetUnitName()
			break;
		end
	end
	return exist, theHero;
end

function HasBottle(bot)
	local slot = bot:FindItemSlot('item_bottle');
	return slot >= 0 and slot <= 5;
end

function IsSuitableToPick(npcBot)
	local mode = npcBot:GetActiveMode();
	local Enemies = npcBot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	if ( ( mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or Enemies ~= nil and #Enemies >= 2
		or ( Enemies ~= nil and #Enemies == 1 and Enemies[1] ~= nil and IsStronger(npcBot, Enemies[1]) )
		) 
	then
		return false;
	end
	return true;
end

function IsStronger(bot, enemy)
	local BPower = bot:GetEstimatedDamageToTarget(true, enemy, 4.0, DAMAGE_TYPE_ALL);
	local EPower = enemy:GetEstimatedDamageToTarget(true, bot, 4.0, DAMAGE_TYPE_ALL);
	return EPower > BPower;
end

function GetEstimatedTimeToRune(bot)
	local ApproxTime = 15;
		
	if GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_BOT then
		local EstTime = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RUNE_BOUNTY_1)) / movementSpeed;
		if  EstTime < 60 then 
			ApproxTime = EstTime;
		end
	elseif GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_TOP then	
		local EstTime = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RUNE_BOUNTY_2)) / movementSpeed;
		if  EstTime < 60 then 
			ApproxTime = EstTime;
		end
	elseif GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_TOP then	
		local EstTime = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RUNE_BOUNTY_3)) / movementSpeed;
		if  EstTime < 60 then 
			ApproxTime = EstTime;
		end	
	elseif GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_BOT then	
		local EstTime = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RUNE_BOUNTY_4)) / movementSpeed;
		if  EstTime < 60 then 
			ApproxTime = EstTime;
		end
	end
	
	return ApproxTime;
end

function IsTheClosestOne(bot, r)
	local Players = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	local RuneLoc = GetRuneSpawnLocation(r);
	local minDist = GetUnitToLocationDistance(bot, RuneLoc);
	local closest = bot;
	for _,unit in pairs(Players)
	do	
		if  unit ~= nil and not unit:IsIllusion() and unit:IsAlive() then
			local dist = GetUnitToLocationDistance(unit, RuneLoc);
			if dist < minDist then
				minDist = dist;
				closest = unit;
			end
		end
	end
	return closest:GetUnitName() == bot:GetUnitName();
end
