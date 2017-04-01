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

local castCFDesire = 0;
local castIBDesire = 0;
local castIVDesire = 0;
local castCTDesire = 0;
local castIBRDesire = 0;
local ReleaseLoc = {};


function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	abilityCF = npcBot:GetAbilityByName( "ancient_apparition_cold_feet" );
	abilityIB = npcBot:GetAbilityByName( "ancient_apparition_ice_blast" );
	abilityIV = npcBot:GetAbilityByName( "ancient_apparition_ice_vortex" );
	abilityCT = npcBot:GetAbilityByName( "ancient_apparition_chilling_touch" );
	abilityIBR = npcBot:GetAbilityByName( "ancient_apparition_ice_blast_release" );

	-- Consider using each ability
	castCFDesire, castCFTarget = ConsiderColdFeet();
	castIBDesire, castIBLocation = ConsiderIceBlast();
	castIVDesire, castIVLocation = ConsiderIceVortex();
	castCTDesire, castCTLocation = ConsiderChillingTouch();
	castIBRDesire = ConsiderIceBlastRelease();

	if ( castIBRDesire > 0 ) 
	then
		
		npcBot:Action_UseAbility( abilityIBR );
		return;
	end
	
	if ( castCTDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCT, castCTLocation );
		return;
	end	
	
	if ( castCFDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityCF, castCFTarget );
		return;
	end
	
	if ( castIBDesire > 0  ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityIB, castIBLocation);
		ReleaseLoc = castIBLocation;
		return;
	end		
	
	if ( castIVDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityIV, castIVLocation );
		return;
	end	
	
end

function CanCastColdFeetOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastIceBlastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderColdFeet()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityCF:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastColdFeetOnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
			if ( CanCastColdFeetOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and not npcTarget:HasModifier("modifier_ancient_apparition_cold_feet") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderIceBlast()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityIB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nSpeed = abilityIB:GetSpecialValueInt("speed");
	local nCastPoint = abilityIB:GetCastPoint();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
		npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIceBlastOnTarget(npcTarget)  ) 
		then
			local nTime = GetUnitToUnitDistance(npcTarget, npcBot) / nSpeed;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nTime + nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderIceVortex()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIV:IsFullyCastable() or abilityIV:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityIV:GetSpecialValueInt("radius");
	local nCastRange = abilityIV:GetCastRange();
	local nCastPoint = abilityIV:GetCastPoint();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
		npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
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
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
 
		if ( locationAoE.count >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.75) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange + 200 and not npcEnemy:HasModifier("modifier_ancient_apparition_ice_vortex_thinker") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
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
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200 and not npcTarget:HasModifier("modifier_ancient_apparition_ice_vortex_thinker")  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderIceBlastRelease()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityIBR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	local pro = GetLinearProjectiles();
	for _,pr in pairs(pro)
	do
		if pr ~= nil and pr.ability:GetName() == "ancient_apparition_ice_blast"  then
			if pr ~= nil and ReleaseLoc ~= nil and utils.GetDistance(ReleaseLoc, pr.location) < 100 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChillingTouch()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( abilityCT:IsHidden() or not abilityCT:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCT:GetSpecialValueInt("radius");
	local nCastRange = abilityCT:GetCastRange();
	local nCastPoint = abilityCT:GetCastPoint();

	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange  ) 
		then
			local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );	
			if ( locationAoE.count >= 1 ) 
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

