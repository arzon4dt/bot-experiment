--[[_G._savedEnv = getfenv()
module( "ability_item_usage_generic", package.seeall )]]--
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

local BotAbilityPriority = build["skills"];
local IdleTime = 0;
local AllowedIddle = 15;
local npcBot = GetBot();

function AbilityLevelUpThink()  
	
	if DotaTime() > 0 then
		UnImplementedItemUsage()
		UseShrine()
		UseGlyph()
	end
	
	--[[if not IsLocationPassable(npcBot:GetLocation()) then
		print(npcBot:GetUnitName().." Unpassaable")
	end]]--
	
	if npcBot:GetAbilityPoints()<1 or #BotAbilityPriority==0 or  (GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS) then
		return;
	end
	
	--if (npcBot:GetAbilityPoints() > 0) then 
	if npcBot:GetAbilityPoints() > 0 and BotAbilityPriority[1] ~= "-1" and BotAbilityPriority[1] ~= nil then
		local sNextAbility = npcBot:GetAbilityByName(BotAbilityPriority[1])
		if (sNextAbility~=nil and sNextAbility:CanAbilityBeUpgraded() and sNextAbility:GetLevel() < sNextAbility:GetMaxLevel()) then
			--npcBot:Action_Chat(BotAbilityPriority[1],true);
			if string.find(npcBot:GetUnitName(), "troll_warlord") and BotAbilityPriority[1] == "troll_warlord_whirling_axes_ranged" then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("troll_warlord_whirling_axes_melee");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end
			elseif string.find(npcBot:GetUnitName(), "tusk") and BotAbilityPriority[1] == "tusk_snowball" then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end	
			elseif string.find(npcBot:GetUnitName(), "alchemist") and BotAbilityPriority[1] == "alchemist_unstable_concoction" then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("alchemist_unstable_concoction_throw");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "ancient_apparition") and BotAbilityPriority[1] == "ancient_apparition_ice_blast" then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("ancient_apparition_ice_blast_release");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "kunkka") and BotAbilityPriority[1] == "kunkka_x_marks_the_spot" then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("kunkka_return");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end	
			elseif string.find(npcBot:GetUnitName(), "keeper_of_the_light") and BotAbilityPriority[1] == "keeper_of_the_light_illuminate" then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("keeper_of_the_light_spirit_form_illuminate");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "elder_titan") and BotAbilityPriority[1] == "elder_titan_ancestral_spirit" then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "lone_druid") and BotAbilityPriority[1] == "lone_druid_true_form" then
				if sNextAbility:IsHidden() then
					npcBot:ActionImmediate_LevelAbility("lone_druid_true_form_druid");
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "wisp") and BotAbilityPriority[1] == "wisp_tether" then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end	
			elseif string.find(npcBot:GetUnitName(), "life_stealer") then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "naga_siren") and BotAbilityPriority[1] == "naga_siren_song_of_the_siren" then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "shredder") and BotAbilityPriority[1] == "shredder_chakram" then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end		
			elseif string.find(npcBot:GetUnitName(), "morphling") and BotAbilityPriority[1] == "morphling_replicate" then
				if sNextAbility:IsHidden() then
					return;
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end			
			else
				npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
			end
			table.remove( BotAbilityPriority, 1 )
		end	
	else
		table.remove( BotAbilityPriority, 1 )
	end	
	--end
end

function CanBuybackUpperRespawnTime( respawnTime )
	if ( not npcBot:IsAlive() and respawnTime ~= nil and npcBot:GetRespawnTime() >= respawnTime
		and npcBot:GetBuybackCooldown() <= 0 and npcBot:GetGold() > npcBot:GetBuybackCost() ) then
		return true;
	end

	return false;

end
--GXC BUYBACK LOGIC	
function BuybackUsageThink() 
	if npcBot:IsIllusion() then
		return;
	end	
	
	-- no buyback, no need to use GetUnitList() for performance considerations
	if ( not CanBuybackUpperRespawnTime(10) ) then
		return;
	end

	local tower_top_3 = GetTower( GetTeam(), TOWER_TOP_3 );
	local tower_mid_3 = GetTower( GetTeam(), TOWER_MID_3 );
	local tower_bot_3 = GetTower( GetTeam(), TOWER_BOT_3 );
	local tower_base_1 = GetTower( GetTeam(), TOWER_BASE_1 );
	local tower_base_2 = GetTower( GetTeam(), TOWER_BASE_2 );

	local barracks_top_melee = GetBarracks( GetTeam(), BARRACKS_TOP_MELEE );
	local barracks_mid_melee = GetBarracks( GetTeam(), BARRACKS_MID_MELEE );
	local barracks_bot_melee = GetBarracks( GetTeam(), BARRACKS_BOT_MELEE );

	local ancient = GetAncient( GetTeam() );

	local buildList = {
		tower_top_3, tower_mid_3, tower_bot_3, tower_base_1, tower_base_2,
		barracks_top_melee, 
		barracks_mid_melee,
		barracks_bot_melee, 
		ancient
	};

	for _, build in pairs(buildList) do
		local tableNearbyEnemyHeroes = build:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );

		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) then
			if ( build:GetHealth() / build:GetMaxHealth() < 0.5
				and build:WasRecentlyDamagedByAnyHero(2.0) and CanBuybackUpperRespawnTime(30) ) then
				npcBot:ActionImmediate_Buyback();
				return;
			end
		end
	end

	if ( DotaTime() > 60 * 60 and CanBuybackUpperRespawnTime(30) ) then
		npcBot:ActionImmediate_Buyback();
	end

	
