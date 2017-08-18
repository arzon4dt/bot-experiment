local npcBot = GetBot();
local BOT_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE )
local TOP_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE2 )
local closestSideShop = nil;

function GetDesire()
	
	if npcBot:IsIllusion() or npcBot:IsChanneling() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if string.find(GetBot():GetUnitName(), "monkey") and npcBot:IsInvulnerable() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if not IsSuitableToBuy() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	local invFull = true;
	
	for i=0,8 do 
		if npcBot:GetItemInSlot(i) == nil then
			invFull = false;
		end	
	end
	
	if invFull then
		return BOT_MODE_DESIRE_NONE
	end
	
	if npcBot.SideShop then
		closestSideShop = GetClosestSideShop();
		if IsNearbyEnemyClosestToLoc(closestSideShop) == false then
			return BOT_MODE_DESIRE_HIGH
		end
	end

	return BOT_MODE_DESIRE_NONE

end

function Think()
	
	if npcBot:DistanceFromSideShop() > 0 then
		npcBot:Action_MoveToLocation(closestSideShop);
		return
	end	
	
end

function IsNearbyEnemyClosestToLoc(loc)
	local closestDist = GetUnitToLocationDistance(npcBot, loc);
	local closestUnit = npcBot;
	local enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,enemy in pairs(enemies) do
		local dist = GetUnitToLocationDistance(enemy, loc);
		if dist < closestDist then
			return true;
		end
	end
	return false;
end

function GetClosestSideShop()

	local TSSD = GetUnitToLocationDistance(npcBot, TOP_SIDE_SHOP);
	local BSSD = GetUnitToLocationDistance(npcBot, BOT_SIDE_SHOP);
	
	if TSSD < BSSD then 
		return TOP_SIDE_SHOP;
	else
		return BOT_SIDE_SHOP;
	end	

end

function IsSuitableToBuy()
	local mode = npcBot:GetActiveMode();
	if ( ( mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		) 
	then
		return false;
	end
	return true;
end
