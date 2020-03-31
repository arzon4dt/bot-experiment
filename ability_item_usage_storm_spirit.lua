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
local castFBDesire = 0;
local castTDDesire = 0;

local abilityTD = nil;
local abilityFB = nil;
local abilityTW = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "storm_spirit_static_remnant" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "storm_spirit_electric_vortex" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "storm_spirit_ball_lightning" ) end
	
	castTDDesire = ConsiderTimeDilation();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		if npcBot:HasScepter() then
			npcBot:Action_UseAbility( abilityFB );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
			return;
		end
	end
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end


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

function BallLightningAllowed(manaCost)
	if ( npcBot:GetMana() - manaCost ) / npcBot:GetMaxMana() >= 0.20
	then
		return true
	end
	return false
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange() + 200;
	if nCastRange < npcBot:GetAttackRange() then nCastRange = npcBot:GetAttackRange() + 200; end
	if npcBot:HasScepter() then nCastRange = 475 end 
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200) and npcBot:HasScepter()
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) then
			return BOT_ACTION_DESIRE_MODERATE, nil;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-100) and
		   not mutil.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or abilityTW:IsInAbilityPhase() or npcBot:HasModifier("modifier_storm_spirit_ball_lightning") or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastPoint = abilityTW:GetCastPoint( );
	local nInitialMana = abilityTW:GetSpecialValueInt("ball_lightning_initial_mana_base")
	local nInitialManaP = abilityTW:GetSpecialValueInt("ball_lightning_initial_mana_percentage") / 100
	local nTravelCost = abilityTW:GetSpecialValueInt("ball_lightning_travel_cost_base")
	local nTravelCostP = abilityTW:GetSpecialValueFloat("ball_lightning_travel_cost_percent") / 100

	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, 600 );
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			local loc = mutil.GetEscapeLoc();
		    return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, 600 );
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, npcBot:GetAttackRange()-200) and  mutil.IsInRange(npcTarget, npcBot, 1600)   
		then
			local MaxMana = npcBot:GetMaxMana();
			local distance = GetUnitToUnitDistance( npcTarget, npcBot );
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
			local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
			local TotalMana = TotalInitMana + TotalTravelMana;
			--print(TotalMana)
			if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and BallLightningAllowed( TotalMana ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 2*nCastPoint );
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
	
	-- Get some of its values
	local nRadius = abilityTD:GetSpecialValueInt("static_remnant_radius");

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

