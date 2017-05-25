if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local WardUtils = require(GetScriptDirectory() ..  "/WardUtility")
local bot = GetBot();
local MWardSpot = {};
local MWardSpotTowerFall = {};
local AggressiveSpot = {};
local nWardCastRange = 500;
local nThresholdDist = 1200;
local wt = nil;
local visionRad = 1600;
local Boots = { 
	"item_boots", 
	"item_phase_boots", 
	"item_power_treads", 
	"item_tranquil_boots", 
	"item_arcane_boots",
	"item_travel_boots",
	"item_travel_boots_2"
}

function GetDesire()
	
	if bot:IsIllusion() or bot:IsInvulnerable() or not bot:IsHero() or not IsSuitableToWard() 
	   or bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE 
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	bot.WardSlot = WardUtils.HasWardInInventory();
	bot.HasWard  = false;
	
	if bot.WardSlot >= 0 and bot.WardSlot <= 8 then
		bot.HasWard = true;
	end
	
	if not bot.HasWard then
		return ( 0.0 );
	end
	
	if IsPingedByHumanPlayer() then
		return BOT_MODE_DESIRE_HIGH;
	end
	
	if #AggressiveSpot == 0 then
		AggressiveSpot = WardUtils.GetAggressiveSpot();
	end
	
	if DotaTime() <= 0  then
		--print(bot:GetUnitName().."Warding Early Game")
		return BOT_MODE_DESIRE_HIGH;
	elseif DotaTime() > 0 then
		if IsThereAWardSpot()  then
			--print(bot:GetUnitName().."Warding If There Is a Mandate Spot")
			return BOT_MODE_DESIRE_HIGH;
		elseif IsThereAWardSpotForTowerFall() then
			--print(bot:GetUnitName().."Warding If There Is a Tower Fall Spot")
			return BOT_MODE_DESIRE_HIGH;
		else
			for _,AggSpot in pairs(AggressiveSpot)
			do
				if GetUnitToLocationDistance(bot, AggSpot) < nThresholdDist and not IsWardExistInWardRange(AggSpot) then
					--print(bot:GetUnitName().."Warding If Near Aggresive Spot")
					return BOT_MODE_DESIRE_HIGH;
				end
			end
		end
	end	
	
	return ( 0.0 );
end

