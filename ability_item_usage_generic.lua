if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local BotsInit = require( "game/botsinit" );
local MyModule = BotsInit.CreateGeneric();

local build = "NOT IMPLEMENTED";

--if not GetBot():IsNull() and not GetBot():IsIllusion() and string.find(GetBot():GetUnitName(), "hero") then	
if string.find(GetBot():GetUnitName(), "hero") and build == "NOT IMPLEMENTED" then
	build = require(GetScriptDirectory() .. "/builds/item_build_" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""))
end

if build == "NOT IMPLEMENTED" then 
	return 
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
local mutil = require(GetScriptDirectory() ..  "/MyUtility")
local utils = require(GetScriptDirectory() ..  "/util")

local BotAbilityPriority = build["skills"];
local IdleTime = 0;
local AllowedIddle = 15;
local npcBot = GetBot();
local TimeDeath = nil;

function AbilityLevelUpThink()  
	
	if npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() then
		return;
	end
	
	--if DotaTime() > 0 then
		UnImplementedItemUsage()
		UseShrine()
		UseGlyph()
	--end
	
	local botLoc = npcBot:GetLocation();
	if npcBot:IsAlive() and not IsLocationPassable(botLoc) then
		if npcBot.stuckLoc == nil then
			npcBot.stuckLoc = botLoc
			npcBot.stuckTime = DotaTime();
		elseif npcBot.stuckLoc ~= botLoc then
			npcBot.stuckLoc = botLoc
			npcBot.stuckTime = DotaTime();
		end
	else	
		npcBot.stuckTime = nil;
		npcBot.stuckLoc = nil;
	end
	
	if npcBot:GetAbilityPoints() < 1 or #BotAbilityPriority == 0 or  (GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS) then
		return;
	end
	
	if BotAbilityPriority[1] ~= "-1" 
	then
		local sNextAbility = npcBot:GetAbilityByName(BotAbilityPriority[1])
		if ( sNextAbility ~= nil and sNextAbility:CanAbilityBeUpgraded() and sNextAbility:GetLevel() < sNextAbility:GetMaxLevel() ) 
		then
			if string.find(npcBot:GetUnitName(), "troll_warlord") and BotAbilityPriority[1] == "troll_warlord_whirling_axes_ranged" 
			then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("troll_warlord_whirling_axes_melee");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end
			elseif string.find(npcBot:GetUnitName(), "keeper_of_the_light") and BotAbilityPriority[1] == "keeper_of_the_light_illuminate" then
				if sNextAbility:IsHidden() then 
					local ability = npcBot:GetAbilityByName("keeper_of_the_light_spirit_form_illuminate");
					if not ability:IsHidden() then
						npcBot:ActionImmediate_LevelAbility("keeper_of_the_light_spirit_form_illuminate");
					else
						return;
					end	
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end			
			elseif sNextAbility:IsHidden() then
				return;	
			else
				npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
			end
			table.remove( BotAbilityPriority, 1 )
		end	
	else
		table.remove( BotAbilityPriority, 1 )
	end	
	
end

function CanBuybackUpperRespawnTime( respawnTime )
	return npcBot:GetRespawnTime() > respawnTime;
end

function IsThereHeroNearby(building)
	local heroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local nearbynum = 0;
	for _,hero in pairs(heroes)
	do
		if GetUnitToUnitDistance(building, hero) <= 2750 then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum >= 2;
end

function CanBB()
	return not npcBot:IsAlive() and npcBot:GetBuybackCooldown() == 0 and npcBot:GetGold() >= npcBot:GetBuybackCost();
end

function GetRemainingRespawnTime()
	if TimeDeath == nil then
		return 0;
	else
		return npcBot:GetRespawnTime() - ( DotaTime() - TimeDeath );
	end
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

