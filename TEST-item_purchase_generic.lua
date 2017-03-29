
local utils = require(GetScriptDirectory() .. "/util")
local purchase ="NOT IMPLEMENTED"
if string.find(GetBot():GetUnitName(), "hero") then
    purchase = require(GetScriptDirectory() .. "/builds/item_build_" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""))
end

if purchase == "NOT IMPLEMENTED" then 
	return 
end
----------------------------------------------------------------------------------------------------

--[[ Set up your item build.  Remember to use base items.  
To build an derived item like item_magic_wand you will just 
buy the four base items so take care to get items in your 
inventory in the correct order! ]]

local tableItemsToBuy = purchase["items"]
local earlyBoots = { 
		"item_phase_boots", 
		"item_power_treads", 
		"item_tranquil_boots", 
		"item_arcane_boots"  
	}
----------------------------------------------------------------------------------------------------
 
-- Think function to purchase the items and call the skill point think
function ItemPurchaseThink()
	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	
    local npcBot = GetBot();
	
	if not string.find(npcBot:GetUnitName(), "hero") then
		return;
	end
	
    -- check if real meepo
    if( GetBot():GetUnitName() == "npc_dota_hero_meepo") then
        if(npcBot:GetLevel() > 1) then
            for i=0, 5 do
                if(npcBot:GetItemInSlot(i) ~= nil ) then
                    if not (npcBot:GetItemInSlot(i):GetName() == "item_boots" or npcBot:GetItemInSlot(i):GetName() == "item_power_treads") then
                        break
                    end
                end
                if i == 5 then
                    return
                end
            end
        end
    end
	
	PurchaseTP();
	PurchaseCourier();
	UpgradeCourier();
	PurchaseWard();
	PurchaseDust();
	PurchaseRainDrop();
	SwapItemForWarding();
	PutWardOnBackPack();
	SellEarlyGameItem();
	PurchaseBOT();
	sellBoots();
	PurchaseBOT2();
	PurchaseMoonShard();
	UseMoonShard();
	if npcBot:GetActiveMode() ~= BOT_MODE_WARD then
		SwapBoots();
	end
	

	local currentItems = {}
	for i=0, 8 do
		currentItems[i] = npcBot:GetItemInSlot(i)
	end

	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local sNextItem = tableItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );
	
	if  npcBot.secretShopMode and npcBot:GetGold() < GetItemCost( sNextItem ) then
		print("Whu U dead or BB?")
		npcBot.secretShopMode = false;
	end

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		
		--print(sNextItem);
        if ( not npcBot.secretShopMode and IsItemPurchasedFromSecretShop( sNextItem ) and npcBot:DistanceFromSecretShop() >= 0 ) then
            -- this item is from secret shop
            
            --print("secretshopmode:"..tostring(npcBot.secretShopMode))
				npcBot.secretShopMode = true;
        end
        if npcBot.secretShopMode and  npcBot:DistanceFromSecretShop() > 00  then
			--print(npcBot:GetUnitName().." : "..sNextItem)
            return
        end
		if npcBot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS then
            npcBot.secretShopMode = false;
    		--if(IsCourierAvailable()) then
    			--print("useCourier" .. tableItemsToBuy[1]
    			--npcBot:Action_Courier( npcBot, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS )
    		--end
    		table.remove( tableItemsToBuy, 1 );
		elseif npcBot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_INSUFFICIENT_GOLD then
			npcBot.secretShopMode = false;
        end
	end
	
end


function SwapBoots()
	local npcBot = GetBot();
	
	local itemSlot = -1;
	for _,item in pairs(earlyBoots)
	do
		itemSlot = npcBot:FindItemSlot(item);
		if itemSlot >= 0
		then
			break
		end
	end	
	
	if itemSlot >= 0 and npcBot:GetItemSlotType(itemSlot) == ITEM_SLOT_TYPE_BACKPACK and not HasItem(npcBot, "item_travel_boots") and not HasItem(npcBot, "item_travel_boots_2")
	then
		local lessValItem = getLessValuableItemSlot();
		if lessValItem ~= -1
		then
			npcBot:ActionImmediate_SwapItems( itemSlot, lessValItem );
		end
	end
	
end

function SwapItemForWarding() 
	local npcBot = GetBot();
	if npcBot:GetActiveMode() == BOT_MODE_WARD and npcBot:GetItemSlotType( npcBot:FindItemSlot( "item_ward_observer" ) ) == ITEM_SLOT_TYPE_BACKPACK then
		local wdSlot =  npcBot:FindItemSlot( "item_ward_observer" );
		local lviSlot = getLessValuableItemSlot();
		if wdSlot ~= -1 then
			npcBot:ActionImmediate_SwapItems( wdSlot, lviSlot );
		end
	end
end

function PutWardOnBackPack()
	local npcBot = GetBot();
	local wardSlot = npcBot:FindItemSlot( "item_ward_observer" );
	
	if wardSlot >= 0 then
		if npcBot:GetActiveMode() ~= BOT_MODE_WARD and 
		   npcBot:GetItemSlotType(wardSlot) == ITEM_SLOT_TYPE_MAIN  and 
		   IsInvFull() and 
		   HasItemInBP() then
			local wdSlot =  wardSlot --npcBot:FindItemSlot( "item_ward_observer" );
			local mviSlot = getMostValuableBPSlot();
			if mviSlot ~= -1 then
				npcBot:ActionImmediate_SwapItems( wdSlot, mviSlot );
			end
		end
	end
end

function getLessValuableItemSlot()
	local npcBot = GetBot();
	local minPrice = 10000;
	local minIdx = -1;
		for i=0, 5 do
			if  npcBot:GetItemInSlot(i) ~= nil and npcBot:GetItemInSlot(i):GetName() ~= "item_aegis"  then
				local _item = npcBot:GetItemInSlot(i):GetName()
				if( GetItemCost(_item) < minPrice ) then
					minPrice = GetItemCost(_item)
					minIdx = i;
				end
			end
		end
		
		return minIdx;
end

function IsBoots(item)
	for _,boot in pairs (earlyBoots)
	do
		if boot == item then
			return true
		end	
	end
	return false
end

function getMostValuableBPSlot()
	local npcBot = GetBot();
	local maxPrice = 0;
	local maxIdx = -1;
		for i=6, 8 do
			if(npcBot:GetItemInSlot(i) ~= nil) then
				local _item = npcBot:GetItemInSlot(i):GetName()
				if( GetItemCost(_item) > maxPrice ) then
					maxPrice = GetItemCost(_item)
					maxIdx = i;
				end
			end
		end
		
	return maxIdx;
end

function SellEarlyGameItem()
    local earlyGameItem = {
		 "item_magic_wand",
	 	 "item_ring_of_aquila", 
		 "item_urn_of_shadows", 
		 "item_clarity", 
		 "item_flask", 
		 "item_quelling_blade", 
		 "item_stout_shield", 
		 "item_poor_mans_shield",
		 "item_tango", 
		 --"item_soul_ring", 
		 "item_bottle", 
		 --"item_ward_observer",
		 "item_tpscroll",
		 "item_infused_raindrop",
		 "item_dust"
	}
	local npcBot = GetBot();
	if ( npcBot:DistanceFromFountain() < 100 or npcBot:DistanceFromSecretShop() < 100 ) and DotaTime() > 30*60 then
		for _,item in pairs(earlyGameItem)
		do
			local itemSlot = npcBot:FindItemSlot(item);
			if itemSlot >= 0 and GetEmptySlotAmount() <= 4 then
				--[[if npcBot:GetUnitName() == "npc_dota_hero_life_stealer" and item == "item_stout_shield"  then
				
				print(itemSlot)
				print(item)
				if HasCGorABBuild() then
					print("dont sell ss")
				else 
					print("sell ss")
				end
				if HasItem(npcBot, "item_travel_boots") then
					print("have BoT")
				else
					print("no BoT")
				end
				end]]--
				if item ~= "item_stout_shield" and item ~= "item_tpscroll" then
					npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
				elseif item == "item_stout_shield"  then
					if not HasCGorABBuild() then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
					end
				elseif item == "item_tpscroll" then
					if HasItem(npcBot, "item_travel_boots") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
					end
				elseif item == "item_soul_ring" then
					if not HasSomeBuild("item_recipe_bloodstone") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
					end	
				end
			end
		end		
	end
end

function HasCGorABBuild()
	local npcBot = GetBot();
	local npcCourier = GetCourier(0);
	
	if HasItem(npcBot, "item_recipe_abyssal_blade") or 
	   HasItem(npcBot, "item_recipe_crimson_guard") or 
	   HasItem(npcCourier, "item_recipe_abyssal_blade") or
	   HasItem(npcCourier, "item_recipe_crimson_guard")
	then
		return true
	end	
	
	for _,item in pairs(tableItemsToBuy)
	do
		if item == "item_recipe_abyssal_blade" then
			return true
		elseif item == "item_recipe_crimson_guard" then
			return true
		end
	end
	
	return false
	
end

function HasSomeBuild(build_name)
	local npcBot = GetBot();
	local npcCourier = GetCourier(0);
	
	if HasItem(npcBot, build_name) or 
	   HasItem(npcCourier, build_name)
	then
		return true
	end	
	for _,item in pairs(tableItemsToBuy)
	do
		if item == build_name then
			return true
		end
	end
	return false
end

function PurchaseCourier()
	local npcBot = GetBot();
	if( GetItemStockCount( "item_courier" ) > 0 and DotaTime() < 0.0  ) then
		if(npcBot:DistanceFromFountain() <= 600 ) then
			if ( npcBot:ActionImmediate_PurchaseItem("item_courier") == PURCHASE_ITEM_SUCCESS ) then
				activateCourier( );
			end
		end
	end
end

function PurchaseWard()
	local npcBot = GetBot();
	local minute = math.floor(DotaTime() / 60);
	local sec = DotaTime() % 60;
	if ( ( minute % 5 == 0 and sec > 30 ) or DotaTime() < 0) then
		if( GetItemStockCount( "item_ward_observer" ) > 0 and 
			npcBot:GetGold() >= GetItemCost( "item_ward_observer" ) and
		--npcBot:DistanceFromFountain() <= 100 and 
			GetEmptySlotAmount() >= 3 and
			not HasItem(npcBot, "item_courier") and 
			not HasItem(npcBot, "item_ward_observer") ) 
		then
			print("Purchase Ward");
			npcBot:ActionImmediate_PurchaseItem("item_ward_observer"); 
		end
	end	
end

function PurchaseDust()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcBot = GetBot();
	local npcCourier = GetCourier(0);
	if ( DotaTime() > 2*60 ) 
	then
		if( GetItemStockCount( "item_dust" ) > 0 and 
			npcBot:GetGold() >= GetItemCost( "item_dust" ) and
			GetEmptySlotAmount() >= 4 and
			not HasItem(npcBot, "item_dust") and 
			not HasItem(npcCourier, "item_dust") 
		) 
		then
			npcBot:ActionImmediate_PurchaseItem("item_dust"); 
		end
	end	
end

function PurchaseRainDrop()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcBot = GetBot();
	local npcCourier = GetCourier(0);
	if ( DotaTime() > 3*60 and DotaTime() < 10*60 ) 
	then
		if( GetItemStockCount( "item_infused_raindrop" ) > 0 and 
			npcBot:GetGold() >= GetItemCost( "item_infused_raindrop" ) and
			GetEmptySlotAmount() >= 4 and
			not HasItem(npcBot, "item_infused_raindrop") and 
			not HasItem(npcCourier, "item_infused_raindrop") 
		) 
		then
			npcBot:ActionImmediate_PurchaseItem("item_infused_raindrop"); 
		end
	end	
end

function UpgradeCourier()
	local npcBot = GetBot();
	if( GetItemStockCount( "item_flying_courier" ) > 0 and DotaTime() >= 3*60 and DotaTime() <= 4*60  ) then
		if ( npcBot:GetGold() >= GetItemCost( "item_flying_courier" ) ) then
			npcBot:ActionImmediate_PurchaseItem("item_flying_courier");
		end
	end
end

function activateCourier( )
	local npcBot = GetBot();
    local courierSlot = npcBot:FindItemSlot("item_courier");
	if courierSlot >= 0 then
		npcBot:Action_UseAbility( npcBot:GetItemInSlot(courierSlot) );
	end
end

function PurchaseTP()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcCourier = GetCourier(0);
	local npcBot = GetBot();
	if( GetEmptySlotAmount() > 3 and 
		not HasItem(npcBot, "item_tpscroll") and 
		not HasItem(npcCourier, "item_tpscroll") and 
		not HasItem(npcCourier, "item_travel_boots") and 
		not HasItem( npcBot, "item_travel_boots") and
		not HasItem(npcCourier, "item_travel_boots_2") and 
		not HasItem( npcBot, "item_travel_boots_2") and
		npcBot:GetGold() >= GetItemCost( "item_tpscroll" ) and 
		DotaTime() > 60 ) 
	then
		--if(npcBot:DistanceFromFountain() <= 50 or npcBot:DistanceFromSideShop() <= 00 ) then
		--print(npcBot:GetUnitName()..'buy tp')
				npcBot:ActionImmediate_PurchaseItem("item_tpscroll");
		--end
	end
end

function HasItem( hUnit, sItem )
	if hUnit:FindItemSlot( sItem ) >= 0 then
		return true
	end
	return false
end

function PurchaseMoonShard()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcBot = GetBot();
	--[[if npcBot:GetUnitName() == "npc_dota_hero_monkey_king" then
		local nModifier = npcBot:NumModifiers( )
		for i=0, nModifier do
			local modName = npcBot:GetModifierName( i )
			print(modName)
		end
	end]]--
	local npcCourier = GetCourier(0);
	if #tableItemsToBuy == 0 and 
		npcBot:GetGold() >= GetItemCost( "item_hyperstone" ) and
		not npcBot:HasModifier("modifier_item_moon_shard_consumed") and
		not HasItem( npcBot, "item_moon_shard" ) and
		not HasItem( npcBot, "item_recipe_assault" ) and
		not HasItem( npcCourier, "item_recipe_assault" ) and
		GetEmptySlotAmount() >= 1 and
		HasItem( npcBot, "item_travel_boots")
	then
		table.insert(tableItemsToBuy, "item_hyperstone");
	end
end

function UseMoonShard()
	local npcBot = GetBot();
	if HasItem( npcBot, "item_moon_shard" ) then
		local MSSlot = npcBot:FindItemSlot("item_moon_shard");
		if MSSlot >= 0 then
			npcBot:ActionQueue_UseAbilityOnEntity( npcBot:GetItemInSlot(MSSlot), npcBot );
		end
	end
end

function PurchaseBOT()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcCourier = GetCourier(0);
	local npcBot = GetBot();
	if #tableItemsToBuy == 0 and 
		npcBot:GetGold() >= GetItemCost( "item_recipe_travel_boots" ) + GetItemCost( "item_boots" ) and
		not HasItem( npcBot, "item_travel_boots") and
		not HasItem( npcCourier, "item_travel_boots") and
		not HasItem( npcBot, "item_travel_boots_2") and
		not HasItem( npcCourier, "item_travel_boots_2") 
	then
		npcBot:ActionImmediate_PurchaseItem("item_recipe_travel_boots");
		npcBot:ActionImmediate_PurchaseItem("item_boots");
	end
end

function PurchaseBOT2()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcBot = GetBot();
	local npcCourier = GetCourier(0);
	if npcBot:GetGold() >= GetItemCost( "item_recipe_travel_boots" ) and 
	   HasItem(npcBot, "item_travel_boots") and 
	   npcBot:HasModifier("modifier_item_moon_shard_consumed") and 
	   not HasItem(npcBot, "item_travel_boots_2") and
	   not HasItem(npcBot, "item_recipe_travel_boots") and
	   not HasItem(npcCourier, "item_recipe_travel_boots")
	then
		npcBot:ActionImmediate_PurchaseItem("item_recipe_travel_boots");
		return;
	end
end

function sellBoots()
	local npcBot = GetBot();
	if ( HasItem( npcBot, "item_travel_boots") or HasItem( npcBot, "item_travel_boots_2")) and
		( npcBot:DistanceFromFountain() < 100 or npcBot:DistanceFromSecretShop() < 100 )
	then	
		for _,boots in pairs(earlyBoots)
		do
			local bootsSlot = npcBot:FindItemSlot(boots);
			if bootsSlot >= 0 then
				npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(bootsSlot));
			end
		end
	end
