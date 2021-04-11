if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local utils = require(GetScriptDirectory() ..  "/util");
local role = require(GetScriptDirectory() .. "/RoleUtility");
local uItem = require(GetScriptDirectory() .. "/ItemUtility" );
local mUtils = require(GetScriptDirectory() .. "/MyUtility" );
local hero_roles = role["hero_roles"];
local bot = GetBot();
local minute = 0;
local sec = 0;
local closestRune  = -1;
local runeStatus = -1;
local ProxDist = 1500;
local teamPlayers = nil;
local PingTimeGap = 10;
local bottle = nil;
local enemyPids = nil
local neutralItemCheck = -90;
local dropNeutralItemCheck = -90;
local swapNeutralItemCheck = -90;
local neutralItem = nil;
local droppedNeutralItems = {};

local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}

local lastPing = -90;
bot.RuneType = RUNE_INVALID;

function GetDesire()
	--print(bot:GetUnitName()..bot:GetAssignedLane())
	--[[if bot.lastPlayerChat ~= nil and string.find(bot.lastPlayerChat.text, "rune") then
		bot:ActionImmediate_Chat("Catch this in mode_rune_generic", false);
		bot.lastPlayerChat = nil;
	end]]--
	-- if DotaTime() > lastPing + 3.0 then
		-- bot:ActionImmediate_Ping( GetRuneSpawnLocation(RUNE_BOUNTY_4).x,  GetRuneSpawnLocation(RUNE_BOUNTY_4).y, true)
		-- lastPing = DotaTime()
	-- end

	if GetGameMode() == GAMEMODE_1V1MID then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if GetGameMode() == GAMEMODE_MO and DotaTime() <= 0 then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	if bot:IsIllusion() or bot:IsInvulnerable() or not bot:IsHero() or bot:HasModifier("modifier_arc_warden_tempest_double") or
       bot:IsUsingAbility() or bot:IsChanneling() or bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE 
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	-- if DotaTime() > dropNeutralItemCheck + 0.25 then
		-- local canDrop, hItem = uItem.CanDropNeutralItem(bot);
		-- if canDrop == true then
			-- bot:Action_DropItem(hItem, bot:GetLocation() + RandomVector(100));
			-- return;
		-- end
		-- canDrop, hItem = uItem.CanDropExcessNeutralItem(bot);
		-- if canDrop == true then
			-- bot:Action_DropItem(hItem, bot:GetLocation() + RandomVector(100));
			-- return;
		-- end
		-- dropNeutralItemCheck = DotaTime();
	-- end
	
	-- if DotaTime() > swapNeutralItemCheck + 0.25 then
		-- local canSwap, hItem1, hItem2 = uItem.CanSwapNeutralItem(bot);
		-- if canSwap == true then
			-- bot:ActionImmediate_SwapItems(hItem1, hItem2);
			-- return;
		-- end
		-- swapNeutralItemCheck = DotaTime();
	-- end

	if GetUnitToUnitDistance(bot, GetAncient(GetTeam())) < 3500 or  GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) < 3500 then
		return BOT_MODE_DESIRE_NONE;
	end

	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	if not IsSuitableToPick() then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	if DotaTime() < 0 and not bot:WasRecentlyDamagedByAnyHero(5.0) then 
		return BOT_MODE_DESIRE_HIGH;
	end	
	
	-- if neutralItem ~= nil then
		-- return CountDesire(BOT_MODE_DESIRE_MODERATE, GetUnitToLocationDistance(bot, neutralItem.location), 2000);
	-- end
	
	closestRune, closestDist = GetBotClosestRune();
	if closestRune ~= -1 and IsEnemyCloserToRuneLoc(closestRune, closestDist) == false then
		if closestRune == RUNE_BOUNTY_1 or closestRune == RUNE_BOUNTY_2 or closestRune == RUNE_BOUNTY_3 or closestRune == RUNE_BOUNTY_4 then
			runeStatus = GetRuneStatus( closestRune );
			if runeStatus == RUNE_STATUS_AVAILABLE then
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 3000);
			elseif runeStatus == RUNE_STATUS_UNKNOWN and closestDist <= ProxDist then
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
			elseif runeStatus == RUNE_STATUS_MISSING and DotaTime() > 60 and ( minute % 4 == 0 and sec > 52 ) and closestDist <= ProxDist then
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
			elseif IsTeamMustSaveRune(closestRune) and runeStatus == RUNE_STATUS_UNKNOWN then
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 5000);
			end
		else
			if DotaTime() > 3 * 60 + 50 then
				runeStatus = GetRuneStatus( closestRune );
				if runeStatus == RUNE_STATUS_AVAILABLE then
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 5000);
				elseif runeStatus == RUNE_STATUS_UNKNOWN and closestDist <= ProxDist then
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
				elseif runeStatus == RUNE_STATUS_MISSING and DotaTime() > 60 and ( minute % 2 == 1 and sec > 52 ) and closestDist <= ProxDist then
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
				elseif IsTeamMustSaveRune(closestRune) and runeStatus == RUNE_STATUS_UNKNOWN then
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 5000);
				end
			end	
		end	
	end
	-- print(bot:GetUnitName())
	-- for i=0,25 do
		-- if bot:GetItemSlotType(i) == ITEM_SLOT_TYPE_MAIN then
			-- print(tostring(i)..'Main')
		-- elseif bot:GetItemSlotType(i) == ITEM_SLOT_TYPE_BACKPACK then
			-- print(tostring(i)..'Back')
		-- elseif bot:GetItemSlotType(i) == ITEM_SLOT_TYPE_STASH then
			-- print(tostring(i)..'Stash')
		-- else
			-- print(tostring(i)..'NA')
		-- end
	-- end
	-- if DotaTime() >= neutralItemCheck + 0.5 and neutralItem == nil and uItem.IsMeepoClone(bot) == false then
		-- if uItem.GetEmptySlotAmount(bot, ITEM_SLOT_TYPE_BACKPACK) > 1 or uItem.IsNeutralItemSlotEmpty(bot) then
			-- local dropped = GetDroppedItemList();
			-- for _,drop in pairs(dropped) do
				-- if uItem.GetNeutralItemTier(drop.item:GetName()) > 0 
					-- and uItem.IsRecipeNeutralItem(drop.item:GetName()) == false 
					-- and utils.GetDistance(drop.location, mUtils.GetTeamFountain()) > 500
					-- and CanPickupNeutralItem(drop.location) == true 
				-- then
					-- print(bot:GetUnitName().." taking item:"..tostring(drop))
					-- neutralItem = drop;
					-- break;
				-- end
			-- end
		-- end	
		-- neutralItemCheck = DotaTime();
	-- end
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	local bottle_slot = bot:FindItemSlot('item_bottle');
	if bot:GetItemSlotType(bottle_slot) == ITEM_SLOT_TYPE_MAIN then
		bottle = bot:GetItemInSlot(bottle_slot);
	end	