function BuybackUsageThink() 
	
	if npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() or IsMeepoClone() then
		return;
	end
	
	if npcBot:IsAlive() and TimeDeath ~= nil then
		TimeDeath = nil;
	end
	
	if not CanBB() then
		return;
	end

	if not npcBot:IsAlive() then
		if TimeDeath == nil then
			TimeDeath = DotaTime();
		end
		--print(npcBot:GetUnitName()..":"..tostring(npcBot:GetRespawnTime()).."><"..tostring(RespawnTime))
	end
	
	local RespawnTime = GetRemainingRespawnTime();
	
	if RespawnTime < 10 then
		return;
	end
	
	local team = GetTeam();
	
	local ancient = GetAncient(team );

	if ( ancient ~= nil and IsThereHeroNearby(ancient) ) 
	then
		npcBot:ActionImmediate_Buyback();
		return;
	end

end

--[[function ItemUsageThink()
	--print(npcBot:GetUnitName().."item usage")
	if GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	
	UnImplementedItemUsage()
	--UseShrine()
end]]--

local courierTime = -90;
local cState = -1;
function CourierUsageThink()

	if npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() or GetNumCouriers() == 0 then
		return;
	end
	
	local npcCourier = GetCourier(0);	
	local cState = GetCourierState( npcCourier );

	if cState == COURIER_STATE_DEAD then
		return
	end
	
	if IsCourierNearShop(npcCourier) and IdleTime == 0 then
		IdleTime = DotaTime();
	elseif not IsCourierNearShop(npcCourier) then
		IdleTime = 0;
	end
	
	if  not npcBot:IsAlive() and cState == COURIER_STATE_DELIVERING_ITEMS  
		and npcBot:GetCourierValue( ) > 0 and DotaTime() > courierTime + 2.0
	then
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS );
		courierTime = DotaTime();
		return
	end
	
	
	if  cState == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() > 00 and 
	( not IsCourierNearShop(npcCourier) or ( IsCourierNearShop(npcCourier) and DotaTime() >= IdleTime + AllowedIddle ))
	then
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
		return
	end
	
	if DotaTime() >= IdleTime + AllowedIddle and npcBot:IsAlive() and npcBot:GetCourierValue( ) > 0 
	   and not IsInvFull(npcBot) and IsCourierAvailable() and DotaTime() > courierTime + 2.0
	then
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
		courierTime = DotaTime();
		return
	end
	
	if DotaTime() >= IdleTime + AllowedIddle and IsCourierAvailable() and DotaTime() > courierTime + 2.0 then
		local numPlayer =  GetTeamPlayers(GetTeam());
		local maxVal = 0;
		local target = nil;
		for i = 1, #numPlayer
		do
			local member =  GetTeamMember(i);
			if member ~= nil and IsPlayerBot(numPlayer[i]) and member:IsAlive() 
			then
				local SVal = member:GetStashValue();
				if SVal ~= 0 and SVal > maxVal then
					maxVal = SVal;
					target = member;
				end
			end
		end
		
		if target ~= nil 
		then
			target:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS )
			courierTime = DotaTime();
			return
		end
		
	end
	
end

function IsCourierNearShop(npcCourier)

local Shops = {
	SHOP_SIDE,
	SHOP_SIDE2,
	SHOP_SECRET,
	SHOP_SECRET2
}

for _,shop in pairs(Shops)
do
	local dist = GetUnitToLocationDistance(npcCourier, GetShopLocation(GetTeam(), shop));
	if dist < 600 then
		--print("Near Shop")
		return true;
	end	
end

return false;
end

