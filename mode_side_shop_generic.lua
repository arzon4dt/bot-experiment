--[[function GetDesire()

	return ( 0.0 );

end
]]--

function GetDesire()

	local npcBot = GetBot();

	if ( npcBot.sideShopMode == true ) then
		return ( 0.5 );
	end
  
	if ( #(npcBot.tableItemsToBuy) > 0 ) then
		local sNextItem = npcBot.tableItemsToBuy[1];

		if ( not IsItemPurchasedFromSideShop( sNextItem ) ) then
			npcBot.secretSideMode = false;
		end
	end

	return ( 0.0 );

end

----------------------------------------------------------------------------------------------------

function Think()

	local npcBot = GetBot();

	local shopLoc1 = GetShopLocation( GetTeam(), SHOP_SIDE );
	local shopLoc2 = GetShopLocation( GetTeam(), SHOP_SIDE2 );

	if ( GetUnitToLocationDistance(npcBot, shopLoc1) <= GetUnitToLocationDistance(npcBot, shopLoc2) ) then
		npcBot:Action_MoveToLocation( shopLoc1 );
	else
		npcBot:Action_MoveToLocation( shopLoc2 );
	end

end
