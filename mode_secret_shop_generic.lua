local npcBot = GetBot();
local preferedSS = nil;
local RAD_SECRET_SHOP = GetShopLocation(GetTeam(), SHOP_SECRET )
local DIRE_SECRET_SHOP = GetShopLocation(GetTeam(), SHOP_SECRET2 )
local reason = "";
local have = false;

function GetDesire()
	
	if npcBot:IsChanneling() or npcBot:IsIllusion() or (string.find(GetBot():GetUnitName(), "monkey") and npcBot:IsInvulnerable()) then
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
		if DotaTime() > 25*60 then
			have, itemSlot = HaveItemToSell();
			if have then
				preferedSS = GetPreferedSecretShop();
				if  preferedSS ~= nil then
					return RemapValClamped(  GetUnitToLocationDistance(npcBot, preferedSS), 6000, 0, 0.75, 1.0 );
				end	
			end
		end
		return BOT_MODE_DESIRE_NONE;
	end
	
	local npcCourier = GetCourier(0);	
	local cState = GetCourierState( npcCourier );
	
	if npcBot.SecretShop and cState ~= COURIER_STATE_MOVING  then
		preferedSS = GetPreferedSecretShop();
		if  preferedSS ~= nil and cState == COURIER_STATE_DEAD then
			return RemapValClamped(  GetUnitToLocationDistance(npcBot, preferedSS), 6000, 0, 0.5, 0.75 );
		else
			if preferedSS ~= nil and GetUnitToLocationDistance(npcBot, preferedSS) <= 2500 then
				return RemapValClamped(  GetUnitToLocationDistance(npcBot, preferedSS), 2500, 0, 0.5, 0.75 );
			end
		end
	end
	
	return BOT_MODE_DESIRE_NONE

end

function OnEnd()
	reason = "";
end

function Think()
	
	npcBot:Action_MoveToLocation(preferedSS);
	return
	
end

function HaveItemToSell()
	 local earlyGameItem = {
		 "item_clarity",
		 "item_faerie_fire",
		 "item_tango",  
		 "item_flask", 
		 "item_infused_raindrop",
		 "item_iron_talon",
		 "item_poor_mans_shield",
		 "item_magic_wand",
		 "item_bottle",  
		 "item_ring_of_aquila", 
		 "item_urn_of_shadows",
		 "item_dust",
		 "item_ward_observer",
	}
	for _,item in pairs(earlyGameItem) do
		local slot = npcBot:FindItemSlot(item);
		if slot >= 0 and slot <= 8 then
			return true, slot;
		end
	end
	return false, nil;
end

function GetPreferedSecretShop()
	if GetTeam() == TEAM_RADIANT then
		if GetUnitToLocationDistance(npcBot, DIRE_SECRET_SHOP) <= 2000 then
			return DIRE_SECRET_SHOP;
		else
			return RAD_SECRET_SHOP;
		end
	elseif GetTeam() == TEAM_DIRE then
		if GetUnitToLocationDistance(npcBot, RAD_SECRET_SHOP) <= 2000 then
			return RAD_SECRET_SHOP;
		else
			return DIRE_SECRET_SHOP;
		end
	end
	return nil;
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
