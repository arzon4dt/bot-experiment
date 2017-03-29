local preciousItem = {
		"item_aegis",
		"item_cheese",
		"item_gem"
};

local listBoots = { 
	"item_boots",
	"item_tranquil_boots",
    "item_power_treads", 
	"item_phase_boots", 
	"item_arcane_boots",
	"item_guardian_greaves",
	"item_travel_boots",
	"item_travel_boots_2"
}

function GetDesire()
	local npcBot = GetBot();
	local listDrppedItem = GetDroppedItemList()

	for _,item in pairs(listDrppedItem)
	do
		local Own = item.owner;
		print(Own..item.item:GetName())
		local item_name = item.item:GetName();
		if IsPreciousItem(item_name) then
			return BOT_MODE_DESIRE_HIGH;
		elseif item.owner ~= npcBot then
			return ( 0.0 );
		end
	end
	
	return ( 0.0 );
end

function Think()
	local npcBot = GetBot();
	local listDrppedItem = GetDroppedItemList()
	print("pick")
	for _,item in pairs(listDrppedItem)
	do
		local item_name = item.item:GetName();
		if IsPreciousItem(item_name) then
				
				npcBot:Action_ClearAction(true);
				--SwapAndTake();
				npcBot:ActionImmediate_SwapItems( 2, 6 );
				npcBot:ActionPush_PickUpItem(item.item);
				return
			--[[if HasEmptySlot(true) then
				npcBot:Action_PickUpItem(item.item);
				return
			elseif not HasEmptySlot(true) and HasEmptySlot(false) then
				npcBot:Action_ClearAction(true);
				--SwapAndTake();
				npcBot:ActionImmediate_SwapItems( 2, 4 );
				npcBot:Action_PickUpItem(item.item);
				return
			end]]--
			--[[local lviSlot = getLessValuableItemSlot(true);
			local lviBPSlot = getLessValuableItemSlot(false);
			local bpSlot = findEmptySlotOnBP();
			if lviSlot ~= -1 and bpSlot ~= -1  then
				npcBot:ActionImmediate_SwapItems( lviSlot, bpSlot );
				npcBot:Action_PickUpItem(item.item);
			elseif 	lviSlot ~= -1 and bpSlot == -1 then
				npcBot:Action_DropItem( npcBot:GetItemInSlot(lviBPSlot), npcBot:GetLocation() + RandomVector(100) );
				bpSlot = findEmptySlotOnBP();
				npcBot:ActionImmediate_SwapItems( lviSlot, bpSlot );
				npcBot:Action_PickUpItem(item.item);
			end]]--
		end
	end
	
end

function HasEmptySlot( mainInv )
	local npcBot = GetBot();
	if mainInv then
		for i=0, 5 do
			local _item = npcBot:GetItemInSlot(i);
			if _item == nil then
				return true
			end
		end
	else
		for i=6, 8 do
			local _item = npcBot:GetItemInSlot(i);
			if _item == nil then
				return true
			end
		end
	end
	return false
end

function SwapItem()
	local npcBot = GetBot();
	local lviSlot = getLessValuableItemSlot(true);
	local bpSlot = findEmptySlotOnBP();
	npcBot:ActionImmediate_SwapItems( lviSlot, bpSlot );
end


function findEmptySlotOnBP()
	local npcBot = GetBot();
	for i=6, 8 do
		local _item = npcBot:GetItemInSlot(i);
		if _item == nil then
			return i;
		end
	end
	return -1;
end

function getLessValuableItemSlot(main)
	local npcBot = GetBot();
	local minPrice = 10000;
	local minIdx = -1;
	
	if main then
		for i=0, 5 do
			local _item = npcBot:GetItemInSlot(i):GetName()
			if( not IsBoots(_item) and _item ~= "item_aegis" and GetItemCost(_item) < minPrice ) then
				minPrice = GetItemCost(_item)
				minIdx = i;
			end
		end
	else
		for i=6, 8 do
			if npcBot:GetItemInSlot(i) ~= nil then
				local _item = npcBot:GetItemInSlot(i):GetName()
				if( not IsBoots(_item) and GetItemCost(_item) < minPrice ) then
					minPrice = GetItemCost(_item)
					minIdx = i;
				end
			end
		end
	end
	
	return minIdx;
end

function IsBoots(item)
	for _,boot in pairs (listBoots)
	do
		if boot == item then
			return true
		end	
	end
	return false
end

function IsPreciousItem(item_name)
	for _,item in pairs(preciousItem)
	do
		if item_name == item then
			return true;
		end	
	end
	return false;
end