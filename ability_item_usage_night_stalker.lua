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

local castWBDesire = 0;
local castCH1Desire = 0;
local castEDesire = 0;
local castCHDesire = 0;

local abilityCH1 = nil;
local abilityCH = nil;
local abilityE = nil;
local abilityWB = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityCH1 == nil then abilityCH1 = npcBot:GetAbilityByName( "night_stalker_void" ) end
	if abilityCH == nil then abilityCH = npcBot:GetAbilityByName( "night_stalker_crippling_fear" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "night_stalker_hunter_in_the_night" ) end
	if abilityWB == nil then abilityWB = npcBot:GetAbilityByName( "night_stalker_darkness" ) end
	
	-- Consider using each ability
	castCH1Desire, castCH1Target = ConsiderCorrosiveHaze1();
	castCHDesire, castCHTarget = ConsiderCorrosiveHaze();
	-- castEDesire = ConsiderE();
	castWBDesire = ConsiderWildBoar();

	if ( castCH1Desire > 0 ) 
	then
		if npcBot:HasScepter() == true then
			npcBot:Action_UseAbility( abilityCH1 );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityCH1, castCH1Target );
			return;
		end
	end
	
	if ( castCHDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityCH );
		return;
	end
	
	if ( castWBDesire > 0  ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end
	
	if ( castEDesire > 0  ) 
	then
		npcBot:Action_UseAbility( abilityE );
		return;
	end

end

function IsNightTime()
	return GetTimeOfDay() == 0.0 or npcBot:HasModifier("modifier_night_stalker_darkness");
end

function ConsiderWildBoar()

	-- Make sure it's castable
	if ( not abilityWB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	if #tableNearbyAllyHeroes == 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local distance = 600;
	
	if mutil.IsInTeamFight(npcBot, 1200) and not IsNightTime() 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, distance) and not IsNightTime() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local distance = 1000;
	
	if mutil.IsStuck(npcBot) and IsNightTime()
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( distance, true, BOT_MODE_NONE );
		if IsNightTime() and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and not IsLocationPassable(npcBot:GetXUnitsInFront(300)) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, distance) and IsNightTime() and not IsLocationPassable(npcBot:GetXUnitsInFront(300)) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderCorrosiveHaze()

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH:GetSpecialValueInt('radius');

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling()  and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
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
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
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

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderCorrosiveHaze1()

	-- Make sure it's castable
	if ( not abilityCH1:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH1:GetCastRange();
	local hasScepter = npcBot:HasScepter();

	if hasScepter == false then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
		if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN ) 
		then
			local npcTarget = npcBot:GetTarget();
			if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
			then
				return BOT_ACTION_DESIRE_LOW, npcTarget;
			end
		end
		
		-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
		if mutil.IsRetreating(npcBot)
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
		
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end

		-- If we're in a teamfight, use it on the scariest enemy
		if mutil.IsInTeamFight(npcBot, 1200)
		then

			local npcMostDangerousEnemy = nil;
			local nMostDangerousDamage = 0;

			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
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

			if ( npcMostDangerousEnemy ~= nil )
			then
				return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
			end
		end
	else
		local nCastRange = abilityCH1:GetSpecialValueInt('radius_scepter') - 200;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsChanneling()  and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
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
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
		
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end

		-- If we're in a teamfight, use it on the scariest enemy
		if mutil.IsInTeamFight(npcBot, 1200)
		then

			local npcMostDangerousEnemy = nil;
			local nMostDangerousDamage = 0;

			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
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
	end	

	return BOT_ACTION_DESIRE_NONE, 0;
end
