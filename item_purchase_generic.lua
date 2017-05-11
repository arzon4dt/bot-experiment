--BotsInit = require( "game/botsinit" );
--local MyModule = BotsInit.CreateGeneric();
if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return;
end

local purchase ="NOT IMPLEMENTED";

if string.find(GetBot():GetUnitName(), "hero") then
    purchase = require(GetScriptDirectory() .. "/builds/item_build_" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""))
end

if purchase == "NOT IMPLEMENTED" then 
	return 
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
npcBot = GetBot()

npcBot.tableItemsToBuy = purchase["items"];
local hero_roles = role["hero_roles"];
local supportExist = nil;
local invisEnemyExist = false;
local enemyInvisCheck = false;
local buyBOT = false;
local buyBOT2 = false;
local buyMS = false;
local buyRD = false;

local earlyBoots = { 
	"item_phase_boots", 
	"item_power_treads", 
	"item_tranquil_boots", 
	"item_arcane_boots"  
}
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
	['npc_dota_hero_broodmother'] = 1,
	['npc_dota_hero_weaver'] = 1
} 

 local earlyGameItem = {
		 "item_clarity", 
		 "item_tango", 
		 "item_flask", 
		 "item_infused_raindrop",
		 "item_quelling_blade", 
		 "item_stout_shield", 
		 "item_poor_mans_shield",
		 "item_magic_wand",
		 "item_bottle",  
	 	 "item_ring_of_aquila", 
		 "item_urn_of_shadows",
		 "item_tpscroll"
		 --"item_soul_ring", 
		 --"item_ward_observer",
	}

function ItemPurchaseThink()
		
	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	
	if npcBot:IsIllusion() or npcBot:IsInvulnerable() then
		return;
	end
	
	if( npcBot:GetUnitName() == "npc_dota_hero_meepo") then
        if(npcBot:GetLevel() > 1) then
            for i=0, 5 do
                if(npcBot:GetItemInSlot(i) ~= nil ) then
                    if not ( npcBot:GetItemInSlot(i):GetName() == "item_travel_boots" or 
							 npcBot:GetItemInSlot(i):GetName() == "item_travel_boots_2" or 
							 npcBot:GetItemInSlot(i):GetName() == "item_boots" or 
							 npcBot:GetItemInSlot(i):GetName() == "item_power_treads"
							) 
					then
                        break
                    end
                end
                if i == 5 then
                    return
                end
            end
        end
    end
	
	if supportExist == nil then supportExist = IsSupportExist(); end
	
	if not invisEnemyExist then invisEnemyExist = IsInvisEnemyExist(); end

	PurchaseTP();
	
	if  supportExist ~= nil and supportExist and 
		role.CanBeSupport(npcBot:GetUnitName()) 
	then
		if invisEnemyExist then
			PurchaseDust();	
		end
		if GetCourier(0) == nil then
			PurchaseCourier();
		end
		UpgradeCourier();
		PurchaseWard();
	elseif supportExist ~= nil and not supportExist then
		PurchaseCourier();
		UpgradeCourier();
	end	
	
	PurchaseRainDrop();
	SellEarlyGameItem();
	
	if #(npcBot.tableItemsToBuy) == 0 then
		PurchaseBOT();
		PurchaseMoonShard();
		PurchaseBOT2();
	end
	
	UseMoonShard();
	
	sellBoots();
	
	if npcBot:GetActiveMode() ~= BOT_MODE_WARD then
		SwapBoots();
	end
	
	if ( npcBot.tableItemsToBuy == nil or #(npcBot.tableItemsToBuy) == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end
	
	MyItemPurchase();
	
end	

function IsSupportExist()

	if role.CanBeSupport(npcBot:GetUnitName()) then
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

function MyItemPurchase()
	local sNextItem = npcBot.tableItemsToBuy[1];
	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );
	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) ) then
		if not CanDoSecretOrSideShop(sNextItem)   
		then
			if ( npcBot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS ) then
				table.remove( npcBot.tableItemsToBuy, 1 );
			end
		end
	end
end

