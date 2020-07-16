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

local castHSDesire = 0;
local castDEDesire = 0;
local castRTDesire = 0;
local castSTDesire = 0;

local abilityHS = nil;
local abilityDE = nil;
local abilityRT = nil;
local abilityST = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityHS == nil then abilityHS = npcBot:GetAbilityByName( "centaur_hoof_stomp" ) end
	if abilityDE == nil then abilityDE = npcBot:GetAbilityByName( "centaur_double_edge" ) end
	if abilityRT == nil then abilityRT = npcBot:GetAbilityByName( "centaur_return" ) end
	if abilityST == nil then abilityST = npcBot:GetAbilityByName( "centaur_stampede" ) end

	-- Consider using each ability
	castHSDesire = ConsiderHoofStomp();
	castDEDesire, castDETarget = ConsiderDoubleEdge();
	--castRTDesire = ConsiderReturn();
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

	if ( castRTDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityRT );
		return;
	end
	
	if ( castDEDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDE, castDETarget );
		return;
	end

end


function ConsiderHoofStomp()

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
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   mutil.IsInRange(npcTarget, npcBot, nRadius - 100) 
	then   
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nRadius - 100) and not mutil.IsDisabled(true, npcTarget)
		then   
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderDoubleEdge()
	
	-- Make sure it's castable
	if ( not abilityDE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityDE:GetCastRange();
	local nDamage = abilityDE:GetSpecialValueInt( "edge_damage" );
	local nRadius = abilityDE:GetSpecialValueInt( "radius" );
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   mutil.IsInRange(npcTarget, npcBot, nCastRange + 100) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcTarget;
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nCastRange + 100) 
		then   
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderReturn()

	-- Make sure it's castable
	if ( not abilityRT:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = 300;
	local maxStacks = abilityRT:GetSpecialValueInt('max_stacks');

	local stack = 0;
	local modIdx = npcBot:GetModifierByName("modifier_centaur_return_counter");
	if modIdx > -1 then
		stack = npcBot:GetModifierStackCount(modIdx);
	end

	if stack <= maxStacks / 2 then
		return BOT_ACTION_DESIRE_NONE;
	end	

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nRadius) 
		then   
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderStampede()

	-- Make sure it's castable
	if ( not abilityST:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
