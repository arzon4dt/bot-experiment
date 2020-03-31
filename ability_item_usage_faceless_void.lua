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

local castTWDesire = 0;
local castTDDesire = 0;
local castCSDesire = 0;

local abilityTW = nil;
local abilityTD = nil;
local abilityCS = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "faceless_void_time_walk" ) end
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "faceless_void_time_dilation" ) end
	if abilityCS == nil then abilityCS = npcBot:GetAbilityByName( "faceless_void_chronosphere" ) end

	-- Consider using each ability
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castCSDesire, castCSLocation = ConsiderChrono();
	castTDDesire = ConsiderTimeDilation();

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
	
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end

end

function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( npcBot:HasModifier("modifier_faceless_void_chronosphere_speed") ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetSpecialValueInt("range");
	local nCastPoint = abilityTW:GetCastPoint( );

	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			local loc = mutil.GetEscapeLoc();
		    return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
		end	
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 200) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			local tableNearbyEnemies = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAllies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if #tableNearbyEnemies <= #tableNearbyAllies then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot) / 3000) + nCastPoint );
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeDilation()

	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if ( castTWDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nRadius = abilityTD:GetSpecialValueInt("radius");

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderChrono()

	-- Make sure it's castable
	if ( not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = abilityCS:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+(nRadius/2), true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and  #tableNearbyAllyHeroes >= 2 then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
				then
					local allies = mutil.GetAlliesNearLoc(npcEnemy:GetLocation(), nRadius);
					if #allies <= 2 then
						return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
					end	
				end
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local nInvUnit = mutil.FindNumInvUnitInLoc(true, npcBot, nCastRange, nRadius/2, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				local allies = mutil.GetAlliesNearLoc(locationAoE.targetloc, nRadius);
				if #allies <= 2 then
					return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
				end
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+(nRadius/2)) )   
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius/2, false, BOT_MODE_NONE );
			local nInvUnit = mutil.CountInvUnits(true, tableNearbyEnemyHeroes);
			if nInvUnit >= 2 then
				local allies = mutil.GetAlliesNearLoc(npcTarget:GetLocation(), nRadius);
				if #allies <= 2 then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				end
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end



