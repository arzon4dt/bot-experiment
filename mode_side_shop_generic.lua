if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local npcBot = GetBot();
local sNextItem = nil;
local BOT_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE )
local TOP_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE2 )

function GetDesire()
	
	if npcBot:IsIllusion() or not npcBot:IsHero() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if not IsSuitableToBuy() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if npcBot.tableItemsToBuy == nil or #(npcBot.tableItemsToBuy) == 0 then
		return BOT_MODE_DESIRE_NONE;
	end
	
	sNextItem = npcBot.tableItemsToBuy[1];
	
	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) ) then
		if IsItemPurchasedFromSideShop( sNextItem ) and npcBot:DistanceFromSideShop() < 2000  
		then
			return BOT_MODE_DESIRE_VERYHIGH;
		end
	end

	return BOT_MODE_DESIRE_NONE

end

function Think()
	
	if npcBot:DistanceFromSideShop() == 0 then 
		if ( npcBot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
			table.remove( npcBot.tableItemsToBuy, 1 );
		end
	end		
	
	local closestSideShop = GetClosestSideShop()
	
	if npcBot:DistanceFromSideShop() > 0 then
		npcBot:Action_MoveToLocation(closestSideShop);
		return
	end	
	
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
	if ( ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or npcBot:GetActiveMode() == BOT_MODE_ATTACK
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
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