end

function OnEnd()
	bottle = nil;
	neutralItem = nil;
end

function Think()
	
	
	if neutralItem ~= nil then
		if GetUnitToLocationDistance(bot, neutralItem.location) > 300 then 
			bot:Action_MoveToLocation(neutralItem.location);
			return
		else
			bot:Action_PickUpItem(neutralItem.item);
			return
		end
	end
	
	if DotaTime() < 0 then 
		if GetTeam() == TEAM_RADIANT then
			if bot:GetAssignedLane() == LANE_BOT then 
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3));
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2));
				return
			end
		elseif GetTeam() == TEAM_DIRE then
			if bot:GetAssignedLane() == LANE_TOP then 
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1));
				return
			else
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4));
				return
			end
		end
	end	
	
	if runeStatus == RUNE_STATUS_AVAILABLE then
		if bottle ~= nil and closestDist < 1200 then 
			local bottle_charge = bottle:GetCurrentCharges() 
			if bottle:IsFullyCastable() and bottle_charge > 0 and ( bot:GetHealth() < bot:GetMaxHealth() or bot:GetMana() < bot:GetMaxMana() ) then
				bot:Action_UseAbility( bottle );
				return;
			end
		end
		
		if closestDist > 200 then
			bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune));
			return
		else
			bot.RuneType = GetRuneType(closestRune);
			bot:Action_PickUpRune(closestRune);
			return
		end
	else 
		bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune));
		return
	end
	
end

function CountDesire(base_desire, dist, maxDist)
	 return base_desire + RemapValClamped( dist, maxDist, 0, 0, 1-base_desire );
end	


function GetBotClosestRune()
	local cDist = 100000;	
	local cRune = -1;	
	for _,r in pairs(ListRune)
	do
		local rLoc = GetRuneSpawnLocation(r);
		if not IsHumanPlayerNearby(rLoc) and not IsPingedByHumanPlayer(rLoc) and not IsThereMidlaner(rLoc) and IsTheClosestOne(rLoc)
		then
			local dist = GetUnitToLocationDistance(bot, rLoc);
			if dist < cDist then
				cDist = dist;
				cRune = r;
			end	
		end
	end
	return cRune, cDist;
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function IsTeamMustSaveRune(rune)
	if GetTeam() == TEAM_DIRE then
		return rune == RUNE_BOUNTY_2 or rune == RUNE_BOUNTY_4 or rune == RUNE_POWERUP_1 or rune == RUNE_POWERUP_2
	else
		return rune == RUNE_BOUNTY_1 or rune == RUNE_BOUNTY_3 or rune == RUNE_POWERUP_1 or rune == RUNE_POWERUP_2
	end
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
		if p ~= nil and not p.normal_ping and GetDistance(p.location, runeLoc) < 1200 and dist2 < 1200 and GameTime() - p.time < PingTimeGap then
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
	return closest == bot;
end

function CanPickupNeutralItem(r)
	local minDist = GetUnitToLocationDistance(bot, r);
	local closest = bot;
	for k,v in pairs(teamPlayers)
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() 
			and ( uItem.GetEmptySlotAmount(member, ITEM_SLOT_TYPE_BACKPACK) >= 2 or uItem.IsNeutralItemSlotEmpty(member) )
		then
			local dist = GetUnitToLocationDistance(member, r);
			if dist < minDist then
				minDist = dist;
				closest = member;
			end
		end
	end
	return closest == bot;
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
	if ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or ( #Enemies >= 1 and IsIBecameTheTarget(Enemies) )
		or bot:WasRecentlyDamagedByAnyHero(5.0)
	then
		return false;
	end
	return true;
end

function IsIBecameTheTarget(units)
	for _,u in pairs(units) do
		if u:GetAttackTarget() == bot then
			return true;
		end
	end
	return false;
end

function IsEnemyCloserToRuneLoc(iRune, botDist)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.0  and utils.GetDistance(dInfo.location, GetRuneSpawnLocation(iRune)) <  botDist
			then	
				return true;
			end
		end	
	end
	return false;
end


