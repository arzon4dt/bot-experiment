if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local npcBot = GetBot();
local sNextItem = nil;
local RAD_SECRET_SHOP = GetShopLocation(GetTeam(), SHOP_SECRET )
local DIRE_SECRET_SHOP = GetShopLocation(GetTeam(), SHOP_SECRET2 )

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
		if ( IsItemPurchasedFromSecretShop( sNextItem ) and not IsItemPurchasedFromSideShop( sNextItem ) ) or
		   ( IsItemPurchasedFromSecretShop( sNextItem ) and IsItemPurchasedFromSideShop( sNextItem ) and npcBot:DistanceFromSideShop() > 2000  )
		then
			return BOT_MODE_DESIRE_VERYHIGH;
		end
	end

	return BOT_MODE_DESIRE_NONE

end

function Think()
	

	if npcBot:DistanceFromSecretShop() == 0 then 
		if ( npcBot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
			table.remove( npcBot.tableItemsToBuy, 1 );
		end
	end		
	
	if GetTeam() == TEAM_RADIANT then
		if GetUnitToLocationDistance(npcBot, DIRE_SECRET_SHOP) <= 2000 then
			npcBot:Action_MoveToLocation(DIRE_SECRET_SHOP);
			return
		else
			npcBot:Action_MoveToLocation(RAD_SECRET_SHOP);
			return
		end
	elseif GetTeam() == TEAM_DIRE then
		if GetUnitToLocationDistance(npcBot, RAD_SECRET_SHOP) <= 2000 then
			npcBot:Action_MoveToLocation(RAD_SECRET_SHOP);
			return
		else
			npcBot:Action_MoveToLocation(DIRE_SECRET_SHOP);
			return
		end
	end
	
end

function IsSuitableToBuy()
	local Enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if ( ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or npcBot:GetActiveMode() == BOT_MODE_ATTACK
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
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