function IsInvFull(npcHero)
	for i=0, 8 do
		if(npcHero:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
end

function CourierCanDeliverItems(npcCourier)
	if GetCourierState( npcCourier ) ~= COURIER_STATE_DELIVERING_ITEMS or GetCourierState( npcCourier ) ~= COURIER_ACTION_RETURN_STASH_ITEMS then
		return true;
	end
	return false;
end


function CanCastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOnMagicImmuneTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsSilenced() or npcTarget:IsNightmared() then
		return true;
	end
	return false;
end

function UseConsumables()

	

end

function GiveToMidLaner()
	local teamPlayers = GetTeamPlayers(GetTeam())
	local target = nil;
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and member:IsAlive() then
			local num_stg = GetItemCount(member, "item_tango_single"); 
			local num_ff = GetItemCount(member, "item_faerie_fire"); 
			if num_ff > 0 and num_stg < 1 then
				return member;
			end
		end
	end
	return nil;
end

function GetItemCount(unit, item_name)
	local count = 0;
	for i = 0, 8 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
end

local giveTime = -90;
function UnImplementedItemUsage()

	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() or npcBot:IsMuted( )  then
		return;
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	local npcTarget = npcBot:GetTarget();
	local mode = npcBot:GetActiveMode();
	
	local itg=IsItemAvailable("item_tango");
	if itg~=nil and itg:IsFullyCastable() then
		local tCharge = itg:GetCurrentCharges()
		if DotaTime() > -80 and DotaTime() < 0 and npcBot:DistanceFromFountain() == 0 and role.CanBeSupport(npcBot:GetUnitName())
		   and npcBot:GetAssignedLane() ~= LANE_MID and tCharge > 2 and DotaTime() > giveTime + 2.0 then
			local target = GiveToMidLaner()
			if target ~= nil then
				npcBot:ActionImmediate_Chat(string.gsub(npcBot:GetUnitName(),"npc_dota_hero_","")..
						" giving tango to "..
						string.gsub(target:GetUnitName(),"npc_dota_hero_","")
						, false);
				npcBot:Action_UseAbilityOnEntity(itg, target);
				giveTime = DotaTime();
				return;
			end
		elseif npcBot:GetActiveMode() == BOT_MODE_LANING and role.CanBeSupport(npcBot:GetUnitName()) and tCharge > 1 and DotaTime() > giveTime + 2.0 then
			local allies = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			for _,ally in pairs(allies)
			do
				local tangoSlot = ally:FindItemSlot('item_tango');
				if ally:GetUnitName() ~= npcBot:GetUnitName() and not ally:IsIllusion() 
				   and tangoSlot == -1 and GetItemCount(ally, "item_tango_single") == 0 
				then
					npcBot:Action_UseAbilityOnEntity(itg, ally);
					giveTime = DotaTime();
					return
				end
			end
		end
	end
	
	local bdg=IsItemAvailable("item_blink");
	if bdg~=nil and bdg:IsFullyCastable() then
		if mutil.IsStuck(npcBot)
		then
			npcBot:ActionImmediate_Chat("I'm using blink while stuck.", true);
			npcBot:Action_UseAbilityOnLocation(bdg, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), 1100 ));
			return;
		end
	end
	
	local fst=IsItemAvailable("item_force_staff");
	if fst~=nil and fst:IsFullyCastable() then
		if mutil.IsStuck(npcBot)
		then
			npcBot:ActionImmediate_Chat("I'm using force staff while stuck.", true);
			npcBot:Action_UseAbilityOnEntity(fst, npcBot);
			return;
		end
	end
	
	local tpt=IsItemAvailable("item_tpscroll");
	if tpt~=nil and tpt:IsFullyCastable() then
		if mutil.IsStuck(npcBot)
		then
			npcBot:ActionImmediate_Chat("I'm using tp while stuck.", true);
			npcBot:Action_UseAbilityOnLocation(tpt, GetAncient(GetTeam()):GetLocation());
			return;
		end
	end
	
	local msh=IsItemAvailable("item_moon_shard");
	if msh~=nil and msh:IsFullyCastable() then
		if not npcBot:HasModifier("modifier_item_moon_shard_consumed")
		then
			print("use Moon")
			npcBot:Action_UseAbilityOnEntity(msh, npcBot);
			return;
		end
	end
	
	local arm=IsItemAvailable("item_armlet");
	if arm~=nil and arm:IsFullyCastable() then
		if #tableNearbyEnemyHeroes == 0 and arm:GetToggleState( ) then
			npcBot:Action_UseAbility(arm);
			return;
		end
	end
	
	local mg=IsItemAvailable("item_enchanted_mango");
	if mg~=nil and mg:IsFullyCastable() then
		if  npcBot:GetMaxMana() - npcBot:GetMana() > 150 
		then
			npcBot:Action_UseAbility(mg);
			return;
		end
	end
	
	local tok=IsItemAvailable("item_tome_of_knowledge");
	if tok~=nil and tok:IsFullyCastable() then
		npcBot:Action_UseAbility(tok);
		return;
	end
	
	local ff=IsItemAvailable("item_faerie_fire");
	if ff~=nil and ff:IsFullyCastable() then
		if  mode == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			npcBot:DistanceFromFountain() > 0 and
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.15 
		then
			npcBot:Action_UseAbility(ff);
			return;
		end
	end
	
	local bst=IsItemAvailable("item_bloodstone");
	if bst ~= nil and bst:IsFullyCastable() then
		if  mode == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.10
		then
			npcBot:Action_UseAbilityOnLocation(bst, npcBot:GetLocation());
			return;
		end
	end
	
	local pb=IsItemAvailable("item_phase_boots");
	if pb~=nil and pb:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_ATTACK or
			 mode == BOT_MODE_RETREAT or
			 mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK or
			 mode == BOT_MODE_DEFEND_ALLY )
		then
			npcBot:Action_UseAbility(pb);
			return;
		end	
	end
	
	local bt=IsItemAvailable("item_bloodthorn");
	if bt~=nil and bt:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_ATTACK or
			 mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK or
			 mode == BOT_MODE_DEFEND_ALLY )
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOnTarget(npcTarget) and GetUnitToUnitDistance(npcTarget, npcBot) < 900 )
			then
			    npcBot:Action_UseAbilityOnEntity(bt,npcTarget);
				return
			end
		end
	end
	
	local sc=IsItemAvailable("item_solar_crest");
	if sc~=nil and sc:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_ATTACK or
			 mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK or
			 mode == BOT_MODE_DEFEND_ALLY )
		then
			if ( npcTarget ~= nil and npcTarget:IsHero() and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < 900 )
			then
			    npcBot:Action_UseAbilityOnEntity(sc,npcTarget);
				return
			end
		end
	end
	
	if sc~=nil and sc:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and CanCastOnTarget(Ally) ) or 
			   ( IsDisabled(Ally) and CanCastOnTarget(Ally) )
			then
				npcBot:Action_UseAbilityOnEntity(sc,Ally);
				return;
			end
		end
	end
	
	local se=IsItemAvailable("item_silver_edge");
    if se ~= nil and se:IsFullyCastable() then
		if mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0
		then
			npcBot:Action_UseAbility(se);
			return;
	    end
		if ( mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK )
		then
			if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) > 1000 and  GetUnitToUnitDistance(npcTarget, npcBot) < 2500 )
			then
			    npcBot:Action_UseAbility(se);
				return;
			end
		end
	end
	
	local hood=IsItemAvailable("item_hood_of_defiance");
    if hood~=nil and hood:IsFullyCastable() and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.8 
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
			npcBot:Action_UseAbility(hood);
			return;
		end
	end
	
	local lotus=IsItemAvailable("item_lotus_orb");
	if lotus~=nil and lotus:IsFullyCastable() 
	then
		if  ( npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.45 and tableNearbyEnemyHeroes ~=nil and #tableNearbyEnemyHeroes > 0 ) or
			 npcBot:IsSilenced() or
		    ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.75 )
	    then
			npcBot:Action_UseAbilityOnEntity(lotus,npcBot);
			return;
		end
	end
	
	if lotus~=nil and lotus:IsFullyCastable() 
	then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 )  or 
				 IsDisabled(Ally)
			then
				npcBot:Action_UseAbilityOnEntity(lotus,Ally);
				return;
			end
		end
	end
	
	local hurricanpike = IsItemAvailable("item_hurricane_pike");
	if hurricanpike~=nil and hurricanpike:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < 400 and CanCastOnTarget(npcEnemy) )
				then
					npcBot:Action_UseAbilityOnEntity(hurricanpike,npcEnemy);
					return
				end
			end
			if npcBot:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),10) and npcBot:DistanceFromFountain() > 0 
			then
				npcBot:Action_UseAbilityOnEntity(hurricanpike,npcBot);
				return;
			end
		end
	end
	
	local glimer=IsItemAvailable("item_glimmer_cape");
	if glimer~=nil and glimer:IsFullyCastable() then
		if ( npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.45 and ( tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes>0) ) or 
		   ( tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes >= 3 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65 )  	
		then	
			npcBot:Action_UseAbilityOnEntity(glimer,npcBot);
			return;
		end
	end
	
	local hod=IsItemAvailable("item_helm_of_the_dominator");
	if hod~=nil and hod:IsFullyCastable() 
	then
		local maxHP = 0;
		local NCreep = nil;
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( 1000, true );
		if #tableNearbyCreeps >= 2 
		then
			for _,creeps in pairs(tableNearbyCreeps)
			do
				local CreepHP = creeps:GetHealth();
				if CreepHP > maxHP and ( creeps:GetHealth() / creeps:GetMaxHealth() ) > .75  and not creeps:IsAncientCreep()
				then
					NCreep = creeps;
					maxHP = CreepHP;
				end
			end
		end
		if NCreep ~= nil then
			npcBot:Action_UseAbilityOnEntity(hod,NCreep);
			return
		end	
	end
	
	if glimer~=nil and glimer:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and CanCastOnTarget(Ally) ) or 
			   ( IsDisabled(Ally) and CanCastOnTarget(Ally) )
			then
				npcBot:Action_UseAbilityOnEntity(glimer,Ally);
				return;
			end
		end
	end
	
	local guardian=IsItemAvailable("item_guardian_greaves");
	if guardian~=nil and guardian:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				npcBot:Action_UseAbility(guardian);
				return;
			end
		end
	end
	
	local satanic=IsItemAvailable("item_satanic");
	if satanic~=nil and satanic:IsFullyCastable() then
		if  npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.50 and 
			tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 and 
			npcBot:GetActiveMode() == BOT_MODE_ATTACK
		then
			npcBot:Action_UseAbility(satanic);
			return;
		end
	end
	
