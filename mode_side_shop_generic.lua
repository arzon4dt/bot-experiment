local npcBot = GetBot();

local BOT_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE )
local TOP_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE2 )

function GetDesire()
	
	if npcBot:IsIllusion() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if string.find(GetBot():GetUnitName(), "monkey") and npcBot:IsInvulnerable() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if not IsSuitableToBuy() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if npcBot.SideShop then
		return BOT_MODE_DESIRE_HIGH
	end

	return BOT_MODE_DESIRE_NONE

end

function Think()
	
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
