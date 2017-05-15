if GetBot():IsNull() or GetBot() == nil or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
local items = require(GetScriptDirectory() .. "/ItemUtility" )
local hero_roles = role["hero_roles"];

Bot = GetBot();
local BotName = Bot:GetUnitName();
local AttackRange = Bot:GetAttackRange();
local PrimaryAttr = Bot:GetPrimaryAttribute();
local supportExist = nil;
local invisEnemyExist = false;
local enemyInvisCheck = false;
local BuyRainDrop = false;
local invisHeroes = {
	['npc_dota_hero_templar_assassin'] = 1,
	['npc_dota_hero_clinkz'] = 1,
	['npc_dota_hero_mirana'] = 1,
	['npc_dota_hero_riki'] = 1,
	['npc_dota_hero_nyx_assassin'] = 1,
	['npc_dota_hero_bounty_hunter'] = 1,
	['npc_dota_hero_invoker'] = 1,
	['npc_dota_hero_sand_king'] = 1,
	['npc_dota_hero_treant'] = 1,
	['npc_dota_hero_broodmother'] = 1
} 

 local earlyGameItem = {
	 "item_tango",
	 "item_clarity", 
	 "item_flask", 
	 "item_infused_raindrop",
	 "item_quelling_blade", 
	 "item_stout_shield", 
	 "item_poor_mans_shield",
	 "item_magic_wand",
	 "item_bottle", 
	 "item_ring_of_aquila", 
	 "item_urn_of_shadows", 
	 "item_soul_ring", 
	 --"item_ward_observer",
	 --"item_tpscroll",
}

Bot.StartingItem = {};	
Bot.EarlyItem = {};	
Bot.CoreItem = {};	
Bot.SituationalItem = {};	
Bot.tableItemsToBuy = {};