end

function IsItemAvailable(item_name)
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if item~=nil and item:GetName() == item_name then
			return item;
		end
    end
    return nil;
end

function UseShrine()

	--[[local nModifier = npcBot:NumModifiers( )
	for i=0, nModifier do
		local modName = npcBot:GetModifierName( i )
		print(modName)
	end]]--
	
	if npcBot:IsIllusion() then
		return
	end	
	
	if npcBot:HasModifier("modifier_filler_heal") then
		MoveToHealerShrine();
		return
	end	
	
	if  npcBot:GetHealth() / npcBot:GetMaxHealth() > 0.45 then
		return
	end
	
	local Team = GetTeam();
	local distance = 1000;
	local SJ1 = GetShrine(Team, SHRINE_JUNGLE_1);
	if SJ1 ~= nil and SJ1:GetHealth() > 0 and GetUnitToUnitDistance(SJ1 , npcBot ) < distance and GetShrineCooldown(SJ1) < 1 then
		npcBot:Action_UseShrine(SJ1)
		return
	end
	local SJ2 = GetShrine(Team, SHRINE_JUNGLE_2);
	if SJ2 ~= nil and SJ2:GetHealth() > 0 and GetUnitToUnitDistance(SJ2 , npcBot ) < distance and GetShrineCooldown(SJ2) < 1 then
		npcBot:Action_UseShrine(SJ2)
		return
	end
	local SB1 = GetShrine(Team, SHRINE_BASE_1);
	if SB1 ~= nil and SB1:GetHealth() > 0 and GetUnitToUnitDistance(SB1 , npcBot ) < distance and GetShrineCooldown(SB1) < 1 then
		npcBot:Action_UseShrine(SB1)
		return
	end
	local SB2 = GetShrine(Team, SHRINE_BASE_2);
	if SB2 ~= nil and SB2:GetHealth() > 0 and GetUnitToUnitDistance(SB2 , npcBot ) < distance and GetShrineCooldown(SB2) < 1 then
		npcBot:Action_UseShrine(SB2)
		return
	end
	local SB3 = GetShrine(Team, SHRINE_BASE_3);
	if SB3 ~= nil and SB3:GetHealth() > 0 and GetUnitToUnitDistance(SB3 , npcBot ) < distance and GetShrineCooldown(SB3) < 1 then
		npcBot:Action_UseShrine(SB3)
		return
	end
