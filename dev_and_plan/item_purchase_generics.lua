if string.find(GetBot():GetUnitName(), "monkey") then 
	if ( DotaTime() < 0 and GetBot():GetLocation() ~= Vector(0.000000, 0.000000, 0.000000) ) 
	  or ( DotaTime() >= 0 and GetBot():IsInvulnerable() )
	then 
		return; 
	end
end

local purchase ="NOT IMPLEMENTED";

if string.find(GetBot():GetUnitName(), "hero") and not GetBot():IsIllusion() and not GetBot():IsMinion() then
    purchase = require(GetScriptDirectory() .. "/builds/item_build_" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""))
end

if purchase == "NOT IMPLEMENTED" then 
	return 
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
local items = require(GetScriptDirectory() .. "/ItemUtility" )
npcBot = GetBot()

--npcBot.tableItemsToBuy = purchase["items"];
npcBot.tableItemsToBuy  = {};
local temp = {};

local supportExist = nil;
local invisEnemyExist = false;
local enemyInvisCheck = false;
local buyBOT = false;
local buyBOT2 = false;
local buyMS = false;
local buyRD = false;
local buyHeal = false;
local buyBottle = false;

local earlyBoots = {  
	"item_phase_boots", 
	"item_power_treads", 
	"item_tranquil_boots", 
	"item_arcane_boots"  
}

 local earlyGameItem = {
	 "item_tango_single",
	 "item_clarity",
	 "item_faerie_fire",
	 "item_tango",  
	 "item_flask", 
	 "item_infused_raindrop",
	 "item_quelling_blade", 
	 "item_stout_shield", 
	 "item_iron_talon",
	 "item_poor_mans_shield",
	 "item_magic_wand",
	 "item_bottle",  
	 "item_ring_of_aquila", 
	 "item_dust",
	 "item_ward_observer",
	 "item_tpscroll"
}