function CanDoSecretOrSideShop(sNextItem)
	local CanPurchaseFromSecret =  IsItemPurchasedFromSecretShop(sNextItem);
	local CanPurchaseFromSide = IsItemPurchasedFromSideShop(sNextItem);
	if  npcBot:DistanceFromSideShop() < 2000 
	then
		if CanPurchaseFromSecret and CanPurchaseFromSide then
			return true;
		elseif not CanPurchaseFromSecret and CanPurchaseFromSide then
			return true;
		end
	else
		if CanPurchaseFromSecret then
			return true;
		end
	end
	return false;
end


function SwapBoots()
	
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
			return
		end
	end
	
end

function getLessValuableItemSlot()
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
	if ( npcBot:DistanceFromFountain() < 100 or npcBot:DistanceFromSecretShop() < 100 ) and DotaTime() > 30*60 and GetEmptySlotAmount() < 4 then
		for _,item in pairs(earlyGameItem)
		do
			local itemSlot = npcBot:FindItemSlot(item);
			if itemSlot >= 0 then
				if item ~= "item_stout_shield" and item ~= "item_tpscroll" and item ~= "item_soul_ring" and item ~= "item_quelling_blade" then
					npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
					return;
				elseif item == "item_stout_shield"  then
					if not HasCGorABBuild() then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						return;
					end
				elseif item == "item_tpscroll" then
					if HasItem(npcBot, "item_travel_boots") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						return;
					end
				elseif item == "item_soul_ring" then
					if not HasSomeBuild("item_recipe_bloodstone") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						return;
					end	
				elseif item == "item_quelling_blade" then
					if not string.find(npcBot:GetUnitName(), "antimage") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						return;
					end		
				end
			end
		end		
	end
end

function HasCGorABBuild()
	local npcCourier = GetCourier(0);
	
	if HasItem(npcBot, "item_recipe_abyssal_blade") or 
	   HasItem(npcBot, "item_recipe_crimson_guard") or 
	   HasItem(npcCourier, "item_recipe_abyssal_blade") or
	   HasItem(npcCourier, "item_recipe_crimson_guard")
	then
		return true
	end	
	
	for _,item in pairs(npcBot.tableItemsToBuy)
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
	local npcCourier = GetCourier(0);
	
	if HasItem(npcBot, build_name) or 
	   HasItem(npcCourier, build_name)
	then
		return true
	end	
	for _,item in pairs(npcBot.tableItemsToBuy)
	do
		if item == build_name then
			return true
		end
	end
	return false
end

function PurchaseCourier()
	if( GetItemStockCount( "item_courier" ) > 0 and DotaTime() < 0.0  ) then
		if(npcBot:DistanceFromFountain() <= 600 ) then
			if ( npcBot:ActionImmediate_PurchaseItem("item_courier") == PURCHASE_ITEM_SUCCESS ) then
				npcBot:ActionImmediate_Chat("I'm Buying Courier Guys.", true);
				activateCourier( );
			end
		end
	end
end

function PurchaseWard()

	local minute = math.floor(DotaTime() / 60);
	if( GetItemStockCount( "item_ward_observer" ) > 0 and 
		npcBot:GetGold() >= GetItemCost( "item_ward_observer" ) and
		GetEmptySlotAmount() >= 2 and
		GetItemCharges("item_ward_observer") < 2  and
		npcBot:GetCourierValue() == 0
		) 
	then
		npcBot:ActionImmediate_PurchaseItem("item_ward_observer"); 
	end
end

function GetItemCharges(_item)
	local charges = 0;
	for i = 0, 15 
	do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == _item then
			charges = charges + item:GetCurrentCharges();
		end
	end
	return charges;
end


function PurchaseDust()
	if ( DotaTime() > 2*60 ) 
	then
		if( npcBot:GetGold() >= GetItemCost( "item_dust" ) and
			GetEmptySlotAmount() >= 4 and
			GetItemCharges("item_dust") < 1 and 
			npcBot:GetCourierValue() == 0
		) 
		then
			npcBot:ActionImmediate_PurchaseItem("item_dust"); 
		end
	end
end

