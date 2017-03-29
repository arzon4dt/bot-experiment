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

local castHSDesire = 0;
local castDEDesire = 0;
local castSTDesire = 0;

function AbilityUsageThink()
	AbilityLevelUpThink()
	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityHS = npcBot:GetAbilityByName( "centaur_hoof_stomp" );
	abilityDE = npcBot:GetAbilityByName( "centaur_double_edge" );
	abilityST = npcBot:GetAbilityByName( "centaur_stampede" );

	-- Consider using each ability
	castHSDesire = ConsiderHoofStomp();
	castDEDesire, castDETarget = ConsiderDoubleEdge();
	castSTDesire = ConsiderStampede();
	

	if ( castSTDesire > castHSDesire and castSTDesire > castDEDesire ) 
	then
		npcBot:Action_UseAbility( abilityST );
		return;
	end

	if ( castHSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityHS );
		return;
	end
	
	if ( castDEDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDE, castDETarget );
		return;
	end

end

function CanCastHoofStompOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastDoubleEdgeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderHoofStomp()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityHS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityHS:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilityHS:GetSpecialValueInt( "stomp_damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and CanCastHoofStompOnTarget( npcTargetToKill ) and not enemyDisabled(npcTargetToKill) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < nRadius - 50 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastHoofStompOnTarget( npcEnemy ) and not enemyDisabled(npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_HIGH;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and not enemyDisabled(npcTarget) ) 
		then
			if ( CanCastHoofStompOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius - 50 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderDoubleEdge()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityDE:GetCastRange();
	local nDamage = abilityDE:GetSpecialValueInt( "edge_damage" );
	local nRadius = abilityDE:GetSpecialValueInt( "radius" );
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and CanCastDoubleEdgeOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange) + 100 )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill;
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

		if ( npcTarget ~= nil and CanCastDoubleEdgeOnTarget( npcTarget )) 
		then
			if ( GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange ) + 100 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderStampede()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityST:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
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
			if ( GetUnitToUnitDistance( npcTarget, npcBot ) < 600 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