function ItemPurchaseThink()

	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS and DotaTime() < -60 then
		return;
	end
	
	if supportExist == nil then supportExist = IsSupportExist(); end
	
	if not invisEnemyExist then invisEnemyExist = IsInvisEnemyExist(); end

	PurchaseTP();
	
	if  supportExist ~= nil and supportExist and role.CanBeSupport(BotName) then
		if GetCourier(0) == nil then
			PurchaseCourier();
		end
		UpgradeCourier();
		if invisEnemyExist then
			PurchaseDust();	
		end
		PurchaseWard();
	elseif supportExist ~= nil and not supportExist then
		PurchaseCourier();
		UpgradeCourier();
	end	
	
	PurchaseRainDrop();
	
	FillStartingItem();
	
	if DotaTime() > 15 then
		FillEarlyItem();
		FillCoreItem();
		--FillSituatonalItem();
	end
	
	if ( Bot.tableItemsToBuy == nil or #(Bot.tableItemsToBuy) == 0 ) then
		Bot:SetNextItemPurchaseValue( 0 );
		return;
	end
	
	GeneralItemPurchasing()

end	

--CHECK IF SUPPORT EXIST
function IsSupportExist()
	if role.CanBeSupport(BotName) then
		return true;
	end
	local TeamMember = GetTeamPlayers(GetTeam())
	for i = 1, #TeamMember
	do
		if GetTeamMember(i) == nil or not GetTeamMember(i):IsAlive() then
			return nil;
		end
	end
	for i = 1, #TeamMember
	do
		local ally = GetTeamMember(i);
		if ally ~= nil and ally:IsHero() and role.CanBeSupport(ally:GetUnitName()) 
		then
			return true;
		end
	end
	return false;
end
--CHECK IF INVIS ENEMY OR INVIS ITEM EXIST
function IsInvisEnemyExist()
	if not enemyInvisCheck then
		local globalEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		for _, enemy in pairs(globalEnemies) do
			if enemy ~= nil and invisHeroes[enemy:GetUnitName()] == 1 then
				enemyInvisCheck = true;
				return true;
			end
		end
	end
	
	if DotaTime() > 15*60 then
		local tableEnemies = Bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		for _,enemy in pairs(tableEnemies)
		do
			local SASlot = enemy:FindItemSlot("item_shadow_amulet");
			local GCSlot = enemy:FindItemSlot("item_glimmer_cape");
			local ISSlot = enemy:FindItemSlot("item_invis_sword");
			local SESlot = enemy:FindItemSlot("item_silver_edge");
			if SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0 then
				return true;
			end	
		end
	end
	return false;
end
--PURCHASE TP
function PurchaseTP()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcCourier = GetCourier(0);
	if( GetEmptySlotAmount() > 3 and 
		not HasItem( Bot, "item_tpscroll") and 
		not HasItem(npcCourier, "item_tpscroll") and 
		not HasItem(npcCourier, "item_travel_boots") and 
		not HasItem( Bot, "item_travel_boots") and
		not HasItem(npcCourier, "item_travel_boots_2") and 
		not HasItem( Bot, "item_travel_boots_2") and
		Bot:GetGold() >= GetItemCost( "item_tpscroll" ) and 
		DotaTime() > 60 ) 
	then
		Bot:ActionImmediate_PurchaseItem("item_tpscroll");
	end
end
--PURCHASE DUST
function PurchaseDust()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcCourier = GetCourier(0);	
	if( DotaTime() > 2*60 and Bot:GetGold() >= GetItemCost( "item_dust" ) and
		GetEmptySlotAmount() >= 4 and
		GetItemCharges("item_dust") < 1 and 
		not HasItem(npcCourier, "item_dust") 
	) 
	then
		Bot:ActionImmediate_PurchaseItem("item_dust"); 
	end
end
--PURCHASE WARD
function PurchaseWard()	
	if( GetItemStockCount( "item_ward_observer" ) > 0 and 
		Bot:GetGold() >= GetItemCost( "item_ward_observer" ) and
		GetEmptySlotAmount() >= 2 and
		GetItemCharges("item_ward_observer") < 2
		) 
	then
		Bot:ActionImmediate_PurchaseItem("item_ward_observer"); 
	end
end
--PURCHASE RAINDROP
function PurchaseRainDrop()
	if( not BuyRainDrop and GetItemStockCount( "item_infused_raindrop" ) > 0 and 
		Bot:GetGold() >= GetItemCost( "item_infused_raindrop" ) and
		GetEmptySlotAmount() >= 4 
	) 
	then
		BuyRainDrop = true;
		Bot:ActionImmediate_PurchaseItem("item_infused_raindrop"); 
	end
end
--CHECK FOR CERTAIN ITEM
function HasItem( hUnit, sItem )
	return hUnit:FindItemSlot( sItem ) >= 0;
end
--CHECK NUMBER OF MAIN+BACKPACK INVENTORY EMPTY SLOT
function GetEmptySlotAmount()
	local empty = 9;
	for i=0, 8 do
		if(Bot:GetItemInSlot(i) ~= nil) then
			empty = empty - 1;
		end
	end
	return empty;
end
--GET ITEM TOTAL CHARGE
function GetItemCharges(_item)
	local charges = 0;
	for i = 0, 15 
	do
		local item = Bot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == _item then
			charges = charges + item:GetCurrentCharges();
		end
	end
	return charges;
end
--CHECK IF INVENTORY FULL
function IsNonStashInvFull()
	for i = 6, 8 do
		local item = Bot:GetItemInSlot(i);
		if item ~= nil then
			return false;
		end
	end
	return true; 
end
--SELLING EARLY GAME ITEM
function SellEarlyGameItem()
	if DotaTime() < 20*60 or not IsNonStashInvFull() then
		return
	end	
	
	if Bot:DistanceFromFountain() < 100 or Bot:DistanceFromSecretShop() < 200 then
		for _,eItem in pairs(earlyGameItem)
		do
			local slot = Bot:FindItemSlot(eItem);
			if slot >= 0 and slot <= 9 then
				if eItem == "item_stout_shield" then
					if not IsExistInAllTable("item_vanguard") and 
					   not IsExistInAllTable("item_crimson_guard") and
					   not IsExistInAllTable("item_abyssal_blade") 
					then
						Bot:ActionImmediate_SellItem(Bot:GetItemInSlot(slot));
						return
					end
				elseif eItem == "item_quelling_blade" then	
					if not IsExistInAllTable("item_bfury") then
						Bot:ActionImmediate_SellItem(Bot:GetItemInSlot(slot));
						return
					end
				elseif eItem == "item_soul_ring" then	
					if not IsExistInAllTable("item_bloodstone") then
						Bot:ActionImmediate_SellItem(Bot:GetItemInSlot(slot));
						return
					end
				else
					Bot:ActionImmediate_SellItem(Bot:GetItemInSlot(slot));
					return
				end	
			end
		end
	end
	
end
--FILLING STARTING ITEM TABLE
function FillStartingItem()
	if #Bot.StartingItem == 0 and ( Bot.tableItemsToBuy == nil or #(Bot.tableItemsToBuy) == 0 ) then
		if Bot:GetAssignedLane() == LANE_MID then 
			InsertItemToTable(0, 'item_flask');
		else
			InsertItemToTable(0, 'item_tango');
			InsertItemToTable(0, 'item_flask');
		end
		if role.CanBeSupport(BotName) then
			InsertItemToTable(0, 'item_clarity');
		end
		if role.IsMelee(AttackRange) then
			if string.find(BotName, "tidehunter") then 
			  InsertItemToTable(0, 'item_stout_shield');
			end  
			InsertItemToTable(0, 'item_quelling_blade');
			BuyStartingStatItem();
		end
	end
end
--FILLING EARLY ITEM TABLE
function FillEarlyItem()
	if #Bot.EarlyItem == 0 and ( Bot.tableItemsToBuy == nil or #(Bot.tableItemsToBuy) == 0 ) then
		BuyBottle();
		InsertItemToTable(1, 'item_magic_wand');
		BuyEarlyBoots();
	end	
end
--FILLING CORE ITEM TABLE
function FillCoreItem()
	if #Bot.CoreItem == 0 and ( Bot.tableItemsToBuy == nil or #(Bot.tableItemsToBuy) == 0 ) then
		BuyCoreItem();
	end	
end

function BuyStartingStatItem()
	if PrimaryAttr == ATTRIBUTE_STRENGTH then
		InsertItemToTable(1, 'item_bracer')
	elseif PrimaryAttr == ATTRIBUTE_AGILITY then
		InsertItemToTable(1, 'item_wraith_band')
	else
		InsertItemToTable(1, 'item_null_talisman')
	end	
end

function BuyBottle()
	if Bot:GetAssignedLane() == LANE_MID then
		InsertItemToTable(1, 'item_bottle');
	end
end

function BuyEarlyBoots()
	local rollStat = RollPercentage(50);
	if role.CanBeSupport(BotName) then
		if rollStat then
			InsertItemToTable(1, 'item_arcane_boots');
		else
			InsertItemToTable(1, 'item_tranquil_boots');
		end
	elseif role.CanBeMidlaner(BotName) or role.CanBeSafeLaneCarry(BotName) or role.CanBeOfflaner(BotName) then
		if role.IsCarry(BotName) and role.IsMelee(AttackRange) then
			if role.BetterBuyPhaseBoots(BotName) and rollStat then
				InsertItemToTable(1, 'item_phase_boots')
			else
				ChooseTheRightPT();
			end
		elseif role.IsCarry(BotName) and not role.IsMelee(AttackRange) then
			ChooseTheRightPT();
		elseif role.IsInitiator(BotName) then
			if rollStat then
				InsertItemToTable(1, 'item_arcane_boots');
			else
				InsertItemToTable(1, 'item_tranquil_boots');
			end
		end
	end
end

function ChooseTheRightPT()
	if PrimaryAttr == ATTRIBUTE_STRENGTH then
		InsertItemToTable(1, 'item_power_treads_str')
	elseif PrimaryAttr == ATTRIBUTE_AGILITY then
		InsertItemToTable(1, 'item_power_treads_agi')
	else
		InsertItemToTable(1, 'item_power_treads_int')
	end	
end

function BuyCoreItem()
	if role.CanBeSafeLaneCarry(BotName) and PrimaryAttr == ATTRIBUTE_AGILITY then
		InsertItemToTable(2, 'item_ring_of_aquila')
	elseif role.CanBeSafeLaneCarry(BotName) and PrimaryAttr == ATTRIBUTE_STRENGTH	then
		InsertItemToTable(2, 'item_drums_of_endurance')
	elseif role.CanBeSafeLaneCarry(BotName) and PrimaryAttr == ATTRIBUTE_INTELLECT	then
		InsertItemToTable(2, 'item_force_staff')	
	elseif role.CanBeSupport(BotName) and 
		   PrimaryAttr == ATTRIBUTE_INTELLECT and 
		   HaveSpecificItem('item_tranquil_boots') and
		   not TeamHaveSpecificItem('item_urn_of_shadows') 
	then
		InsertItemToTable(2, 'item_urn_of_shadows')	
	elseif role.CanBeSupport(BotName) and
		   PrimaryAttr == ATTRIBUTE_INTELLECT and 
		   HaveSpecificItem('item_arcane_boots') and
		   not TeamHaveSpecificItem('item_mekansm') 
	then
		InsertItemToTable(2, 'item_mekansm')	
	end
end

function HaveSpecificItem(item_name)
	local Slot = Bot:FindItemSlot(item_name);
	return Slot ~= -1;
end

function TeamHaveSpecificItem(item_name)
	local TeamMember = GetTeamPlayers(GetTeam())
	for i = 1, #TeamMember 
	do
		local Player = GetTeamMember(i)
		if Player ~= nil and IsPlayerBot(Player:GetPlayerID()) and Player:GetUnitName() ~= BotName then
			for _,item in pairs(Player.CoreItem)
			do
				if item == item_name then
					return true;
				end
			end
		end
	end
	return false;
end

function InsertItemToTable(no_table, item_name)
	InsertToPurchaseTable(item_name);
	if no_table == 0 then
		table.insert(Bot.StartingItem, item_name);
	elseif no_table == 1 then
		table.insert(Bot.EarlyItem, item_name);
	elseif no_table == 2 then
		table.insert(Bot.CoreItem, item_name);
	else
		table.insert(Bot.SituationalItem, item_name);
	end
   
end

function InsertToPurchaseTable(item_name)
	local tempList = { item_name }
	local tempTable = GetBasicItems(tempList)
	for _,item in pairs(tempTable)
	do	
		table.insert(Bot.tableItemsToBuy, item);
	end
end


function GetBasicItems( ... )
    local basicItemTable = {}
    for i,v in pairs(...) do
		print(v)
        if items[v] ~= nil and not IsExistInAllTable(v) then
            for _,w in pairs(GetBasicItems(items[v])) do
                table.insert(basicItemTable, w)
            end
        elseif items[v] == nil then
            table.insert(basicItemTable, v)
        end
    end
    return basicItemTable
end

function IsExistInAllTable(v)
	for _,si in pairs(Bot.StartingItem)
	do
		if si == v then
			return true
		end	
	end
	for _,ei in pairs(Bot.EarlyItem)
	do
		if ei == v then
			return true
		end	
	end
	for _,ci in pairs(Bot.CoreItem)
	do
		if ci == v then
			return true
		end	
	end
	for _,sti in pairs(Bot.SituationalItem)
	do
		if sti == v then
			return true
		end	
	end
	return false;
end

--COURIER PURCHASING LOGIC
function PurchaseCourier()
	if GetNumCouriers() == 0 then
	if(Bot:DistanceFromFountain() == 0 ) then
		if ( Bot:ActionImmediate_PurchaseItem("item_courier") == PURCHASE_ITEM_SUCCESS ) then
			Bot:ActionImmediate_Chat("I'm Buying Courier Guys.", true);
			activateCourier( );
		end
	end 
	end
end
function activateCourier( )
    local courierSlot = Bot:FindItemSlot("item_courier");
	if courierSlot >= 0 and courierSlot <= 5 then
		Bot:Action_UseAbility( Bot:GetItemInSlot(courierSlot) );
	end
end
function UpgradeCourier()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcCourier = GetCourier(0);
	if not IsFlyingCourier(npcCourier) and GetItemStockCount( "item_flying_courier" ) > 0 and Bot:GetGold() >= GetItemCost( "item_flying_courier" ) then
		Bot:ActionImmediate_Chat("I'm Upgrading Courier Guys.", true);
		Bot:ActionImmediate_PurchaseItem("item_flying_courier");
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function GeneralItemPurchasing()

	local sNextItem = Bot.tableItemsToBuy[1];
	Bot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );
	if ( Bot:GetGold() >= GetItemCost( sNextItem ) ) then

		if ( IsItemPurchasedFromSecretShop( sNextItem ) and IsItemPurchasedFromSideShop( sNextItem ) ) then
			if ( Bot:DistanceFromSecretShop() == 0 or Bot:DistanceFromSideShop() == 0 ) then
				if ( Bot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
					table.remove( Bot.tableItemsToBuy, 1 );
					Bot.secretShopMode = false;
					Bot.sideShopMode = false;
				end
			elseif ( Bot:DistanceFromSecretShop() <= Bot:DistanceFromSideShop() ) then
				if ( not Bot.secretShopMode and IsSuitablePurchaseActiveMode() ) then
					Bot.secretShopMode = true;
					Bot.sideShopMode = false;
				end
			elseif ( Bot:DistanceFromSecretShop() > Bot:DistanceFromSideShop() ) then
				if ( not Bot.sideShopMode and IsSuitablePurchaseActiveMode() ) then
					Bot.secretShopMode = false;
					Bot.sideShopMode = true;
				end
			end
		elseif ( IsItemPurchasedFromSecretShop( sNextItem ) and not IsItemPurchasedFromSideShop( sNextItem ) ) then
			if ( Bot:DistanceFromSecretShop() == 0 ) then
				if ( Bot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
					table.remove( Bot.tableItemsToBuy, 1 );
					Bot.secretShopMode = false;
					Bot.sideShopMode = false;
				end
			else
				if ( not Bot.secretShopMode and IsSuitablePurchaseActiveMode() ) then
					Bot.secretShopMode = true;
					Bot.sideShopMode = false;
				end
			end
		elseif ( not IsItemPurchasedFromSecretShop( sNextItem ) and IsItemPurchasedFromSideShop( sNextItem ) ) then
			if ( Bot:DistanceFromSideShop() == 0 ) then
				if ( Bot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
					table.remove( Bot.tableItemsToBuy, 1 );
					Bot.secretShopMode = false;
					Bot.sideShopMode = false;
				end
			elseif ( Bot:DistanceFromSideShop() < 2500 ) then
				if ( not Bot.sideShopMode and IsSuitablePurchaseActiveMode() ) then
					Bot.secretShopMode = false;
					Bot.sideShopMode = true;
				end
			else
				if ( Bot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
					table.remove( Bot.tableItemsToBuy, 1 );
					Bot.secretShopMode = false;
					Bot.sideShopMode = false;
				end
			end
		else
			if ( Bot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
				table.remove( Bot.tableItemsToBuy, 1 );
				Bot.secretShopMode = false;
				Bot.sideShopMode = false;
			end
		end
	else
		Bot.secretShopMode = false;
		Bot.sideShopMode = false;
	end

end

function IsSuitablePurchaseActiveMode()
	local emptySlot = GetEmptySlotAmount();
	if ( emptySlot < 2
		or Bot:GetActiveMode() == BOT_MODE_RETREAT
		or Bot:GetActiveMode() == BOT_MODE_ATTACK
		or Bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
		or Bot:GetActiveMode() == BOT_MODE_ROSHAN
		or Bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
		or Bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
		or Bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT 
		or Bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or Bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or Bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		return false;
	end
	return true;
end