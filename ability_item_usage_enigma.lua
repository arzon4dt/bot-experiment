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

local castDCDesire = 0;
local castIGDesire = 0;
local castFBDesire = 0;
local castOODesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityIG = npcBot:GetAbilityByName( "enigma_malefice" );
	abilityFB = npcBot:GetAbilityByName( "enigma_demonic_conversion" );
	abilityOO = npcBot:GetAbilityByName( "enigma_midnight_pulse" );
	abilityDC = npcBot:GetAbilityByName( "enigma_black_hole" );
	

	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castFBDesire, castFBTarget = ConsiderFireblast();
	
	
	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end

	
end

function CanCastDecayOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOverWhelmingOddsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastIgniteOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderIgnite()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = 4 * abilityIG:GetSpecialValueInt("damage");
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and CanCastIgniteOnTarget( npcEnemy ) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIgniteOnTarget( npcTarget ) )
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
				if ( CanCastIgniteOnTarget( npcEnemy ) ) 
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
			if ( CanCastIgniteOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		if npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 then
			local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange, false );
			local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange, true );
			for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
			do
				if ( GetUnitToUnitDistance( npcECreep, npcBot ) < nCastRange + 200 and CanCastFireblastOnTarget(npcECreep)  ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcECreep;
				end
			end
			for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
			do
				if ( GetUnitToUnitDistance( npcACreep, npcBot ) < nCastRange + 200 and CanCastFireblastOnTarget(npcACreep) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcACreep;
				end
			end
		end
	end
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < 700 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.5 ) 
		then
			local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange, false );
			local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange, true );
			for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
			do
				if ( GetUnitToUnitDistance( npcECreep, npcBot ) < nCastRange + 200 and CanCastFireblastOnTarget(npcECreep)  ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcECreep;
				end
			end
			for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
			do
				if ( GetUnitToUnitDistance( npcACreep, npcBot ) < nCastRange + 200 and CanCastFireblastOnTarget(npcACreep) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcACreep;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--

	-- Get some of its values
	local nRadius = abilityOO:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOO:GetCastRange();
	local nCastPoint = abilityOO:GetCastPoint();

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
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange ) then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - 200 and CanCastOverWhelmingOddsOnTarget( npcTarget )  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end



function ConsiderDecay()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if castOODesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityDC:GetSpecialValueInt( "far_radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2
		then		
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange  ) then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if ( #EnemyHeroes >= 2 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
				
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end
