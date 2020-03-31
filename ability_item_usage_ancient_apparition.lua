if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castCFDesire = 0;
local castIBDesire = 0;
local castIVDesire = 0;
local castCTDesire = 0;
local castIBRDesire = 0;

local ReleaseLoc = {};

local abilityCF = nil;
local abilityIB = nil;
local abilityIV = nil;
local abilityCT = nil;
local abilityIBR = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityCF == nil then abilityCF = npcBot:GetAbilityByName( "ancient_apparition_cold_feet" ) end
	if abilityIB == nil then abilityIB = npcBot:GetAbilityByName( "ancient_apparition_ice_blast" ) end
	if abilityIV == nil then abilityIV = npcBot:GetAbilityByName( "ancient_apparition_ice_vortex" ) end
	if abilityCT == nil then abilityCT = npcBot:GetAbilityByName( "ancient_apparition_chilling_touch" ) end
	if abilityIBR == nil then abilityIBR = npcBot:GetAbilityByName( "ancient_apparition_ice_blast_release" ) end

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
		npcBot:Action_UseAbilityOnEntity( abilityCT, castCTLocation );
		return;
	end	
	
	if ( castCFDesire > 0 ) 
	then
		local typeAOE = mutil.CheckFlag(abilityCF:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			npcBot:Action_UseAbilityOnLocation( abilityCF, castCFTarget:GetLocation() );
		else
			npcBot:Action_UseAbilityOnEntity( abilityCF, castCFTarget );
		end
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

function ConsiderColdFeet()

	-- Make sure it's castable
	if ( not abilityCF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCF:GetCastRange();
	if nCastRange + 200 > 1600 then nCastRange = 1300; end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		   and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and not npcTarget:HasModifier("modifier_ancient_apparition_cold_feet")
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderIceBlast()

	-- Make sure it's castable
	if ( not abilityIB:IsFullyCastable() or abilityIB:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nSpeed = abilityIB:GetSpecialValueInt("speed");
	local nCastPoint = abilityIB:GetCastPoint();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
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
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) 
		then
			local nTime = GetUnitToUnitDistance(npcTarget, npcBot) / nSpeed;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nTime + nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderIceVortex()

	-- Make sure it's castable
	if ( not abilityIV:IsFullyCastable() or abilityIV:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityIV:GetSpecialValueInt("radius");
	local nCastRange = abilityIV:GetCastRange();
	local nCastPoint = abilityIV:GetCastPoint();
	
	if nCastRange + 200 > 1600 then nCastRange = 1300; end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and npcTarget:HasModifier('modifier_ice_vortex') == false  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.75
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and not npcEnemy:HasModifier("modifier_ice_vortex") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
			and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and not npcTarget:HasModifier("modifier_ice_vortex") 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderIceBlastRelease()

	-- Make sure it's castable
	if ( not abilityIBR:IsFullyCastable() or abilityIBR:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	local pro = GetLinearProjectiles();
	for _,pr in pairs(pro)
	do
		if pr ~= nil and pr.ability:GetName() == "ancient_apparition_ice_blast"  then
			if ReleaseLoc ~= nil and utils.GetDistance(ReleaseLoc, pr.location) < 100 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChillingTouch()

	-- Make sure it's castable
	if ( abilityCT:IsHidden() or not abilityCT:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange();

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_VERYHIGH, npcTarget;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

