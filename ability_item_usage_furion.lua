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

local castFBDesire = 0;
local castTWDesire = 0;
local castOODesire = 0;
local castCSDesire = 0;

local abilityFB = nil;
local abilityTW = nil;
local abilityOO = nil;
local abilityCS = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "furion_sprout" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "furion_teleportation" ) end
	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "furion_force_of_nature" ) end
	if abilityCS == nil then abilityCS = npcBot:GetAbilityByName( "furion_wrath_of_nature" ) end

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

function ConsiderFireblast()

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
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) )
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
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)  
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local closestEnemyDist = 10000;
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
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and
		   not mutil.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTimeWalk()

	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, GetAncient(GetTeam()):GetLocation();
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)  
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = mutil.GetTeamFountain();
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		then
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and not mutil.IsInRange(npcTarget, npcBot, 2000) then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderOverwhelmingOdds()

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
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
		then
			local nearbyTrees = npcBot:GetNearbyTrees(nCastRange + nRadius)
			if nearbyTrees[1] ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, GetTreeLocation(nearbyTrees[1])
			end
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1200)
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

	-- Make sure it's castable
	if ( not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				local location = mutil.GetEnemyFountain();
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			local location = mutil.GetEnemyFountain();
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 
			then
				local location = mutil.GetEnemyFountain();
				return BOT_ACTION_DESIRE_MODERATE, location;
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