function IsInvisEnemyExist()

	if not enemyInvisCheck then
	    local invEnemyExs = false;
		local globalEnemies = GetTeamPlayers(GetOpposingTeam())
		for _,id in pairs(globalEnemies) do
			if invisHeroes[GetSelectedHeroName(id)] == 1 
			then
				invEnemyExs = true;
				break;
			end
		end
		enemyInvisCheck = true;
		return invEnemyExs;
	end
	
	if DotaTime() > 15*60 then
		local globalEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		for _,enemy in pairs(globalEnemies)
		do
			if enemy ~= nil and not enemy:IsNull() then
				local SASlot = enemy:FindItemSlot("item_shadow_amulet");
				local GCSlot = enemy:FindItemSlot("item_glimmer_cape");
				local ISSlot = enemy:FindItemSlot("item_invis_sword");
				local SESlot = enemy:FindItemSlot("item_silver_edge");
				if SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0 then
					return true;
				end	
			end
		end
	end
	
	return false;
end

function PurchaseRainDrop()
	if( not buyRD and GetItemStockCount( "item_infused_raindrop" ) > 0 and 
		npcBot:GetGold() >= GetItemCost( "item_infused_raindrop" ) 
	) 
	then
		npcBot:ActionImmediate_PurchaseItem("item_infused_raindrop"); 
		buyRD = true;
	end
end

function UpgradeCourier()
	if GetNumCouriers() == 0 then
		return 
	end
	local npcCourier = GetCourier(0);
	if( GetItemStockCount( "item_flying_courier" ) > 0 and not IsFlyingCourier(npcCourier) and npcBot:GetGold() >= GetItemCost( "item_flying_courier" )  ) then
		npcBot:ActionImmediate_Chat("I'm Upgrading Courier Guys.", true);
		npcBot:ActionImmediate_PurchaseItem("item_flying_courier");
	end
end

function activateCourier( )
    local courierSlot = npcBot:FindItemSlot("item_courier");
	if courierSlot >= 0 then
		npcBot:Action_UseAbility( npcBot:GetItemInSlot(courierSlot) );
	end
end

function PurchaseTP()
	if( DotaTime() > 60 and
		npcBot:GetGold() >= GetItemCost( "item_tpscroll" ) and 
		GetEmptySlotAmount() > 3 and 
	    npcBot:GetCourierValue() == 0 and
		not HasItem(npcBot, "item_tpscroll") and 
		not HasItem( npcBot, "item_travel_boots") and
		not HasItem( npcBot, "item_travel_boots_2") 
	) 
	then
		npcBot:ActionImmediate_PurchaseItem("item_tpscroll");
	end
end

function HasItem( hUnit, sItem )
	if hUnit:FindItemSlot( sItem ) >= 0 then
		return true
	end
	return false
end

function PurchaseMoonShard()
	if  buyBOT and not buyMS
	then
		table.insert(npcBot.tableItemsToBuy, "item_hyperstone");
		table.insert(npcBot.tableItemsToBuy, "item_hyperstone");
		buyMS = true;
	end
end

function UseMoonShard()
	if HasItem( npcBot, "item_moon_shard" ) then
		local MSSlot = npcBot:FindItemSlot("item_moon_shard");
		if MSSlot >= 0 then
			npcBot:ActionQueue_UseAbilityOnEntity( npcBot:GetItemInSlot(MSSlot), npcBot );
		end
	end
end

function PurchaseBOT()
	if not buyBOT
	then
	    if HasItem( npcBot, "item_travel_boots" ) then
			buyBOT = true;
		else	
			table.insert(npcBot.tableItemsToBuy, "item_boots");
			table.insert(npcBot.tableItemsToBuy, "item_recipe_travel_boots");
			buyBOT = true;
		end
	end
end

function PurchaseBOT2()
	if buyBOT and buyMS and not buyBOT2 
	then
		table.insert(npcBot.tableItemsToBuy, "item_recipe_travel_boots");
		buyBOT2 = true;
	end
end

function sellBoots()
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
	local empty = 9;
	for i=0, 8 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			empty = empty - 1;
		end
	end
	return empty;
end

function IsInvFull()
	for i=0, 8 do
		if(npcBot:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
end

function HasItemInBP()
	for i=6, 8 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			return true;
		end
	end
	return false;
end


--[[this chunk prevents dota_bot_reload_scripts from breaking your 
	item/skill builds.  Note the script doesn't account for 
	consumables. ]]

local npcBot = GetBot();

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
		for j = 0, #(npcBot.tableItemsToBuy) do
			if npcBot.tableItemsToBuy[j] == currentItems[i] then
				--print("Removing Item " .. currentItems[i] .. " index " .. j)
				table.remove(npcBot.tableItemsToBuy, j)
				break
			end
		end
	end
end

--return MyModule;	