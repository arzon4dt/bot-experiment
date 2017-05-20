local npcBot = GetBot();

local RAD_SECRET_SHOP = GetShopLocation(GetTeam(), SHOP_SECRET )
local DIRE_SECRET_SHOP = GetShopLocation(GetTeam(), SHOP_SECRET2 )

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
	
	if npcBot.SecretShop then
		return BOT_MODE_DESIRE_HIGH
	end
	
	return BOT_MODE_DESIRE_NONE

end

function Think()

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
	local mode = npcBot:GetActiveMode();
	local Enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
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