function ItemPurchaseThink()
		
	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS 
		or npcBot:IsIllusion() 
		or ( npcBot:GetUnitName() == "npc_dota_hero_monkey_king" and npcBot:IsInvulnerable() )
		or npcBot:HasModifier("modifier_arc_warden_tempest_double")
		or IsMeepoClone()
	then
		return;
	end
	
	if supportExist == nil then supportExist = IsSupportExist(); end
	
	if not invisEnemyExist then invisEnemyExist = IsInvisEnemyExist(); end

	PurchaseTP();
	
	--if DotaTime() < 0 and npcBot:DistanceFromFountain() == 0 and role.CanBeMidlaner(npcBot:GetUnitName()) and npcBot:GetAssignedLane() == LANE_MID then
	if  GetGameMode() ~= GAMEMODE_1V1MID and DotaTime() < 0 and npcBot:DistanceFromFountain() == 0 and npcBot.theRole == "midlaner" then
		local salve = npcBot:FindItemSlot("item_flask");
		if salve >= 0 then
			npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(salve));
			table.insert(npcBot.tableItemsToBuy, 1, "item_faerie_fire")
		end	
		local tango = npcBot:FindItemSlot("item_tango");
		if tango >= 0 then
			npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(tango));
			table.insert(npcBot.tableItemsToBuy, 1, "item_faerie_fire")
		end	
	end
	
	--Buy bottle for mid heroes
	if GetGameMode() ~= GAMEMODE_1V1MID and DotaTime() > 0 and DotaTime() < 15 then
		if role["bottle"][npcBot:GetUnitName()] == 1 and npcBot:GetAssignedLane() == LANE_MID and not buyBottle 
		then
			table.insert(npcBot.tableItemsToBuy, 1, "item_bottle");
		end
		buyBottle = true;
	end
	
	if  supportExist ~= nil and supportExist 
		--role.CanBeSupport(npcBot:GetUnitName()) and npcBot:GetAssignedLane() ~= LANE_MID  
		and npcBot.theRole == "support"  
	then
		PurchaseSmoke();
		if invisEnemyExist then
			PurchaseDust();	
		end
		if GetCourier(0) == nil then
			PurchaseCourier();
		end
		PurchaseWard();
	elseif supportExist ~= nil and not supportExist then
		PurchaseCourier();
	end	
	
	PurchaseRainDrop();
	SellEarlyGameItem();
	
	if #(npcBot.tableItemsToBuy) == 0 then
		PurchaseBOT();
		PurchaseMoonShard();
		PurchaseBOT2();
	end
	
	--UseMoonShard();
	
	sellBoots();
	
	if npcBot:GetActiveMode() ~= BOT_MODE_WARD then
		SwapBoots();
	end
	
	if ( npcBot.tableItemsToBuy == nil or #(npcBot.tableItemsToBuy) == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end
	
	GeneralPurchase()
	
end	

function IsSupportExist()
	--if role.CanBeSupport(npcBot:GetUnitName()) then
	if npcBot.theRole == "support" then
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
		--if ally ~= nil and ally:IsHero() and role.CanBeSupport(ally:GetUnitName()) 
		if ally ~= nil and ally:IsHero() and ally.theRole == "support" 
		then
			return true;
		end
	end
	return false;
end

function IsMeepoClone()
	if npcBot:GetUnitName() == "npc_dota_hero_meepo" and npcBot:GetLevel() > 1 
	then
		for i=0, 5 do
			local item = npcBot:GetItemInSlot(i);
			if item ~= nil and not ( string.find(item:GetName(),"boots") or string.find(item:GetName(),"treads") )  
			then
				return false;
			end
		end
		return true;
    end
	return false;
end

local testMode = true;

function GeneralPurchase()
	
	if GetGameMode() == GAMEMODE_1V1MID and ( testMode or npcBot:GetAssignedLane() ~= LANE_MID ) then
		return;
	end

	local sNextItem = npcBot.tableItemsToBuy[1];
	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );
	local CanPurchaseFromSecret = IsItemPurchasedFromSecretShop(sNextItem);
	local CanPurchaseFromSide   = IsItemPurchasedFromSideShop(sNextItem);
	local itemCost = GetItemCost( sNextItem );
	local t3AlreadyDamaged = false;
	
	for i=2, 8, 3 do
		local tower = GetTower(GetTeam(), i);
		if tower == nil or tower:GetHealth()/tower:GetMaxHealth() < 0.5 then
			t3AlreadyDamaged = true;
			break;
		end
	end
	
	if npcBot:GetBuybackCooldown() <= 10 and t3AlreadyDamaged then
		itemCost = itemCost + npcBot:GetBuybackCost() + ( 100 + npcBot:GetNetWorth()/40 );
		--print(npcBot:GetUnitName().." : "..sNextItem.." cost "..itemCost);
	end
	if ( npcBot:GetGold() >= itemCost ) then
		
		local courier = GetCourier(0);
		if npcBot.SecretShop and courier ~= nil and GetCourierState(courier) == COURIER_STATE_IDLE and courier:DistanceFromSecretShop() == 0 then
			if courier:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS then
				table.remove( npcBot.tableItemsToBuy, 1 );
				courier.latestUser = npcBot;
				npcBot.SecretShop = false;
			    npcBot.SideShop = false;
				return
			end
		end
		
		if CanPurchaseFromSecret and not CanPurchaseFromSide and npcBot:DistanceFromSecretShop() > 0 
		then
			--print("secret 1"..npcBot:GetUnitName()..tostring(npcBot:DistanceFromSecretShop()))
			npcBot.SecretShop = true;
		elseif CanPurchaseFromSecret and CanPurchaseFromSide and npcBot:DistanceFromSideShop() < npcBot:DistanceFromSecretShop() 
		       and npcBot:DistanceFromSideShop() > 0 and npcBot:DistanceFromSideShop() <= 2500 
		then
			--print("side 1"..npcBot:GetUnitName()..tostring(npcBot:DistanceFromSideShop()))
			npcBot.SideShop = true;
		elseif CanPurchaseFromSecret and CanPurchaseFromSide and npcBot:DistanceFromSideShop() > npcBot:DistanceFromSecretShop() and npcBot:DistanceFromSecretShop() > 0 
		then
			--print("secret 2"..npcBot:GetUnitName()..tostring(npcBot:DistanceFromSecretShop()))
			npcBot.SecretShop = true;
		elseif CanPurchaseFromSecret and CanPurchaseFromSide and npcBot:DistanceFromSideShop() > 2500 and npcBot:DistanceFromSecretShop() > 0 
		then
			npcBot.SecretShop = true;
		elseif CanPurchaseFromSide and not CanPurchaseFromSecret and npcBot:DistanceFromSideShop() > 0 and npcBot:DistanceFromSideShop() <= 2500 
		then
			--print("side 2"..npcBot:GetUnitName()..tostring(npcBot:DistanceFromSideShop()))
			npcBot.SideShop = true;
		else
			if npcBot:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS then
				table.remove( npcBot.tableItemsToBuy, 1 );
				npcBot.SecretShop = false;
				npcBot.SideShop = false;	
				return
			else
				print("[Generic]"..npcBot:GetUnitName().." failed to purchase "..sNextItem.." : "..tostring(npcBot:ActionImmediate_PurchaseItem( sNextItem )))	
			end
		end
	else
		npcBot.SecretShop = false;
		npcBot.SideShop = false;
	end
