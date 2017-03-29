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

local castESDesire = 0;
local castVODesire = 0;
local castSHDesire = 0;
local castMSWDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityES = npcBot:GetAbilityByName( "shadow_shaman_ether_shock" );
	abilityVO = npcBot:GetAbilityByName( "shadow_shaman_voodoo" );
	abilitySH = npcBot:GetAbilityByName( "shadow_shaman_shackles" );
	abilityMSW = npcBot:GetAbilityByName( "shadow_shaman_mass_serpent_ward" );
	
	-- Consider using each ability
	castESDesire, castESTarget = ConsiderEtherShock();
	castVODesire, castVOTarget = ConsiderVoodoo();
	castSHDesire, castSHTarget = ConsiderShackles();
	castMSWDesire, castMSWLocation = ConsiderMassSerpentWards();

	if ( castMSWDesire > castESDesire and castMSWDesire > castVODesire and castMSWDesire > castSHDesire  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityMSW, castMSWLocation );
		return;
	end

	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityES, castESTarget );
		return;
	end
	
	if ( castVODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityVO, castVOTarget );
		return;
	end
	
	if ( castSHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySH, castSHTarget );
		return;
	end
	
end

function CanCastEtherShockOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastVoodooOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastShackleOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderMassSerpentWards()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityMSW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityMSW:GetCastRange();
	local nCastPoint = abilityMSW:GetCastPoint();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange and #tableNearbyEnemyHeroes >= 3 ) 
			then
				--return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation() + npcEnemy:GetExtrapolatedLocation(nCastPoint);
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, 400, 0, 10000 );

		if ( locationAoE.count >= 3 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsInFront(nCastRange);
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderEtherShock()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityES:GetCastRange();
	local nDamage = abilityES:GetSpecialValueInt( "damage" );
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastEtherShockOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill;
		end
	end
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastEtherShockOnTarget( npcEnemy ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, 600, 0, nDamage );

		if ( locationAoE.count >= 4 ) 
		then
			local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
			for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
				if ( GetUnitToUnitDistance( npcCreepTarget, npcBot  ) < nCastRange ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
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
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastEtherShockOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVoodoo()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityVO:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityVO:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and CanCastVoodooOnTarget( npcEnemy ) and not enemyDisabled( npcEnemy ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		--local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastVoodooOnTarget( npcEnemy ) and not enemyDisabled( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastVoodooOnTarget( npcEnemy ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange + 300 and not enemyDisabled( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastVoodooOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 300 and not enemyDisabled( npcTarget ))
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderShackles()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilitySH:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and CanCastShackleOnTarget( npcEnemy ) and not enemyDisabled( npcEnemy ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastShackleOnTarget( npcEnemy ) and GetUnitToUnitDistance( npcEnemy, npcBot ) < nCastRange + 300 and not enemyDisabled( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastShackleOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 300  and not enemyDisabled( npcTarget ))
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