end
--[[
function ItemUsageThink()
	print("item usage")
	if GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	
	UnImplementedItemUsage()
	--UseShrine()
end
]]--
function CourierUsageThink()
	--print("cour usage")
	if GetNumCouriers() == 0 then
		return
	end

	local npcCourier = GetCourier(0);	

	if GetCourierState( npcCourier ) == COURIER_STATE_DEAD then
		return
	end
	
	if IsCourierNearShop(npcCourier) and IdleTime == 0 then
		IdleTime = DotaTime();
	elseif not IsCourierNearShop(npcCourier) then
		IdleTime = 0;
	end
	
	if  not npcBot:IsAlive() and GetCourierState( npcCourier ) == COURIER_STATE_DELIVERING_ITEMS  and npcBot:GetCourierValue( ) > 0  then
		--print(npcBot:GetUnitName().."return stash")
		--print("Return Stash "..npcBot:GetUnitName())
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS );
		return
	end
	
	if  GetCourierState( npcCourier ) == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() > 00 and 
	( not IsCourierNearShop(npcCourier) or ( IsCourierNearShop(npcCourier) and DotaTime() >= IdleTime + AllowedIddle ))
	then
		--print("Return "..npcBot:GetUnitName())
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
		return
	end
	
	if DotaTime() >= IdleTime + AllowedIddle and npcBot:IsAlive() and npcBot:GetCourierValue( ) > 0 and not IsInvFull(npcBot) and IsCourierAvailable() then
		--print("Transfer.."..npcBot:GetUnitName())
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
		return
	end
	
	if DotaTime() >= IdleTime + AllowedIddle and IsCourierAvailable() then
		
		local numPlayer =  GetTeamPlayers(GetTeam());
		local maxVal = 0;
		local target = nil;
		for i = 1, #numPlayer
		do
		--print(numPlayer[i]..tostring(IsPlayerBot(numPlayer[i])));
			if GetTeamMember(i) ~= nil and IsPlayerBot(numPlayer[i]) then
				local SVal = GetTeamMember(i):GetStashValue();
				if SVal ~= 0 and SVal > maxVal then
					maxVal = SVal;
					target = GetTeamMember(i);
				end
			end
		end
		
		if target ~= nil and target:IsAlive() then
			--print("TakeNTransfer "..target:GetUnitName())
			target:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS )
			return
		end
		
	end
	
	--[[if  npcBot:IsAlive() and npcBot:GetStashValue( ) > 200 and  CourierCanDeliverItems(npcCourier) then
		--print(npcBot:GetUnitName().."taketransf")
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS )
		return
	end]]--
	
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


function UnImplementedItemUsage()

	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() or npcBot:IsMuted( )  then
		return;
	end
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	local npcTarget = npcBot:GetTarget();
	
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
		if  npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.15 
		then
			npcBot:Action_UseAbility(ff);
			return;
		end
	end
	
	local bst=IsItemAvailable("item_bloodstone");
	if bst ~= nil and bst:IsFullyCastable() then
		if  npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
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
		if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_RETREAT or
			 npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
		then
			npcBot:Action_UseAbility(pb);
			return;
		end	
	end
	
	local bt=IsItemAvailable("item_bloodthorn");
	if bt~=nil and bt:IsFullyCastable() 
	then
		if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
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
		if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
			 npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK or
			 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
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
		if npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0
		then
			npcBot:Action_UseAbility(se);
			return;
	    end
		if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 npcBot:GetActiveMode() == BOT_MODE_GANK )
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
		if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
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
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
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
	local SB4 = GetShrine(Team, SHRINE_BASE_4);
	if SB4 ~= nil and SB4:GetHealth() > 0 and GetUnitToUnitDistance(SB4 , npcBot ) < distance and GetShrineCooldown(SB4) < 1 then
		npcBot:Action_UseShrine(SB4)
		return
	end
	local SB5 = GetShrine(Team, SHRINE_BASE_5);
	if SB5 ~= nil and SB5:GetHealth() > 0 and GetUnitToUnitDistance(SB5 , npcBot ) < distance and GetShrineCooldown(SB5) < 1 then
		npcBot:Action_UseShrine(SB5)
		return
	end
end

function UseGlyph()

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
--for k,v in pairs( ability_item_usage_generic ) do	_G._savedEnv[k] = v end

