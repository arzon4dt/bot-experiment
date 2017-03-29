--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
--local inspect = require(GetScriptDirectory() ..  "/inspect")
--local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

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
local castTSDesire = 0;
local castGMDesire = 0;
local castKFDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityTS = npcBot:GetAbilityByName( "disruptor_thunder_strike" );
	abilityGM = npcBot:GetAbilityByName( "disruptor_glimpse" );
	abilitySS = npcBot:GetAbilityByName( "disruptor_static_storm" );
	abilityKF = npcBot:GetAbilityByName( "disruptor_kinetic_field" );
	

	-- Consider using each ability
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	castKFDesire, castKFLocation = ConsiderKineticField();
	castTSDesire, castTSTarget = ConsiderThunderStorm();
	castGMDesire, castGMTarget = ConsiderGlimpse();
	
	
	if ( castTSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityTS, castTSTarget );
		return;
	end
	
	if ( castKFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityKF, castKFLocation );
		return;
	end
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		return;
	end
	
	if ( castGMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityGM, castGMTarget );
		return;
	end

	
end

function CanCastStaticStormOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastKineticFieldOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastThunderStrikeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastGlimpseOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderThunderStorm()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nDamage = 4 * abilityTS:GetAbilityDamage( );
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastThunderStrikeOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastThunderStrikeOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
			for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
				if ( GetUnitToUnitDistance( npcCreepTarget, npcBot  ) < nCastRange and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
				end
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

		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastThunderStrikeOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderGlimpse()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityGM:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityGM:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastGlimpseOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
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
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastGlimpseOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) > 600 and  GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderStaticStorm()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );
	local nDamage = 5 * abilitySS:GetSpecialValueInt("damage_max");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0.1, 10000 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange - 200 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastStaticStormOnTarget( npcTarget ) ) 
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius - 200, false, BOT_MODE_NONE );
			if ( #EnemyHeroes >= 1 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
				--[[if npcTarget:IsFacingUnit( npcBot, 15 ) then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				else
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(200);
				end]]--
				
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderKineticField()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityKF:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castDLDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityKF:GetSpecialValueInt( "radius" );
	local nCastRange = abilityKF:GetCastRange();
	local nCastPoint = abilityKF:GetCastPoint( );
	local nDamage = 1000

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0.1, 10000 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange - 200 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastKineticFieldOnTarget( npcTarget )  ) 
		then
			--[[if npcTarget:IsFacingUnit( npcBot, 15 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(300);
			end]]--
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end
