local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castSSDesire = 0;
local castSWDesire = 0;
local castIHDesire = 0;

local abilitySS = "";
local abilitySW = "";
local abilityIH = "";

local cast = false;
local timeCast = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	if abilitySS == "" then abilitySS = npcBot:GetAbilityByName( "broodmother_spawn_spiderlings" ); end
	if abilitySW == "" then abilitySW = npcBot:GetAbilityByName( "broodmother_spin_web" ); end
	if abilityIH == "" then abilityIH = npcBot:GetAbilityByName( "broodmother_insatiable_hunger" ); end

	-- Consider using each ability
	castSSDesire, castSSTarget = ConsiderSpawnSpiderlings();
	castSWDesire, castSWLocation = ConsiderSpinWeb();
	castIHDesire = ConsiderInsatiableHunger();
	
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySS, castSSTarget );
		return;
	end
	if ( castSWDesire > 0 and DotaTime() >= timeCast + 0.8 ) 
	then
		npcBot:ActionPush_UseAbilityOnLocation( abilitySW, castSWLocation );
		timeCast = DotaTime();
		return;
	end
	if ( castIHDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityIH );
		return;
	end
	
end

function CanCastSpawnSpiderlingsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function LocationOverlapWeb(location, nRadius)
	local unit = GetUnitList(UNIT_LIST_ALLIES);
	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_broodmother_web"
		then
			local flag = ( 2*nRadius ) - 100;
			--print(GetUnitToLocationDistance(u, location).."><"..flag);
			if GetUnitToLocationDistance(u, location) <= flag then
			 --print("overlap")
				return true
			end
		end
	end
	return false;
end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function ConsiderSpawnSpiderlings()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilitySS:GetCastRange();
	local nDamage = abilitySS:GetSpecialValueInt("damage");
	local level = abilitySS:GetLevel();
	local mana = npcBot:GetMana() / npcBot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastSpawnSpiderlingsOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
	) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange + 200, true );
		for _,creep in pairs(tableNearbyEnemyCreeps)
		do
			if creep:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > creep:GetHealth() and mana > .45 then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSpinWeb()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilitySW:IsFullyCastable() or npcBot:IsCastingAbility() or abilitySW:IsInAbilityPhase() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilitySW:GetSpecialValueInt( "radius" );
	local nCastRange = 900;
	local nCastPoint = abilitySW:GetCastPoint( );
    
	--[[if DotaTime() > 15 and npcBot:DistanceFromFountain() > 1000 and not LocationOverlapWeb( npcBot:GetXUnitsInFront(nCastRange), nRadius ) then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange);
	end]]--
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and 
				not LocationOverlapWeb(GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange ), nRadius) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange );
			end
		end
	end

	if npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
	then
		local NearbyTower = npcBot:GetNearbyTowers(nRadius, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius / 3, 0, 0 );
		if locationAoE.count >= 3 and not LocationOverlapWeb(locationAoE.targetloc, nRadius) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
	then
		local NearbyTower = npcBot:GetNearbyTowers(nRadius, false);
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and not LocationOverlapWeb(npcBot:GetLocation(), nRadius) then
			return BOT_MODE_DESIRE_MODERATE, npcBot:GetLocation();
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and 
			GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and 
			not LocationOverlapWeb(npcTarget:GetExtrapolatedLocation( nCastPoint ), nRadius)  
			) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderInsatiableHunger()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nAttackRange = npcBot:GetAttackRange();
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < 2*nAttackRange  ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end
