local bot = GetBot();
local pItem = nil;
local swapState = "";

function GetDesire()
	if bot:IsIllusion() or bot:IsInvulnerable() or not bot:IsHero() or bot:IsUsingAbility() or bot:IsChanneling() 	
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if bot:GetActiveMode() == BOT_MODE_WARD then return BOT_MODE_DESIRE_NONE end
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	local mode = bot:GetActiveMode();
	local droppedItems = GetDroppedItemList();
	
	for _,item in pairs(droppedItems)
	do	
		--print("Name :"..item.item:GetName());
		--print("pID  :"..tostring(item.playerid));
		--print("Own  :"..tostring(item.owner));
		--print("Loc  :"..tostring(item.location));
		if IsPrecisioudItem(item.item:GetName()) and IsTheClosestOne(item.location) then
			pItem = item;
			return BOT_MODE_DESIRE_HIGH;
		elseif item.owner == bot and GetNumEmptySlot(bot, "all") > 0 then
			pItem = item;
			return BOT_MODE_DESIRE_HIGH;
		end	
	end 
	
	return  BOT_MODE_DESIRE_NONE;
end

function OnStart()
	--[[print(bot:GetUnitName().. GetNumEmptySlot(bot, "main"))
	if GetNumEmptySlot(bot, "main") == 0 and GetNumEmptySlot(bot, "backpack") > 0 then
		PutItemToBP();
	end]]--
end

function OnEnd()
	pItem = nil;
end

function Think()
	if pItem ~= nil then
		if GetNumEmptySlot(bot, "main") == 0 and GetNumEmptySlot(bot, "backpack") > 0 then
			PutItemToBP();
		end
		if GetUnitToLocationDistance(bot, pItem.location) > 200 then
			bot:Action_MoveToLocation(pItem.location)
			return
		elseif GetNumEmptySlot(bot, "main") == 0 and GetNumEmptySlot(bot, "backpack") > 0 then
			PutItemToBP();
		elseif GetNumEmptySlot(bot, "all") == 0 then
			local lessValItem = GetItemWParam(false, "all")
			if lessValItem ~= -1 then
				bot:Action_DropItem( bot:GetItemInSlot(lessValItem), bot:GetLocation() + RandomVector(200) )
				return
			end
		else
			bot:Action_PickUpItem( pItem.item )
			pItem = nil;
			return
		end
	end
end

function PutItemToBP()
	local index1 = GetItemWParam(false, "main");
	local index2 = GetEmptySlotIdx("backpack");
	if index1 ~= -1 and index2 ~= -1 then
		print(bot:GetUnitName().." Swap "..tostring(index1).." to "..tostring(index2))
		bot:ActionImmediate_SwapItems( index1, index2 ); 
	end
end

function GetItemWParam(most_val, inv_type)
	local price = 10000;
	if most_val then price = 0; end
	local slot = -1;
	local sIdx, eIdx = GetStartEndIdx(inv_type);
	for i = sIdx, eIdx
	do
		local item = bot:GetItemInSlot(i);
		if item ~= nil and not IsPrecisioudItem(item:GetName()) then
			local cost = GetItemCost(item:GetName());
			if ( most_val and cost > price ) or ( not most_val and cost < price ) then
				price = cost;
				slot = i;
			end	
		end
	end
	return slot;
end

function GetEmptySlotIdx(inv_type)
	local slot = -1;
	local sIdx, eIdx = GetStartEndIdx(inv_type);
	for i = sIdx, eIdx
	do
		if bot:GetItemInSlot(i) == nil then
			return i;
		end
	end
	return slot;
end

function GetStartEndIdx(inv_type)
	if inv_type == "main" then
		return 0, 5;
	elseif inv_type == "backpack" then
		return 6, 8;
	else
		return 0, 8;
	end
end


function IsPrecisioudItem(item_name)
	return item_name == "item_rapier" or item_name == "item_aegis" or item_name == "item_cheese" or item_name == "item_gem";
end

function IsTheClosestOne(loc)
	local minDist = GetUnitToLocationDistance(bot, loc);
	local closest = bot;
	for k,v in pairs(teamPlayers)
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() and GetNumEmptySlot(member, "all") > 0 then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist < minDist then
				minDist = dist;
				closest = member;
			end
		end
	end
	return closest:GetUnitName() == bot:GetUnitName();
end

function GetNumEmptySlot(unit, invType)
	local numESlot = 0;
	local sIdx = 0;
	local eIdx = 8;
	if invType == "main" then
		eIdx = 5; 
	elseif invType == "backpack" then
 		sIdx = 6;
 		eIdx = 8;
	end
	for i=sIdx, eIdx
	do
		if unit:GetItemInSlot(i) == nil then
			numESlot = numESlot + 1;
		end
	end
	return numESlot;
end