end

function AlreadyAddedInTable(item)
	for _,value in pairs(npcBot.tableItemsToBuy) do
		if value == item then
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
	
	if itemSlot == -1 and not buyBOT then
		itemSlot = npcBot:FindItemSlot("item_boots")
	end
	
	if itemSlot >= 0 and npcBot:GetItemSlotType(itemSlot) == ITEM_SLOT_TYPE_BACKPACK and not HasItem(npcBot, "item_travel_boots") and not HasItem(npcBot, "item_travel_boots_2")
	then
		local lessValItem = getLessValuableItemSlot();
		if lessValItem ~= -1 and GetItemCost(npcBot:GetItemInSlot(lessValItem):GetName()) <  GetItemCost(npcBot:GetItemInSlot(itemSlot):GetName()) 
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

	if ( npcBot:DistanceFromFountain() == 0 or npcBot:DistanceFromSecretShop() == 0 ) and DotaTime() > 25*60 and GetEmptySlotAmount() < 3 then
		for _,item in pairs(earlyGameItem)
		do
			local itemSlot = npcBot:FindItemSlot(item);
			if itemSlot >= 0 then
				if item == "item_dust" or item == "item_ward_observer" then
					if GetEmptySlotAmount() <= 1 then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						break;
					end	
				elseif item == "item_stout_shield"  then
					if not HasCGorABBuild() then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						break;
					end
				elseif item == "item_tpscroll" then
					if HasItem(npcBot, "item_travel_boots") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						break;
					end
				elseif item == "item_soul_ring" then
					if not HasSomeBuild("item_recipe_bloodstone") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						break;
					end	
				elseif item == "item_quelling_blade" then
					if not string.find(npcBot:GetUnitName(), "antimage") then
						npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
						break;
					end		
				else
					npcBot:ActionImmediate_SellItem(npcBot:GetItemInSlot(itemSlot));
					break;
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

function PurchaseSmoke()
	if ( DotaTime() < 0 ) 
	then
		if( npcBot:GetGold() >= GetItemCost( "item_smoke_of_deceit" ) and
			GetItemStockCount( "item_smoke_of_deceit" ) > 1 and
			GetEmptySlotAmount() >= 4 
		) 
		then
			npcBot:ActionImmediate_PurchaseItem("item_smoke_of_deceit"); 
		end
	end
end

function IsInvisEnemyExist()

	if not enemyInvisCheck then
	    local invEnemyExs = false;
		local globalEnemies = GetTeamPlayers(GetOpposingTeam())
		for _,id in pairs(globalEnemies) do
			if role["invisHeroes"][GetSelectedHeroName(id)] == 1 
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
			if enemy ~= nil and not enemy:IsNull() and enemy:CanBeSeen() then
				local SASlot = enemy:FindItemSlot("item_shadow_amulet");
				local GCSlot = enemy:FindItemSlot("item_glimmer_cape");
				local ISSlot = enemy:FindItemSlot("item_invis_sword");
				local SESlot = enemy:FindItemSlot("item_silver_edge");
				if  SASlot >= 0 or 
				    GCSlot >= 0 or 
					ISSlot >= 0 or 
					SESlot >= 0 
				then
					return true;
				end	
			end
		end
	end
	
	return false;