end

function UseGlyph()

	if npcBot:IsIllusion() then
		return;
	end	

	if GetGlyphCooldown( ) > 0 then
		return
	end	
	
	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_3,
		TOWER_MID_3, 
		TOWER_BOT_3, 
		TOWER_BASE_1, 
		TOWER_BASE_2
	}
	
	for _,t in pairs(T1)
	do
		local tower = GetTower(GetTeam(), t);
		if  tower ~= nil and tower:GetHealth() > 0 and tower:GetHealth()/tower:GetMaxHealth() < 0.20  
		then
			npcBot:ActionImmediate_Glyph( )
			return
		end
	end
	

	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}
	
	for _,b in pairs(MeleeBarrack)
	do
		local barrack = GetBarracks(GetTeam(), b);
		if barrack ~= nil and barrack:GetHealth() > 0 and barrack:GetHealth()/barrack:GetMaxHealth() < 0.5  
		then
			npcBot:ActionImmediate_Glyph( )
			return
		end
	end
	
	local Ancient = GetAncient(GetTeam())
	if Ancient ~= nil and Ancient:GetHealth() > 0 and Ancient:GetHealth()/Ancient:GetMaxHealth() < 0.5 
	then
		npcBot:ActionImmediate_Glyph( )
		return
	end

end

