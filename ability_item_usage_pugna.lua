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
local castOODesire = 0;
local castFBDesire = 0;
local castTSDesire = 0;
local castLDDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	--[[local m = npcBot:NumModifiers();
	for i = 0, m
	do
		print(npcBot:GetModifierName(i))
	end]]--
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityOO = npcBot:GetAbilityByName( "pugna_nether_blast" );
	abilityFB = npcBot:GetAbilityByName( "pugna_decrepify" );
	abilityTS = npcBot:GetAbilityByName( "pugna_nether_ward" );
	abilityLD = npcBot:GetAbilityByName( "pugna_life_drain" );

	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTSDesire, castTSLocation = ConsiderTombStone();
	castLDDesire, castLDTarget = ConsiderLifeDrain();

	if ( castTSDesire > 0  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTS, castTSLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	if ( castLDDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLD, castLDTarget );
		return;
	end
end

function CanCastOverWhelmingOddsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nDelay = abilityOO:GetSpecialValueInt( "delay" );
	local nRadius = abilityOO:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOO:GetCastRange();
	local nCastPoint = abilityOO:GetCastPoint( );
	local nDamage = abilityOO:GetSpecialValueInt("blast_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTargetToKill ) )
	then
		local distance = GetUnitToUnitDistance(npcTargetToKill, npcBot);
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and distance < nCastRange + nRadius + 200 )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nDelay + nCastPoint );
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 10000 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, nDamage );
		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, nDelay, 10000 );
		local tableNearbyTowers = npcBot:GetNearbyTowers( 1000, true);
		local tableNearbyBarracks = npcBot:GetNearbyBarracks( 1000, true);
		if tableNearbyTowers[1] ~= nil then
			return BOT_ACTION_DESIRE_LOW, tableNearbyTowers[1]:GetLocation();
		end
		if tableNearbyBarracks[1] ~= nil then
			return BOT_ACTION_DESIRE_LOW, tableNearbyBarracks[1]:GetLocation();
		end
		if ( locationAoE.count >= 4 ) 
		then
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
		local distance = GetUnitToUnitDistance(npcTarget, npcBot);
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTarget ) and distance < ( nCastRange + nRadius + 200 )  ) 
		then
			--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay + nCastPoint );
		end
	end
--
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
	local nRadius = 0;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastFireblastOnTarget( npcEnemy ) and GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			else
				return BOT_ACTION_DESIRE_HIGH, npcBot;
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
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTombStone()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nCastPoint = abilityTS:GetCastPoint();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLifeDrain()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityLD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityLD:GetCastRange();
	local nDamage = 500;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastFireblastOnTarget( npcEnemy ) and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
			if ( CanCastFireblastOnTarget( npcTarget ) and 
				GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange  )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end