end

function PurchaseRainDrop()
	if( not buyRD and HasItem(npcBot, 'item_boots') and GetItemStockCount( "item_infused_raindrop" ) > 0 and 
		npcBot:GetGold() >= GetItemCost( "item_infused_raindrop" ) 
	) 
	then
		npcBot:ActionImmediate_PurchaseItem("item_infused_raindrop"); 
		buyRD = true;
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
	local MSSlot = npcBot:FindItemSlot("item_moon_shard");
	if MSSlot >= 0 and MSSlot <= 5 then
		local MS = npcBot:GetItemInSlot(MSSlot);
		if MS:IsFullyCastable() then
			npcBot:Action_UseAbilityOnEntity( MS, npcBot );
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

function IsStashFull()
	for i=9, 14 do
		if(npcBot:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
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


---------------------------------------------------------------------INITIATE ITEM PURCHASE---------------------------------------------------------------
function IsExistInAllTable(v)
	for _,si in pairs(temp)
	do
		if si == v then
			return true
		end	
	end
end

function GetBasicItems( ... )
    local basicItemTable = {}
    for i,v in pairs(...) do
        if items[v] ~= nil and not IsExistInAllTable(v) then
            for _,w in pairs(GetBasicItems(items[v])) do
                table.insert(basicItemTable, w)
            end
        elseif items[v] == nil and not IsExistInAllTable(v) then
            table.insert(basicItemTable, v)
        end
    end
    return basicItemTable
end

function InsertToPurchaseTable(item_name)
	local tempList = { item_name }
	local tempTable = GetBasicItems(tempList)
	for _,item in pairs(tempTable)
	do	
		table.insert(npcBot.tableItemsToBuy , item);
	end
end

--print(npcBot:GetUnitName()..":"..tostring(npcBot:GetAssignedLane()))
if DotaTime() < 0 then
	table.insert(npcBot.tableItemsToBuy , "item_tango");
	table.insert(npcBot.tableItemsToBuy , "item_flask");
	if role.IsSupport(npcBot:GetUnitName()) then
		table.insert(npcBot.tableItemsToBuy , "item_clarity");
	end
	if  role.IsMelee(npcBot:GetAttackRange()) then
		if role.IsCarry(npcBot:GetUnitName()) then
			table.insert(npcBot.tableItemsToBuy , "item_stout_shield");
			table.insert(temp , "item_stout_shield");
			table.insert(npcBot.tableItemsToBuy , "item_quelling_blade");
			table.insert(temp , "item_quelling_blade");
		else
			table.insert(npcBot.tableItemsToBuy , "item_stout_shield");
			table.insert(temp , "item_stout_shield");
		end
	end
end
for _,it in pairs(purchase["items"])
do	
	if it ~= "item_poor_mans_shield" then
		InsertToPurchaseTable(it)
		table.insert(temp, it)
	end
end
	
--[[for _,i in pairs(npcBot.tableItemsToBuy )
do
	print(i)
end]]--

temp = {}
--print(#temp)

-------------------------------------------------------------------------------------------------------------------------------------------------

--[[this chunk prevents dota_bot_reload_scripts from breaking your 
	item/skill builds.  Note the script doesn't account for 
	consumables. ]]
-- check item build vs current items
local currentItems = {}

for i=0, 15 do
    if(npcBot:GetItemInSlot(i) ~= nil) then
        local _item = npcBot:GetItemInSlot(i):GetName()
        if items[_item] == nil then
            table.insert(currentItems, _item)
        else
            for _,v in pairs(GetBasicItems(items[_item])) do
                table.insert(currentItems, v)
            end
        end
    end
end

--utils.print_r(currentItems)
for i = 0, #currentItems do
    if(currentItems[i] ~= nil) then
        for j = 0, #npcBot.tableItemsToBuy do
            if npcBot.tableItemsToBuy[j] == currentItems[i] then
                --print("Removing Item " .. currentItems[i] .. " index " .. j)
                table.remove(npcBot.tableItemsToBuy, j)
                break
            end
        end
    end
end

currentItems = {}