function MoveToHealerShrine()
	local Health = npcBot:GetHealth()/npcBot:GetMaxHealth();
	local Mana = npcBot:GetMana()/npcBot:GetMaxMana();
	local listShrines = {
		SHRINE_JUNGLE_1,
		SHRINE_JUNGLE_2,
		SHRINE_BASE_1,
		SHRINE_BASE_2,
		SHRINE_BASE_3,
		SHRINE_BASE_4,
		SHRINE_BASE_5
	}
	local selectedShrine = nil;
	for _,Shrine in pairs(listShrines)
	do
		local TempShrine = GetShrine(GetTeam(), Shrine);
		local distance = GetUnitToUnitDistance(TempShrine, npcBot);
		if distance < 300 then
			selectedShrine = TempShrine;
		end
	end
	
	if selectedShrine ~= nil and selectedShrine:GetHealth() > 0 and ( Health < 0.75 or Mana < 0.55 ) then
		npcBot:Action_MoveToLocation(selectedShrine:GetLocation() + RandomVector(200));
	end
end

--[[this chunk prevents dota_bot_reload_scripts from breaking your 
    item/skill builds.  Note the script doesn't account for 
    consumables. ]]

-- check skill build vs current level
local npcBot = GetBot()
local ability_name = BotAbilityPriority[1];
local ability = GetBot():GetAbilityByName(ability_name);
--print(ability:GetLevel())
if(ability ~= nil and ability:GetLevel() > 0) then
    --print (#BotAbilityPriority .. " > " .. "25 - " .. npcBot:GetLevel())
    if #BotAbilityPriority > (25 - npcBot:GetLevel()) then
        --print(#BotAbilityPriority - (25 - npcBot:GetLevel()))
        for i=1, (#BotAbilityPriority - (25 - npcBot:GetLevel())) do
            table.remove(BotAbilityPriority, 1)
        end
    end
end

return MyModule;