end

function GetEmptySlotAmount()
	local npcBot = GetBot();
	local empty = 9;
	for i=0, 8 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			empty = empty - 1;
		end
	end
	return empty;
end

function IsInvFull()
	local npcHero = GetBot();
	for i=0, 8 do
		if(npcHero:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
end

function HasItemInBP()
	local npcHero = GetBot();
	for i=6, 8 do
		if(npcHero:GetItemInSlot(i) ~= nil) then
			return true;
		end
	end
	return false;
end

----------------------------------------------------------------------------------------------------

--[[this chunk prevents dota_bot_reload_scripts from breaking your 
	item/skill builds.  Note the script doesn't account for 
	consumables. ]]

local npcBot = GetBot();

-- check skill build vs current level
--[[local ability_name = BotAbilityPriority[1];
local ability = GetBot():GetAbilityByName(ability_name);
--print(ability:GetLevel())
if(ability ~= nil and ability:GetLevel() > 0) then
    --print (#BotAbilityPriority .. " > " .. "25 - " .. npcBot:GetHeroLevel())
    if #BotAbilityPriority > (25 - npcBot:GetLevel()) then
        --print(#BotAbilityPriority - (25 - npcBot:GetHeroLevel()))
        for i=1, (#BotAbilityPriority - (25 - npcBot:GetLevel())) do
            table.remove(BotAbilityPriority, 1)
        end
    end
end]]--

-- check item build vs current items
local currentItems = {}
for i=0, 15 do
    if(npcBot:GetItemInSlot(i) ~= nil) then
        local _item = npcBot:GetItemInSlot(i):GetName()
        if(_item == "item_magic_wand")then
            table.insert(currentItems, "item_magic_stick")
            table.insert(currentItems, "item_branches")
            table.insert(currentItems, "item_branches")
            table.insert(currentItems, "item_circlet")
        elseif(_item == "item_arcane_boots")then
            table.insert(currentItems, "item_energy_booster")
            table.insert(currentItems, "item_boots")
        elseif(_item == "item_null_talisman")then
            table.insert(currentItems, "item_circlet")
            table.insert(currentItems, "item_mantle")
            table.insert(currentItems, "item_recipe_null_talisman")
        elseif(_item == "item_iron_talon")then
            table.insert(currentItems, "item_quelling_blade")
            table.insert(currentItems, "item_ring_of_protection")
            table.insert(currentItems, "item_recipe_iron_talon")
        elseif(_item == "item_poor_mans_shield")then
            table.insert(currentItems, "item_slippers")
            table.insert(currentItems, "item_slippers")
            table.insert(currentItems, "item_stout_shield")
        elseif(_item == "item_ultimate_scepter")then
            table.insert(currentItems, "item_point_booster")
            table.insert(currentItems, "item_staff_of_wizardry")
            table.insert(currentItems, "item_ogre_axe")
            table.insert(currentItems, "item_blade_of_alacrity")
        elseif(_item == "item_power_treads")then
            table.insert(currentItems, "item_boots")
            table.insert(currentItems, "item_gloves")
            table.insert(currentItems, "item_belt_of_strength")
        elseif(_item == "item_force_staff")then
            table.insert(currentItems, "item_ring_of_regen")
            table.insert(currentItems, "item_staff_of_wizardry")
            table.insert(currentItems, "item_recipe_force_staff")
        elseif(_item == "item_dragon_lance")then
            table.insert(currentItems, "item_ogre_axe")
            table.insert(currentItems, "item_boots_of_elves")
            table.insert(currentItems, "item_boots_of_elves")
        elseif(_item == "item_hurricane_pike")then
            table.insert(currentItems, "item_ring_of_regen")
            table.insert(currentItems, "item_staff_of_wizardry")
            table.insert(currentItems, "item_recipe_force_staff")
            table.insert(currentItems, "item_ogre_axe")
            table.insert(currentItems, "item_boots_of_elves")
            table.insert(currentItems, "item_boots_of_elves")
            table.insert(currentItems, "item_recipe_hurricane_pike")
        elseif(_item == "item_sange")then
            table.insert(currentItems, "item_ogre_axe")
            table.insert(currentItems, "item_belt_of_strength")
            table.insert(currentItems, "item_recipe_sange")
        elseif(_item == "item_yasha")then
            table.insert(currentItems, "item_blade_of_alacrity")
            table.insert(currentItems, "item_boots_of_elves")
            table.insert(currentItems, "item_recipe_yasha")
        elseif(_item == "item_sange_and_yasha")then
            table.insert(currentItems, "item_ogre_axe")
            table.insert(currentItems, "item_belt_of_strength")
            table.insert(currentItems, "item_recipe_sange")
            table.insert(currentItems, "item_blade_of_alacrity")
            table.insert(currentItems, "item_boots_of_elves")
            table.insert(currentItems, "item_recipe_yasha")
        elseif(_item == "item_hood_of_defiance")then
            table.insert(currentItems, "item_ring_of_health")
            table.insert(currentItems, "item_cloak")
            table.insert(currentItems, "item_ring_of_regen")
        elseif(_item == "item_phase_boots")then
            table.insert(currentItems, "item_boots")
            table.insert(currentItems, "item_blades_of_attack")
            table.insert(currentItems, "item_blades_of_attack")
        elseif(_item == "item_vanguard")then
            table.insert(currentItems, "item_stout_shield")
            table.insert(currentItems, "item_ring_of_health")
            table.insert(currentItems, "item_vitality_booster")
        else
            table.insert(currentItems, npcBot:GetItemInSlot(i):GetName())
        end
    end
end

--utils.print_r(currentItems)
for i = 0, #currentItems do
	if(currentItems[i] ~= nil) then
		for j = 0, #tableItemsToBuy do
			if tableItemsToBuy[j] == currentItems[i] then
				--print("Removing Item " .. currentItems[i] .. " index " .. j)
				table.remove(tableItemsToBuy, j)
				break
			end
		end
	end
end
--utils.print_r(tableItemsToBuy)