function OnStart()
	MWardSpot = WardUtils.GetMandatorySpot();
	MWardSpotTowerFall = WardUtils.GetWardSpotWhenTowerFall();
	--print(#MWardSpotTowerFall)
	if bot:GetItemSlotType( bot.WardSlot ) == ITEM_SLOT_TYPE_BACKPACK then
		SwapItemForWarding();
	end
	if IsPingedByHumanPlayer() then
		wt = GetWardTarget();
	end
end

function OnEnd()
	MWardSpot = {};
	MWardSpotTowerFall = {};
	PutWardOnBackPack();
	wt = nil;
end

function Think()

	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	
	--local bot = GetBot()
	
	if not bot.HasWard then return end;
	
	UpdateAvailableWardSpot("mandate");
	UpdateAvailableWardSpot("tower_fall");
	
	local MclosestWardSpot = GetClosestWardSpot("mandate");
	local MTFclosestWardSpot = GetClosestWardSpot("tower_fall");
	
	if MclosestWardSpot ~= nil and MTFclosestWardSpot ~= nil then
		if GetUnitToLocationDistance(bot,  MclosestWardSpot) < GetUnitToLocationDistance(bot,  MTFclosestWardSpot) then
			MTFclosestWardSpot = nil;
		else
			MclosestWardSpot = nil;
		end
	end	
	
	if IsPingedByHumanPlayer() then
		if bot.HasWard and bot:GetItemSlotType(bot.WardSlot) == ITEM_SLOT_TYPE_MAIN  then
			local wardItem = bot:GetItemInSlot(bot.WardSlot);
			bot:Action_ClearActions(false);	
			bot:Action_UseAbilityOnEntity(wardItem, wt);
			return;	
		end	
	end
	
	if ( bot:IsUsingAbility() or bot:IsChanneling() ) then return end;
	
	if DotaTime() <= 0 and #MWardSpot > 0 and MclosestWardSpot ~= nil then
		if bot.HasWard and bot:GetItemSlotType(bot.WardSlot) == ITEM_SLOT_TYPE_MAIN  then
			local wardItem = bot:GetItemInSlot(bot.WardSlot);
			if GetUnitToLocationDistance(bot,  MclosestWardSpot) < nWardCastRange then
				--print("Use Ward Time < 0");
				bot:Action_UseAbilityOnLocation(wardItem, MclosestWardSpot);
				return
			else
				bot:Action_MoveToLocation(MclosestWardSpot);
				return
			end
		end
	elseif DotaTime() > 0 and #MWardSpot > 0 and MclosestWardSpot ~= nil then 
		if bot.HasWard and bot:GetItemSlotType(bot.WardSlot) == ITEM_SLOT_TYPE_MAIN  then
			local wardItem = bot:GetItemInSlot(bot.WardSlot);
			if GetUnitToLocationDistance(bot,  MclosestWardSpot) < nWardCastRange then
				--print("Use Ward Time > 0 Mandate");
				bot:Action_UseAbilityOnLocation(wardItem, MclosestWardSpot);
				return
			else
				bot:Action_MoveToLocation(MclosestWardSpot);
				return
			end
		end
	elseif DotaTime() > 0 and #MWardSpotTowerFall > 0 and MTFclosestWardSpot ~= nil then
		if bot.HasWard and bot:GetItemSlotType(bot.WardSlot) == ITEM_SLOT_TYPE_MAIN  then
			local wardItem = bot:GetItemInSlot(bot.WardSlot);
			if GetUnitToLocationDistance(bot,  MTFclosestWardSpot) < nWardCastRange then
				--print("Use Ward Time > 0 Tower Fall");
				bot:Action_UseAbilityOnLocation(wardItem, MTFclosestWardSpot);
				return
			else
				bot:Action_MoveToLocation(MTFclosestWardSpot);
				return
			end
		end
	else
		for _, AggSpot in pairs(AggressiveSpot)
		do
			if bot.HasWard and GetUnitToLocationDistance(bot, AggSpot) < nThresholdDist and not IsWardExistInWardRange(AggSpot) and bot:GetItemSlotType(bot.WardSlot) == ITEM_SLOT_TYPE_MAIN
			then
				local wardItem = bot:GetItemInSlot(bot.WardSlot);
				if GetUnitToLocationDistance(bot,  AggSpot) < nWardCastRange then
					--print("Use Ward Time > 0 Aggresive");
					bot:Action_UseAbilityOnLocation(wardItem, AggSpot);
					return
				else
					bot:Action_MoveToLocation(AggSpot);
					return
				end
			end
		end
	end

end

function IsPingedByHumanPlayer()
	local ListUnits = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	for _,unit in pairs(ListUnits)
	do
		if unit ~= nil and not unit:IsIllusion() and not IsPlayerBot(unit:GetPlayerID()) and unit:IsAlive() then
			local ping = unit:GetMostRecentPing();
			local Wslot = unit:FindItemSlot('item_ward_observer');
			if GetUnitToUnitDistance(bot, unit) < 600 and 
			   GetUnitToLocationDistance(bot, ping.location) < 600 and 
			   GameTime() - ping.time < 10 and 
			   Wslot == -1
			then
				return true;
			end	
		end
	end
	return false;
end

function GetWardTarget()
	local ListUnits = GetUnitList(UNIT_LIST_ALLIED_HEROES);
	for _,unit in pairs(ListUnits)
	do
		if unit ~= nil and not unit:IsIllusion() and not IsPlayerBot(unit:GetPlayerID()) and unit:IsAlive() then
			local ping = unit:GetMostRecentPing();
			local Wslot = unit:FindItemSlot('item_ward_observer');
			if GetUnitToUnitDistance(bot, unit) < 600 and 
			   GetUnitToLocationDistance(bot, ping.location) < 600 and 
			   GameTime() - ping.time < 10 and 
			   Wslot == -1
			then
				return unit;
			end	
		end
	end
	return nil;
end

function IsWardExistInWardRange(Spot)
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
	for _,ward in pairs(WardList)
	do	
		if ward ~= nil and IsObserver(ward) and GetUnitToLocationDistance(ward, Spot) <= visionRad then
			return true;
		end
	end
	return false;
end

function IsObserver(wardUnit)
	return string.find(wardUnit:GetUnitName(), "observer");
end

function UpdateAvailableWardSpot(sType)
	if sType == "mandate" then
		for i = 1, #MWardSpot
		do
			if IsWardExistInWardRange(MWardSpot[i]) then
				table.remove(MWardSpot, i);
				return
			end
		end
	elseif sType == "tower_fall" then
		for i = 1, #MWardSpotTowerFall
		do
			if IsWardExistInWardRange(MWardSpotTowerFall[i])  then
				table.remove(MWardSpotTowerFall, i);
				return
			end
		end
	end
	
end

function GetClosestWardSpot(sType)
	local closestSpot = nil;
	local closestDistance = 50000;
	if sType == "mandate" then
		for _,ws in pairs(MWardSpot)
		do
			local dist = GetUnitToLocationDistance(bot, ws);
			if dist < closestDistance then
				closestDistance = dist;
				closestSpot = ws;
			end
		end
		return closestSpot;
	elseif sType == "tower_fall" then
		for _,ws in pairs(MWardSpotTowerFall)
		do
			local dist = GetUnitToLocationDistance(bot, ws);
			if dist < closestDistance then
				closestDistance = dist;
				closestSpot = ws;
			end
		end
		return closestSpot;
	end
end

function IsThereAWardSpot()
	local SPots = WardUtils.GetMandatorySpot();
	local s = nil;
	for i = 1, #SPots
	do
		if not IsWardExistInWardRange(SPots[i]) then
			s = SPots[i];
			break
		end
	end
	return s ~= nil;
end

function IsThereAWardSpotForTowerFall()
	local SPots = WardUtils.GetWardSpotWhenTowerFall();
	local s = nil;
	for i = 1, #SPots
	do
		if not IsWardExistInWardRange(SPots[i]) then
			s = SPots[i];
			break
		end
	end
	return s ~= nil;
end


--check if the condition is suitable for warding
function IsSuitableToWard()
	local Enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	local mode = bot:GetActiveMode();
	if ( ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or Enemies ~= nil and #Enemies >= 2
		or ( Enemies ~= nil and #Enemies == 1 and Enemies[1] ~= nil and IsStronger(Enemies[1]) )
		) 
	then
		return false;
	end
	return true;
end

function IsStronger(enemy)
	local BPower = bot:GetEstimatedDamageToTarget(true, enemy, 4.0, DAMAGE_TYPE_ALL);
	local EPower = enemy:GetEstimatedDamageToTarget(true, bot, 4.0, DAMAGE_TYPE_ALL);
	return EPower > BPower;
end

function SwapItemForWarding() 
	--if bot:GetItemSlotType( bot.WardSlot ) == ITEM_SLOT_TYPE_BACKPACK then
		local lviSlot = getLessValuableItemSlot();
		if wdSlot ~= -1 then
			bot:ActionImmediate_SwapItems( bot.WardSlot, lviSlot );
			return
		end
	--end
end

function PutWardOnBackPack()
	local wardSlot = bot:FindItemSlot( "item_ward_observer" );
	if wardSlot >= 0 and wardSlot <= 8 then
		--if bot:GetActiveMode() ~= BOT_MODE_WARD and 
		if bot:GetItemSlotType(wardSlot) == ITEM_SLOT_TYPE_MAIN  and 
		   IsInvFull() and 
		   HasItemInBP() then
			local wdSlot =  wardSlot --npcBot:FindItemSlot( "item_ward_observer" );
			local mviSlot = getMostValuableBPSlot();
			if mviSlot ~= -1 then
				--print("SwapBack");
				bot:ActionImmediate_SwapItems( wdSlot, mviSlot );
				return
			end
		end
	end
end

function IsBoots(item)
	for _,boot in pairs(Boots)
	do
		if item == boot then
			return true;
		end	
	end
	return false;
end

function getLessValuableItemSlot()
	local npcBot = GetBot();
	local minPrice = 10000;
	local minIdx = -1;
	for i=0, 5 do
		if  npcBot:GetItemInSlot(i) ~= nil and npcBot:GetItemInSlot(i):GetName() ~= "item_aegis"  then
			local _item = npcBot:GetItemInSlot(i):GetName()
			if( GetItemCost(_item) < minPrice ) then
				minPrice = GetItemCost(_item)
				minIdx = i;
			end
		end
	end
	
	return minIdx;
end

function getMostValuableBPSlot()
	local npcBot = GetBot();
	local maxPrice = 0;
	local maxIdx = -1;
		for i=6, 8 do
			if(npcBot:GetItemInSlot(i) ~= nil) then
				local _item = npcBot:GetItemInSlot(i):GetName()
				if( GetItemCost(_item) > maxPrice ) then
					maxPrice = GetItemCost(_item)
					maxIdx = i;
				end
			end
		end
		
	return maxIdx;
end

function IsInvFull()
	local npcHero = GetBot();
	for i=0, 8 do
		if(npcHero:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
end

function HasItemInBP()
	local npcHero = GetBot();
	for i=6, 8 do
		if(npcHero:GetItemInSlot(i) ~= nil) then
			return true;
		end
	end
	return false;
end