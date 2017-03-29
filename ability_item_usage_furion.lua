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

local castFBDesire = 0;
local castTWDesire = 0;
local castOODesire = 0;
local castCSDesire = 0;
function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityFB = npcBot:GetAbilityByName( "furion_sprout" );
	abilityTW = npcBot:GetAbilityByName( "furion_teleportation" );
	abilityOO = npcBot:GetAbilityByName( "furion_force_of_nature" );
	abilityCS = npcBot:GetAbilityByName( "furion_wrath_of_nature" );

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castCSDesire, castCSLocation = ConsiderChrono();
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	
	if ( castCSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCS, castCSLocation );
		return;
	end	
	
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastDoomOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = 400;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastDoomOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastDoomOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PURE ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local closestEnemyDist = 1000000;
		local target = nil;
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local dist = GetUnitToUnitDistance(npcEnemy, npcBot);
			if dist < closestEnemyDist then
				closestEnemyDist = dist;
				target = npcEnemy;
			end
		end
		if target ~= nil and abilityTW:IsCooldownReady() then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		elseif target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
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
			if ( CanCastDoomOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and not enemyDisabled(npcTarget))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTimeWalk()

	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = npcBot:GetXUnitsInFront( 1000 );
				if GetOpposingTeam( ) == TEAM_DIRE then
					location = RB;
				end
				if GetOpposingTeam( ) == TEAM_RADIANT then
					location = DB;
				end
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero()  ) 
		then
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and GetUnitToUnitDistance(npcTarget, npcBot) > 2500 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityOO:GetSpecialValueInt( "area_of_effect" );
	local nCastRange = abilityOO:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 10000 );
		if ( locationAoE.count >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
		then
			local nearbyTrees = npcBot:GetNearbyTrees(nCastRange + nRadius)
			if nearbyTrees[1] ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(nearbyTrees[1])
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  ) 
		then
			local nearbyTrees = npcBot:GetNearbyTrees(nCastRange + nRadius)
			if nearbyTrees[1] ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(nearbyTrees[1])
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end



function ConsiderChrono()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				if GetOpposingTeam( ) == TEAM_DIRE then
					return BOT_ACTION_DESIRE_MODERATE, DB;
				end
				if GetOpposingTeam( ) == TEAM_RADIANT then
					return BOT_ACTION_DESIRE_MODERATE, RB;
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			if GetOpposingTeam( ) == TEAM_DIRE then
				return BOT_ACTION_DESIRE_MODERATE, DB;
			end
			if GetOpposingTeam( ) == TEAM_RADIANT then
				return BOT_ACTION_DESIRE_MODERATE, RB;
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcTarget ~= nil  and npcTarget:IsHero() and #tableNearbyEnemyHeroes >= 2 ) 
		then
			if GetOpposingTeam( ) == TEAM_DIRE then
				return BOT_ACTION_DESIRE_MODERATE, DB;
			end
			if GetOpposingTeam( ) == TEAM_RADIANT then
				return BOT_ACTION_DESIRE_MODERATE, RB;
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


